*&---------------------------------------------------------------------*
*& Include          ZGTPPR2150F01
*&---------------------------------------------------------------------*
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

  PERFORM INIT_DATA.

  CASE ABAP_TRUE.
    WHEN P_RAD01 OR P_RAD02.
      PERFORM GET_MAIN_DATA.
*    WHEN P_RAD02.

    WHEN P_RAD03.
      PERFORM GET_MAIN_DATA_03.
  ENDCASE.


  IF GT_MAIN_DISP[] IS INITIAL.
    MESSAGE S001 DISPLAY LIKE 'E'.
    LEAVE LIST-PROCESSING.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form INIT_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM INIT_DATA .

* 초기화면 구성을 위한 필드 구성
  DEFINE __SET_CHK_FIELD.
    CLEAR GS_CHK_MAINTAIN.
    GS_CHK_MAINTAIN-FIELDNAME = &1.
    GS_CHK_MAINTAIN-REPTEXT = &2.
    GS_CHK_MAINTAIN-NOT_CHK = &3.
    APPEND GS_CHK_MAINTAIN TO GT_CHK_MAINTAIN.
  END-OF-DEFINITION.

  REFRESH GT_CHK_MAINTAIN.

  IF P_RAD02 = ABAP_TRUE.
    GV_CHK_GAGONG = ABAP_TRUE.
  ENDIF.

  CASE ABAP_TRUE.
    WHEN P_RAD01 OR P_RAD02.
      __SET_CHK_FIELD : 'CHK_01' '작업대상' ''.
      __SET_CHK_FIELD : 'CHK_02' '오더생성' ''.
      __SET_CHK_FIELD : 'CHK_03' '신선작업지시' '',
                                     'CHK_04' '조장확정' ''.

    WHEN P_RAD03.
      __SET_CHK_FIELD : 'CHK_01' '작업대상' ''.
      __SET_CHK_FIELD : 'CHK_02' '오더생성' ''.
      __SET_CHK_FIELD : 'MENGE01' '외장오더수' '',
                         'MENGE02' '외장재작업지시' '',
                         'CHK_11' '조장확정' ''.
  ENDCASE.

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

  DATA : LT_GRPNR TYPE RANGE OF ZGTPPT2000-GRPNR.
  DATA : LT_SGRPNR TYPE RANGE OF ZGTPPT2011-SGRPNR.
  DATA : LT_MATNR TYPE RANGE OF MATNR.
  DATA : LV_CST_SEQ TYPE I.
  DATA : LV_BWD_SEQ TYPE I.
  DATA : LT_MAIN_VBELN LIKE GT_MAIN_DISP.
  DATA : LV_CHK.
  DATA : LV_TABIX TYPE I.
  FIELD-SYMBOLS : <LV_SOSUN> TYPE ANY.

  FIELD-SYMBOLS : <LV_CHK> TYPE ANY.

  DEFINE __SET_CHK.
    READ TABLE GT_CHK_MAINTAIN INTO GS_CHK_MAINTAIN WITH KEY REPTEXT = &1.
    IF SY-SUBRC EQ 0.
      IF <LV_CHK> IS ASSIGNED. UNASSIGN <LV_CHK>. ENDIF.
      ASSIGN COMPONENT GS_CHK_MAINTAIN-FIELDNAME OF STRUCTURE <LS_MAIN> TO <LV_CHK>.
      IF <LV_CHK> IS ASSIGNED.
        <LV_CHK> = ABAP_TRUE.
      ENDIF.
    ENDIF.
  END-OF-DEFINITION.

  PERFORM GET_JOJANG_DATA.

* 신선공정 유/무 확인을 위한 데이터
  REFRESH LT_MATNR.
  LT_MATNR = VALUE #( FOR LW_2000 IN GT_MAIN_DISP WHERE ( MATNR IS NOT INITIAL )
                               ( SIGN = 'I' OPTION = 'EQ' LOW = LW_2000-MATNR ) ).

  SORT LT_MATNR BY LOW.
  DELETE ADJACENT DUPLICATES FROM LT_MATNR COMPARING LOW.

  IF GV_CHK_GAGONG = ABAP_TRUE.
    SELECT MATNR FROM MARA
      INTO TABLE @DATA(LT_MARA)
     WHERE MATNR IN @LT_MATNR
      AND SPART = '31'.
  ELSE.
    SELECT MATNR FROM MARA
      INTO TABLE @LT_MARA
     WHERE MATNR IN @LT_MATNR
      AND SPART NE '31'.
  ENDIF.

  IF LT_MARA[] IS NOT INITIAL.
    REFRESH LT_MATNR.
    LOOP AT LT_MARA INTO DATA(LS_MARA).
      APPEND INITIAL LINE TO LT_MATNR ASSIGNING FIELD-SYMBOL(<LS_MATNR>).
      <LS_MATNR>-SIGN = 'I'.
      <LS_MATNR>-OPTION = 'EQ'.
      <LS_MATNR>-LOW = LS_MARA-MATNR.
    ENDLOOP.

    SORT LT_MATNR BY LOW.
    DELETE ADJACENT DUPLICATES FROM LT_MATNR COMPARING LOW.

    DELETE GT_MAIN_DISP WHERE MATNR NOT IN LT_MATNR.

  ELSE.
    REFRESH GT_MAIN_DISP.
    RETURN.
  ENDIF.


  SELECT *
    FROM ZGTCVMSTVAL
    INTO TABLE @DATA(LT_CVMSTVAL)
   WHERE WERKS = @P_WERKS
     AND MATNR IN @LT_MATNR.

  SORT LT_CVMSTVAL BY MATNR.
  DELETE ADJACENT DUPLICATES FROM LT_CVMSTVAL COMPARING MATNR.

  IF LT_CVMSTVAL[] IS NOT INITIAL.
    WITH +SULNO AS ( SELECT A~MATNR,
                B~SUL_NO,
                B~REV_SEQ,
                B~GONG_CD,
                B~GONG_SEQ
        FROM @LT_CVMSTVAL AS A
        INNER JOIN ZEDT1010 AS B ON B~SUL_NO = A~PDCADESIGNNO
                                           AND B~REV_SEQ = A~PDCADESIGNREVNO
       WHERE A~WERKS = @P_WERKS
         AND A~MATNR IN @LT_MATNR
         AND B~GONG_CD = 'CST' )
     SELECT C~MATNR, C~GONG_CD, C~GONG_SEQ,
             D~GONG_CD AS PRE_GONG_CD,
             D~GONG_SEQ AS PRE_GONG_SEQ
          FROM +SULNO AS C
          INNER JOIN ZEDT1010 AS D ON D~SUL_NO = C~SUL_NO
                                             AND D~REV_SEQ = C~REV_SEQ
                                             AND D~AFT_GONG_SEQ = C~GONG_SEQ
          WHERE D~GONG_CD IN ( 'BWD', 'CNF' )
          INTO TABLE @DATA(LT_TEMP).

* 소선 정보
    WITH +SULNO2 AS (
      SELECT A~MATNR,
                  B~SUL_NO,
                  B~REV_SEQ,
                  B~GONG_CD,
                  B~GONG_SEQ
          FROM @LT_CVMSTVAL AS A
          INNER JOIN ZEDT1010 AS B ON B~SUL_NO = A~PDCADESIGNNO
                                             AND B~REV_SEQ = A~PDCADESIGNREVNO
         WHERE A~WERKS = @P_WERKS
           AND B~GONG_CD = 'CST' )
        SELECT DISTINCT A~MATNR, B~DATA_CHAR, B~DATA_NUM
          FROM +SULNO2 AS A
          INNER JOIN ZEDT1030 AS B ON B~SUL_NO = A~SUL_NO
                                             AND B~REV_SEQ = A~REV_SEQ
                                             AND B~GONG_SEQ = A~GONG_SEQ
                                             AND B~ATTRIBUTE = 'SOSUNCD'
        INTO TABLE @DATA(LT_SOSUN).
  ENDIF.

  SORT LT_SOSUN BY MATNR DATA_CHAR DATA_NUM.

* 연선(CST)공정 바로 이전 공정이 신선(BWD) 일때만 신선재 대상
  LOOP AT LT_TEMP ASSIGNING FIELD-SYMBOL(<LS_TEMP>).
    LV_TABIX = SY-TABIX.
    CLEAR : LV_CST_SEQ, LV_BWD_SEQ.
    LV_CST_SEQ = <LS_TEMP>-GONG_SEQ + 0.
    LV_BWD_SEQ = <LS_TEMP>-PRE_GONG_SEQ + 1.
    IF LV_CST_SEQ NE LV_BWD_SEQ.
      DELETE LT_TEMP INDEX LV_TABIX.
    ENDIF.
  ENDLOOP.
  SORT LT_TEMP BY MATNR.



* 판매오더정보 확인을 위해 오더 담아준다.
  REFRESH LT_MAIN_VBELN.
  LT_MAIN_VBELN = VALUE #( FOR LW_MAIN IN GT_MAIN_DISP WHERE ( GCATG = '판매오더'
                                                                                OR   GCATG = '견적'  )
                                      ( CORRESPONDING #( LW_MAIN ) ) ).

  SORT LT_MAIN_VBELN BY ORDNO POSNR.
  DELETE ADJACENT DUPLICATES FROM LT_MAIN_VBELN COMPARING ORDNO POSNR..
  IF LT_MAIN_VBELN[] IS NOT INITIAL.
    SELECT A~VBELN, A~POSNR, A~VRKME, A~KWMENG, A~CUOBJ
      FROM VBAP AS A
      INNER JOIN @LT_MAIN_VBELN AS C ON C~ORDNO = A~VBELN
                                                   AND C~POSNR = A~POSNR
      INTO TABLE @DATA(LT_VBAP).
  ENDIF.


* 신선공정 지시 유무를 위한 데이터 추출
  REFRESH LT_GRPNR.
  LT_GRPNR = VALUE #( FOR LW_2000 IN GT_MAIN_DISP WHERE ( GRPNR IS NOT INITIAL )
                               ( SIGN = 'I' OPTION = 'EQ' LOW = LW_2000-GRPNR ) ).
  SORT LT_GRPNR BY LOW.
  DELETE ADJACENT DUPLICATES FROM LT_GRPNR COMPARING LOW.

  REFRESH : GT_2010, GT_2011.
  IF LT_GRPNR[] IS NOT INITIAL.
    SELECT * FROM ZGTPPT2010
      INTO TABLE GT_2010
     WHERE GRPNR IN LT_GRPNR
        AND GONG_CD = 'CST'
        AND ORDTY NE 'PLN'.

* 신선오더 연결정보
    SELECT A~*
      FROM ZGTPPT2013 AS A
      INNER JOIN ZGTPPT2011 AS B ON B~SGRPNR = A~SGRPNR
      INTO TABLE @GT_2013
     WHERE A~GRPNR IN @LT_GRPNR
        AND B~JOBTY = '1'.
  ENDIF.


* 신선오더 정보
  REFRESH LT_SGRPNR.
  LT_SGRPNR = VALUE #( FOR LW_2013 IN GT_2013 WHERE ( SGRPNR IS NOT INITIAL )
                               ( SIGN = 'I' OPTION = 'EQ' LOW = LW_2013-SGRPNR ) ).
  SORT LT_SGRPNR BY LOW.
  DELETE ADJACENT DUPLICATES FROM LT_SGRPNR COMPARING LOW.

  IF LT_SGRPNR[] IS NOT INITIAL.
    SELECT * FROM ZGTPPT2012
      INTO TABLE GT_2012
     WHERE SGRPNR IN LT_SGRPNR.

    SELECT * FROM ZGTPPT2011
      INTO TABLE GT_2011
     WHERE SGRPNR IN LT_SGRPNR.

  ENDIF.


* 생산오더로 조장구성표 적용되었을 경우 차후에 인터널테이블 구성
  SORT GT_MAIN_DISP BY GRPNR.

  DATA : LV_ORDNO_C(12).
  DATA : LV_POSNR_C(6).

  LOOP AT GT_MAIN_DISP ASSIGNING FIELD-SYMBOL(<LS_MAIN>).
*  오더번호
    LV_ORDNO_C = <LS_MAIN>-ORDNO.
    LV_POSNR_C = <LS_MAIN>-POSNR.
    __ALPHA_OUT : LV_ORDNO_C, LV_POSNR_C.
    CONCATENATE LV_ORDNO_C LV_POSNR_C
                  INTO <LS_MAIN>-ORDNO_C SEPARATED BY '/'.

* 거래처
    SELECT SINGLE NAME1 FROM KNA1
      INTO <LS_MAIN>-NAME1
     WHERE KUNNR = <LS_MAIN>-KUNNR.
** 제품내역
*    <LS_MAIN>-MAKTX = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = <LS_MAIN>-MATNR  ).

    IF <LS_MAIN>-GCATG NE '생산오더'.
      READ TABLE LT_VBAP INTO DATA(LS_VBAP) WITH KEY VBELN = <LS_MAIN>-ORDNO
                                                                    POSNR = <LS_MAIN>-POSNR.
      IF SY-SUBRC EQ 0.
** 조장, 조장수, 판매조장
        ZGTPP_CL_COMMON=>GET_CHA_MILLCA(
          EXPORTING
            IV_CUOBJ      = LS_VBAP-CUOBJ                 " 구성
          IMPORTING
            EV_SO_INDLEN = <LS_MAIN>-SO_INLENGTH ).
        <LS_MAIN>-SO_WMENG = LS_VBAP-KWMENG.
        <LS_MAIN>-SO_VRKME = LS_VBAP-VRKME.
      ENDIF.

    ENDIF.

*    CHECK box
* 신선작업
    READ TABLE LT_TEMP INTO DATA(LS_TEMP) WITH KEY MATNR = <LS_MAIN>-MATNR.
    IF SY-SUBRC EQ 0.
      __SET_CHK '작업대상'.
    ENDIF.

* 신선오더생성
    IF P_RAD01 = ABAP_TRUE AND GV_CHK_GAGONG IS INITIAL.
      CLEAR LV_CHK.
      PERFORM CHECK_ORDNO_BWD USING <LS_MAIN> CHANGING LV_CHK.
      IF LV_CHK = ABAP_TRUE.
        __SET_CHK '오더생성'.
      ENDIF.
    ENDIF.

    IF P_RAD02 = ABAP_TRUE AND GV_CHK_GAGONG = ABAP_TRUE.
      CLEAR LV_CHK.
      PERFORM CHECK_ORDNO_BWD_GAGONG USING <LS_MAIN> CHANGING LV_CHK.
      IF LV_CHK = ABAP_TRUE.
        __SET_CHK '오더생성'.
      ENDIF.
    ENDIF.


* 신선작업지시
    CLEAR LV_CHK.
    PERFORM CHECK_WORKING_BWD USING <LS_MAIN> CHANGING LV_CHK.
    IF LV_CHK = ABAP_TRUE.
      __SET_CHK '신선작업지시'.
    ENDIF.

* 조장확정
    CLEAR LV_CHK.
    PERFORM CHK_CONFIRM_JOJANGCHAIN USING <LS_MAIN>-GRPNR CHANGING LV_CHK.
    IF LV_CHK = ABAP_TRUE.
      __SET_CHK '조장확정'.
    ENDIF.

  ENDLOOP.

  IF P_CHECK IS INITIAL.
    READ TABLE GT_CHK_MAINTAIN INTO GS_CHK_MAINTAIN WITH KEY REPTEXT = '신선작업지시'.
    DATA : LV_STRING TYPE STRING.
    LV_STRING = |{ GS_CHK_MAINTAIN-FIELDNAME } = ABAP_TRUE |.
    DELETE GT_MAIN_DISP WHERE (LV_STRING).
  ENDIF.

  IF P_CHECK2 IS INITIAL.
    READ TABLE GT_CHK_MAINTAIN INTO GS_CHK_MAINTAIN WITH KEY REPTEXT = '조장확정'.
    LV_STRING = |{ GS_CHK_MAINTAIN-FIELDNAME } = ABAP_FALSE |.
    DELETE GT_MAIN_DISP WHERE (LV_STRING).
  ENDIF.

* 일반 신선재의 경우 소선코드 입력 해주다.
  IF P_RAD01 = ABAP_TRUE AND GV_CHK_GAGONG IS INITIAL.

    LOOP AT GT_MAIN_DISP ASSIGNING <LS_MAIN>.
      CLEAR LV_TABIX.
      LOOP AT LT_SOSUN INTO DATA(LS_SOSUN) WHERE MATNR = <LS_MAIN>-MATNR.
        ADD 1 TO LV_TABIX.
        IF <LV_SOSUN> IS ASSIGNED. UNASSIGN <LV_SOSUN>. ENDIF.
        CASE LV_TABIX. " 신선공정의 경우 복합선도 2종류만 존재하므로 1번과 2번에 담아준다.
          WHEN 1.
            ASSIGN COMPONENT 'SOSUNCD1' OF STRUCTURE <LS_MAIN> TO <LV_SOSUN>.
          WHEN 2.
            ASSIGN COMPONENT 'SOSUNCD2' OF STRUCTURE <LS_MAIN> TO <LV_SOSUN>.
        ENDCASE.

        IF LS_SOSUN-DATA_NUM NE 0.
          <LV_SOSUN> = LS_SOSUN-DATA_NUM.
        ELSE.
          <LV_SOSUN> = LS_SOSUN-DATA_CHAR.
        ENDIF.
      ENDLOOP.
    ENDLOOP.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_JOJANG_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_JOJANG_DATA .

  DATA : LT_GRPNR_CHK TYPE RANGE OF ZGTPPT2000-GRPNR.
  DATA : LT_GRPNR_CHK2 TYPE RANGE OF ZGTPPT2000-GRPNR.
  RANGES : LT_KUNNR FOR KNA1-KUNNR.

  IF P_KUNNR IS NOT INITIAL.
    APPEND INITIAL LINE TO LT_KUNNR ASSIGNING FIELD-SYMBOL(<LS_KUNNR>).
    IF P_KUNNR CO '*'.
      <LS_KUNNR> = VALUE #( SIGN = 'I' OPTION = 'CP' LOW = P_KUNNR ).
    ELSE.
      <LS_KUNNR> = VALUE #( SIGN = 'I' OPTION = 'EQ' LOW = P_KUNNR ).
    ENDIF.
  ENDIF.

  REFRESH GT_MAIN_DISP .

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
      AND ZSTATUS NE 'D'
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
          AND ZSTATUS NE 'D'
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
          AND ZSTATUS NE 'D'
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
          AND ZSTATUS NE 'D'
          AND GCATG IN ( '판매오더', '견적' ).
    ENDIF.


    SORT LT_GRPNR_CHK BY LOW.
    DELETE ADJACENT DUPLICATES FROM LT_GRPNR_CHK COMPARING LOW.

    IF LT_GRPNR_CHK[] IS NOT INITIAL.
      SELECT * FROM ZGTPPT2000
      INTO CORRESPONDING FIELDS OF TABLE GT_MAIN_DISP
      WHERE SPGCD = P_SPGCD
        AND WERKS = P_WERKS
        AND GRPNR IN LT_GRPNR_CHK
        AND  ZSTATUS NE 'D'.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_WORKING_BWD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LS_MAIN>_GRPNR
*&      <-- LV_CHK
*&---------------------------------------------------------------------*
FORM CHECK_WORKING_BWD  USING    PS_MAIN LIKE GS_MAIN_DISP
                        CHANGING PV_CHK.

  DATA : LT_AUFNR TYPE RANGE OF AUFNR.
  DATA : LT_2013 TYPE TABLE OF ZGTPPT2013.

  LT_2013 = VALUE #( FOR LW_2013 IN GT_2013 WHERE ( GRPNR = PS_MAIN-GRPNR )
                            ( CORRESPONDING #( LW_2013 ) ) ).
  IF LT_2013[] IS INITIAL. " 조장번호 대상이 없으면 소선지시 미존재
    RETURN.
  ELSE.
    READ TABLE LT_2013 INTO DATA(LS_2013) INDEX 1.

    LT_AUFNR = VALUE #( FOR LW_2012 IN GT_2012 WHERE ( SGRPNR = LS_2013-SGRPNR
                                                                       AND   JOBTY = '1' )
                                ( SIGN = 'I' OPTION = 'EQ' LOW = LW_2012-ORDNR ) ).
    IF LT_AUFNR[] IS NOT INITIAL.
      SELECT AUFNR FROM ZGTCVORDSYVAL
        WHERE AUFNR IN @LT_AUFNR
          AND REL = 'X'
        INTO TABLE @DATA(LT_TEMP).
      IF SY-SUBRC EQ 0.
        SELECT AUFNR FROM ZGTCVORDSYVAL
                WHERE AUFNR IN @LT_AUFNR
                INTO TABLE @DATA(LT_TEMP2).

        IF LINES( LT_TEMP ) = LINES( LT_TEMP2 ).
          PV_CHK = ABAP_TRUE.
        ENDIF.
      ELSE.
        RETURN.
      ENDIF.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_CONFIRM_JOJANGCHAIN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LS_MAIN>_GRPNR
*&      <-- LV_CHK
*&---------------------------------------------------------------------*
FORM CHK_CONFIRM_JOJANGCHAIN  USING    PV_GRPNR TYPE ZGTPPT2010-GRPNR
                        CHANGING PV_CHK.

  DATA : LV_PLN_CHK.
  DATA : LV_EXIST_CHK.

  LV_EXIST_CHK = ABAP_TRUE.
  LOOP AT GT_2010 INTO DATA(LS_2010) WHERE GRPNR = PV_GRPNR.
    CLEAR LV_EXIST_CHK.
    IF LS_2010-ORDTY = 'PLN'.
      LV_PLN_CHK = ABAP_TRUE.
      EXIT.
    ENDIF.
  ENDLOOP.

* 조장여부 연선(CST) 공정내 PLN오더가 존재해야함
* CST 미존재시 미확정
  IF LV_EXIST_CHK NE ABAP_TRUE AND LV_PLN_CHK IS INITIAL.
    PV_CHK = ABAP_TRUE.
  ENDIF.


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
      PERFORM SET_CELL_ATTRIBUTE_GRID_0100.
      GO_GRID_0100->SET_FRONTEND_LAYOUT( IS_LAYOUT = GS_LAYOUT_0100 ).
    WHEN GO_GRID_0101.
      GO_GRID_0101->SET_FRONTEND_LAYOUT( IS_LAYOUT = GS_LAYOUT_0101 ).
    WHEN GO_GRID_0102.
      GO_GRID_0102->SET_FRONTEND_LAYOUT( IS_LAYOUT = GS_LAYOUT_0102 ).
    WHEN GO_GRID_0103.
      PERFORM SET_CELL_ATTRIBUTE_GRID_0103.
      GO_GRID_0103->SET_FRONTEND_LAYOUT( IS_LAYOUT = GS_LAYOUT_0103 ).
    WHEN GO_GRID_0104.
      PERFORM SET_FIELDCAT_GRID_0104.
      GO_GRID_0104->SET_FRONTEND_FIELDCATALOG( IT_FIELDCATALOG = GT_FIELDCAT_0104 ).
      GO_GRID_0104->SET_FRONTEND_LAYOUT( IS_LAYOUT = GS_LAYOUT_0104 ).
      PERFORM SET_CELL_ATTRIBUTE_GRID_0104.
    WHEN GO_GRID_1100.
      GO_GRID_1100->SET_FRONTEND_LAYOUT( IS_LAYOUT = GS_LAYOUT_1100 ).
    WHEN GO_GRID_1101.
      GO_GRID_1101->SET_FRONTEND_LAYOUT( IS_LAYOUT = GS_LAYOUT_1101 ).
    WHEN GO_GRID_1102.
      GO_GRID_1102->SET_FRONTEND_LAYOUT( IS_LAYOUT = GS_LAYOUT_1102 ).
      PERFORM SET_CELL_ATTRIBUTE_GRID_1102.
    WHEN GO_GRID_1103.
      GO_GRID_1103->SET_FRONTEND_LAYOUT( IS_LAYOUT = GS_LAYOUT_1103 ).
      PERFORM SET_CELL_ATTRIBUTE_GRID_1103.
    WHEN GO_GRID_0401.
      GO_GRID_0401->SET_FRONTEND_LAYOUT( IS_LAYOUT = GS_LAYOUT_0401 ).
    WHEN GO_GRID_0402.
      GO_GRID_0402->SET_FRONTEND_LAYOUT( IS_LAYOUT = GS_LAYOUT_0402 ).
    WHEN GO_GRID_0403.
      PERFORM SET_CELL_ATTRIBUTE_GRID_0403.
      GO_GRID_0403->SET_FRONTEND_LAYOUT( IS_LAYOUT = GS_LAYOUT_0403 ).
    WHEN GO_GRID_0404.
      PERFORM SET_LAYOUT_GRID_0404.
      GO_GRID_0404->SET_FRONTEND_FIELDCATALOG( IT_FIELDCATALOG = GT_FIELDCAT_0404 ).
      GO_GRID_0404->SET_FRONTEND_LAYOUT( IS_LAYOUT = GS_LAYOUT_0404 ).
      PERFORM SET_CELL_ATTRIBUTE_GRID_0404.
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
      SET HANDLER GO_EVENT_HANDLER->HANDLE_DATA_CHANGED        FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_DOUBLE_CLICK          FOR PO_GRID.
    WHEN GO_GRID_0101.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_DOUBLE_CLICK          FOR PO_GRID.
    WHEN GO_GRID_0102.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_DOUBLE_CLICK          FOR PO_GRID.
    WHEN GO_GRID_0103.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_DATA_CHANGED        FOR PO_GRID.
    WHEN GO_GRID_0104.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_TOOLBAR               FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_USER_COMMAND          FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_DOUBLE_CLICK          FOR PO_GRID.
    WHEN GO_GRID_0201.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_DATA_CHANGED        FOR PO_GRID.
    WHEN GO_GRID_1100.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_DOUBLE_CLICK          FOR PO_GRID.
    WHEN GO_GRID_1101.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_DOUBLE_CLICK          FOR PO_GRID.
    WHEN GO_GRID_1102.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_DOUBLE_CLICK          FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_DATA_CHANGED        FOR PO_GRID.
    WHEN GO_GRID_1103.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_DOUBLE_CLICK          FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_HOTSPOT          FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_TOOLBAR               FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_USER_COMMAND          FOR PO_GRID.
    WHEN GO_GRID_1200.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_DATA_CHANGED        FOR PO_GRID.
    WHEN GO_GRID_0401.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_DOUBLE_CLICK          FOR PO_GRID.
    WHEN GO_GRID_0402.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_DOUBLE_CLICK          FOR PO_GRID.
    WHEN GO_GRID_0403.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_DATA_CHANGED        FOR PO_GRID.
    WHEN GO_GRID_0404.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_TOOLBAR               FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_USER_COMMAND          FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_DOUBLE_CLICK          FOR PO_GRID.
    WHEN GO_GRID_0500.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_DATA_CHANGED        FOR PO_GRID.
    WHEN GO_GRID_1300.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_DATA_CHANGED        FOR PO_GRID.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_ON_F4        FOR PO_GRID.
    WHEN GO_GRID_1301.
    WHEN GO_GRID_1302.
      SET HANDLER GO_EVENT_HANDLER->HANDLE_DATA_CHANGED        FOR PO_GRID.

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
  GS_LAYOUT_0100-NO_ROWMARK   = 'X'.
  GS_LAYOUT_0100-SEL_MODE   = 'C'.
  GS_LAYOUT_0100-STYLEFNAME = 'CELLTAB'.

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
  DATA : LV_COL_POS TYPE I.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR2150TOP'
      I_INTERNAL_TABNAME     = 'GS_MAIN_DISP'
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
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '　　'.
    <LS_FCAT>-COL_POS = 1.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '1'.
    <LS_FCAT>-JUST = 'C'.
    <LS_FCAT>-CHECKBOX = ABAP_TRUE.
    <LS_FCAT>-EDIT = ABAP_TRUE.
  ENDIF.

  READ TABLE GT_FIELDCAT_0100 ASSIGNING <LS_FCAT> WITH KEY FIELDNAME = 'ORDNO_C'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0100 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'ORDNO_C'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '오더번호'.
    <LS_FCAT>-COL_POS = 6.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '30'.
    <LS_FCAT>-JUST = 'C'.
  ENDIF.

  LV_COL_POS = 100.
  LOOP AT GT_CHK_MAINTAIN ASSIGNING FIELD-SYMBOL(<LS_CHK_MAINTAIN>) .
    ADD 1 TO LV_COL_POS.

    <LS_CHK_MAINTAIN>-COL_POS = LV_COL_POS.
    IF <LS_CHK_MAINTAIN>-NOT_CHK = ABAP_TRUE.
      CONTINUE.
    ENDIF.

    READ TABLE GT_FIELDCAT_0100 ASSIGNING <LS_FCAT> WITH KEY FIELDNAME = <LS_CHK_MAINTAIN>-FIELDNAME.
    IF SY-SUBRC NE 0.
      APPEND INITIAL LINE TO GT_FIELDCAT_0100 ASSIGNING <LS_FCAT>.
      <LS_FCAT>-FIELDNAME = <LS_CHK_MAINTAIN>-FIELDNAME.
      <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = <LS_CHK_MAINTAIN>-REPTEXT.
      <LS_FCAT>-COL_POS = LV_COL_POS.
      <LS_FCAT>-DATATYPE = 'CHAR'.
      <LS_FCAT>-DD_OUTLEN = '1'.
      <LS_FCAT>-JUST = 'C'.
      <LS_FCAT>-CHECKBOX = ABAP_TRUE.
    ENDIF.
  ENDLOOP.

  LV_COL_POS = 200.

  LOOP AT GT_FIELDCAT_0100 ASSIGNING <LS_FCAT>.
    CLEAR <LS_FCAT>-KEY.
    CASE   <LS_FCAT>-FIELDNAME.
      WHEN 'CHECK'.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'GRPNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '조장번호'(F01).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'ERDAT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '작성일'(F02).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'GCATG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '범주'(F03).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'ORDNO_C'.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'ZZYUSCD'.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '영업소'(F04).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'MATNR'.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '제품'(F05).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'ORDNO'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'POSNR'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '제품내역'(F06).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'KUNNR'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'NAME1'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '납품처'(F07).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'EDATU'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '납품요청일'(F08).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'WMENG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '총수량'(F09).
        <LS_FCAT>-JUST = 'R'.
      WHEN 'INLENGTH'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '조장'(F10).
        <LS_FCAT>-JUST = 'R'.
      WHEN 'MEINS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '단위'(F11).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'INFACTOR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '조장수'(F12).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-DECIMALS_O = '0'.
      WHEN 'SOSUNCD1'.
        IF P_RAD01 = ABAP_TRUE AND GV_CHK_GAGONG IS INITIAL.
          ADD 1 TO LV_COL_POS.
          <LS_FCAT>-COL_POS = LV_COL_POS.
          <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '소선코드1'(F81).
          <LS_FCAT>-JUST = 'R'.
          <LS_FCAT>-DECIMALS_O = '0'.
        ELSE.
          <LS_FCAT>-NO_OUT = ABAP_TRUE.
        ENDIF.
      WHEN 'SOSUNCD2'.
        IF P_RAD01 = ABAP_TRUE AND GV_CHK_GAGONG IS INITIAL.
          ADD 1 TO LV_COL_POS.
          <LS_FCAT>-COL_POS = LV_COL_POS.
          <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '소선코드2'(F82).
          <LS_FCAT>-JUST = 'R'.
          <LS_FCAT>-DECIMALS_O = '0'.
        ELSE.
          <LS_FCAT>-NO_OUT = ABAP_TRUE.
        ENDIF.
      WHEN 'SO_WMENG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '판매수량'(F13).
        ADD 1 TO LV_COL_POS.
        <LS_FCAT>-COL_POS = LV_COL_POS.
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-DECIMALS_O = '0'.
      WHEN 'SO_INLENGTH'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '판매조장'(F14).
        ADD 1 TO LV_COL_POS.
        <LS_FCAT>-COL_POS = LV_COL_POS.
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-DECIMALS_O = '0'.
      WHEN 'SO_VRKME'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '판매단위'(F15).
        ADD 1 TO LV_COL_POS.
        <LS_FCAT>-COL_POS = LV_COL_POS.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'ERNAM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '생성자'(F16).
        ADD 1 TO LV_COL_POS.
        <LS_FCAT>-COL_POS = LV_COL_POS.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'MENGE01' OR 'MENGE02'.
        READ TABLE GT_CHK_MAINTAIN INTO GS_CHK_MAINTAIN WITH KEY FIELDNAME = <LS_FCAT>-FIELDNAME.
        IF SY-SUBRC EQ 0.
          <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = GS_CHK_MAINTAIN-REPTEXT.
          <LS_FCAT>-COL_POS = GS_CHK_MAINTAIN-COL_POS.
          <LS_FCAT>-JUST = 'R'.
          <LS_FCAT>-QUANTITY = 'EA'.
        ELSE.
          <LS_FCAT>-NO_OUT = ABAP_TRUE.
        ENDIF.
      WHEN OTHERS.
        READ TABLE GT_CHK_MAINTAIN TRANSPORTING NO FIELDS WITH KEY FIELDNAME = <LS_FCAT>-FIELDNAME.
        IF SY-SUBRC NE 0.
          <LS_FCAT>-NO_OUT = ABAP_TRUE.
        ENDIF.
    ENDCASE.
  ENDLOOP.

* 외장재 일경우 필드 위치 변경
  IF P_RAD03 = ABAP_TRUE.
    LOOP AT GT_FIELDCAT_0100 ASSIGNING <LS_FCAT>.
      CASE   <LS_FCAT>-FIELDNAME.
        WHEN 'NAME1'.
          <LS_FCAT>-COL_POS = 401.
        WHEN 'EDATU'.
          <LS_FCAT>-COL_POS = 402.
        WHEN 'WMENG'.
          <LS_FCAT>-COL_POS = 403.
        WHEN 'INFACTOR'.
          <LS_FCAT>-COL_POS = 404.
        WHEN 'SO_WMENG'.
          <LS_FCAT>-COL_POS = 405.
        WHEN 'SO_INLENGTH'.
          <LS_FCAT>-COL_POS = 406.
        WHEN 'SO_VRKME'.
          <LS_FCAT>-COL_POS = 407.
        WHEN 'ERNAM'.
          <LS_FCAT>-COL_POS = 408.
      ENDCASE.
    ENDLOOP.
  ENDIF.

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
*& Form SET_CELL_ATTRIBUTE_GRID_0100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_CELL_ATTRIBUTE_GRID_0100 .

  DATA : LT_CELLTAB TYPE LVC_T_STYL.
  DATA : LS_CELLTAB TYPE LVC_S_STYL.

  CLEAR GS_CHK_MAINTAIN.
  CASE ABAP_TRUE.
    WHEN P_RAD01.
      READ TABLE GT_CHK_MAINTAIN INTO GS_CHK_MAINTAIN WITH KEY REPTEXT = '신선작업지시'.
    WHEN P_RAD02.
      READ TABLE GT_CHK_MAINTAIN INTO GS_CHK_MAINTAIN WITH KEY REPTEXT = '신선작업지시'.
    WHEN P_RAD03.
      READ TABLE GT_CHK_MAINTAIN INTO GS_CHK_MAINTAIN WITH KEY REPTEXT = '외장재작업지시'.
  ENDCASE.

  LOOP AT GT_MAIN_DISP ASSIGNING FIELD-SYMBOL(<LS_MAIN_DISP>).
    REFRESH LT_CELLTAB.

    LOOP AT GT_FIELDCAT_0100 INTO DATA(LS_FIELDCAT).
      CASE LS_FIELDCAT-FIELDNAME.
        WHEN 'GRPNR' OR 'ERDAT' OR 'ORDNO_C' OR 'GCATG' OR 'MATNR' OR 'ZZYUSCD'.
          CLEAR LS_CELLTAB.
          LS_CELLTAB-FIELDNAME = LS_FIELDCAT-FIELDNAME.
          LS_CELLTAB-STYLE = ALV_STYLE_COLOR_INT_KEY.
          INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
        WHEN OTHERS.
          IF LS_FIELDCAT-FIELDNAME = GS_CHK_MAINTAIN-FIELDNAME.
            CLEAR LS_CELLTAB.
            LS_CELLTAB-FIELDNAME = LS_FIELDCAT-FIELDNAME.
            LS_CELLTAB-STYLE = ALV_STYLE_COLOR_INT_POSITIVE.
            INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
          ENDIF.
      ENDCASE.
    ENDLOOP.

    <LS_MAIN_DISP>-CELLTAB = LT_CELLTAB.
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

  DATA: LS_MOD_CELLS TYPE LVC_S_MODI.
  DATA : LV_CALL_FUNC.
  DATA : LV_CHK_ERR.
  DATA : LV_NAME1 TYPE LFA1-NAME1.

  DATA : LV_CHK_CAL_1100.

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

  DEFINE __MODI_CELL.
    PO_DATA_CHANGED->MODIFY_CELL(
      I_ROW_ID     = &1                 " Row ID
      I_FIELDNAME = &2                 " Field Name
      I_VALUE       = &3 ).               " Value
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
    WHEN GO_GRID_0103.
      LOOP AT PO_DATA_CHANGED->MT_GOOD_CELLS INTO LS_MOD_CELLS.
        CASE LS_MOD_CELLS-FIELDNAME.
          WHEN 'MENGE02'.
            LV_CALL_FUNC = ABAP_TRUE.
        ENDCASE.
      ENDLOOP.
    WHEN GO_GRID_1102.
      LOOP AT PO_DATA_CHANGED->MT_GOOD_CELLS INTO LS_MOD_CELLS.
        CASE LS_MOD_CELLS-FIELDNAME.
          WHEN 'MENGE02' OR 'YCOEF' OR 'MENGE03'.
            LV_CHK_CAL_1100 = ABAP_TRUE.
        ENDCASE.
      ENDLOOP.

    WHEN GO_GRID_1103.


    WHEN GO_GRID_0403.
      LOOP AT PO_DATA_CHANGED->MT_GOOD_CELLS INTO LS_MOD_CELLS.
        CASE LS_MOD_CELLS-FIELDNAME.
          WHEN 'MENGE01'.
            LV_CALL_FUNC = ABAP_TRUE.
        ENDCASE.
      ENDLOOP.

    WHEN GO_GRID_1300.
      LOOP AT PO_DATA_CHANGED->MT_GOOD_CELLS INTO LS_MOD_CELLS.
        CASE LS_MOD_CELLS-FIELDNAME.
          WHEN 'LIFNR'.
            IF LS_MOD_CELLS-VALUE IS INITIAL.
              CLEAR LV_NAME1.
              __MODI_CELL LS_MOD_CELLS-ROW_ID 'NAME1' LV_NAME1.
            ELSE.
              READ TABLE GT_POPUP_1300 INTO DATA(LS_1300) INDEX LS_MOD_CELLS-ROW_ID.
              CLEAR LV_NAME1.
              PERFORM VALIDATION_LIFNR USING LS_1300-MATNR LS_MOD_CELLS-VALUE CHANGING LV_CHK_ERR LV_NAME1.
              IF LV_CHK_ERR IS INITIAL.
                __MODI_CELL LS_MOD_CELLS-ROW_ID 'NAME1' LV_NAME1.
              ELSE.
                __SET_ERR_MSG '유효하지 않은 공급업체입니다.' LS_MOD_CELLS-FIELDNAME.
              ENDIF.
            ENDIF.

        ENDCASE.
      ENDLOOP.

  ENDCASE.

  IF LV_CHK_ERR IS NOT INITIAL.
    PO_DATA_CHANGED->DISPLAY_PROTOCOL( ).
  ELSE.

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

    IF LV_CHK_CAL_1100 IS NOT INITIAL.
      CALL FUNCTION 'SAPGUI_SET_FUNCTIONCODE'
        EXPORTING
          FUNCTIONCODE           = 'CAL1100'              " Function code
        EXCEPTIONS
          FUNCTION_NOT_SUPPORTED = 1                " Not supported on this front end platform
          OTHERS                 = 2.
      IF SY-SUBRC <> 0.
      ENDIF.

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

  DATA : LT_CHECKED LIKE GT_MAIN_DISP.
  DATA : LT_CHECKED_SOSUN LIKE TABLE OF GS_CHK_SOSUN.
  DATA : LT_CHECKING_SOSUN LIKE TABLE OF GS_CHK_SOSUN.
  DATA : LS_SOSUN LIKE GS_CHK_SOSUN.
  DATA : LV_CHK_ERR.
  DATA : LV_ERR_CODE TYPE C.
  DATA : LT_GRPNR TYPE RANGE OF ZGTPPT2013-GRPNR.
  DATA : LT_SGRPNR TYPE RANGE OF ZGTPPT2013-SGRPNR.

  CASE ABAP_TRUE.
    WHEN P_RAD01.

      DATA(LT_SORT_REPLACE) = GT_SOSUN_REPLACE.
      IF LT_SORT_REPLACE IS NOT INITIAL.
        SORT LT_SORT_REPLACE BY TOBE.
        DELETE ADJACENT DUPLICATES FROM LT_SORT_REPLACE COMPARING TOBE.
      ENDIF.

      IF GV_CHK_GAGONG IS INITIAL.

        READ TABLE GT_MAIN_DISP INTO DATA(LS_CHKING_LINE) INDEX GV_CHK_LINE.

        IF GV_CHK_VALUE = ABAP_TRUE. " 체크시

          REFRESH LT_CHECKED.
          LT_CHECKED = VALUE #( FOR LW_MAIN IN GT_MAIN_DISP WHERE ( CHECK = ABAP_TRUE
                                                                                    AND  GRPNR NE LS_CHKING_LINE-GRPNR )
                                          ( CORRESPONDING #( LW_MAIN ) ) ).

          IF LT_CHECKED IS NOT INITIAL.
*          기존에 선택된 라인 존재시 확인.
*            1)기존 라인이 신선 작업 지시 된 경우 선택 안됨
            IF LINE_EXISTS( LT_CHECKED[ CHK_02 = ABAP_TRUE ] ).
              LV_ERR_CODE = '2'.
              LOOP AT GT_MAIN_DISP ASSIGNING FIELD-SYMBOL(<LS_CHKDATA>) WHERE GRPNR = LS_CHKING_LINE-GRPNR.
                CLEAR <LS_CHKDATA>-CHECK.
              ENDLOOP.
            ELSE.
*            2) 기존라인 작업 지시 없을 경우 소선코드1, 2 확인하여 동일한 소선코드일시 반영.
              IF LS_CHKING_LINE-CHK_02 = ABAP_TRUE.
                LV_ERR_CODE = '3'.
                LOOP AT GT_MAIN_DISP ASSIGNING <LS_CHKDATA> WHERE GRPNR = LS_CHKING_LINE-GRPNR.
                  CLEAR <LS_CHKDATA>-CHECK.
                ENDLOOP.
              ELSE.

* 선택되어있는 조장의 소선정보
                LOOP AT LT_CHECKED INTO DATA(LS_CHECKED).

                  IF LS_CHECKED-SOSUNCD1 NE 0.
                    CLEAR LS_SOSUN.
                    LS_SOSUN-SOSUNCD = LS_CHECKED-SOSUNCD1.
                    APPEND LS_SOSUN TO LT_CHECKED_SOSUN.
                  ENDIF.

                  IF LS_CHECKED-SOSUNCD2 NE 0.
                    CLEAR LS_SOSUN.
                    LS_SOSUN-SOSUNCD = LS_CHECKED-SOSUNCD2.
                    APPEND LS_SOSUN TO LT_CHECKED_SOSUN.
                  ENDIF.
                ENDLOOP.

                SORT LT_CHECKED_SOSUN BY SOSUNCD.
                DELETE ADJACENT DUPLICATES FROM LT_CHECKED_SOSUN COMPARING SOSUNCD.

* 선택된 조장의 소선정보
                LOOP AT GT_MAIN_DISP INTO DATA(LS_CHKING) WHERE GRPNR = LS_CHKING_LINE-GRPNR.
                  IF LS_CHKING-SOSUNCD1 NE 0.
                    CLEAR LS_SOSUN.
                    LS_SOSUN-SOSUNCD = LS_CHKING-SOSUNCD1.
                    APPEND LS_SOSUN TO LT_CHECKING_SOSUN.
                  ENDIF.

                  IF LS_CHKING-SOSUNCD2 NE 0.
                    CLEAR LS_SOSUN.
                    LS_SOSUN-SOSUNCD = LS_CHKING-SOSUNCD2.
                    APPEND LS_SOSUN TO LT_CHECKING_SOSUN.
                  ENDIF.
                ENDLOOP.

                SORT LT_CHECKING_SOSUN BY SOSUNCD.
                DELETE ADJACENT DUPLICATES FROM LT_CHECKING_SOSUN COMPARING SOSUNCD.

                IF LT_CHECKED_SOSUN = LT_CHECKING_SOSUN.
                  LOOP AT GT_MAIN_DISP ASSIGNING <LS_CHKDATA> WHERE GRPNR = LS_CHKING_LINE-GRPNR.
                    <LS_CHKDATA>-CHECK = ABAP_TRUE.
                  ENDLOOP.
                ELSE.
* 소선 정보 테이블 조회후 재결정.
                  CLEAR LV_CHK_ERR..
                  IF LT_SORT_REPLACE IS NOT  INITIAL AND LINES( LT_SORT_REPLACE ) = LINES( LT_CHECKING_SOSUN ).
                    PERFORM CHK_SOSUN TABLES LT_CHECKED_SOSUN LT_CHECKING_SOSUN CHANGING LV_CHK_ERR.

                  ELSEIF LINES( LT_CHECKED_SOSUN ) = LINES( LT_CHECKING_SOSUN ).
                    PERFORM CHK_SOSUN TABLES LT_CHECKED_SOSUN LT_CHECKING_SOSUN CHANGING LV_CHK_ERR.

                  ELSE.
                    LV_CHK_ERR = ABAP_TRUE.
                  ENDIF.

                  IF LV_CHK_ERR IS NOT INITIAL.
                    LV_ERR_CODE = '1'.
                    LOOP AT GT_MAIN_DISP ASSIGNING <LS_CHKDATA> WHERE GRPNR = LS_CHKING_LINE-GRPNR.
                      CLEAR <LS_CHKDATA>-CHECK.
                    ENDLOOP.
                  ENDIF.

                ENDIF.
              ENDIF.
            ENDIF.
          ELSE.
            IF LS_CHKING_LINE-CHK_02 = ABAP_TRUE.
              LT_SGRPNR = VALUE #( FOR LW_2013 IN GT_2013 WHERE ( GRPNR = LS_CHKING_LINE-GRPNR )
                            ( SIGN = 'I' OPTION = 'EQ' LOW = LW_2013-SGRPNR ) ).
              SORT LT_SGRPNR BY LOW.
              DELETE ADJACENT DUPLICATES FROM LT_SGRPNR COMPARING LOW.

              LT_GRPNR = VALUE #( FOR LW_2013 IN GT_2013 WHERE ( SGRPNR IN LT_SGRPNR )
                            ( SIGN = 'I' OPTION = 'EQ' LOW = LW_2013-GRPNR ) ).

              SORT LT_GRPNR BY LOW.
              DELETE ADJACENT DUPLICATES FROM LT_GRPNR COMPARING LOW.

              LOOP AT GT_MAIN_DISP ASSIGNING <LS_CHKDATA> WHERE GRPNR IN LT_GRPNR.
                <LS_CHKDATA>-CHECK = ABAP_TRUE.
              ENDLOOP.

              PERFORM SET_SOSUN_REPLACE.

            ELSE.
              LOOP AT GT_MAIN_DISP ASSIGNING <LS_CHKDATA> WHERE GRPNR = LS_CHKING_LINE-GRPNR.
                <LS_CHKDATA>-CHECK = ABAP_TRUE.
              ENDLOOP.

              PERFORM SET_SOSUN_REPLACE.

            ENDIF.

          ENDIF.

        ELSE. " 체크 삭제시
          IF LS_CHKING_LINE-CHK_02 = ABAP_TRUE.
            LOOP AT GT_MAIN_DISP ASSIGNING <LS_CHKDATA> WHERE CHECK = ABAP_TRUE.
              CLEAR <LS_CHKDATA>-CHECK.
            ENDLOOP.
            REFRESH GT_SOSUN_REPLACE.

          ELSE.
            LOOP AT GT_MAIN_DISP ASSIGNING <LS_CHKDATA> WHERE GRPNR = LS_CHKING_LINE-GRPNR.
              CLEAR <LS_CHKDATA>-CHECK.

              READ TABLE GT_SOSUN_REPLACE INTO DATA(LS_EXISTS) WITH KEY SOSUNCD = <LS_CHKDATA>-SOSUNCD1.
              IF SY-SUBRC EQ 0.
                DELETE GT_SOSUN_REPLACE WHERE SOSUNCD = <LS_CHKDATA>-SOSUNCD1.
              ENDIF.

              IF <LS_CHKDATA>-SOSUNCD2 NE 0.
                READ TABLE GT_SOSUN_REPLACE INTO LS_EXISTS WITH KEY SOSUNCD = <LS_CHKDATA>-SOSUNCD2.
                IF SY-SUBRC EQ 0.
                  DELETE GT_SOSUN_REPLACE WHERE SOSUNCD = <LS_CHKDATA>-SOSUNCD2.
                ENDIF.
              ENDIF.

            ENDLOOP.
          ENDIF.


        ENDIF.
      ELSE.

        LOOP AT GT_MAIN_DISP ASSIGNING FIELD-SYMBOL(<LS_DISP_201>).
          CLEAR <LS_DISP_201>-CHECK.
        ENDLOOP.

        READ TABLE GT_MAIN_DISP INTO DATA(LS_MAIN_DISP) INDEX GV_CHK_LINE.
        LS_MAIN_DISP-CHECK = GV_CHK_VALUE.
        MODIFY GT_MAIN_DISP FROM LS_MAIN_DISP TRANSPORTING CHECK WHERE GRPNR = LS_MAIN_DISP-GRPNR .
      ENDIF.
    WHEN P_RAD02.
      LOOP AT GT_MAIN_DISP ASSIGNING <LS_DISP_201>.
        CLEAR <LS_DISP_201>-CHECK.
      ENDLOOP.

      READ TABLE GT_MAIN_DISP INTO LS_MAIN_DISP INDEX GV_CHK_LINE.
      LS_MAIN_DISP-CHECK = GV_CHK_VALUE.
      MODIFY GT_MAIN_DISP FROM LS_MAIN_DISP TRANSPORTING CHECK WHERE GRPNR = LS_MAIN_DISP-GRPNR .
    WHEN P_RAD03.
      READ TABLE GT_MAIN_DISP INTO LS_MAIN_DISP INDEX GV_CHK_LINE.
      LS_MAIN_DISP-CHECK = GV_CHK_VALUE.
      MODIFY GT_MAIN_DISP FROM LS_MAIN_DISP TRANSPORTING CHECK WHERE GRPNR = LS_MAIN_DISP-GRPNR .

  ENDCASE.


  PERFORM REFRESH_GRID USING GO_GRID_0100.
  CASE LV_ERR_CODE.
    WHEN '1'.
      MESSAGE S006 DISPLAY LIKE 'E' WITH '소선정보가 다른 조장이 선택되었습니다.'.
    WHEN '2'.
      MESSAGE S006 DISPLAY LIKE 'E' WITH '오더 생성된 조장이 이미 선택되어 추가로 선택할 수 없습니다.'.
    WHEN '3'.
      MESSAGE S006 DISPLAY LIKE 'E' WITH '선택된 조장이 있어 오더 생성된 조장을 추가로 선택할 수 없습니다.'.
  ENDCASE.

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
*& Form PROC_WORKING_SINSUN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_WORKING_SINSUN .

  DATA : LV_CHK_ERR.

  PERFORM CHK_PROC_WORKING_SINSUN CHANGING LV_CHK_ERR.

  IF LV_CHK_ERR IS NOT INITIAL.
    RETURN.
  ENDIF.

  CLEAR GS_HEADER_200.

  PERFORM SET_ITAB_101.
  PERFORM SET_ITAB_102.

  REFRESH GT_MAIN_DISP_103.
  IF <GT_MAIN_DISP_104> IS ASSIGNED.
    REFRESH <GT_MAIN_DISP_104>.
  ENDIF.

  CLEAR : GV_CHK_EXCUTE_100, GV_CHK_EXCUTE_103.
  GV_CHK_EXCUTE_100 = ABAP_TRUE.

*  PERFORM CHECK_AND_LOCK CHANGING LV_CHK_ERR.

  IF LV_CHK_ERR IS NOT INITIAL.
    RETURN.
  ENDIF.

  CALL SCREEN '0200'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_PROC_WORKING_SINSUN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM CHK_PROC_WORKING_SINSUN  CHANGING PV_CHK_ERR.

  IF NOT LINE_EXISTS( GT_MAIN_DISP[ CHECK = ABAP_TRUE ] ).
    MESSAGE S005 DISPLAY LIKE 'E' WITH '선택된 조장이 없습니다.'(e03).
    PV_CHK_ERR = ABAP_TRUE.
    RETURN.
  ENDIF.

  LOOP AT GT_MAIN_DISP INTO GS_MAIN_DISP WHERE CHECK = ABAP_TRUE.
* 신선작업대상 여부 확인
    READ TABLE GT_CHK_MAINTAIN INTO GS_CHK_MAINTAIN WITH KEY REPTEXT = '신선작업'.
    IF SY-SUBRC EQ 0.
      IF GS_MAIN_DISP-(GS_CHK_MAINTAIN-FIELDNAME) IS INITIAL.
        MESSAGE S005 DISPLAY LIKE 'E' WITH '신선재 작업지시가 필요하지 않은 대상이 선택되었습니다.'(e01).
        PV_CHK_ERR = ABAP_TRUE.
        RETURN.
      ENDIF.
    ENDIF.

* 조장구성표내 연선정보가 존재해야함
    READ TABLE GT_CHK_MAINTAIN INTO GS_CHK_MAINTAIN WITH KEY REPTEXT = '조장확정'.
    IF SY-SUBRC EQ 0.
      IF GS_MAIN_DISP-(GS_CHK_MAINTAIN-FIELDNAME) IS INITIAL.
        MESSAGE S005 DISPLAY LIKE 'E' WITH '신선재 작업지시는 조장 구성이 먼저 실행되어야 합니다. 선택 대상을 확인해 주세요.'(e02).
        PV_CHK_ERR = ABAP_TRUE.
        RETURN.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ITAB_101
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_ITAB_101 .

  DATA : LV_INDEX TYPE I.

  REFRESH GT_MAIN_DISP_101.

  LOOP AT GT_MAIN_DISP INTO GS_MAIN_DISP WHERE CHECK = ABAP_TRUE.
    ADD 1 TO LV_INDEX.
    IF LV_INDEX = 1.
      GV_GRPNR = GS_MAIN_DISP-GRPNR.
    ENDIF.
    CLEAR GS_MAIN_DISP_101.
    MOVE-CORRESPONDING GS_MAIN_DISP TO GS_MAIN_DISP_101.
    APPEND GS_MAIN_DISP_101 TO GT_MAIN_DISP_101.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ITAB_102
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_ITAB_102 .

  DATA : LT_2010 TYPE TABLE OF ZGTPPT2010.
  DATA : LT_CHK_MATNR TYPE RANGE OF MATNR.
  DATA : LT_MATNR TYPE RANGE OF MATNR.
  DATA : LV_ORDNR_C(12).
  DATA : LV_POSNR_C(6).
  DATA : LT_GRPNR TYPE RANGE OF ZGTPPT2010-GRPNR.

  LT_GRPNR = VALUE #( FOR LW_MAIN IN GT_MAIN_DISP WHERE ( CHECK = ABAP_TRUE )
                              ( SIGN = 'I' OPTION = 'EQ' LOW = LW_MAIN-GRPNR ) ) .
  SORT LT_GRPNR BY LOW.
  DELETE ADJACENT DUPLICATES FROM LT_GRPNR COMPARING LOW.

  LT_MATNR = VALUE #( FOR LW_MAIN IN GT_MAIN_DISP WHERE ( CHECK = ABAP_TRUE )
                              ( SIGN = 'I' OPTION = 'EQ' LOW = LW_MAIN-MATNR ) ) .
  SORT LT_MATNR BY LOW.
  DELETE ADJACENT DUPLICATES FROM LT_MATNR COMPARING LOW.

*  READ TABLE GT_MAIN_DISP INTO GS_MAIN_DISP WITH KEY CHECK = ABAP_TRUE.

  LT_2010 = VALUE #( FOR LW_2010 IN GT_2010 WHERE ( GRPNR IN LT_GRPNR )
                            ( CORRESPONDING #( LW_2010 ) ) ).

  LT_CHK_MATNR = VALUE #( FOR LW_2010 IN LT_2010 WHERE ( MATNR IS NOT INITIAL )
                            ( SIGN = 'I' OPTION = 'EQ' LOW = LW_2010-MATNR ) ).

  SORT LT_CHK_MATNR BY LOW.
  DELETE ADJACENT DUPLICATES FROM LT_CHK_MATNR COMPARING LOW.

  SELECT DISTINCT *
    FROM ZGTCVMSTVAL
    INTO TABLE @DATA(LT_CVMSTVAL)
   WHERE WERKS = @P_WERKS
     AND MATNR IN @LT_MATNR.

  WITH +SULNO2 AS (
    SELECT B~SUL_NO,
                B~REV_SEQ,
                B~GONG_SEQ,
                B~MATNR_N AS MATNR
        FROM @LT_CVMSTVAL AS A
        INNER JOIN ZEDT1050 AS B ON B~SUL_NO = A~PDCADESIGNNO
                                           AND B~REV_SEQ = A~PDCADESIGNREVNO
       WHERE MATNR_N IN @LT_CHK_MATNR )
      SELECT DISTINCT A~MATNR, B~DATA_CHAR, B~DATA_NUM
        FROM +SULNO2 AS A
        INNER JOIN ZEDT1030 AS B ON B~SUL_NO = A~SUL_NO
                                           AND B~REV_SEQ = A~REV_SEQ
                                           AND B~GONG_SEQ = A~GONG_SEQ
                                           AND B~ATTRIBUTE = 'SOSUNCD'
      INTO TABLE @DATA(LT_SOSUN).


  REFRESH GT_MAIN_DISP_102.
  LOOP AT LT_2010 INTO DATA(LS_2010).
    CLEAR GS_MAIN_DISP_102.
* 소선코드
    READ TABLE LT_SOSUN INTO DATA(LS_SOSUN) WITH KEY MATNR = LS_2010-MATNR.
    IF SY-SUBRC EQ 0.
      IF LS_SOSUN-DATA_CHAR IS NOT INITIAL.
        GS_MAIN_DISP_102-SOSUNCD = LS_SOSUN-DATA_CHAR.
      ELSE.
        GS_MAIN_DISP_102-SOSUNCD = LS_SOSUN-DATA_NUM + 0.
      ENDIF.
    ENDIF.

* 같은 규격은 소선코드를 동시에 사용하기 위해 디스플레이용 소선번호 적용
    READ TABLE GT_SOSUN_REPLACE INTO DATA(LS_REPLACE) WITH KEY SOSUNCD = GS_MAIN_DISP_102-SOSUNCD.
    IF SY-SUBRC EQ 0.
      GS_MAIN_DISP_102-DISP_SOSUNCD = LS_REPLACE-TOBE.
    ENDIF.

*  오더번호
    LV_ORDNR_C = GS_MAIN_DISP_102-ORDNR = LS_2010-ORDNR.
    LV_POSNR_C = GS_MAIN_DISP_102-POSNR = LS_2010-POSNR.
    __ALPHA_OUT : LV_ORDNR_C, LV_POSNR_C.
    CONCATENATE LV_ORDNR_C LV_POSNR_C
                  INTO GS_MAIN_DISP_102-ORDNO_C SEPARATED BY '/'.

* 자재
    GS_MAIN_DISP_102-MATNR = LS_2010-MATNR.
    GS_MAIN_DISP_102-MAKTX = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = LS_2010-MATNR ).

* 연선조장(기본)
    GS_MAIN_DISP_102-INLENGTH02 = LS_2010-INLENGTH * LS_2010-INFACTOR.
* 연선조장(여장)
    GS_MAIN_DISP_102-INLENGTH03 = ( LS_2010-QLENGTH + LS_2010-CLENGTH +
                                                    LS_2010-SLENGTH + LS_2010-ELENGTH + LS_2010-ADLENGTH )
                                                  * LS_2010-INFACTOR.
* 연선조장(합계)
    GS_MAIN_DISP_102-INLENGTH01 = GS_MAIN_DISP_102-INLENGTH02 + GS_MAIN_DISP_102-INLENGTH03.

* 단위
    GS_MAIN_DISP_102-MEINS = 'M'.
* 조장수
    GS_MAIN_DISP_102-INFACTOR = LS_2010-INFACTOR.

    APPEND GS_MAIN_DISP_102 TO GT_MAIN_DISP_102.

  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SCREEN_SUB_SINSUN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_SCREEN_SUB_SINSUN .

  IF GO_GRID_0101 IS NOT BOUND.
    PERFORM SET_OBJECT_GRID_0101.
    PERFORM EVENT_HANDLER_REGISTER USING GO_GRID_0101.
    PERFORM SET_LAYOUT_GRID_0101.
    PERFORM SET_FIELDCAT_GRID_0101.
    PERFORM EXCLUDE_OF_TOOLBAR_GRID_0101.
    PERFORM CALL_GRID_0101_DISPLAY.
  ELSE.
    PERFORM REFRESH_GRID USING GO_GRID_0101.
  ENDIF.


  IF GO_GRID_0102 IS NOT BOUND.
    PERFORM SET_OBJECT_GRID_0102.
    PERFORM EVENT_HANDLER_REGISTER USING GO_GRID_0102.
    PERFORM SET_LAYOUT_GRID_0102.
    PERFORM SET_FIELDCAT_GRID_0102.
    PERFORM EXCLUDE_OF_TOOLBAR_GRID_0102.
    PERFORM CALL_GRID_0102_DISPLAY.
  ELSE.
    PERFORM REFRESH_GRID USING GO_GRID_0102.
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

  CREATE OBJECT GO_DOCKING_CONTAINER
    EXPORTING
      CONTAINER_NAME = 'CONTAINER200'.                 " Name of the Screen CustCtrl Name to Link Container To

  CREATE OBJECT GO_SPLITTER
    EXPORTING
      PARENT  = GO_DOCKING_CONTAINER
      ROWS    = 3
      COLUMNS = 1.

  PERFORM SET_SPLITER_HEIGHT.

*&---------------------------------------------------------------------*
* 2열 컨테이너
  CALL METHOD GO_SPLITTER->GET_CONTAINER
    EXPORTING
      ROW       = 1
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_SPLIT_CONTAINER.

* 2열 스플릿
  CREATE OBJECT GO_SPLITTER2
    EXPORTING
      PARENT  = GO_SPLIT_CONTAINER
      ROWS    = 1
      COLUMNS = 2.

  GO_SPLITTER2->SET_COLUMN_WIDTH(
    EXPORTING
      ID                = 1                 " Column ID
      WIDTH             = 50 ).                 " NPlWidth

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
*&---------------------------------------------------------------------*
* 2열 컨테이너
  CALL METHOD GO_SPLITTER->GET_CONTAINER
    EXPORTING
      ROW       = 2
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_CONTAIN_0103.

*&---------------------------------------------------------------------*
* 3열 컨테이너
  CALL METHOD GO_SPLITTER->GET_CONTAINER
    EXPORTING
      ROW       = 3
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_CONTAIN_0104.

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
  GS_LAYOUT_0101-NO_ROWMARK   = 'X'.

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
      I_INCLNAME             = 'ZGTPPR2150TOP'
      I_INTERNAL_TABNAME     = 'GS_MAIN_DISP_101'
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

  READ TABLE GT_FIELDCAT_0101 ASSIGNING FIELD-SYMBOL(<LS_FCAT>) WITH KEY FIELDNAME = 'ORDNO_C'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0101 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'ORDNO_C'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '오더번호'(f17).
    <LS_FCAT>-COL_POS = 3.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '30'.
    <LS_FCAT>-JUST = 'C'.
    <LS_FCAT>-KEY = ABAP_TRUE.
  ENDIF.


  LOOP AT GT_FIELDCAT_0101 ASSIGNING <LS_FCAT>.
    CLEAR <LS_FCAT>-KEY.
    CASE   <LS_FCAT>-FIELDNAME.
      WHEN 'GRPNR' OR 'ORDNO' OR 'POSNR'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'GCATG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '범주'(F03).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-KEY = ABAP_TRUE.
      WHEN 'ZZYUSCD'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '영업소'(F04).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-KEY = ABAP_TRUE.
      WHEN 'ORDNO_C'.
        <LS_FCAT>-KEY = ABAP_TRUE.
      WHEN 'MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '제품'(F05).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-KEY = ABAP_TRUE.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '제품내역'(F06).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'INLENGTH'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '조장'(F10).
        <LS_FCAT>-JUST = 'R'.
      WHEN 'MEINS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '단위'(F11).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'INFACTOR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '조장수'(F12).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-DECIMALS_O = '0'.
    ENDCASE.
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
        USING : CL_GUI_ALV_GRID=>MC_FC_EXCL_ALL.

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
    CHANGING
      IT_OUTTAB            = GT_MAIN_DISP_101
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
  GS_LAYOUT_0102-NO_ROWMARK   = 'X'.

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
      I_INCLNAME             = 'ZGTPPR2150TOP'
      I_INTERNAL_TABNAME     = 'GS_MAIN_DISP_102'
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

  READ TABLE GT_FIELDCAT_0102 ASSIGNING FIELD-SYMBOL(<LS_FCAT>) WITH KEY FIELDNAME = 'ORDNO_C'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0102 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'ORDNO_C'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '연선오더번호'(f18).
    <LS_FCAT>-COL_POS = 2.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '30'.
    <LS_FCAT>-JUST = 'C'.
    <LS_FCAT>-KEY = ABAP_TRUE.
  ENDIF.


  LOOP AT GT_FIELDCAT_0102 ASSIGNING <LS_FCAT>.
    CLEAR <LS_FCAT>-KEY.
    CASE   <LS_FCAT>-FIELDNAME.
      WHEN 'DISP_SOSUNCD'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '소선코드'(F19).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-KEY = ABAP_TRUE.
      WHEN 'SOSUNCD'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'ORDNO_C'.
        <LS_FCAT>-KEY = ABAP_TRUE.
      WHEN 'ORDNR'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'POSNR'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '연선반제품'(F20).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-KEY = ABAP_TRUE.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '반제품내역'(F21).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'INLENGTH01'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '연선조장(합계)'(F22).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-DO_SUM = ABAP_TRUE.
      WHEN 'INLENGTH02'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '연선조장(기본)'(F23).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-DO_SUM = ABAP_TRUE.
      WHEN 'INLENGTH03'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '연선조장(여장)'(F24).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-DO_SUM = ABAP_TRUE.
      WHEN 'MEINS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '단위'(F11).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'INFACTOR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '조장수'(F12).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-DECIMALS_O = '0'.
        <LS_FCAT>-DO_SUM = ABAP_TRUE.
    ENDCASE.
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

  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON TABLES GT_EXCLUDE_0102
        USING : CL_GUI_ALV_GRID=>MC_FC_EXCL_ALL.

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
    CHANGING
      IT_OUTTAB            = GT_MAIN_DISP_102
      IT_SORT              = GT_SORT_0102
      IT_FIELDCATALOG      = GT_FIELDCAT_0102.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SPLITER_HEIGHT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_SPLITER_HEIGHT .

  IF GV_CHK_EXCUTE_103 IS INITIAL.
    GO_SPLITTER->SET_ROW_HEIGHT(
      EXPORTING
        ID                =  1                " Row ID
        HEIGHT            =  50    ).            " Height

    GO_SPLITTER->SET_ROW_HEIGHT(
      EXPORTING
        ID                =  2                " Row ID
        HEIGHT            =  50    ).            " Height

    GO_SPLITTER->SET_ROW_HEIGHT(
      EXPORTING
        ID                =  3                " Row ID
        HEIGHT            =  0    ).            " Height
  ELSE.
    GO_SPLITTER->SET_ROW_HEIGHT(
      EXPORTING
        ID                =  1                " Row ID
        HEIGHT            =  25    ).            " Height

    GO_SPLITTER->SET_ROW_HEIGHT(
      EXPORTING
        ID                =  2                " Row ID
        HEIGHT            =  25    ).            " Height
    GO_SPLITTER->SET_ROW_HEIGHT(
      EXPORTING
        ID                =  3                " Row ID
        HEIGHT            =  50    ).            " Height
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DROPDOWN_SOSUNCD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM DROPDOWN_SOSUNCD .

  DATA : LT_DROPLIST TYPE VRM_VALUES.

  LOOP AT GT_MAIN_DISP_102 INTO DATA(LS_DATA).
    APPEND INITIAL LINE TO LT_DROPLIST ASSIGNING FIELD-SYMBOL(<LS_VALUE>).
    <LS_VALUE>-KEY = LS_DATA-DISP_SOSUNCD.
  ENDLOOP.
  SORT LT_DROPLIST BY KEY.
  DELETE ADJACENT DUPLICATES FROM LT_DROPLIST COMPARING KEY.


  CALL FUNCTION 'VRM_SET_VALUES'
    EXPORTING
      ID              = 'GS_HEADER_200-SOSUNCD'
      VALUES          = LT_DROPLIST
    EXCEPTIONS
      ID_ILLEGAL_NAME = 1
      OTHERS          = 2.
  IF SY-SUBRC <> 0.
* Implement suitable error handling here
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

  PERFORM SET_SORT_TAB TABLES GT_SORT_0102
                            USING : 1 'DISP_SOSUNCD'  'X' '' 'X'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_0103
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GRID_0103 .

  CREATE OBJECT GO_GRID_0103
    EXPORTING
      I_PARENT      = GO_CONTAIN_0103
      I_APPL_EVENTS = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_0103
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_0103 .

  CLEAR GS_LAYOUT_0103.
  GS_LAYOUT_0103-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYOUT_0103-NO_ROWMARK   = 'X'.
  GS_LAYOUT_0103-STYLEFNAME = 'CELLTAB'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_GRID_0103
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_0103 .

  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.
  DATA : LV_COL_POS TYPE I.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR2150TOP'
      I_INTERNAL_TABNAME     = 'GS_MAIN_DISP_103'
    CHANGING
      CT_FIELDCAT            = LT_FCAT_SLIS
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.

  REFRESH GT_FIELDCAT_0103.

*-- lt_fieldcat의 구조체를 pt_fcat의 구조체로 변경
  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT_SLIS
    IMPORTING
      ET_FIELDCAT_LVC = GT_FIELDCAT_0103[]
    TABLES
      IT_DATA         = GT_MAIN_DISP_103
    EXCEPTIONS
      OTHERS          = 1.


  LOOP AT GT_FIELDCAT_0103 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CLEAR <LS_FCAT>-KEY.
    CASE   <LS_FCAT>-FIELDNAME.
      WHEN 'COND_TYPE'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'LAYER'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = 'CAGE'(F25).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'JAEJIL'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '도체재질'(F26).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'SOSUN_DIA'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '소선경'(F27).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'YCOEF'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '연입률'(F28).
        <LS_FCAT>-JUST = 'R'.
      WHEN 'MENGE01'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '연선조장'(F29).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-QUANTITY = 'EA'.
      WHEN 'MENGE02'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '작업여장'(F30).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-EDIT = ABAP_TRUE.
        <LS_FCAT>-QUANTITY = 'EA'.
      WHEN 'MENGE03'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '작업량'(F31).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-QUANTITY = 'EA'.
      WHEN 'MENGE04'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '기준권취량'(F32).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-QUANTITY = 'EA'.
      WHEN 'MENGE05'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '권취개수'(F33).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-QUANTITY = 'EA'.
      WHEN 'MENGE06'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '실권취량'(F34).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-QUANTITY = 'EA'.
      WHEN 'MENGE07'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '작업지시량'(F35).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-QUANTITY = 'EA'.
      WHEN 'MEINS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '단위'(F11).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'YUN'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '연방향'(F36).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'SPECCD'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = 'Spec코드'(F37).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'COND_SIZE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '도체Size'(F38).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'SHAPE'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'VTEXT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '도체형상'(F39).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '신선자재'(F40).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '신선자재명'(F41).
        <LS_FCAT>-JUST = 'L'.
    ENDCASE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SORTTAB_GRID_0103
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_SORTTAB_GRID_0103 .

  REFRESH GT_SORT_0103.

  PERFORM SET_SORT_TAB TABLES GT_SORT_0103
                            USING : 1 'LAYER'  'X' '' ''.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_OF_TOOLBAR_GRID_0103
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EXCLUDE_OF_TOOLBAR_GRID_0103 .

  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON TABLES GT_EXCLUDE_0103
        USING : CL_GUI_ALV_GRID=>MC_FC_EXCL_ALL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_GRID_0103_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_GRID_0103_DISPLAY .


  CALL METHOD GO_GRID_0103->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT_0103
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0103
    CHANGING
      IT_OUTTAB            = GT_MAIN_DISP_103
      IT_SORT              = GT_SORT_0103
      IT_FIELDCATALOG      = GT_FIELDCAT_0103.

* 인풋이벤트 추가
  CALL METHOD GO_GRID_0103->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

  CALL METHOD GO_GRID_0103->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_0104
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GRID_0104 .

  CREATE OBJECT GO_GRID_0104
    EXPORTING
      I_PARENT      = GO_CONTAIN_0104
      I_APPL_EVENTS = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_0104
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_0104 .

  CLEAR GS_LAYOUT_0104.
  GS_LAYOUT_0104-SEL_MODE = 'D'.
  GS_LAYOUT_0104-STYLEFNAME = 'XYZSTYLEZYX'.
  GS_LAYOUT_0104-SMALLTITLE = 'X'.
  GS_LAYOUT_0104-GRID_TITLE = '신선작업 지시'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SORTTAB_GRID_0104
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_SORTTAB_GRID_0104 .

  PERFORM SET_SORT_TAB TABLES GT_SORT_0104
                            USING : 1 'SEQNO' 'X' '' '',
                                       2 'LINE'  'X' '' '',
                                       3 'LAYER'  'X' '' ''.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_OF_TOOLBAR_GRID_0104
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EXCLUDE_OF_TOOLBAR_GRID_0104 .

  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON TABLES GT_EXCLUDE_0104
        USING : CL_GUI_ALV_GRID=>MC_FC_EXCL_ALL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_GRID_0104_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_GRID_0104_DISPLAY .

  CALL METHOD GO_GRID_0104->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT_0104
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0104
    CHANGING
      IT_OUTTAB            = <GT_MAIN_DISP_104>
      IT_SORT              = GT_SORT_0104
      IT_FIELDCATALOG      = GT_FIELDCAT_0104.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ITAB_103
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_ITAB_103 .

* 계산을 위한 상수 등록
  CONSTANTS : LC_CON01 TYPE P LENGTH 15 VALUE '610', "악경
              LC_CON02 TYPE P LENGTH 15 VALUE '360', "내폭
              LC_CON03 TYPE P LENGTH 15 VALUE '300', "보빈동경
              LC_CON04 TYPE P LENGTH 16 DECIMALS 14 VALUE '3.14159265358979'. "보빈동경

  DATA : LV_MENGE TYPE MENGE_D.
  DATA : LV_CHK_EXIST.
  DATA : LV_SGRPNR TYPE ZGTPPT2011-SGRPNR.
  DATA : LV_GRPNR TYPE ZGTPPT2010-GRPNR.
  DATA : LV_CAL01 TYPE P LENGTH 16 DECIMALS 5, "외경
         LV_CAL02 TYPE P LENGTH 16 DECIMALS 5, " 점적률
         LV_CAL03 TYPE P LENGTH 16 DECIMALS 5, " 유효권취
         LV_CAL04 TYPE P LENGTH 16 DECIMALS 5, " 실제권취
         LV_CAL05 TYPE P LENGTH 16 DECIMALS 5. " 기준권취량

  CHECK GS_HEADER_200-SOSUNCD IS NOT INITIAL.

  CLEAR GV_EXIST_103.

  SELECT SINGLE *
    FROM ZGTEDT0050G
    INTO @DATA(LS_0050)
   WHERE SOSUNCD = @GS_HEADER_200-SOSUNCD.

  SELECT * FROM ZGTEDT0051G
    INTO TABLE @DATA(LT_0051)
   WHERE SOSUNCD = @GS_HEADER_200-SOSUNCD.

  REFRESH GT_2012_MAINTAIN.

  LOOP AT GT_MAIN_DISP_102 INTO DATA(LS_TEMP) WHERE DISP_SOSUNCD = GS_HEADER_200-SOSUNCD.
    ADD LS_TEMP-INLENGTH01 TO LV_MENGE.

    IF LV_CHK_EXIST IS INITIAL.
      READ TABLE GT_2013 INTO DATA(LS_2013) WITH KEY DMORD = LS_TEMP-ORDNR
                                                                             DMLINE = LS_TEMP-POSNR.
      IF SY-SUBRC EQ 0.
        LV_CHK_EXIST = ABAP_TRUE.
        LV_SGRPNR = LS_2013-SGRPNR.

        GT_2012_MAINTAIN = VALUE #( FOR LW_2013 IN GT_2012 WHERE ( SGRPNR = LV_SGRPNR )
                                                ( CORRESPONDING #( LW_2013 ) ) ).
      ELSE.
        CLEAR LV_GRPNR.
        SELECT SINGLE GRPNR FROM ZGTPPT2020
          INTO LV_GRPNR
         WHERE GONG_CD = 'CST'
           AND ORDNR = LS_TEMP-ORDNR
           AND POSNR = LS_TEMP-POSNR.
        IF LV_GRPNR IS NOT INITIAL.
          READ TABLE GT_2013 INTO LS_2013 WITH KEY GRPNR = LV_GRPNR.
          IF SY-SUBRC EQ 0.
            READ TABLE GT_2011 INTO DATA(LS_2011) WITH KEY SGRPNR = LS_2013-SGRPNR
                                                                        SOSUNCD = GS_HEADER_200-SOSUNCD.
            IF SY-SUBRC EQ 0.
              LV_CHK_EXIST = ABAP_TRUE.
              LV_SGRPNR = LS_2013-SGRPNR.

              GT_2012_MAINTAIN = VALUE #( FOR LW_2013 IN GT_2012 WHERE ( SGRPNR = LV_SGRPNR )
                                                      ( CORRESPONDING #( LW_2013 ) ) ).
            ENDIF.
          ENDIF.

        ENDIF.
      ENDIF.
    ENDIF.
  ENDLOOP.

  IF GT_MAIN_DISP_103 IS INITIAL.

    SORT LT_0051 BY LAYER.
    LOOP AT LT_0051 INTO DATA(LS_0051).
      CLEAR GS_MAIN_DISP_103.
* CAGE
      GS_MAIN_DISP_103-LAYER = LS_0051-BONSU.
* 도체타입
      GS_MAIN_DISP_103-COND_TYPE = LS_0050-COND_TYPE.
* 도체재질
      GS_MAIN_DISP_103-JAEJIL = LS_0051-JAEJIL.
* 소선경
      GS_MAIN_DISP_103-SOSUN_DIA = LS_0051-SOSUN_DIA.
* 연입율
      GS_MAIN_DISP_103-YCOEF = LS_0051-YCOEF.
* 연선조장
      GS_MAIN_DISP_103-MENGE01 = LV_MENGE.
* 신선재 작업 여장
      IF LV_CHK_EXIST = ABAP_TRUE.
        GV_EXIST_103 = ABAP_TRUE.
        READ TABLE GT_2012_MAINTAIN INTO DATA(LS_2012) WITH KEY SGRPNR = LV_SGRPNR
                                                                        ZCAGE = GS_MAIN_DISP_103-LAYER.
        IF SY-SUBRC EQ 0.
          GS_MAIN_DISP_103-MENGE02 = LS_2012-ADLENGTH.
        ENDIF.
      ENDIF.

* 작업수량
      GS_MAIN_DISP_103-MENGE03 = ( GS_MAIN_DISP_103-MENGE01 * GS_MAIN_DISP_103-YCOEF ) +
                                                   GS_MAIN_DISP_103-MENGE02.
* 버림처리
*      PERFORM CONV_UPPPER_ROUND USING 1 CHANGING GS_MAIN_DISP_103-MENGE03.
      PERFORM CONV_TRUNCATE USING 1 CHANGING GS_MAIN_DISP_103-MENGE03.
*      PERFORM CONV_ROUND USING 1 CHANGING GS_MAIN_DISP_103-MENGE03.

* 기준권취량
      SELECT SINGLE BASE_WD FROM ZGTPPT2260
        INTO @DATA(LV_BASE_WD)
       WHERE SOSUN_DIA = @LS_0051-SOSUN_DIA.
      IF SY-SUBRC EQ 0 AND LV_BASE_WD IS NOT INITIAL.
        GS_MAIN_DISP_103-MENGE04 = LV_BASE_WD.
      ELSE. " 관리테이블에 없으면 계산

* ① 외경 = 보빈 내폭 / 소선경
        LV_CAL01 = LC_CON02 / LS_0051-SOSUN_DIA.

* ② 점적률 = ROUND(INT(외경-1)/외경,4), 소수점 4자리 반올림
        LV_CAL02 = ( LV_CAL01 - 1 ) / LV_CAL01.
        PERFORM CONV_ROUND USING '0.01' CHANGING LV_CAL02.

* ③ 유효권취 = ((악경 - 2 * 15) - 보빈동경) / 2 / 소선경
        LV_CAL03 = ( ( LC_CON01 - 30 ) - LC_CON03 ) / 2 / LS_0051-SOSUN_DIA.

* ④ 실제권취 = INT(유효 권취 + 0.99) -1, 소수점 버림
        LV_CAL04 = ( LV_CAL03 + '0.99' ).
        PERFORM CONV_TRUNCATE USING 1 CHANGING LV_CAL04.
        LV_CAL04 = LV_CAL04 - 1.

* ⑤ 기준권취량 = ROUND(원주율 * 보빈내폭 * 점적율 * 실제권취 * (실제권취 * 소선경 + 보빈동경) / 소선경 / 1000,0)
        LV_CAL05 =  LC_CON04 * LC_CON02 * LV_CAL02 * LV_CAL04 * ( LV_CAL04 * LS_0051-SOSUN_DIA + LC_CON03 ) / LS_0051-SOSUN_DIA / 1000.
        PERFORM CONV_ROUND USING 1 CHANGING LV_CAL05.

        GS_MAIN_DISP_103-MENGE04 = LV_CAL05.

      ENDIF.
      CLEAR LV_BASE_WD.
* 권취개수 계산
      GS_MAIN_DISP_103-MENGE05 = GS_MAIN_DISP_103-MENGE03 / GS_MAIN_DISP_103-MENGE04.
      PERFORM CONV_UPPPER_ROUND USING 1 CHANGING GS_MAIN_DISP_103-MENGE05.

* 실권취량 계산 - 권취개수 정해진후 재계산
*   GS_MAIN_DISP_103-MENGE06

* 작업지시량  - 권취개수 정해진후 재계산

* 신선자재확인
      SELECT SINGLE MATNR FROM ZGTCVMSTVAL
        INTO GS_MAIN_DISP_103-MATNR
       WHERE WERKS = P_WERKS
          AND PDCACONDDIA = LS_0051-SOSUN_DIA
          AND PDCACONDMAT = LS_0051-JAEJIL
          AND PDCAPROCCODE = 'BWD'
          AND LVORMC = ''
          AND LVORMP = ''
          AND MMSTA = ''.

      GS_MAIN_DISP_103-MAKTX = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = GS_MAIN_DISP_103-MATNR ).

* 단위
      SELECT SINGLE MEINS FROM MARA
        INTO GS_MAIN_DISP_103-MEINS
        WHERE MATNR = GS_MAIN_DISP_103-MATNR.
      IF GS_MAIN_DISP_103-MEINS IS INITIAL.
        GS_MAIN_DISP_103-MEINS = 'M'.
      ENDIF.
* 연방향
      GS_MAIN_DISP_103-YUN = LS_0051-YUN.
* Spec 코드
      GS_MAIN_DISP_103-SPECCD = LS_0050-SPECCD.
* 도체 Size
      GS_MAIN_DISP_103-COND_SIZE = LS_0050-COND_SIZE.
* 도체 형상
      GS_MAIN_DISP_103-SHAPE = LS_0051-LAYER_SHAPE.
      GS_MAIN_DISP_103-VTEXT = LS_0051-LAYER_SHAPE.

      APPEND GS_MAIN_DISP_103 TO GT_MAIN_DISP_103.
    ENDLOOP.
  ELSE.

    LOOP AT GT_MAIN_DISP_103 ASSIGNING FIELD-SYMBOL(<LS_TEMP>).
* 작업수량
      <LS_TEMP>-MENGE03 = ( <LS_TEMP>-MENGE01 * <LS_TEMP>-YCOEF ) +
                                          <LS_TEMP>-MENGE02.
      PERFORM CONV_ROUND USING 1 CHANGING <LS_TEMP>-MENGE03.

* 권취갯수
      <LS_TEMP>-MENGE05 = <LS_TEMP>-MENGE03 / <LS_TEMP>-MENGE04.
      PERFORM CONV_UPPPER_ROUND USING 1 CHANGING <LS_TEMP>-MENGE05.
    ENDLOOP.
  ENDIF.


  DATA(LT_CHK_SORT) = GT_MAIN_DISP_103.
  SORT LT_CHK_SORT BY MENGE05 DESCENDING.
  READ TABLE LT_CHK_SORT INTO DATA(LS_CHK_SORT) INDEX 1.

  DATA(LT_BACKUP) = GT_MAINTAIN_LENGTH.
  REFRESH GT_MAINTAIN_LENGTH.

  LOOP AT GT_MAIN_DISP_103 ASSIGNING <LS_TEMP>.

    <LS_TEMP>-MENGE05 = LS_CHK_SORT-MENGE05.

* 실권취량 계산 - 권취개수 정해진후 재계산
    <LS_TEMP>-MENGE06 = <LS_TEMP>-MENGE03 / <LS_TEMP>-MENGE05.
* 올림처리
    PERFORM CONV_UPPPER_ROUND USING 1 CHANGING <LS_TEMP>-MENGE06.
* 작업지시량  - 권취개수 정해진후 재계산
    <LS_TEMP>-MENGE07 = <LS_TEMP>-MENGE06 * <LS_TEMP>-MENGE05.
* 올림처리
    PERFORM CONV_UPPPER_ROUND USING 1 CHANGING <LS_TEMP>-MENGE07.

    CLEAR LV_MENGE.
    DO <LS_TEMP>-MENGE05 TIMES.
      ADD 1 TO LV_MENGE.
      APPEND INITIAL LINE TO GT_MAINTAIN_LENGTH ASSIGNING FIELD-SYMBOL(<LS_LENGTH>).
      <LS_LENGTH>-LAYER = <LS_TEMP>-LAYER.
      <LS_LENGTH>-ZTWSEQ = LV_MENGE.
      READ TABLE GT_2012_MAINTAIN ASSIGNING FIELD-SYMBOL(<LS_2012>) WITH KEY ZCAGE = <LS_LENGTH>-LAYER
                                                                                                         ZWSEQ = <LS_LENGTH>-ZTWSEQ.
      IF SY-SUBRC EQ 0.
        <LS_LENGTH>-MENGE = <LS_2012>-INLENGTH + <LS_2012>-ADLENGTH.
      ELSE.
        READ TABLE GT_2012_MAINTAIN ASSIGNING <LS_2012> WITH KEY ZWSEQ = <LS_LENGTH>-ZTWSEQ.
        IF SY-SUBRC EQ 0.
          <LS_LENGTH>-MENGE = 0.
        ELSE.
          READ TABLE LT_BACKUP INTO DATA(LS_BACKUP) WITH KEY LAYER = <LS_TEMP>-LAYER
                                                                                       ZTWSEQ = LV_MENGE.
          IF SY-SUBRC EQ 0.
            <LS_LENGTH>-MENGE = LS_BACKUP-MENGE - LS_BACKUP-MENGE02 + <LS_TEMP>-MENGE02.
            <LS_LENGTH>-MENGE02 = <LS_TEMP>-MENGE02.
          ELSE.
            <LS_LENGTH>-MENGE = <LS_TEMP>-MENGE06.
            <LS_LENGTH>-MENGE02 = <LS_TEMP>-MENGE02.
          ENDIF.
        ENDIF.
      ENDIF.

    ENDDO.

  ENDLOOP.

  DATA(LT_SORT_ZWSEQ) = GT_2012_MAINTAIN.
  SORT LT_SORT_ZWSEQ BY ZTWSEQ DESCENDING.
  READ TABLE LT_SORT_ZWSEQ INTO DATA(LS_SORT_ZWSEQ) INDEX 1.
  IF SY-SUBRC EQ 0.
    IF GS_HEADER_200-ZTWSEQ < LS_SORT_ZWSEQ-ZTWSEQ.
      GS_HEADER_200-ZTWSEQ = LS_SORT_ZWSEQ-ZTWSEQ.
    ENDIF.

  ELSE.
    IF GS_HEADER_200-ZTWSEQ NE LS_CHK_SORT-MENGE05.
      GS_HEADER_200-ZTWSEQ = LS_CHK_SORT-MENGE05.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ITAB_104
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_ITAB_104 .

  DATA : LV_NUM(2) TYPE N.
  DATA : LV_FIELDNAME TYPE FIELDNAME.
  DATA : LS_104_01 TYPE REF TO DATA. " 아이템 2줄로 추가를 위해 아이템 필드 2개 구성
  DATA : LS_104_02 TYPE REF TO DATA. " 아이템 2줄로 추가를 위해 아이템 필드 2개 구성
  DATA : LV_TABIX TYPE I..

  FIELD-SYMBOLS : <LS_LINE01> TYPE ANY,
                  <LS_LINE02> TYPE ANY.

  FIELD-SYMBOLS : <LV_VALUE01> TYPE ANY,
                  <LV_VALUE02> TYPE ANY.

  DEFINE __SET_FIELD_OF_LINE.
    IF <LV_VALUE01> IS ASSIGNED. UNASSIGN <LV_VALUE01>. ENDIF.
    ASSIGN COMPONENT &1 OF STRUCTURE <LS_LINE01> TO <LV_VALUE01>.
    IF <LV_VALUE02> IS ASSIGNED. UNASSIGN <LV_VALUE02>. ENDIF.
    ASSIGN COMPONENT &1 OF STRUCTURE <LS_LINE02> TO <LV_VALUE02>.
  END-OF-DEFINITION.

  CHECK GT_MAIN_DISP_103 IS NOT INITIAL.
  CHECK GS_HEADER_200-ZTWSEQ NE 0.

  PERFORM INIT_104_SCREEN.

  CREATE DATA LS_104_01 LIKE LINE OF <GT_MAIN_DISP_104>.
  CREATE DATA LS_104_02 LIKE LINE OF <GT_MAIN_DISP_104>.
  ASSIGN LS_104_01->* TO <LS_LINE01>.
  ASSIGN LS_104_02->* TO <LS_LINE02>.

  CLEAR : GS_HEADER_200-ARBPL, GS_HEADER_200-ARBPL2, GS_HEADER_200-KTEXT.
  SORT GT_2012_MAINTAIN BY ZCAGE ZWSEQ.
  READ TABLE GT_2012_MAINTAIN INTO DATA(LS_TEMP) INDEX 1.
  GS_HEADER_200-ARBPL = LS_TEMP-ARBPL.
  GS_HEADER_200-ARBPL2 = LS_TEMP-ARBPL.
  IF GS_HEADER_200-ARBPL2 IS NOT INITIAL.
    READ TABLE GT_MAIN_DISP_103 INTO DATA(LS_TEMP_103) INDEX 1.

    SELECT SINGLE WERKS, MATNR, ARBPL, KTEXT
       FROM ZGTCVROUTING
         INTO @DATA(LS_ARBPL)
       WHERE WERKS = @P_WERKS
         AND MATNR = @LS_TEMP_103-MATNR
         AND ARBPL = @GS_HEADER_200-ARBPL2.
    GS_HEADER_200-KTEXT = LS_ARBPL-KTEXT.

  ENDIF.

  LOOP AT GT_MAIN_DISP_103 INTO GS_MAIN_DISP_103.
    CLEAR : <LS_LINE01>, <LS_LINE02>.
    ADD 1 TO LV_TABIX.
*    CAGE
    __SET_FIELD_OF_LINE 'LAYER'.
    <LV_VALUE01> = <LV_VALUE02> = GS_MAIN_DISP_103-LAYER.
*    내부관리 순번( 인덱스)
    __SET_FIELD_OF_LINE 'SEQNO'.
    <LV_VALUE01> = <LV_VALUE02> = LV_TABIX.

*    내부관리 순번( 2라인 컨트롤 위한 순번)
    __SET_FIELD_OF_LINE 'LINE'.
    <LV_VALUE01> = 1.
    <LV_VALUE02> = 2.

*  차수별 데이터 입력
    CLEAR LV_NUM.
    DO GV_ZTWSEQ TIMES.
      ADD 1 TO LV_NUM.
      LV_FIELDNAME = 'FIELDINFOR_' && LV_NUM.
      __SET_FIELD_OF_LINE LV_FIELDNAME.
      PERFORM SE_LINE_TEXT USING GS_MAIN_DISP_103-LAYER LV_NUM GS_MAIN_DISP_103-MATNR
                                  CHANGING <LV_VALUE01> <LV_VALUE02>.
    ENDDO.

    APPEND <LS_LINE01> TO <GT_MAIN_DISP_104>.
    APPEND <LS_LINE02> TO <GT_MAIN_DISP_104>.

  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONV_ROUND
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_1
*&      <-- GS_MAIN_DISP_103_MENGE03
*&      <-- ENDLOOP
*&---------------------------------------------------------------------*
FORM CONV_ROUND  USING    PV_DIGIT
                 CHANGING PV_MENGE.

  DATA : LV_RUNIT TYPE VTBFIMA-RUNIT.
  DATA : LV_VALUE TYPE MENGE_D.

  LV_RUNIT = PV_DIGIT.

  CALL FUNCTION 'FIMA_NUMERICAL_VALUE_ROUND'
    EXPORTING
      I_RTYPE     = ' '
      I_RUNIT     = LV_RUNIT
      I_VALUE     = PV_MENGE
    IMPORTING
      E_VALUE_RND = PV_MENGE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONV_TRUNCATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_1
*&      <-- GS_MAIN_DISP_103_MENGE03
*&      <-- ENDLOOP
*&---------------------------------------------------------------------*
FORM CONV_TRUNCATE  USING    PV_DIGIT
                 CHANGING PV_MENGE.

  DATA : LV_RUNIT TYPE VTBFIMA-RUNIT.
  DATA : LV_VALUE TYPE MENGE_D.

  LV_RUNIT = PV_DIGIT.

  CALL FUNCTION 'FIMA_NUMERICAL_VALUE_ROUND'
    EXPORTING
      I_RTYPE     = '-'
      I_RUNIT     = LV_RUNIT
      I_VALUE     = PV_MENGE
    IMPORTING
      E_VALUE_RND = PV_MENGE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONV_UPPPER_ROUND
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_1
*&      <-- GS_MAIN_DISP_103_MENGE05
*&---------------------------------------------------------------------*
FORM CONV_UPPPER_ROUND  USING    PV_DIGIT
                 CHANGING PV_MENGE.

  DATA : LV_RUNIT TYPE VTBFIMA-RUNIT.
  DATA : LV_VALUE TYPE MENGE_D.

  LV_RUNIT = PV_DIGIT.

  CALL FUNCTION 'FIMA_NUMERICAL_VALUE_ROUND'
    EXPORTING
      I_RTYPE     = '+'
      I_RUNIT     = LV_RUNIT
      I_VALUE     = PV_MENGE
    IMPORTING
      E_VALUE_RND = PV_MENGE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form INIT_104_SCREEN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM INIT_104_SCREEN .


  IF GV_ZTWSEQ = 0 OR GV_ZTWSEQ NE GS_HEADER_200-ZTWSEQ.
    GV_ZTWSEQ = GS_HEADER_200-ZTWSEQ.
    PERFORM SET_FIELDCAT_GRID_0104.
    IF GV_ZTWSEQ > 50.
      PERFORM MAKE_ITAB_FR_FCAT_104.

    ELSE.
      IF <GT_MAIN_DISP_104> IS ASSIGNED. UNASSIGN <GT_MAIN_DISP_104>. ENDIF.
      ASSIGN GT_MAIN_DISP_104 TO <GT_MAIN_DISP_104>.
    ENDIF.

    CREATE DATA GO_MAIN_DISP_104_NUM LIKE <GT_MAIN_DISP_104>.
    ASSIGN GO_MAIN_DISP_104_NUM->* TO <GT_MAIN_DISP_104_NUM>.

    IF GO_GRID_0104 IS BOUND.
      CALL METHOD GO_GRID_0104->SET_TABLE_FOR_FIRST_DISPLAY
        EXPORTING
          IS_LAYOUT            = GS_LAYOUT_0104
          IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0104
        CHANGING
          IT_OUTTAB            = <GT_MAIN_DISP_104>
          IT_SORT              = GT_SORT_0104
          IT_FIELDCATALOG      = GT_FIELDCAT_0104.

    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_ITAB_FR_FCAT_104
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MAKE_ITAB_FR_FCAT_104 .

  FREE GO_MAIN_DISP_104.
  IF <GT_MAIN_DISP_104> IS ASSIGNED. UNASSIGN <GT_MAIN_DISP_104>. ENDIF.

  CALL METHOD CL_ALV_TABLE_CREATE=>CREATE_DYNAMIC_TABLE
    EXPORTING
      I_STYLE_TABLE             = ABAP_TRUE
      IT_FIELDCATALOG           = GT_FIELDCAT_0104
    IMPORTING
      EP_TABLE                  = GO_MAIN_DISP_104
    EXCEPTIONS
      GENERATE_SUBPOOL_DIR_FULL = 1                " At Most 36 Subroutine Pools Can Be Generated Temporarily
      OTHERS                    = 2.
  IF SY-SUBRC <> 0.
    MESSAGE S005 DISPLAY LIKE 'E' WITH 'At Most 36 Subroutine Pools' 'Can Be Generated Temporarily'.
    LEAVE LIST-PROCESSING..
  ENDIF.

  ASSIGN GO_MAIN_DISP_104->* TO <GT_MAIN_DISP_104>.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_GRID_0104
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_0104 .

  DATA : LT_FCAT TYPE SLIS_T_FIELDCAT_ALV.
  DATA : LV_COL_POS TYPE I.
  DATA : LV_COL_POS2 TYPE I.
  DATA : LV_NUM(2) TYPE N.
  DATA : LV_SEQ TYPE I.
  DATA : LV_SEQ_C TYPE C LENGTH 11.
  DATA : LV_FIELDNAME TYPE FIELDNAME.
  DATA : LV_REPTXT TYPE REPTXT.
  DATA : LV_ZWSEQ TYPE ZGTPPT2012-ZWSEQ.


  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME     = SY-REPID
      I_INTERNAL_TABNAME = 'GS_MAIN_DISP_104'
      I_INCLNAME         = 'ZGTPPR2150TOP'
      I_BYPASSING_BUFFER = 'X'
    CHANGING
      CT_FIELDCAT        = LT_FCAT.

  REFRESH GT_FIELDCAT_0104.

  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT
    IMPORTING
      ET_FIELDCAT_LVC = GT_FIELDCAT_0104[]
    TABLES
      IT_DATA         = GT_MAIN_DISP_104.

* 추가필드 세팅

  READ TABLE GT_FIELDCAT_0104 TRANSPORTING NO FIELDS WITH KEY FIELDNAME = 'LAYER'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0104 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    <LS_FCAT>-COL_POS = 1.
    <LS_FCAT>-FIELDNAME = 'LAYER'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = 'CAGE'(F25).
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '10'.
    <LS_FCAT>-OUTPUTLEN = '6'.
    <LS_FCAT>-JUST = 'C'.
  ENDIF.

  READ TABLE GT_FIELDCAT_0104 TRANSPORTING NO FIELDS WITH KEY FIELDNAME = 'SEQNO'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0104 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-COL_POS = 2.
    <LS_FCAT>-FIELDNAME = 'SEQNO'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = <LS_FCAT>-FIELDNAME.
    <LS_FCAT>-DATATYPE = 'INT'.
    <LS_FCAT>-DD_OUTLEN = '10'.
    <LS_FCAT>-NO_OUT = ABAP_TRUE.
  ENDIF.

  READ TABLE GT_FIELDCAT_0104 TRANSPORTING NO FIELDS WITH KEY FIELDNAME = 'LINE'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0104 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-COL_POS = 3.
    <LS_FCAT>-FIELDNAME = 'LINE'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = <LS_FCAT>-FIELDNAME.
    <LS_FCAT>-DATATYPE = 'INT'.
    <LS_FCAT>-DD_OUTLEN = '10'.
    <LS_FCAT>-NO_OUT = ABAP_TRUE.
  ENDIF.

* 차수 필드 세팅
  LV_COL_POS = 100.
  LV_COL_POS2 = 400.
  DO GV_ZTWSEQ TIMES.
    ADD 1 TO LV_NUM.
    ADD 1 TO LV_SEQ.
    ADD 1 TO LV_COL_POS.
    ADD 1 TO LV_COL_POS2.
    LV_FIELDNAME = 'FIELDINFOR_' && LV_NUM.
    LV_SEQ_C = LV_SEQ.
    CONDENSE LV_SEQ_C.

    LV_REPTXT = LV_SEQ_C && '차'.
    CLEAR LV_ZWSEQ.
    LV_ZWSEQ = LV_SEQ.
    READ TABLE GT_2012_MAINTAIN INTO DATA(LS_CHK_ORDNR) WITH KEY ZWSEQ = LV_ZWSEQ.
    IF SY-SUBRC EQ 0.
* 신선오더는 차수별로 동일한 설비로 세팅되므로 하나의 오더로 조회하여 설비조회
      PERFORM CHECK_SET_ARBPL_TEXT USING LS_CHK_ORDNR-ORDNR CHANGING LV_REPTXT.
    ENDIF.

    READ TABLE GT_FIELDCAT_0104 TRANSPORTING NO FIELDS WITH KEY FIELDNAME = LV_FIELDNAME.
    IF SY-SUBRC NE 0.
      APPEND INITIAL LINE TO GT_FIELDCAT_0104 ASSIGNING <LS_FCAT>.
      <LS_FCAT>-COL_POS = LV_COL_POS.
      <LS_FCAT>-FIELDNAME = LV_FIELDNAME.
      <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = LV_REPTXT.
      <LS_FCAT>-DATATYPE = 'CHAR'.
      <LS_FCAT>-DD_OUTLEN = '50'.
      <LS_FCAT>-OUTPUTLEN = '17'.
      <LS_FCAT>-JUST = 'C'.
    ENDIF.


    LV_FIELDNAME = 'MENGE_' && LV_NUM.

    READ TABLE GT_FIELDCAT_0104 TRANSPORTING NO FIELDS WITH KEY FIELDNAME = LV_FIELDNAME.
    IF SY-SUBRC NE 0.
      APPEND INITIAL LINE TO GT_FIELDCAT_0104 ASSIGNING <LS_FCAT>.
      <LS_FCAT>-COL_POS = LV_COL_POS2.
      <LS_FCAT>-FIELDNAME = LV_FIELDNAME.
      <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = LV_REPTXT.
      <LS_FCAT>-REF_TABLE = 'MSEG'.
      <LS_FCAT>-REF_FIELD = 'MENGE'.
      <LS_FCAT>-QUANTITY = 'EA'.
      <LS_FCAT>-JUST = 'R'.
      <LS_FCAT>-NO_OUT = ABAP_TRUE.
    ENDIF.

  ENDDO.

  LOOP AT GT_FIELDCAT_0104 ASSIGNING <LS_FCAT>.
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'SEQNO' OR 'LINE'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
    ENDCASE.

  ENDLOOP.

  SORT GT_FIELDCAT_0104 BY COL_POS.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SE_LINE_TEXT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_MAIN_DISP_103_LAYER
*&      --> LV_NUM
*&      --> GS_MAIN_DISP_103
*&      <-- <LV_VALUE01>
*&      <-- <LV_VALUE02>
*&---------------------------------------------------------------------*
FORM SE_LINE_TEXT  USING  PV_LAYER TYPE ZGTPPT2012-ZCAGE
                                      PV_NUM
                                      PV_MATNR TYPE MATNR
                        CHANGING PV_VALUE01
                                      PV_VALUE02.

  DATA : LV_ZWSEQ TYPE ZGTPPT2012-ZWSEQ.
  DATA : LV_STRING TYPE STRING.
  DATA : LV_VALUE TYPE C LENGTH 30.
  DATA : LV_VALUE2 TYPE P LENGTH 13 DECIMALS 2.
  DATA : LV_VALUE3 TYPE I.
  DATA : LV_ORDNR TYPE ZGTPPT2010-ORDNR.
  DATA : LV_AUFNR TYPE AUFK-AUFNR.
  DATA : LT_TJ02T LIKE TJ02T OCCURS 0 WITH HEADER LINE.
  DATA : LV_STCD TYPE ZORDSTCD.
  DATA : LV_OBJNR TYPE JEST-OBJNR.
  DATA : LV_USER_LINE TYPE BSVX-STTXT.
  DATA : LT_CHARG TYPE RANGE OF MSEG-CHARG .

  LV_ZWSEQ =   PV_NUM + 0.

  READ TABLE GT_2012_MAINTAIN ASSIGNING FIELD-SYMBOL(<LS_2012>) WITH KEY ZCAGE = PV_LAYER
                                                                                                         ZWSEQ = LV_ZWSEQ.
  IF SY-SUBRC EQ 0. " 생산오더 존재 해당 생산오더 내용 매핑
* 1번 라인
    PV_VALUE01 = 'Prd오더'.

    LV_AUFNR = <LS_2012>-ORDNR.
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

    <LS_2012>-STATUS = LV_STCD.

    CASE LV_STCD.
      WHEN 'Z'.
        PV_VALUE01 = PV_VALUE01 && '(E)'.
      WHEN 'E'.
        PV_VALUE01 = PV_VALUE01 && '(D)'.
        <LS_2012>-STATUS = 'E'.
      WHEN 'A'.
        PV_VALUE01 = PV_VALUE01 && '(C)'.
        <LS_2012>-STATUS = 'C'.
      WHEN OTHERS.
        PV_VALUE01 = PV_VALUE01 && '(R)'.
        <LS_2012>-STATUS = 'R'.

*           오더가 작업 완료 상태일때 재고조회
        CASE LV_STCD.
          WHEN 'D' OR 'G' OR 'F' OR 'C'.
            <LS_2012>-CHK_PRD = ABAP_TRUE.
        ENDCASE.

        DATA : BEGIN OF LS_SUM_MSEG,
                 AUFNR LIKE MSEG-AUFNR,
                 AUFPS LIKE MSEG-AUFPS,
                 MENGE LIKE MSEG-MENGE,
               END OF LS_SUM_MSEG.
        DATA : LT_SUM_MSEG LIKE TABLE OF LS_SUM_MSEG.

        DATA : LV_MATNR TYPE MATNR.

        LV_MATNR = PV_MATNR.

        SELECT AUFNR, AUFPS, BWART, CHARG, MENGE
           FROM MSEG
          WHERE MATNR = @LV_MATNR
              AND BWART IN ('101', '102')
              AND AUFNR = @LV_AUFNR
              AND AUFPS = @<LS_2012>-POSNR+2(4)
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
              AND POSNR = @<LS_2012>-POSNR+2(4)
              AND CHARG NE 'GR_ZERO1'
             INTO @DATA(LS_AFPO).
* 오더의 자재입고 완료 여부
          READ TABLE LT_SUM_MSEG INTO LS_SUM_MSEG INDEX 1. " 한건만 존재
          LS_AFPO-PSMNG  = LS_AFPO-PSMNG  + LS_AFPO-PSAMG.
          "입고된 자재수량과 생산오더의 총수량이 같으면 재고 완료 처리.
          IF LS_SUM_MSEG-MENGE > 0.
            <LS_2012>-CHECK_JEGO = ABAP_TRUE.
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
              <LS_2012>-CHECK_ZERO = ABAP_TRUE.
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
              <LS_2012>-CHECK_ZERO = ABAP_TRUE.
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
      IF <LS_2012>-CHECK_JEGO IS INITIAL AND <LS_2012>-CHECK_ZERO IS INITIAL.
        PV_VALUE01 = PV_VALUE01 && '(P/O)'.
      ENDIF.
      <LS_2012>-CHK_PRD = ABAP_TRUE.
    ENDIF.

    CLEAR LV_STRING.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = <LS_2012>-POSNR
      IMPORTING
        OUTPUT = LV_STRING.

    LV_ORDNR = <LS_2012>-ORDNR.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = LV_ORDNR
      IMPORTING
        OUTPUT = LV_ORDNR.

    LV_STRING = LV_ORDNR && '/' && LV_STRING.
    CONCATENATE PV_VALUE01 LV_STRING INTO PV_VALUE01 SEPARATED BY SPACE.

    DATA : LV_MENGE TYPE MSEG-MENGE.
    DATA : LV_MENGE_C TYPE CHAR30.

*    2번 라인
    IF <LS_2012>-CHECK_JEGO IS INITIAL.
      CLEAR LV_VALUE.
      IF <LS_2012>-ADLENGTH NE 0.
        LV_MENGE = <LS_2012>-INLENGTH.
        WRITE LV_MENGE TO LV_MENGE_C UNIT 'EA'.
        CONDENSE LV_MENGE_C.
        LV_VALUE = LV_MENGE_C.

        LV_MENGE = <LS_2012>-ADLENGTH.
        WRITE LV_MENGE TO LV_MENGE_C UNIT 'EA'.
        CONDENSE LV_MENGE_C.

        CONCATENATE LV_VALUE '+' LV_MENGE_C INTO LV_VALUE.

      ELSE.
        LV_MENGE = <LS_2012>-INLENGTH.
        WRITE LV_MENGE TO LV_MENGE_C UNIT 'EA'.
        CONDENSE LV_MENGE_C.
        LV_VALUE = LV_MENGE_C.

      ENDIF.

      CONDENSE LV_VALUE.
      CONCATENATE '(' LV_VALUE INTO PV_VALUE02.

* 조장수
      LV_VALUE3 = <LS_2012>-INFACTOR.
      LV_VALUE = LV_VALUE3.
      CONDENSE LV_VALUE.

      CONCATENATE PV_VALUE02 ')X' LV_VALUE INTO PV_VALUE02.

    ELSE.
      <LS_2012>-CHECK_JEGO = ABAP_TRUE.
      IF <LS_2012>-CHECK_ZERO = ABAP_TRUE.
        LV_VALUE2 = 0.
      ELSE.
        IF LS_AFPO-KDAUF IS NOT INITIAL. " 완제품 수량
          IF LV_KAINS > 0.
            <LS_2012>-CHECK_JEGO = 'Q'.
            LV_VALUE2 = LV_KAINS.
          ELSEIF LV_KASPE > 0.
            <LS_2012>-CHECK_JEGO = 'B'.
            LV_VALUE2 = LV_KASPE.
          ELSE.
            LV_VALUE2 = LV_KALAB.
          ENDIF.
        ELSE.
          IF LV_CINSM > 0.
            <LS_2012>-CHECK_JEGO = 'Q'.
            LV_VALUE2 = LV_CINSM.
          ELSEIF LV_CSPEM > 0.
            <LS_2012>-CHECK_JEGO = 'B'.
            LV_VALUE2 = LV_CSPEM.
          ELSE.
            LV_VALUE2 = LV_CLABS.
          ENDIF.
        ENDIF.
      ENDIF.
      LV_VALUE = LV_VALUE2.
      CONDENSE LV_VALUE.
*  재고수량,
      IF <LS_2012>-CHECK_JEGO = 'Q'.
        CONCATENATE '( QI Stock' LV_VALUE ')' INTO PV_VALUE02 SEPARATED BY SPACE.
      ELSEIF <LS_2012>-CHECK_JEGO = 'B'.
        CONCATENATE '( Block Stock' LV_VALUE ')' INTO PV_VALUE02 SEPARATED BY SPACE.
      ELSE.
        CONCATENATE '( Stock' LV_VALUE ')' INTO PV_VALUE02 SEPARATED BY SPACE.
      ENDIF.
    ENDIF.

  ELSE.

    CLEAR LV_VALUE.

    READ TABLE GT_MAINTAIN_LENGTH INTO GS_MAINTAIN_LENGTH WITH KEY LAYER = PV_LAYER
                                                                                               ZTWSEQ = LV_ZWSEQ.
    IF SY-SUBRC EQ 0.

      IF GS_MAINTAIN_LENGTH-MENGE = 0.
        LV_VALUE = '0'.
      ELSE.

        IF GS_MAINTAIN_LENGTH-MENGE02 NE 0.
          LV_MENGE = GS_MAINTAIN_LENGTH-MENGE - GS_MAINTAIN_LENGTH-MENGE02.
          WRITE LV_MENGE TO LV_MENGE_C UNIT 'EA'.
          CONDENSE LV_MENGE_C.
          LV_VALUE = LV_MENGE_C.

          LV_MENGE = GS_MAINTAIN_LENGTH-MENGE02.
          WRITE LV_MENGE TO LV_MENGE_C UNIT 'EA'.
          CONDENSE LV_MENGE_C.

          CONCATENATE LV_VALUE '+' LV_MENGE_C INTO LV_VALUE.

        ELSE.
          LV_MENGE = GS_MAINTAIN_LENGTH-MENGE.
          WRITE LV_MENGE TO LV_MENGE_C UNIT 'EA'.
          CONDENSE LV_MENGE_C.
          LV_VALUE = LV_MENGE_C.

        ENDIF.
      ENDIF.

      CONDENSE LV_VALUE.
      CONCATENATE '(' LV_VALUE INTO PV_VALUE02.

* 조장수
      LV_VALUE3 = PV_LAYER.
      LV_VALUE = LV_VALUE3.
      CONDENSE LV_VALUE.

      CONCATENATE PV_VALUE02 ')X' LV_VALUE INTO PV_VALUE02.
    ELSE.
      PV_VALUE02 = 0.

    ENDIF.

  ENDIF.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CELL_ATTRIBUTE_GRID_0104
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_CELL_ATTRIBUTE_GRID_0104 .

  DATA : LT_CELLTAB TYPE LVC_T_STYL.
  DATA : LS_CELLTAB TYPE LVC_S_STYL.

  DATA : LV_NUM(2) TYPE N.
  DATA : LV_FIELDNAME TYPE FIELDNAME.
  DATA : LV_INDEX TYPE I.
  DATA : LV_ZWSEQ TYPE ZGTPPT2012-ZTWSEQ.
  DATA : LV_STYLE TYPE LVC_STYLE.

  CONSTANTS : LC_STYLE01 TYPE LVC_STYLE VALUE ALV_STYLE_COLOR_INT_HEADING, " 계획오더(파랑)
              LC_STYLE02 TYPE LVC_STYLE VALUE ALV_STYLE_COLOR_INT_POSITIVE, "생산오더(초록)
              LC_STYLE03 TYPE LVC_STYLE VALUE ALV_STYLE_COLOR_POSITIVE, "판매오더(연초록)
              LC_STYLE04 TYPE LVC_STYLE VALUE ALV_STYLE_COLOR_INT_GROUP, "재고(주황)
              LC_STYLE05 TYPE LVC_STYLE VALUE CL_GUI_ALV_GRID=>MC_STYLE_ENABLED, "열 수정가능
              LC_STYLE06 TYPE LVC_STYLE VALUE ALV_STYLE_FONT_ITALIC, "이탤릭체
              LC_STYLE07 TYPE LVC_STYLE VALUE ALV_STYLE_COLOR_INV_GROUP. "생산완료 자재출고

  FIELD-SYMBOLS <LV_SEQNO> TYPE ANY.
  FIELD-SYMBOLS <LT_CELLTAB> TYPE ANY.

* Macro
  DEFINE __SET_CELL_ATTRIBUTE.
    CLEAR LS_CELLTAB.
    LS_CELLTAB-FIELDNAME = &1.
    LS_CELLTAB-STYLE = &2.
    INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
  END-OF-DEFINITION.

  DEFINE __ASSIGN_FIELD_SEQNO.
    IF <LV_SEQNO> IS ASSIGNED. UNASSIGN <LV_SEQNO>. ENDIF.
    ASSIGN COMPONENT 'SEQNO' OF STRUCTURE <LS_MAIN> TO <LV_SEQNO>.
  END-OF-DEFINITION.

  LOOP AT <GT_MAIN_DISP_104> ASSIGNING FIELD-SYMBOL(<LS_MAIN>).
    CLEAR LS_CELLTAB.
    REFRESH LT_CELLTAB.

    __SET_CELL_ATTRIBUTE 'LAYER'  ALV_STYLE_ALIGN_CENTER_CENTER.

    __ASSIGN_FIELD_SEQNO.
    READ TABLE GT_MAIN_DISP_103 INTO GS_MAIN_DISP_103 INDEX <LV_SEQNO>.
    CLEAR LV_ZWSEQ.
    CLEAR LV_NUM.
    DO GV_ZTWSEQ TIMES.
      ADD 1 TO LV_ZWSEQ.
      ADD 1 TO LV_NUM.
      CLEAR LV_STYLE.
      CLEAR LV_FIELDNAME.
      LV_FIELDNAME = 'FIELDINFOR_' && LV_NUM.
      LV_STYLE = ALV_STYLE_ALIGN_LEFT_CENTER.

      READ TABLE GT_2012_MAINTAIN ASSIGNING FIELD-SYMBOL(<LS_2012>) WITH KEY ZCAGE = GS_MAIN_DISP_103-LAYER
                                                                                                          ZWSEQ = LV_ZWSEQ.
      IF SY-SUBRC EQ 0.
        IF <LS_2012>-CHECK_JEGO IS NOT INITIAL AND <LS_2012>-CHECK_ZERO = ABAP_TRUE. " 생산완료, 자재 출고
          CLEAR LS_CELLTAB.
          LV_STYLE = LV_STYLE + LC_STYLE07 + LC_STYLE06.
          __SET_CELL_ATTRIBUTE LV_FIELDNAME LV_STYLE.
          INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
        ELSEIF  <LS_2012>-CHECK_JEGO IS NOT INITIAL AND <LS_2012>-CHECK_ZERO = ABAP_FALSE. "생산완료,재고상태
          IF <LS_2012>-CHECK_JEGO = 'Q'.
            LV_STYLE = LV_STYLE + ALV_STYLE_COLOR_POSITIVE.
            __SET_CELL_ATTRIBUTE LV_FIELDNAME LV_STYLE.
          ELSE.
            LV_STYLE = LV_STYLE + LC_STYLE04.
            __SET_CELL_ATTRIBUTE LV_FIELDNAME LV_STYLE.
          ENDIF.
        ELSE.
          LV_STYLE = LV_STYLE + LC_STYLE02.
          __SET_CELL_ATTRIBUTE LV_FIELDNAME LV_STYLE.
        ENDIF.

      ELSE.
        __SET_CELL_ATTRIBUTE LV_FIELDNAME LV_STYLE.
      ENDIF.

    ENDDO.


    IF <LT_CELLTAB> IS ASSIGNED. UNASSIGN <LT_CELLTAB>. ENDIF.
    ASSIGN COMPONENT 'XYZSTYLEZYX' OF STRUCTURE <LS_MAIN> TO <LT_CELLTAB>.
    IF <LT_CELLTAB> IS ASSIGNED.
      <LT_CELLTAB> = LT_CELLTAB.
    ENDIF.

  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ZTWSEQ
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_ZTWSEQ .

  READ TABLE GT_MAIN_DISP_103 INTO GS_MAIN_DISP_103 INDEX 1.
  IF GS_HEADER_200-ZTWSEQ < GS_MAIN_DISP_103-MENGE05.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '차수 변경은 권취개수보다 작을수 없습니다.'(E04).
    RETURN.
  ENDIF.

  IF <GT_MAIN_DISP_104> IS ASSIGNED.
    REFRESH <GT_MAIN_DISP_104>.
  ENDIF.

  PERFORM SET_ITAB_104.
  IF GO_GRID_0104 IS BOUND.
    PERFORM REFRESH_GRID USING GO_GRID_0104.
  ENDIF.

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
  DATA : LV_FIELDNAME TYPE FIELDNAME.
  DATA : LV_INDEX TYPE I.
  DATA : LV_ZWSEQ TYPE ZGTPPT2012-ZTWSEQ.

  FIELD-SYMBOLS <LV_SEQNO> TYPE ANY.
  FIELD-SYMBOLS <LT_CELLTAB> TYPE ANY.

* Macro
  DEFINE __SET_CELL_ATTRIBUTE.
    CLEAR LS_CELLTAB.
    LS_CELLTAB-FIELDNAME = &1.
    LS_CELLTAB-STYLE = &2.
    INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
  END-OF-DEFINITION.

  DEFINE __ASSIGN_FIELD_SEQNO.
    IF <LV_SEQNO> IS ASSIGNED. UNASSIGN <LV_SEQNO>. ENDIF.
    ASSIGN COMPONENT 'SEQNO' OF STRUCTURE <LS_MAIN> TO <LV_SEQNO>.
  END-OF-DEFINITION.

  DATA(LT_TEMP) = GT_2012_MAINTAIN.
  SORT LT_TEMP BY ZWSEQ DESCENDING.
  READ TABLE LT_TEMP INTO DATA(LS_TEMP) INDEX 1.

  LOOP AT <GT_MAIN_DISP_104_NUM> ASSIGNING FIELD-SYMBOL(<LS_MAIN>).
    CLEAR LS_CELLTAB.
    REFRESH LT_CELLTAB.

    __SET_CELL_ATTRIBUTE 'LAYER'  ALV_STYLE_ALIGN_CENTER_CENTER.

    __ASSIGN_FIELD_SEQNO.
    READ TABLE GT_MAIN_DISP_103 INTO GS_MAIN_DISP_103 INDEX <LV_SEQNO>.
    CLEAR LV_ZWSEQ.
    CLEAR LV_NUM.
    DO GV_ZTWSEQ TIMES.
      ADD 1 TO LV_ZWSEQ.
      ADD 1 TO LV_NUM.

      CLEAR LV_FIELDNAME.
      LV_FIELDNAME = 'MENGE_' && LV_NUM.

      READ TABLE GT_2012_MAINTAIN TRANSPORTING NO FIELDS WITH KEY ZWSEQ = LV_ZWSEQ.

      IF SY-SUBRC EQ 0.
        __SET_CELL_ATTRIBUTE LV_FIELDNAME ALV_STYLE_DISABLED.
      ELSE.
        __SET_CELL_ATTRIBUTE LV_FIELDNAME ALV_STYLE_ENABLED.
      ENDIF.

    ENDDO.


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

  PERFORM SET_SORT_TAB TABLES GT_SORT_0201
                            USING : 1 'SEQNO' 'X' '' '',
                                       2 'LINE'  'X' '' ''.


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
*& Form SET_OBJECT_GRID_0201
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GRID_0201 .

  CREATE OBJECT GO_CONTAIN_0201
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

  CREATE OBJECT GO_GRID_0201
    EXPORTING
      I_PARENT      = GO_CONTAIN_0201
      I_APPL_EVENTS = ABAP_TRUE.

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
      IS_LAYOUT            = GS_LAYOUT_0104
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0201
    CHANGING
      IT_OUTTAB            = <GT_MAIN_DISP_104_NUM>
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


ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  F4_ARBPL  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE F4_ARBPL INPUT.

  PERFORM F4_ARBPL.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Form F4_ARBPL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM F4_ARBPL .

  DATA : BEGIN OF LS_ARBPL,
           WERKS TYPE ZGTCVROUTING-WERKS,
           MATNR TYPE ZGTCVROUTING-MATNR,
           ARBPL TYPE ZGTCVROUTING-ARBPL,
           KTEXT TYPE ZGTCVROUTING-KTEXT,
         END OF LS_ARBPL.
  DATA : LT_ARBPL LIKE TABLE OF LS_ARBPL.

  DATA : LT_RETURN_TAB TYPE TABLE OF DDSHRETVAL,
         LS_RETURN_TAB LIKE LINE OF LT_RETURN_TAB.

  DATA : LV_LINE       LIKE SY-STEPL,
         LT_DYNPFIELDS LIKE TABLE OF DYNPREAD.

  READ TABLE GT_MAIN_DISP_103 INTO DATA(LS_TEMP) INDEX 1.

  SELECT WERKS, MATNR, ARBPL, KTEXT
     FROM ZGTCVROUTING
       INTO CORRESPONDING FIELDS OF TABLE @LT_ARBPL
     WHERE WERKS = @P_WERKS
       AND MATNR = @LS_TEMP-MATNR.

  SORT LT_ARBPL BY ARBPL.
  DELETE ADJACENT DUPLICATES FROM LT_ARBPL COMPARING ARBPL.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'  "F4 창 띄움
    EXPORTING
      RETFIELD        = 'ARBPL'
*     DYNPPROG        = SY-CPROG                 "현재 프로그램명->ZTER0010
*     DYNPNR          = SY-DYNNR                 "현재 화면번호->0100
      DYNPROFIELD     = 'GS_HEADER_200-ARBPL'           "F4누른 필드->DEPT_CD
      VALUE_ORG       = 'S'                      "가져오는 엔트리가 다수일 경우인 것 같음. 다수일 경우 C로 하면 F4 안뜸
      WINDOW_TITLE    = '설비 조회'   "Search Help 타이틀
      DISPLAY         = 'F'
    TABLES
      VALUE_TAB       = LT_ARBPL                  "부서코드, 부서명 가져온 인터널 테이블
      RETURN_TAB      = LT_RETURN_TAB            "F4에서 선택한 값이 들어옴
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  READ TABLE LT_RETURN_TAB INTO LS_RETURN_TAB INDEX 1.
  IF SY-SUBRC EQ 0.
    READ TABLE LT_ARBPL INTO LS_ARBPL WITH KEY ARBPL = LS_RETURN_TAB-FIELDVAL.

    GS_HEADER_200-ARBPL = LS_ARBPL-ARBPL.
    GS_HEADER_200-KTEXT = LS_ARBPL-KTEXT.

    REFRESH LT_DYNPFIELDS.
    PERFORM GET_STEPL USING LV_LINE.
*  설비
    APPEND INITIAL LINE TO LT_DYNPFIELDS ASSIGNING FIELD-SYMBOL(<LS_DYNPFIELDS>).
    <LS_DYNPFIELDS>-FIELDNAME = 'GS_HEADER_200-ARBPL'.
    <LS_DYNPFIELDS>-STEPL = LV_LINE.
    <LS_DYNPFIELDS>-FIELDVALUE = LS_ARBPL-ARBPL.

*  설비명
    APPEND INITIAL LINE TO LT_DYNPFIELDS ASSIGNING <LS_DYNPFIELDS>.
    <LS_DYNPFIELDS>-FIELDNAME = 'GS_HEADER_200-KTEXT'.
    <LS_DYNPFIELDS>-STEPL = LV_LINE.
    <LS_DYNPFIELDS>-FIELDVALUE = LS_ARBPL-KTEXT.

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
    WHEN GO_GRID_0104.
*      IF GT_ITEM_DISP[] IS INITIAL.
      PERFORM SET_TOOLBAR TABLES PO_OBJECT->MT_TOOLBAR
                           USING : 'CHG_MENGE' ICON_CHANGE '작업량수정' '작업량수정' 0,
                                       '' '' '' '' 3,
                                      'ALLSEL' ICON_SELECT_ALL '전체선택' '전체선택' 0,
                                      'DESEL' ICON_DESELECT_ALL '선택해제' '선택해제' 0,
                                       '' '' '' '' 3,
                                      'CREATE' ICON_EXECUTE_OBJECT '생산오더생성' '생산오더생성' 0,
*                                      'RELEASE' ICON_RELEASE '생산오더릴리즈' '생산오더릴리즈' 0 ,
                                      'DELE' ICON_DELETE '오더삭제' '오더삭제' 0,
                                      '' '' '' '' 3.    " " 재생산 오더 전환은 추후 재이관 예정

    WHEN GO_GRID_1103.

      PERFORM SET_TOOLBAR TABLES PO_OBJECT->MT_TOOLBAR
                                 USING : 'CHG_MENGE' ICON_CHANGE '작업량수정' '작업량수정' 0,
                                            '' '' '' '' 3,
                                            'CREATE' ICON_EXECUTE_OBJECT '생산오더생성' '생산오더생성' 0,
                                             '' '' '' '' 3,
                                            'CRT_PO' ICON_IMPORT_ALL_REQUESTS '구매오더(사급O)' '구매오더(사급O)' 0,
                                            'CRT_PR' ICON_IMPORT_ALL_REQUESTS '구매요청(사급X)' '구매요청(사급X)' 0,
                                            '' '' '' '' 3,    " " 재생산 오더 전환은 추후 재이관 예정
                                            'DELE' ICON_DELETE '오더삭제' '오더삭제' 0.

    WHEN GO_GRID_0404.
*      IF GT_ITEM_DISP[] IS INITIAL.
      PERFORM SET_TOOLBAR TABLES PO_OBJECT->MT_TOOLBAR
                           USING : 'CHG_MENGE' ICON_CHANGE '작업량수정' '작업량수정' 0,
                                       '' '' '' '' 3,
                                      'ALLSEL' ICON_SELECT_ALL '전체선택' '전체선택' 0,
                                      'DESEL' ICON_DESELECT_ALL '선택해제' '선택해제' 0,
                                       '' '' '' '' 3,
                                      'CREATE' ICON_EXECUTE_OBJECT '생산오더생성' '생산오더생성' 0,
*                                      'RELEASE' ICON_RELEASE '생산오더릴리즈' '생산오더릴리즈' 0 ,
                                      'DELE' ICON_DELETE '오더삭제' '오더삭제' 0,
                                      '' '' '' '' 3,    " " 재생산 오더 전환은 추후 재이관 예정
                                      'CHG_SULBI' ICON_TOOLS '설비변경' '설비변경' 0.

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
*& Form SET_FIELDCAT_GRID_0201
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_0201 .

  REFRESH GT_FIELDCAT_0201.
  MOVE-CORRESPONDING GT_FIELDCAT_0104 TO GT_FIELDCAT_0201.

  LOOP AT GT_FIELDCAT_0201 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    IF <LS_FCAT>-COL_POS BETWEEN 100 AND 399.
      <LS_FCAT>-NO_OUT = ABAP_TRUE.
    ENDIF.

    IF <LS_FCAT>-COL_POS > 400.
      CLEAR <LS_FCAT>-NO_OUT.
    ENDIF.

  ENDLOOP.

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
    WHEN GO_GRID_0104.
      CASE PV_UCOMM.
        WHEN 'CHG_MENGE'. "작업량 수정
          PERFORM PROC_CHG_MENGE.
        WHEN 'CREATE'. " 생산오더생성
          PERFORM PROC_CREATE_ORDER.
        WHEN 'RELEASE'. " 생산오더 릴리즈
          PERFORM PROC_RELEASE_ORDER.
        WHEN 'DELE'. "
          PERFORM PROC_DELETE_ORDER.
        WHEN 'ALLSEL'.
          PERFORM PROCESS_ALLSELECT.
        WHEN 'DESEL'.
          PERFORM PROCESS_DESELECT.
      ENDCASE.
    WHEN GO_GRID_1103.
      CASE PV_UCOMM.
        WHEN 'CHG_MENGE'. "작업량 수정
          PERFORM PROC_CHG_MENGE_1100.
        WHEN 'CREATE'. " 생산오더생성
          PERFORM PROC_CREATE_ORDER_1100.
        WHEN 'CRT_PO'. " 구매오더(사급O)
          PERFORM PROC_CREATE_PO_1100.
        WHEN 'CRT_PR'. "구매요청(사급X)
          PERFORM PROC_CREATE_PR_1100.
        WHEN 'DELE'. "오더삭제
          PERFORM PROC_DELETE_ORDER_1100.
      ENDCASE.


    WHEN GO_GRID_0404.
      CASE PV_UCOMM.
        WHEN 'CHG_MENGE'. "작업량 수정
          PERFORM PROC_CHG_MENGE_400.
        WHEN 'CREATE'. " 생산오더생성
          PERFORM PROC_CREATE_ORDER_400.
        WHEN 'RELEASE'. " 생산오더 릴리즈
          PERFORM PROC_RELEASE_ORDER_400.
        WHEN 'DELE'. "
          PERFORM PROC_DELETE_ORDER_400.
        WHEN 'ALLSEL'.
          PERFORM PROCESS_ALLSELECT_400.
        WHEN 'DESEL'.
          PERFORM PROCESS_DESELECT_400.
        WHEN 'CHG_SULBI'. "설비변경
          PERFORM PROCESS_CHG_SULBI_400.
      ENDCASE.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_CHG_MENGE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_CHG_MENGE .

  DATA : LV_NUM(2) TYPE N.
  DATA : LV_FIELDNAME TYPE FIELDNAME.
  DATA : LS_104_01 TYPE REF TO DATA. " 아이템 2줄로 추가를 위해 아이템 필드 2개 구성
  DATA : LV_TABIX TYPE I..
  DATA : LV_ZWSEQ TYPE ZGTPPT2012-ZWSEQ.

  FIELD-SYMBOLS : <LS_LINE01> TYPE ANY.
  FIELD-SYMBOLS : <LV_VALUE01> TYPE ANY.

  DEFINE __SET_FIELD_OF_LINE.
    IF <LV_VALUE01> IS ASSIGNED. UNASSIGN <LV_VALUE01>. ENDIF.
    ASSIGN COMPONENT &1 OF STRUCTURE <LS_LINE01> TO <LV_VALUE01>.
  END-OF-DEFINITION.

  CREATE DATA LS_104_01 LIKE LINE OF <GT_MAIN_DISP_104_NUM>.
  ASSIGN LS_104_01->* TO <LS_LINE01>.

  REFRESH <GT_MAIN_DISP_104_NUM>.

  SORT GT_2012_MAINTAIN BY ZCAGE ZWSEQ.
  SORT GT_MAINTAIN_LENGTH BY LAYER ZTWSEQ.

  LOOP AT GT_MAIN_DISP_103 INTO GS_MAIN_DISP_103.
    CLEAR : <LS_LINE01>.
    ADD 1 TO LV_TABIX.
*    CAGE
    __SET_FIELD_OF_LINE 'LAYER'.
    <LV_VALUE01> = GS_MAIN_DISP_103-LAYER.
*    내부관리 순번( 인덱스)
    __SET_FIELD_OF_LINE 'SEQNO'.
    <LV_VALUE01> = LV_TABIX.

*    내부관리 순번( 2라인 컨트롤 위한 순번)
    __SET_FIELD_OF_LINE 'LINE'.
    <LV_VALUE01> = 1.

*  차수별 데이터 입력
    CLEAR LV_NUM.
    DO GV_ZTWSEQ TIMES.
      ADD 1 TO LV_NUM.
      LV_FIELDNAME = 'MENGE_' && LV_NUM.
      __SET_FIELD_OF_LINE LV_FIELDNAME.

      LV_ZWSEQ = LV_NUM + 0.

      READ TABLE GT_MAINTAIN_LENGTH INTO DATA(LS_MENGE) WITH KEY LAYER = GS_MAIN_DISP_103-LAYER
                                                                                 ZTWSEQ = LV_ZWSEQ.
      IF SY-SUBRC EQ 0.
        <LV_VALUE01> = LS_MENGE-MENGE.
      ENDIF.
    ENDDO.

    APPEND <LS_LINE01> TO <GT_MAIN_DISP_104_NUM>.
  ENDLOOP.

  CLEAR GV_CHK_CONFIRM_201.
  CALL SCREEN '0201' STARTING AT 5 5 ENDING AT 120 12.

  IF GV_CHK_CONFIRM_201 IS INITIAL.
    RETURN.
  ENDIF.

  LOOP AT <GT_MAIN_DISP_104_NUM> ASSIGNING <LS_LINE01>.
    CLEAR LV_NUM.
*    내부관리 순번( 인덱스)
    __SET_FIELD_OF_LINE 'SEQNO'.
    READ TABLE GT_MAIN_DISP_103 INTO GS_MAIN_DISP_103 INDEX <LV_VALUE01>.
    DO GV_ZTWSEQ TIMES.
      ADD 1 TO LV_NUM.
      LV_FIELDNAME = 'MENGE_' && LV_NUM.
      __SET_FIELD_OF_LINE LV_FIELDNAME.

      LV_ZWSEQ = LV_NUM + 0.

      READ TABLE GT_MAINTAIN_LENGTH ASSIGNING FIELD-SYMBOL(<LS_MENGE>) WITH KEY LAYER = GS_MAIN_DISP_103-LAYER
                                                                                 ZTWSEQ = LV_ZWSEQ.
      IF SY-SUBRC EQ 0.
        <LS_MENGE>-MENGE = <LV_VALUE01>.
      ELSE.
        IF <LV_VALUE01> NE 0.
          APPEND INITIAL LINE TO GT_MAINTAIN_LENGTH ASSIGNING <LS_MENGE>.
          <LS_MENGE>-LAYER = GS_MAIN_DISP_103-LAYER.
          <LS_MENGE>-ZTWSEQ = LV_ZWSEQ.
          <LS_MENGE>-MENGE = <LV_VALUE01>.
        ENDIF.
      ENDIF.
    ENDDO.

  ENDLOOP.

  REFRESH <GT_MAIN_DISP_104>.

  PERFORM SET_ITAB_104.

  IF GO_GRID_0104 IS BOUND.
    PERFORM REFRESH_GRID USING GO_GRID_0104.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_CREATE_ORDER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_CREATE_ORDER .

  DATA : LT_COLUMN TYPE LVC_T_COL.
  DATA : LV_STRING TYPE STRING.
  DATA : LV_NUM(2) TYPE N.
  DATA : LV_ZWSEQ TYPE ZGTPPT2012-ZWSEQ.
  DATA : BEGIN OF LS_CREATE,
           ZWSEQ TYPE ZGTPPT2012-ZWSEQ,
         END OF LS_CREATE.
  DATA : LT_CREATE LIKE TABLE OF LS_CREATE.
  DATA : LV_CHK_CREATE.
  DATA : LV_SGRPNR TYPE ZGTESGRPNR.


  GO_GRID_0104->GET_SELECTED_COLUMNS(
    IMPORTING
      ET_INDEX_COLUMNS = LT_COLUMN ).                " Cell IDs

  IF LT_COLUMN[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '선택된 컬럼이 없습니다.'(E05).
    RETURN.
  ENDIF.

  LOOP AT LT_COLUMN INTO DATA(LS_COLUMN).
    CLEAR LV_CHK_CREATE.
    SPLIT LS_COLUMN-FIELDNAME AT  '_'  INTO TABLE DATA(LT_STRING).
    READ TABLE LT_STRING INTO DATA(LS_STRING) INDEX 1.
    LV_STRING = LS_STRING.
    IF LV_STRING NE 'FIELDINFOR'.
      MESSAGE S003 DISPLAY LIKE 'E' WITH '차수가 아닌 컬럼이 선택되었습니다.'(E06).
      RETURN.
    ENDIF.

    READ TABLE LT_STRING INTO LS_STRING INDEX 2.
    LV_NUM = LS_STRING.
    LV_ZWSEQ = LV_NUM + 0.

    LOOP AT GT_MAINTAIN_LENGTH INTO GS_MAINTAIN_LENGTH WHERE ZTWSEQ = LV_ZWSEQ.
      IF GS_MAINTAIN_LENGTH-MENGE > 0.
        LV_CHK_CREATE = ABAP_TRUE.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF LV_CHK_CREATE IS INITIAL.
      MESSAGE S003 DISPLAY LIKE 'E' WITH '작업량이 입력되지 않은 내역이 있습니다.'(E07).
      RETURN.
    ENDIF.

    READ TABLE GT_2012_MAINTAIN TRANSPORTING NO FIELDS WITH KEY ZWSEQ = LV_ZWSEQ.
    IF SY-SUBRC NE 0.
      APPEND INITIAL LINE TO LT_CREATE ASSIGNING FIELD-SYMBOL(<LS_CREATE>).
      <LS_CREATE>-ZWSEQ = LV_ZWSEQ.
    ENDIF.
  ENDLOOP.

  IF LT_CREATE[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '생산오더 생성가능한 차수가 없습니다.'(E08).
    RETURN.
  ENDIF.

*  IF GS_HEADER_200-ARBPL IS INITIAL.
*    MESSAGE S003 DISPLAY LIKE 'E' WITH '대상설비는 필수 필드 입니다.'(E09).
*    RETURN.
*  ENDIF.


  CLEAR GV_ANSWER.
  PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
    ' '
    '선택된 차수의 생산오더 생성합니다. 계속 진행 하시겠습니까?'
    '생성확인'.
  IF GV_ANSWER NE 'J'.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
    RETURN.
  ENDIF.


* 오더 생성을 위한 데이터 생성
  DATA : LT_2011 TYPE TABLE OF ZGTPPT2011.
  DATA : LT_2012 TYPE TABLE OF ZGTPPT2012.
  DATA : LT_2013 TYPE TABLE OF ZGTPPT2013.
  DATA : LT_2014 TYPE TABLE OF ZGTPPT2014.
  DATA : LV_CHK_ERR.

  REFRESH GT_PRD_ORDERS.

  PERFORM MAKE_DATA_TO_SAVE01 TABLES LT_2011 LT_2013 LT_2014 CHANGING LV_SGRPNR LV_CHK_ERR.

  IF LV_CHK_ERR IS INITIAL.
    READ TABLE LT_2011 INTO DATA(LS_2011) INDEX 1.

    LOOP AT LT_CREATE INTO LS_CREATE.
      PERFORM MAKE_DATA_TO_SAVE02 TABLES LT_2012 USING LS_CREATE-ZWSEQ LV_SGRPNR LS_2011-ZZBUNDLE
                                                     CHANGING LV_CHK_ERR.
      IF LV_CHK_ERR = ABAP_TRUE.
        EXIT.
      ENDIF.

    ENDLOOP.
  ENDIF.

  IF LV_CHK_ERR = ABAP_TRUE.
    DATA : LS_RETURN2 TYPE BAPIRET2.
    DATA : LT_DETAIL_RETURN TYPE BAPI_ORDER_RETURN_TT.
    CALL FUNCTION 'BAPI_PRODORD_SET_DELETION_FLAG'
      IMPORTING
        RETURN        = LS_RETURN2
      TABLES
        ORDERS        = GT_PRD_ORDERS
        DETAIL_RETURN = LT_DETAIL_RETURN.
  ENDIF.

  IF LV_SGRPNR IS INITIAL.
    DATA : LV_CHK_NEW.
    LV_CHK_NEW = ABAP_TRUE.

    PERFORM GET_NUM_SGRPNR CHANGING LV_SGRPNR LV_CHK_ERR.
    IF LV_CHK_ERR = ABAP_TRUE.
      RETURN.
    ENDIF.

    LOOP AT LT_2011 ASSIGNING FIELD-SYMBOL(<LS_2011>).
      <LS_2011>-SGRPNR = LV_SGRPNR.
    ENDLOOP.

    LOOP AT LT_2012 ASSIGNING FIELD-SYMBOL(<LS_2012>).
      <LS_2012>-SGRPNR = LV_SGRPNR.
    ENDLOOP.

    LOOP AT LT_2013 ASSIGNING FIELD-SYMBOL(<LS_2013>).
      <LS_2013>-SGRPNR = LV_SGRPNR.
    ENDLOOP.

    LOOP AT LT_2014 ASSIGNING FIELD-SYMBOL(<LS_2014>).
      <LS_2014>-SGRPNR = LV_SGRPNR.
    ENDLOOP.

  ENDIF.


  IF LV_CHK_NEW IS INITIAL.
    DELETE FROM ZGTPPT2011 WHERE SGRPNR = LV_SGRPNR.
    IF SY-SUBRC NE 0.
      ROLLBACK WORK.
      CALL FUNCTION 'BAPI_PRODORD_SET_DELETION_FLAG'
        IMPORTING
          RETURN        = LS_RETURN2
        TABLES
          ORDERS        = GT_PRD_ORDERS
          DETAIL_RETURN = LT_DETAIL_RETURN.
      MESSAGE S003 DISPLAY LIKE 'E' WITH '생산오더 생성중 오류 발생하였습니다.'(e12).
      RETURN.

    ENDIF.

    DELETE FROM ZGTPPT2013 WHERE SGRPNR = LV_SGRPNR.
    IF SY-SUBRC NE 0.
      ROLLBACK WORK.
      CALL FUNCTION 'BAPI_PRODORD_SET_DELETION_FLAG'
        IMPORTING
          RETURN        = LS_RETURN2
        TABLES
          ORDERS        = GT_PRD_ORDERS
          DETAIL_RETURN = LT_DETAIL_RETURN.
      MESSAGE S003 DISPLAY LIKE 'E' WITH '생산오더 생성중 오류 발생하였습니다.'(e12).
      RETURN.
    ENDIF.

    DELETE FROM ZGTPPT2014 WHERE SGRPNR = LV_SGRPNR.
    IF SY-SUBRC NE 0.
      ROLLBACK WORK.
      CALL FUNCTION 'BAPI_PRODORD_SET_DELETION_FLAG'
        IMPORTING
          RETURN        = LS_RETURN2
        TABLES
          ORDERS        = GT_PRD_ORDERS
          DETAIL_RETURN = LT_DETAIL_RETURN.
      MESSAGE S003 DISPLAY LIKE 'E' WITH '생산오더 생성중 오류 발생하였습니다.'(e12).
      RETURN.
    ENDIF.


  ENDIF.

  MODIFY ZGTPPT2011 FROM TABLE LT_2011.
  IF SY-SUBRC NE 0.
    ROLLBACK WORK.
    CALL FUNCTION 'BAPI_PRODORD_SET_DELETION_FLAG'
      IMPORTING
        RETURN        = LS_RETURN2
      TABLES
        ORDERS        = GT_PRD_ORDERS
        DETAIL_RETURN = LT_DETAIL_RETURN.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '생산오더 생성중 오류 발생하였습니다.'(e12).
    RETURN.
  ENDIF.

  MODIFY ZGTPPT2012 FROM TABLE LT_2012.
  IF SY-SUBRC NE 0.
    ROLLBACK WORK.
    CALL FUNCTION 'BAPI_PRODORD_SET_DELETION_FLAG'
      IMPORTING
        RETURN        = LS_RETURN2
      TABLES
        ORDERS        = GT_PRD_ORDERS
        DETAIL_RETURN = LT_DETAIL_RETURN.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '생산오더 생성중 오류 발생하였습니다.'(e12).
    RETURN.
  ENDIF.

  MODIFY ZGTPPT2013 FROM TABLE LT_2013.
  IF SY-SUBRC NE 0.
    ROLLBACK WORK.
    CALL FUNCTION 'BAPI_PRODORD_SET_DELETION_FLAG'
      IMPORTING
        RETURN        = LS_RETURN2
      TABLES
        ORDERS        = GT_PRD_ORDERS
        DETAIL_RETURN = LT_DETAIL_RETURN.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '생산오더 생성중 오류 발생하였습니다.'(e12).
    RETURN.
  ENDIF.

  MODIFY ZGTPPT2014 FROM TABLE LT_2014.
  IF SY-SUBRC NE 0.
    ROLLBACK WORK.
    CALL FUNCTION 'BAPI_PRODORD_SET_DELETION_FLAG'
      IMPORTING
        RETURN        = LS_RETURN2
      TABLES
        ORDERS        = GT_PRD_ORDERS
        DETAIL_RETURN = LT_DETAIL_RETURN.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '생산오더 생성중 오류 발생하였습니다.'(e12).
    RETURN.
  ENDIF.

  DELETE GT_2011 WHERE SGRPNR = LV_SGRPNR.
  APPEND LINES OF LT_2011 TO GT_2011.

  DELETE GT_2013 WHERE SGRPNR = LV_SGRPNR.
  APPEND LINES OF LT_2013 TO GT_2013.

  APPEND LINES OF LT_2012 TO GT_2012.

  REFRESH GT_ZZBUNDLE.
  LOOP AT LT_2011 INTO DATA(LS_2011_MODI).
    APPEND INITIAL LINE TO GT_ZZBUNDLE ASSIGNING FIELD-SYMBOL(<LS_ZZBUNDLE>).
    <LS_ZZBUNDLE>-SIGN = 'I'.
    <LS_ZZBUNDLE>-OPTION = 'EQ'.
    <LS_ZZBUNDLE>-LOW = LS_2011_MODI-ZZBUNDLE.
  ENDLOOP.

  SORT GT_ZZBUNDLE BY LOW.
  DELETE ADJACENT DUPLICATES FROM GT_ZZBUNDLE COMPARING LOW.
  PERFORM SENG_LOG_BWD.

  IF <GT_MAIN_DISP_104> IS ASSIGNED.
    REFRESH <GT_MAIN_DISP_104>.
  ENDIF.

  PERFORM SET_ITAB_103.
  PERFORM REFRESH_GRID USING GO_GRID_0103.
  PERFORM SET_ITAB_104.
  IF GO_GRID_0104 IS BOUND.
    PERFORM REFRESH_GRID USING GO_GRID_0104.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_DATA_TO_SAVE01
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_2011
*&      --> LT_2013
*&---------------------------------------------------------------------*
FORM MAKE_DATA_TO_SAVE01  TABLES   PT_2011 STRUCTURE ZGTPPT2011
                                   PT_2013 STRUCTURE ZGTPPT2013
                                   PT_2014 STRUCTURE ZGTPPT2014
                                    CHANGING PV_SGRPNR TYPE ZGTESGRPNR
                                               PV_CHK_ERR.

  DATA : LT_2013 TYPE TABLE OF ZGTPPT2013.
  DATA : LT_2014 TYPE TABLE OF ZGTPPT2014.
  DATA : LS_2013 TYPE ZGTPPT2013.
  DATA : LS_2014 TYPE ZGTPPT2014.
  DATA : LV_SGRPNR TYPE ZGTESGRPNR.
  DATA : LT_GRPNR TYPE RANGE OF ZGTPPT2013-GRPNR.

  LT_GRPNR = VALUE #( FOR LW_MAIN IN GT_MAIN_DISP_101 WHERE ( GRPNR IS NOT INITIAL )
                              ( SIGN = 'I' OPTION = 'EQ' LOW = LW_MAIN-GRPNR ) ).
*  READ TABLE GT_MAIN_DISP_101 INTO DATA(LS_101_TEMP) INDEX 1.

  LT_2013 = VALUE #( FOR LW_2013 IN GT_2013 WHERE ( GRPNR IN LT_GRPNR )
                           ( CORRESPONDING #( LW_2013 ) ) ).

  IF LT_2013[] IS NOT INITIAL.
    SORT LT_2013 BY SGRPNR.
    DELETE ADJACENT DUPLICATES FROM LT_2013 COMPARING SGRPNR.

    LOOP AT LT_2013 INTO LS_2013.
      READ TABLE GT_2011 INTO DATA(LS_2011) WITH KEY SGRPNR = LS_2013-SGRPNR
                                                                      SOSUNCD = GS_HEADER_200-SOSUNCD
                                                                      JOBTY = '1'.
      IF SY-SUBRC EQ 0.
        LV_SGRPNR = LS_2011-SGRPNR.
        PV_SGRPNR = LS_2011-SGRPNR.
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDIF.

* 데이터 구성
  REFRESH LT_2013.

  LOOP AT GT_MAIN_DISP_102 INTO GS_MAIN_DISP_102 WHERE DISP_SOSUNCD = GS_HEADER_200-SOSUNCD.
    READ TABLE GT_2010 INTO DATA(LS_2010) WITH KEY ORDNR = GS_MAIN_DISP_102-ORDNR
                                                                  POSNR = GS_MAIN_DISP_102-POSNR.
    IF SY-SUBRC EQ 0.

      CLEAR LS_2013.
      LS_2013-DMORD = GS_MAIN_DISP_102-ORDNR.
      LS_2013-DMLINE = GS_MAIN_DISP_102-POSNR.
      LS_2013-DMORDTY = LS_2010-ORDTY.
      LS_2013-GRPNR = LS_2010-GRPNR.
      LS_2013-MATNR = LS_2010-MATNR.
      LS_2013-INLENGTH = GS_MAIN_DISP_102-INLENGTH01.
      LS_2013-INFACTOR = 1.
      APPEND LS_2013 TO LT_2013.
    ENDIF.

  ENDLOOP.

* 소선정보 데이터 구성
  LOOP AT GT_MAIN_DISP_103 INTO GS_MAIN_DISP_103.
    CLEAR LS_2014.
    LS_2014-ZCAGE = GS_MAIN_DISP_103-LAYER.
    LS_2014-JAEJIL = GS_MAIN_DISP_103-JAEJIL.
    LS_2014-SOSUN_DIA = GS_MAIN_DISP_103-SOSUN_DIA.
* 신선 조달유형 차후 적용예정
*    LS_2014-BESKZ = GS_MAIN_DISP_103-LAYER.
    LS_2014-YCOEF = GS_MAIN_DISP_103-YCOEF.
    LS_2014-ADLENGTH = GS_MAIN_DISP_103-MENGE02.
* 작업수량
    LS_2014-BSMENGE = GS_MAIN_DISP_103-MENGE03.
* 기준권취량
    LS_2014-BSLENGTH = GS_MAIN_DISP_103-MENGE04.
* 권취개수
    LS_2014-INFACTOR = GS_MAIN_DISP_103-MENGE05.
* 실권취량
    LS_2014-INLENGTH = GS_MAIN_DISP_103-MENGE06.
* 작업지시량
    LS_2014-MENGE = GS_MAIN_DISP_103-MENGE07.
    LS_2014-MEINS = GS_MAIN_DISP_103-MEINS.
    LS_2014-YUN = GS_MAIN_DISP_103-YUN.
    LS_2014-SPECCD = GS_MAIN_DISP_103-SPECCD.
    LS_2014-COND_SIZE = GS_MAIN_DISP_103-COND_SIZE.
    LS_2014-SHAPE = GS_MAIN_DISP_103-VTEXT.
    APPEND LS_2014 TO LT_2014.

  ENDLOOP.

  IF LV_SGRPNR IS NOT INITIAL. " 저장 정보가 있다는 의미
    PT_2011[] = VALUE #( FOR LW_2011 IN GT_2011 WHERE ( SGRPNR = LV_SGRPNR )
                           ( CORRESPONDING #( LW_2011 ) ) ).

    LOOP AT PT_2011 ASSIGNING FIELD-SYMBOL(<LS_2011>).
      <LS_2011>-AEDAT = SY-DATUM.
      <LS_2011>-AENAM = SY-UNAME.
    ENDLOOP.

    LOOP AT LT_2013 ASSIGNING FIELD-SYMBOL(<LS_2013>).
      <LS_2013>-SGRPNR = LV_SGRPNR.
    ENDLOOP.

    LOOP AT LT_2014 ASSIGNING FIELD-SYMBOL(<LS_2014>).
      <LS_2014>-SGRPNR = LV_SGRPNR.
    ENDLOOP.


  ELSE.
    APPEND INITIAL LINE TO PT_2011 ASSIGNING <LS_2011>.

    <LS_2011>-JOBTY = '1'.
    <LS_2011>-SOSUNCD = GS_HEADER_200-SOSUNCD.
    PERFORM GET_ZZBUNDLE_NO CHANGING <LS_2011>-ZZBUNDLE PV_CHK_ERR.
    IF PV_CHK_ERR = ABAP_TRUE.
      RETURN.
    ENDIF.

    <LS_2011>-ERNAM = SY-UNAME.
    <LS_2011>-AEDAT = SY-DATUM.
    <LS_2011>-AENAM = SY-UNAME.

  ENDIF.

  APPEND LINES OF LT_2013 TO PT_2013[].
  APPEND LINES OF LT_2014 TO PT_2014[].


ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_DATA_TO_SAVE02
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_2012
*&      --> LS_CREATE_ZWSEQ
*&---------------------------------------------------------------------*
FORM MAKE_DATA_TO_SAVE02  TABLES   PT_2012 STRUCTURE ZGTPPT2012
                          USING    PV_ZWSEQ TYPE ZGTPPT2012-ZWSEQ
                                   PV_SGRPNR TYPE ZGTESGRPNR
                                   PV_ZZBUNDLE TYPE AUFK-ZZBUNDLE
                       CHANGING PV_CHK_ERR.

  DATA : LS_2012 TYPE ZGTPPT2012.
  DATA : LT_2012 TYPE TABLE OF ZGTPPT2012.

  LOOP AT GT_MAIN_DISP_103 INTO GS_MAIN_DISP_103.
    LOOP AT GT_MAINTAIN_LENGTH INTO GS_MAINTAIN_LENGTH WHERE LAYER =  GS_MAIN_DISP_103-LAYER
                                                                                 AND ZTWSEQ = PV_ZWSEQ.

      IF GS_MAINTAIN_LENGTH-MENGE = 0.
        CONTINUE.
      ENDIF.

      CLEAR LS_2012.
      IF PV_SGRPNR IS NOT INITIAL.
        LS_2012-SGRPNR = PV_SGRPNR.
      ENDIF.
      LS_2012-GONG_CD = 'BWD'.
      LS_2012-JOBTY = '1'.
      LS_2012-COND_TYPE = GS_MAIN_DISP_103-COND_TYPE.
      LS_2012-POSNR = 1.
      LS_2012-ORDTY = 'PRD'.
      IF GS_MAINTAIN_LENGTH-MENGE = GS_MAIN_DISP_103-MENGE06 AND
        GS_MAIN_DISP_103-MENGE02 NE 0..
        LS_2012-INLENGTH = GS_MAIN_DISP_103-MENGE06 - GS_MAIN_DISP_103-MENGE02.
        LS_2012-ADTYPE = 'C'.
        LS_2012-ADLENGTH = GS_MAIN_DISP_103-MENGE02.
      ELSE.
        LS_2012-INLENGTH = GS_MAINTAIN_LENGTH-MENGE.
      ENDIF.
      LS_2012-INFACTOR = GS_MAIN_DISP_103-LAYER.
      LS_2012-ZCAGE = GS_MAIN_DISP_103-LAYER.
      LS_2012-ZTWSEQ = GS_HEADER_200-ZTWSEQ.
      LS_2012-ZWSEQ = PV_ZWSEQ.
* 연입률 세팅
      LS_2012-YCOEF = GS_MAIN_DISP_103-YCOEF.
*      LS_2012-ARBPL = GS_HEADER_200-ARBPL.

      APPEND LS_2012 TO LT_2012.

    ENDLOOP.
  ENDLOOP.

  IF LT_2012 IS NOT INITIAL.

    DATA : LV_ZZPOSNR TYPE AUFK-ZZPOSNR.
    DATA : LV_FINDATE TYPE SY-DATUM.

    PERFORM GET_FINDATE CHANGING LV_FINDATE.
    LV_ZZPOSNR = PV_ZWSEQ + 0.

    LOOP AT LT_2012 ASSIGNING FIELD-SYMBOL(<LS_2012>).
*    해당 정보로 생산오더 생성
      PERFORM CREATE_PRD_ORDER USING <LS_2012> PV_ZZBUNDLE LV_ZZPOSNR LV_FINDATE CHANGING <LS_2012>-ORDNR PV_CHK_ERR.
      IF PV_CHK_ERR = ABAP_TRUE.
        RETURN.
      ENDIF.
      PERFORM CHECK_SET_ARBPL USING <LS_2012>-ORDNR CHANGING <LS_2012>-ARBPL.

    ENDLOOP.

    APPEND LINES OF LT_2012 TO PT_2012[].
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_ZZBUNDLE_NO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_ZZBUNDLE
*&---------------------------------------------------------------------*
FORM GET_ZZBUNDLE_NO  CHANGING PV_ZZBUNDLE TYPE AUFK-ZZBUNDLE
                                                   PV_CHK_ERR.

  DATA : LV_NR     LIKE  INRI-NRRANGENR.

  LV_NR = '02'.
  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      NR_RANGE_NR             = LV_NR
      OBJECT                  = 'ZGTPP_GORD'
    IMPORTING
      NUMBER                  = PV_ZZBUNDLE
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
    MESSAGE S000 DISPLAY LIKE 'E' WITH '묶음 오더 채번중 오류 발생하였습니다.'(E10).
    PV_CHK_ERR = ABAP_TRUE.
    RETURN.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_PRD_ORDER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LS_2010>
*&      --> LV_ZZBUNDLE
*&      --> LV_ZZPOSNR
*&      <-- <LS_2010>_ORDNR
*&      <-- PV_CHK_ERR
*&---------------------------------------------------------------------*
FORM CREATE_PRD_ORDER  USING    PS_2012 TYPE ZGTPPT2012
                                PV_ZZBUNDLE TYPE AUFK-ZZBUNDLE
                                PV_ZZPOSNR TYPE AUFK-ZZPOSNR
                                PV_FINDATE  TYPE SY-DATUM
                       CHANGING PV_ORDNR TYPE ZGTPPT2012-ORDNR
                                PV_CHK_ERR.

  DATA : LS_ORDER TYPE BAPI_PP_ORDER_CREATE.
  DATA : LS_RETURN TYPE BAPIRET2.
  DATA : LV_ORDER_NUMBER TYPE BAPI_ORDER_KEY-ORDER_NUMBER.
  DATA : LS_ORDER_KEY TYPE BAPI_ORDER_KEY.

  READ TABLE GT_MAIN_DISP_103 INTO DATA(LS_103_TEMP) WITH KEY LAYER = PS_2012-ZCAGE.
  IF SY-SUBRC EQ 0.

    LS_ORDER-MATERIAL = LS_103_TEMP-MATNR.
    LS_ORDER-PLANT = P_WERKS.
    LS_ORDER-BASIC_START_DATE = PV_FINDATE.
    LS_ORDER-BASIC_END_DATE = PV_FINDATE.
    LS_ORDER-ORDER_TYPE = 'PP01'.
    LS_ORDER-BASIC_SCHEDULING_TYPE = '3'.
    LS_ORDER-QUANTITY = ( PS_2012-INLENGTH + PS_2012-ADLENGTH ) * PS_2012-INFACTOR.

    PERFORM CHK_MATNR_INFOR2 CHANGING LS_ORDER PV_CHK_ERR.
    IF PV_CHK_ERR = ABAP_TRUE.
      RETURN.
    ENDIF.

* 생산오더 생성
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

      CLEAR LS_ORDER_KEY.
      LS_ORDER_KEY-ORDER_NUMBER = LV_ORDER_NUMBER.
      COLLECT LS_ORDER_KEY INTO GT_PRD_ORDERS.

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

    ELSE.
      PV_CHK_ERR = ABAP_TRUE.
      MESSAGE S003 DISPLAY LIKE 'E' WITH '생산오더 생성중 오류 발생하였습니다.'(e12).
      RETURN.
    ENDIF.

    PERFORM SET_PRD_CHG_BY_BDC USING LV_ORDER_NUMBER PS_2012 PV_ZZBUNDLE PV_ZZPOSNR CHANGING PV_CHK_ERR.
    IF PV_CHK_ERR = ABAP_TRUE.
      RETURN.
    ENDIF.

* 설비 변경은 생산계획에서 진행 기본 설비로 세팅
*    PERFORM SET_ARBPL_CHG_BY_BDC USING LV_ORDER_NUMBER PS_2012 CHANGING PV_CHK_ERR.
*    IF PV_CHK_ERR = ABAP_TRUE.
*      RETURN.
*    ENDIF.

    PV_ORDNR = LV_ORDER_NUMBER.

  ELSE.
    PV_CHK_ERR = ABAP_TRUE.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '생산오더 생성중 오류 발생하였습니다.'(e12).
    RETURN.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_FINDATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_FINDATE
*&---------------------------------------------------------------------*
FORM GET_FINDATE  CHANGING PV_FINDATE TYPE SY-DATUM.

  DATA : LT_AUFNR TYPE RANGE OF AUFNR.

  LT_AUFNR = VALUE #( FOR LW_DATA IN GT_MAIN_DISP_102 WHERE ( SOSUNCD = GS_HEADER_200-SOSUNCD
                                                                                     AND   ORDNR IS NOT INITIAL  )
                              ( SIGN = 'I' OPTION = 'EQ' LOW = LW_DATA-ORDNR ) ).

  SELECT SINGLE MIN( GSTRP ) AS GSTRP FROM ZGTCVORDSYVAL
    WHERE AUFNR IN @LT_AUFNR
     INTO @PV_FINDATE.

  PV_FINDATE = PV_FINDATE - 1.

ENDFORM.
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form SET_PRD_CHG_BY_BDC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_ORDER_NUMBER
*&      --> PS_2012
*&      <-- PV_CHK_ERR
*&---------------------------------------------------------------------*
FORM SET_PRD_CHG_BY_BDC  USING    PV_ORDER_NUMBER TYPE AUFNR
                                  PS_2012 TYPE ZGTPPT2012
                                  PV_ZZBUNDLE TYPE AUFK-ZZBUNDLE
                                  PV_ZZPOSNR TYPE AUFK-ZZPOSNR
                         CHANGING PV_CHK_ERR.

  DATA : LV_INLENGTH TYPE I.
  DATA : LV_INLENGTH_C(10) TYPE C.
  DATA : LV_INFACTOR TYPE I.
  DATA : LV_INFACTOR_C(10) TYPE C.
  DATA : LV_FIELDNAME TYPE FNAM_____4.
  DATA : LV_NUM(2) TYPE N.

  REFRESH : GT_BDCDATA, GT_MESSTAB.

  LV_INLENGTH = PS_2012-INLENGTH.
  LV_INLENGTH_C = LV_INLENGTH.
  CONDENSE LV_INLENGTH_C.

  LV_INFACTOR = PS_2012-INFACTOR.
  LV_INFACTOR_C = LV_INFACTOR.
  CONDENSE LV_INFACTOR_C.

  __SETTING_BDC_PARAMS.

  __BDC_DYNPRO 'SAPLCOKO1' '0110'.
  __BDC_FIELD : 'CAUFVD-AUFNR' PV_ORDER_NUMBER,
                      'R62CLORD-FLG_OVIEW'  'X',
                      'BDC_OKCODE' '=ENTK'.

*  __BDC_DYNPRO 'SAPLCOKO1' '0115'.
*  __BDC_FIELD : 'BDC_OKCODE' '=KOTA'. " 빠른입력화면으로 전환
*
*
*  __BDC_DYNPRO 'SAPLCOKO1' '0115'.
*  __BDC_FIELD :  'BDC_OKCODE' '=MILL_BT_SEL_ALL'.
*
*
*  __BDC_DYNPRO 'SAPLCOKO1' '0115'.
*  __BDC_FIELD :  'BDC_OKCODE' '=MILL_BT_CONFIG'.
*
*
*  __BDC_DYNPRO 'SAPLCOKO1' '0115'.
*  __BDC_FIELD :  'BDC_OKCODE' '=MILL_BT_CONFIG'.
*
*
*  __BDC_DYNPRO 'SAPLCEI0' '0109'.
*  __BDC_FIELD : 'RCTMS-MNAME(01)' '조장(기본단위)',
*                      'RCTMS-MNAME(02)' '조장수',
*                      'RCTMS-MNAME(03)' '전선_공정코드',
*                      'RCTMS-MWERT(01)' LV_INLENGTH_C,
*                      'RCTMS-MWERT(02)' LV_INFACTOR_C,
*                      'RCTMS-MWERT(03)' 'BWD',
*                      'BDC_OKCODE' '=BACK'.

  __BDC_DYNPRO 'SAPLCOKO1' '0115'.
  __BDC_FIELD :  'BDC_OKCODE' '=+COI'.
  __BDC_DYNPRO 'SAPLCOKO1' '0115'.
  __BDC_FIELD :  'BDC_OKCODE' '/00',
                       'GV_ZZBUNDLE' PV_ZZBUNDLE,
                       'GV_ZZPOSNR' PV_ZZPOSNR.

  __BDC_DYNPRO 'SAPLCOKO1' '0115'.
  __BDC_FIELD : 'BDC_OKCODE' '=BU'.

  __BDC_TRANSACTION 'CO02'.

  IF NOT LINE_EXISTS( GT_MESSTAB[ MSGTYP = 'S' MSGID = 'CO' MSGNR = '100' ] ).
    MESSAGE S003 DISPLAY LIKE 'E' WITH '생산오더 생성중 오류 발생하였습니다.- 특성입력'(e11).

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ARBPL_CHG_BY_BDC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_ORDER_NUMBER
*&      --> PS_2012
*&      <-- PV_CHK_ERR
*&---------------------------------------------------------------------*
FORM SET_ARBPL_CHG_BY_BDC  USING    PV_ORDER_NUMBER TYPE AUFNR
                                  PS_2012 TYPE ZGTPPT2012
                           CHANGING PV_CHK_ERR.

  DATA : LV_PLNFL(6).

  REFRESH : GT_BDCDATA, GT_MESSTAB.

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
   WHERE A~AUFNR = @PV_ORDER_NUMBER
    AND  F~SPRAS = @SY-LANGU
   INTO TABLE @DATA(LT_ARBPL).

  READ TABLE LT_ARBPL INTO DATA(LS_ARBPL) WITH KEY ARBPL = PS_2012-ARBPL.
*    현재 설비로 세팅되어 있다면 변경없이 종료
  IF LS_ARBPL-PLNFL = '000000'.
    RETURN.
  ENDIF.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      INPUT  = LS_ARBPL-PLNFL
    IMPORTING
      OUTPUT = LV_PLNFL.

  CONDENSE LV_PLNFL.

  IF LV_PLNFL IS INITIAL.
    RETURN.
  ENDIF.

  __SETTING_BDC_PARAMS.

  __BDC_DYNPRO 'SAPLCOKO1' '0110'.
  __BDC_FIELD : 'CAUFVD-AUFNR' PV_ORDER_NUMBER,
                      'R62CLORD-FLG_OVIEW'  'X',
                      'BDC_OKCODE' '=FLGU'.

  __BDC_DYNPRO 'SAPLCOVG' '0200'.
  __BDC_FIELD : 'BDC_OKCODE' '=SEQC'. " 빠른입력화면으로 전환

  __BDC_DYNPRO 'SAPLCOKO1' '0630'.
  __BDC_FIELD :  'BDC_OKCODE' '=POSI'.

  __BDC_DYNPRO 'SAPLSPO4' '0300'.
  __BDC_FIELD :  'SVALD-VALUE(01)' LV_PLNFL,
                       'BDC_OKCODE' '=FURT'.

  __BDC_DYNPRO 'SAPLCOKO1' '0630'.
  __BDC_FIELD :  'BDC_OKCODE' '=ENT1'.


  __BDC_DYNPRO 'SAPLCOVG' '0200'.
  __BDC_FIELD : 'BDC_OKCODE' '=BU'.

  __BDC_TRANSACTION 'CO02'.
  IF NOT LINE_EXISTS( GT_MESSTAB[ MSGTYP = 'S' MSGID = 'CO' MSGNR = '100' ] ).
    MESSAGE S003 DISPLAY LIKE 'E' WITH '생산오더 생성중 오류 발생하였습니다.- 설비변경'(e13).

  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_NUM_SGRPNR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_SGRPNR
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM GET_NUM_SGRPNR  CHANGING PV_SGRPNR TYPE ZGTPPT2011-SGRPNR
                                                   PV_CHK_ERR.

  DATA : LV_NR     LIKE  INRI-NRRANGENR,
         LV_NUMBER TYPE C LENGTH 5.

  LV_NR = 'SO'.
  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      NR_RANGE_NR             = LV_NR
      OBJECT                  = 'ZSPG'
    IMPORTING
      NUMBER                  = LV_NUMBER
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
    MESSAGE S000 DISPLAY LIKE 'E' WITH '소선오더 그룹번호 채번중 오류 발생하였습니다.'(E14).
    PV_CHK_ERR = ABAP_TRUE.
    RETURN.
  ENDIF.
  PV_SGRPNR = 'SO' && SY-DATUM+0(4) && SY-DATUM+4(2) && LV_NUMBER.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CELL_ATTRIBUTE_GRID_0103
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_CELL_ATTRIBUTE_GRID_0103 .

  DATA : LT_CELLTAB TYPE LVC_T_STYL.
  DATA : LS_CELLTAB TYPE LVC_S_STYL.
  FIELD-SYMBOLS <LT_CELLTAB> TYPE ANY.
* Macro
  DEFINE __SET_CELL_ATTRIBUTE.
    CLEAR LS_CELLTAB.
    LS_CELLTAB-FIELDNAME = &1.
    LS_CELLTAB-STYLE = &2.
    INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
  END-OF-DEFINITION.


  LOOP AT GT_MAIN_DISP_103 ASSIGNING FIELD-SYMBOL(<LS_MAIN>).
    CLEAR LS_CELLTAB.
    REFRESH LT_CELLTAB.

    __SET_CELL_ATTRIBUTE 'LAYER'  ALV_STYLE_COLOR_INT_KEY.
    __SET_CELL_ATTRIBUTE 'JAEJIL'  ALV_STYLE_COLOR_INT_KEY.
    __SET_CELL_ATTRIBUTE 'SOSUN_DIA'  ALV_STYLE_COLOR_INT_KEY.


    IF GT_2012_MAINTAIN[] IS INITIAL.
      __SET_CELL_ATTRIBUTE 'MENGE02'  ALV_STYLE_ENABLED.
    ELSE.
      __SET_CELL_ATTRIBUTE 'MENGE02'  ALV_STYLE_DISABLED.
    ENDIF.

    IF <LT_CELLTAB> IS ASSIGNED. UNASSIGN <LT_CELLTAB>. ENDIF.
    ASSIGN COMPONENT 'CELLTAB' OF STRUCTURE <LS_MAIN> TO <LT_CELLTAB>.
    IF <LT_CELLTAB> IS ASSIGNED.
      <LT_CELLTAB> = LT_CELLTAB.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_DELETE_ORDER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_DELETE_ORDER .

  DATA : LT_COLUMN TYPE LVC_T_COL.
  DATA : LV_STRING TYPE STRING.
  DATA : LV_NUM(2) TYPE N.
  DATA : LV_ZWSEQ TYPE ZGTPPT2012-ZWSEQ.
  DATA : LT_2012_DEL TYPE TABLE OF ZGTPPT2012.
  DATA : LS_2012_DEL TYPE ZGTPPT2012.

  REFRESH GT_PRD_ORDERS.

  GO_GRID_0104->GET_SELECTED_COLUMNS(
    IMPORTING
      ET_INDEX_COLUMNS = LT_COLUMN ).                " Cell IDs

  IF LT_COLUMN[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '선택된 컬럼이 없습니다.'(E05).
    RETURN.
  ENDIF.

  LOOP AT LT_COLUMN INTO DATA(LS_COLUMN).
    SPLIT LS_COLUMN-FIELDNAME AT  '_'  INTO TABLE DATA(LT_STRING).
    READ TABLE LT_STRING INTO DATA(LS_STRING) INDEX 1.
    LV_STRING = LS_STRING.
    IF LV_STRING NE 'FIELDINFOR'.
      MESSAGE S003 DISPLAY LIKE 'E' WITH '차수가 아닌 컬럼이 선택되었습니다.'(E06).
      RETURN.
    ENDIF.

    READ TABLE LT_STRING INTO LS_STRING INDEX 2.
    LV_NUM = LS_STRING.
    LV_ZWSEQ = LV_NUM + 0.

    LOOP AT GT_2012_MAINTAIN INTO DATA(LS_2012) WHERE ZWSEQ = LV_ZWSEQ.
      IF LS_2012-CHK_PRD IS NOT INITIAL.
        MESSAGE S005 DISPLAY LIKE 'E' WITH LS_2012-ORDNR '오더는 생산 진행 중으로 삭제 할 수 없습니다.'(E15).
        RETURN.
      ENDIF.

      APPEND INITIAL LINE TO GT_PRD_ORDERS ASSIGNING FIELD-SYMBOL(<LS_ORDER>).
      <LS_ORDER>-ORDER_NUMBER = LS_2012-ORDNR.
      CLEAR LS_2012_DEL.
      MOVE-CORRESPONDING LS_2012 TO LS_2012_DEL.
      APPEND LS_2012_DEL TO LT_2012_DEL.
    ENDLOOP.

  ENDLOOP.

  IF LT_2012_DEL[] IS INITIAL.
    RETURN.
  ENDIF.

  CLEAR GV_ANSWER.
  PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
    ' '
    '선택된 차수의 오더가 삭제 됩니다. 계속 진행 하시겠습니까?'
    '삭제확인'.
  IF GV_ANSWER NE 'J'.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
    RETURN.
  ENDIF.

  DATA : LS_RETURN2 TYPE BAPIRET2.
  DATA : LT_DETAIL_RETURN TYPE BAPI_ORDER_RETURN_TT.

  CALL FUNCTION 'BAPI_PRODORD_SET_DELETION_FLAG'
    IMPORTING
      RETURN        = LS_RETURN2
    TABLES
      ORDERS        = GT_PRD_ORDERS
      DETAIL_RETURN = LT_DETAIL_RETURN.

  DELETE ZGTPPT2012  FROM TABLE LT_2012_DEL.
  IF SY-SUBRC NE 0.
    ROLLBACK WORK.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '생산오더 삭제중 오류 발생하였습니다.'(e16).
    RETURN.
  ELSE.
    COMMIT WORK AND WAIT.
  ENDIF.

  READ TABLE LT_2012_DEL INTO DATA(LS_TEMP) INDEX 1.
  DELETE GT_2012 WHERE SGRPNR = LS_TEMP-SGRPNR.

  SELECT * FROM ZGTPPT2012
    INTO TABLE @DATA(LT_2012)
   WHERE SGRPNR = @LS_TEMP-SGRPNR.
  IF SY-SUBRC NE 0. " 신선재 오더 정보가 없다면
    DELETE FROM ZGTPPT2011 WHERE SGRPNR = LS_TEMP-SGRPNR.
    DELETE GT_2011 WHERE SGRPNR = LS_TEMP-SGRPNR.
    DELETE FROM ZGTPPT2013 WHERE SGRPNR = LS_TEMP-SGRPNR.
    DELETE GT_2013 WHERE SGRPNR = LS_TEMP-SGRPNR.
    DELETE FROM ZGTPPT2014 WHERE SGRPNR = LS_TEMP-SGRPNR.
    COMMIT WORK AND WAIT.
  ELSE.
    APPEND LINES OF LT_2012 TO GT_2012.
  ENDIF.


  IF <GT_MAIN_DISP_104> IS ASSIGNED.
    REFRESH <GT_MAIN_DISP_104>.
  ENDIF.

  PERFORM SET_ITAB_103.
  PERFORM REFRESH_GRID USING GO_GRID_0103.
  PERFORM SET_ITAB_104.
  IF GO_GRID_0104 IS BOUND.
    PERFORM REFRESH_GRID USING GO_GRID_0104.
  ENDIF.

  MESSAGE S003 WITH '생산오더 삭제하였습니다.'(e17).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_RELEASE_ORDER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_RELEASE_ORDER .

  DATA : LT_COLUMN TYPE LVC_T_COL.
  DATA : LV_STRING TYPE STRING.
  DATA : LV_NUM(2) TYPE N.
  DATA : LV_ZWSEQ TYPE ZGTPPT2012-ZWSEQ.

  GO_GRID_0104->GET_SELECTED_COLUMNS(
    IMPORTING
      ET_INDEX_COLUMNS = LT_COLUMN ).                " Cell IDs

  IF LT_COLUMN[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '선택된 컬럼이 없습니다.'(E05).
    RETURN.
  ENDIF.

  REFRESH GT_PRD_ORDERS.

  LOOP AT LT_COLUMN INTO DATA(LS_COLUMN).
    SPLIT LS_COLUMN-FIELDNAME AT  '_'  INTO TABLE DATA(LT_STRING).
    READ TABLE LT_STRING INTO DATA(LS_STRING) INDEX 1.
    LV_STRING = LS_STRING.
    IF LV_STRING NE 'FIELDINFOR'.
      MESSAGE S003 DISPLAY LIKE 'E' WITH '차수가 아닌 컬럼이 선택되었습니다.'(E06).
      RETURN.
    ENDIF.

    READ TABLE LT_STRING INTO LS_STRING INDEX 2.
    LV_NUM = LS_STRING.
    LV_ZWSEQ = LV_NUM + 0.

    LOOP AT GT_2012_MAINTAIN INTO DATA(LS_2012) WHERE ZWSEQ = LV_ZWSEQ.
      IF LS_2012-STATUS ='C'.

        APPEND INITIAL LINE TO GT_PRD_ORDERS ASSIGNING FIELD-SYMBOL(<LS_ORDER>).
        <LS_ORDER>-ORDER_NUMBER = LS_2012-ORDNR.
      ENDIF.
    ENDLOOP.

  ENDLOOP.

  IF GT_PRD_ORDERS[] IS INITIAL.
    RETURN.
  ENDIF.

  CLEAR GV_ANSWER.
  PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
    ' '
    '선택된 오더가 릴리즈 됩니다. 계속 진행 하시겠습니까?'
    '작업확인'.

  IF GV_ANSWER NE 'J'.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
    RETURN.
  ENDIF.

  DATA : LT_ERR_ORDER TYPE BAPI_ORDER_RETURN_TT.
  CALL FUNCTION 'BAPI_PRODORD_RELEASE'
    TABLES
      ORDERS        = GT_PRD_ORDERS
      DETAIL_RETURN = LT_ERR_ORDER.

  IF <GT_MAIN_DISP_104> IS ASSIGNED.
    REFRESH <GT_MAIN_DISP_104>.
  ENDIF.

  PERFORM SET_ITAB_103.
  PERFORM REFRESH_GRID USING GO_GRID_0103.
  PERFORM SET_ITAB_104.
  IF GO_GRID_0104 IS BOUND.
    PERFORM REFRESH_GRID USING GO_GRID_0104.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CHANG_MENGE02
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_CHANG_MENGE02 .

  IF <GT_MAIN_DISP_104> IS ASSIGNED.
    REFRESH <GT_MAIN_DISP_104>.
  ENDIF.

  PERFORM SET_ITAB_103.
  PERFORM REFRESH_GRID USING GO_GRID_0103.
  PERFORM SET_ITAB_104.
  IF GO_GRID_0104 IS BOUND.
    PERFORM REFRESH_GRID USING GO_GRID_0104.
  ENDIF.

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

  DATA : LT_COLUMN TYPE LVC_T_COL.
  DATA : LV_STRING TYPE STRING.
  DATA : LV_NUM(2) TYPE N.
  DATA : LV_ZWSEQ TYPE ZGTPPT2012-ZWSEQ.
  DATA : LV_MATNR TYPE MATNR.
  FIELD-SYMBOLS : <LV_SEQNO> TYPE ANY.
  FIELD-SYMBOLS : <LV_LINE> TYPE ANY.
  FIELD-SYMBOLS : <LV_LAYER> TYPE ANY.

  DEFINE __GET_FIELD.

    IF <LV_SEQNO> IS ASSIGNED. UNASSIGN <LV_SEQNO>. ENDIF.
    ASSIGN COMPONENT 'SEQNO' OF STRUCTURE <LS_MAIN> TO <LV_SEQNO>.

    IF <LV_LINE> IS ASSIGNED. UNASSIGN <LV_LINE>. ENDIF.
    ASSIGN COMPONENT 'LINE' OF STRUCTURE <LS_MAIN> TO <LV_LINE>.

    IF <LV_LAYER> IS ASSIGNED. UNASSIGN <LV_LAYER>. ENDIF.
    ASSIGN COMPONENT 'LAYER' OF STRUCTURE <LS_MAIN> TO <LV_LAYER>.

  END-OF-DEFINITION.

  DEFINE __GET_FIELD2.

    IF <LV_SEQNO> IS ASSIGNED. UNASSIGN <LV_SEQNO>. ENDIF.
    ASSIGN COMPONENT 'SEQNO' OF STRUCTURE <LS_MAIN2> TO <LV_SEQNO>.

    IF <LV_LINE> IS ASSIGNED. UNASSIGN <LV_LINE>. ENDIF.
    ASSIGN COMPONENT 'LINE' OF STRUCTURE <LS_MAIN2> TO <LV_LINE>.

    IF <LV_LAYER> IS ASSIGNED. UNASSIGN <LV_LAYER>. ENDIF.
    ASSIGN COMPONENT 'BONSU' OF STRUCTURE <LS_MAIN2> TO <LV_LAYER>.

  END-OF-DEFINITION.

  DEFINE __GET_FIELD3.

    IF <LV_SEQNO> IS ASSIGNED. UNASSIGN <LV_SEQNO>. ENDIF.
    ASSIGN COMPONENT 'SEQNO' OF STRUCTURE <LS_MAIN3> TO <LV_SEQNO>.

    IF <LV_LINE> IS ASSIGNED. UNASSIGN <LV_LINE>. ENDIF.
    ASSIGN COMPONENT 'LINE' OF STRUCTURE <LS_MAIN3> TO <LV_LINE>.

  END-OF-DEFINITION.


  CASE P_SENDER.
    WHEN GO_GRID_0100.
      READ TABLE GT_MAIN_DISP INTO GS_MAIN_DISP INDEX P_ROW-INDEX.
      CASE P_COLUMN-FIELDNAME.
        WHEN 'ORDNO_C'.
          CASE GS_MAIN_DISP-GCATG.
            WHEN '판매오더'.
              SET PARAMETER ID 'AUN' FIELD GS_MAIN_DISP-ORDNO.
              CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.
              SET PARAMETER ID 'AUN' FIELD ' '.

            WHEN '생산오더'.
              CLEAR GS_MAKE_ORDER.
              PERFORM GET_SMORDER USING GS_MAIN_DISP-ORDNO.
              CALL SCREEN '0300' STARTING AT 5 5 ENDING AT 83 19.

          ENDCASE.

        WHEN 'MATNR'.
          SET PARAMETER ID 'WRK' FIELD P_WERKS.
          SET PARAMETER ID 'MXX' FIELD 'A'.
          SET PARAMETER ID 'MAT' FIELD GS_MAIN_DISP-MATNR.
          CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.
          SET PARAMETER ID 'MXX' FIELD ' '.
          SET PARAMETER ID 'MAT' FIELD ' '.


      ENDCASE.
    WHEN GO_GRID_0101.
      READ TABLE GT_MAIN_DISP_101 INTO GS_MAIN_DISP_101 INDEX P_ROW-INDEX.

      CASE P_COLUMN-FIELDNAME.
        WHEN 'ORDNO_C'.
          CASE GS_MAIN_DISP_101-GCATG.
            WHEN '판매오더'.
              SET PARAMETER ID 'AUN' FIELD GS_MAIN_DISP_101-ORDNO.
              CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.
              SET PARAMETER ID 'AUN' FIELD ' '.

            WHEN '생산오더'.
              CLEAR GS_MAKE_ORDER.
              PERFORM GET_SMORDER USING GS_MAIN_DISP_101-ORDNO.
              CALL SCREEN '0300' STARTING AT 5 5 ENDING AT 83 19.

          ENDCASE.

        WHEN 'MATNR'.
          SET PARAMETER ID 'WRK' FIELD P_WERKS.
          SET PARAMETER ID 'MXX' FIELD 'A'.
          SET PARAMETER ID 'MAT' FIELD GS_MAIN_DISP_101-MATNR.
          CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.
          SET PARAMETER ID 'MXX' FIELD ' '.
          SET PARAMETER ID 'MAT' FIELD ' '.


      ENDCASE.
    WHEN GO_GRID_0102.
      READ TABLE GT_MAIN_DISP_102 INTO GS_MAIN_DISP_102 INDEX P_ROW-INDEX.

      CASE P_COLUMN-FIELDNAME.
        WHEN 'ORDNO_C'.
          SET PARAMETER ID 'ANR' FIELD GS_MAIN_DISP_102-ORDNR.
          CALL TRANSACTION 'CO03' AND SKIP FIRST SCREEN.
          SET PARAMETER ID 'ANR' FIELD ''.

        WHEN 'MATNR'.
          SET PARAMETER ID 'WRK' FIELD P_WERKS.
          SET PARAMETER ID 'MXX' FIELD 'A'.
          SET PARAMETER ID 'MAT' FIELD GS_MAIN_DISP_102-MATNR.
          CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.
          SET PARAMETER ID 'MXX' FIELD ' '.
          SET PARAMETER ID 'MAT' FIELD ' '.


      ENDCASE.
    WHEN GO_GRID_0103.
      CASE P_COLUMN-FIELDNAME.
        WHEN 'MATNR'.
          READ TABLE GT_MAIN_DISP_103 INTO GS_MAIN_DISP_103 INDEX P_ROW-INDEX.
          SET PARAMETER ID 'WRK' FIELD P_WERKS.
          SET PARAMETER ID 'MXX' FIELD 'A'.
          SET PARAMETER ID 'MAT' FIELD GS_MAIN_DISP_103-MATNR.
          CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.
          SET PARAMETER ID 'MXX' FIELD ' '.
          SET PARAMETER ID 'MAT' FIELD ' '.

      ENDCASE.
    WHEN GO_GRID_0104.

      SPLIT P_COLUMN-FIELDNAME AT  '_'  INTO TABLE DATA(LT_STRING).
      READ TABLE LT_STRING INTO DATA(LS_STRING) INDEX 1.
      LV_STRING = LS_STRING.
      IF LV_STRING NE 'FIELDINFOR'.
        RETURN.
      ENDIF.

      READ TABLE LT_STRING INTO LS_STRING INDEX 2.
      LV_NUM = LS_STRING.
      LV_ZWSEQ = LV_NUM + 0.

      READ TABLE <GT_MAIN_DISP_104> ASSIGNING FIELD-SYMBOL(<LS_MAIN>) INDEX P_ROW-INDEX.
      __GET_FIELD.
      READ TABLE GT_2012_MAINTAIN INTO GS_2012_MAINTAIN WITH KEY ZCAGE = <LV_LAYER>
                                                                                           ZWSEQ = LV_ZWSEQ.
      IF SY-SUBRC EQ 0.
        CASE <LV_LINE>.
          WHEN 1.
            SET PARAMETER ID 'ANR' FIELD GS_2012_MAINTAIN-ORDNR.
            CALL TRANSACTION 'CO03' AND SKIP FIRST SCREEN.
            SET PARAMETER ID 'ANR' FIELD ''.
          WHEN 2.

        ENDCASE.
      ENDIF.

    WHEN GO_GRID_1100.
      CLEAR GS_MAIN_DISP_1100.
      READ TABLE GT_MAIN_DISP_1100 INTO GS_MAIN_DISP_1100 INDEX P_ROW-INDEX.
      CASE P_COLUMN-FIELDNAME.
        WHEN 'ORDNO_C'.
          CASE GS_MAIN_DISP_1100-GCATG.
            WHEN '판매오더'.
              SET PARAMETER ID 'AUN' FIELD GS_MAIN_DISP_1100-ORDNO.
              CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.
              SET PARAMETER ID 'AUN' FIELD ' '.

            WHEN '생산오더'.
              CLEAR GS_MAKE_ORDER.
              PERFORM GET_SMORDER USING GS_MAIN_DISP_1100-ORDNO.
              CALL SCREEN '0300' STARTING AT 5 5 ENDING AT 83 19.
          ENDCASE.

        WHEN 'MATNR'.
          SET PARAMETER ID 'WRK' FIELD P_WERKS.
          SET PARAMETER ID 'MXX' FIELD 'A'.
          SET PARAMETER ID 'MAT' FIELD GS_MAIN_DISP_1100-MATNR.
          CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.
          SET PARAMETER ID 'MXX' FIELD ' '.
          SET PARAMETER ID 'MAT' FIELD ' '.
      ENDCASE.

    WHEN GO_GRID_1101.
      CLEAR GS_MAIN_DISP_1101.
      READ TABLE GT_MAIN_DISP_1101 INTO GS_MAIN_DISP_1101 INDEX P_ROW-INDEX.
      CASE P_COLUMN-FIELDNAME.
        WHEN 'ORDNO_C'.
          SET PARAMETER ID 'ANR' FIELD GS_MAIN_DISP_1101-ORDNR.
          CALL TRANSACTION 'CO03' AND SKIP FIRST SCREEN.
          SET PARAMETER ID 'ANR' FIELD ''.
        WHEN 'MATNR'.
          SET PARAMETER ID 'WRK' FIELD P_WERKS.
          SET PARAMETER ID 'MXX' FIELD 'A'.
          SET PARAMETER ID 'MAT' FIELD GS_MAIN_DISP_1101-MATNR.
          CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.
          SET PARAMETER ID 'MXX' FIELD ' '.
          SET PARAMETER ID 'MAT' FIELD ' '.
      ENDCASE.

    WHEN GO_GRID_1102.
      CLEAR GS_MAIN_DISP_1101.
      READ TABLE GT_MAIN_DISP_1102 INTO GS_MAIN_DISP_1102 INDEX P_ROW-INDEX.
      CASE P_COLUMN-FIELDNAME.
        WHEN 'MATNR'.
          SET PARAMETER ID 'WRK' FIELD P_WERKS.
          SET PARAMETER ID 'MXX' FIELD 'A'.
          SET PARAMETER ID 'MAT' FIELD GS_MAIN_DISP_1102-MATNR.
          CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.
          SET PARAMETER ID 'MXX' FIELD ' '.
          SET PARAMETER ID 'MAT' FIELD ' '.
        WHEN 'MATNR_O'.
          SET PARAMETER ID 'WRK' FIELD P_WERKS.
          SET PARAMETER ID 'MXX' FIELD 'A'.
          SET PARAMETER ID 'MAT' FIELD GS_MAIN_DISP_1102-MATNR_O.
          CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.
          SET PARAMETER ID 'MXX' FIELD ' '.
          SET PARAMETER ID 'MAT' FIELD ' '.
      ENDCASE.
    WHEN GO_GRID_1103.

      REFRESH LT_STRING.
      SPLIT P_COLUMN-FIELDNAME AT  '_'  INTO TABLE LT_STRING.
      READ TABLE LT_STRING INTO LS_STRING INDEX 1.
      LV_STRING = LS_STRING.
      IF LV_STRING NE 'FIELDINFOR'.
        RETURN.
      ENDIF.

      READ TABLE LT_STRING INTO LS_STRING INDEX 2.
      LV_NUM = LS_STRING.
      LV_ZWSEQ = LV_NUM + 0.

      READ TABLE <GT_MAIN_DISP_1103> ASSIGNING FIELD-SYMBOL(<LS_MAIN3>) INDEX P_ROW-INDEX.
      __GET_FIELD3.

      READ TABLE GT_MAIN_DISP_1102 INTO GS_MAIN_DISP_1102 WITH KEY SEQNO = <LV_SEQNO>.
      IF SY-SUBRC EQ 0 AND GS_MAIN_DISP_1102-SGRPNR IS NOT INITIAL.
        READ TABLE GT_2012_MAINTAIN INTO GS_2012_MAINTAIN WITH KEY SGRPNR = GS_MAIN_DISP_1102-SGRPNR
                                                                                             ZWSEQ = LV_ZWSEQ.
        IF SY-SUBRC EQ 0.
          CASE <LV_LINE>.
            WHEN 1.
              CASE GS_2012_MAINTAIN-ORDTY.
                WHEN 'PRD'.
                  SET PARAMETER ID 'ANR' FIELD GS_2012_MAINTAIN-ORDNR.
                  CALL TRANSACTION 'CO03' AND SKIP FIRST SCREEN.
                  SET PARAMETER ID 'ANR' FIELD ''.
                WHEN 'PR'.
                  SET PARAMETER ID 'BAN' FIELD GS_2012_MAINTAIN-ORDNR.
                  CALL TRANSACTION 'ME53N'.
                  SET PARAMETER ID 'BAN' FIELD ''.
                WHEN 'PO'.
                  SET PARAMETER ID 'BES' FIELD GS_2012_MAINTAIN-ORDNR.
                  CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.
                  SET PARAMETER ID 'BES' FIELD ''.
              ENDCASE.

            WHEN 2.

          ENDCASE.
        ENDIF.
      ENDIF.


    WHEN GO_GRID_0401.
      READ TABLE GT_MAIN_DISP_101 INTO GS_MAIN_DISP_101 INDEX P_ROW-INDEX.

      CASE P_COLUMN-FIELDNAME.
        WHEN 'ORDNO_C'.
          CASE GS_MAIN_DISP_101-GCATG.
            WHEN '판매오더'.
              SET PARAMETER ID 'AUN' FIELD GS_MAIN_DISP_101-ORDNO.
              CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.
              SET PARAMETER ID 'AUN' FIELD ' '.

            WHEN '생산오더'.
              CLEAR GS_MAKE_ORDER.
              PERFORM GET_SMORDER USING GS_MAIN_DISP_101-ORDNO.
              CALL SCREEN '0300' STARTING AT 5 5 ENDING AT 83 19.

          ENDCASE.

        WHEN 'MATNR'.
          SET PARAMETER ID 'WRK' FIELD P_WERKS.
          SET PARAMETER ID 'MXX' FIELD 'A'.
          SET PARAMETER ID 'MAT' FIELD GS_MAIN_DISP_101-MATNR.
          CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.
          SET PARAMETER ID 'MXX' FIELD ' '.
          SET PARAMETER ID 'MAT' FIELD ' '.


      ENDCASE.
    WHEN GO_GRID_0402.
      READ TABLE GT_MAIN_DISP_402 INTO GS_MAIN_DISP_402 INDEX P_ROW-INDEX.

      CASE P_COLUMN-FIELDNAME.
        WHEN 'ORDNO_C'.
          SET PARAMETER ID 'ANR' FIELD GS_MAIN_DISP_402-ORDNR.
          CALL TRANSACTION 'CO03' AND SKIP FIRST SCREEN.
          SET PARAMETER ID 'ANR' FIELD ''.

        WHEN 'MATNR'.
          SET PARAMETER ID 'WRK' FIELD P_WERKS.
          SET PARAMETER ID 'MXX' FIELD 'A'.
          SET PARAMETER ID 'MAT' FIELD GS_MAIN_DISP_402-MATNR.
          CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.
          SET PARAMETER ID 'MXX' FIELD ' '.
          SET PARAMETER ID 'MAT' FIELD ' '.


      ENDCASE.
    WHEN GO_GRID_0403.
      CASE P_COLUMN-FIELDNAME.
        WHEN 'MATNR'.
          READ TABLE GT_MAIN_DISP_403 INTO GS_MAIN_DISP_403 INDEX P_ROW-INDEX.
          SET PARAMETER ID 'WRK' FIELD P_WERKS.
          SET PARAMETER ID 'MXX' FIELD 'A'.
          SET PARAMETER ID 'MAT' FIELD GS_MAIN_DISP_403-MATNR.
          CALL TRANSACTION 'MM03' AND SKIP FIRST SCREEN.
          SET PARAMETER ID 'MXX' FIELD ' '.
          SET PARAMETER ID 'MAT' FIELD ' '.

      ENDCASE.
    WHEN GO_GRID_0404.

      REFRESH LT_STRING.
      SPLIT P_COLUMN-FIELDNAME AT  '_'  INTO TABLE LT_STRING.
      READ TABLE LT_STRING INTO LS_STRING INDEX 1.
      LV_STRING = LS_STRING.
      IF LV_STRING NE 'FIELDINFOR'.
        RETURN.
      ENDIF.

      READ TABLE LT_STRING INTO LS_STRING INDEX 2.
      LV_NUM = LS_STRING.
      LV_ZWSEQ = LV_NUM + 0.

      READ TABLE <GT_MAIN_DISP_404> ASSIGNING FIELD-SYMBOL(<LS_MAIN2>) INDEX P_ROW-INDEX.
      __GET_FIELD2.
      READ TABLE GT_2012_MAINTAIN INTO GS_2012_MAINTAIN WITH KEY ZCAGE = <LV_LAYER>
                                                                                           ZWSEQ = LV_ZWSEQ.
      IF SY-SUBRC EQ 0.
        CASE <LV_LINE>.
          WHEN 1.
            SET PARAMETER ID 'ANR' FIELD GS_2012_MAINTAIN-ORDNR.
            CALL TRANSACTION 'CO03' AND SKIP FIRST SCREEN.
            SET PARAMETER ID 'ANR' FIELD ''.
          WHEN 2.

        ENDCASE.
      ENDIF.


  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Module STATUS_0300 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0300 OUTPUT.
  SET PF-STATUS '0300'.
  SET TITLEBAR '0300'.
ENDMODULE.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0300  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0300 INPUT.

  CLEAR GV_OK_CODE4.
  GV_OK_CODE4 = SY-UCOMM.

  CASE GV_OK_CODE4.
    WHEN 'BACK' OR 'EXIT' OR 'CANC' OR 'CONFIRM'.
      GO_CONTAINER_300->FREE( ).
      GO_TEXT_300->FREE( ).
      FREE : GO_CONTAINER_300, GO_TEXT_300.
      LEAVE TO SCREEN 0.

  ENDCASE.

ENDMODULE.
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

  GO_TEXT_300->SET_READONLY_MODE( EXPORTING READONLY_MODE = 1 ).

  GO_TEXT_300->SET_TEXT_AS_R3TABLE( EXPORTING TABLE = GT_TEXT ).

  CALL METHOD CL_GUI_CFW=>FLUSH
    EXCEPTIONS
      OTHERS = 1.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_SMORDER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_MAIN_DISP_ORDNO
*&      <-- GS_MAKE_ORDER
*&---------------------------------------------------------------------*
FORM GET_SMORDER  USING    PV_ORDNO TYPE ZGTPPT2001-ORDNO.

  DATA : LS_2001 TYPE ZGTPPT2001.

  SELECT SINGLE * FROM ZGTPPT2001
    INTO LS_2001
   WHERE ORDNO = PV_ORDNO.

  GS_MAKE_ORDER-ORDNO = LS_2001-ORDNO.
  GS_MAKE_ORDER-POSNR = LS_2001-POSNR.
  GS_MAKE_ORDER-MATNR = LS_2001-MATNR.
  GS_MAKE_ORDER-MAKTX = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = LS_2001-MATNR ).
  GS_MAKE_ORDER-GAMNG = LS_2001-GAMNG.
  GS_MAKE_ORDER-GMEIN = LS_2001-MEINS.
  GS_MAKE_ORDER-GSTRP = LS_2001-GSTRP.
  GS_MAKE_ORDER-GLTRP = LS_2001-GLTRP.
  GS_MAKE_ORDER-INLENGTH = LS_2001-INLENGTH.
  GS_MAKE_ORDER-INFACTOR = LS_2001-INFACTOR.
  GS_MAKE_ORDER-COV_MATNR = LS_2001-ZPMAT.
  GS_MAKE_ORDER-COV_MAKTX = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = LS_2001-ZPMAT ).
  GS_MAKE_ORDER-ZZPRIORITY = LS_2001-ZZPRIORITY.

  SPLIT LS_2001-SNOTE AT CL_ABAP_CHAR_UTILITIES=>NEWLINE INTO TABLE GT_TEXT.



ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_MAIN_DATA_03
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_MAIN_DATA_03 .

  DATA : LT_GRPNR TYPE RANGE OF ZGTPPT2000-GRPNR.
  DATA : LT_SGRPNR TYPE RANGE OF ZGTPPT2011-SGRPNR.
  DATA : LT_MATNR TYPE RANGE OF MATNR.
  DATA : LT_CHK_MATNR TYPE RANGE OF MATNR.
  DATA : LT_CHK_MATNR_N TYPE RANGE OF MATNR.
  DATA : LV_CST_SEQ TYPE I.
  DATA : LV_BWD_SEQ TYPE I.
  DATA : LT_MAIN_VBELN LIKE GT_MAIN_DISP.
  DATA : LV_CHK.
  DATA : LV_MENGE01 TYPE MENGE_D.
  DATA : LV_MENGE02 TYPE MENGE_D.
  DATA : LV_MENGE03 TYPE MENGE_D.
  DATA : LV_TABIX TYPE I.
  DATA : BEGIN OF LS_EBAN_CHK,
           BANFN TYPE EBAN-BANFN,
           BNFPO TYPE EBAN-BNFPO,
         END OF LS_EBAN_CHK.
  DATA : LT_EBAN_CHK LIKE TABLE OF LS_EBAN_CHK.

  DATA : LT_AUFNR TYPE RANGE OF AUFNR.

  FIELD-SYMBOLS : <LV_CHK> TYPE ANY.
  FIELD-SYMBOLS : <LV_VALUE> TYPE ANY.

  DEFINE __SET_CHK.
    READ TABLE GT_CHK_MAINTAIN INTO GS_CHK_MAINTAIN WITH KEY REPTEXT = &1.
    IF SY-SUBRC EQ 0.
      IF <LV_CHK> IS ASSIGNED. UNASSIGN <LV_CHK>. ENDIF.
      ASSIGN COMPONENT GS_CHK_MAINTAIN-FIELDNAME OF STRUCTURE <LS_MAIN> TO <LV_CHK>.
      IF <LV_CHK> IS ASSIGNED.
        <LV_CHK> = ABAP_TRUE.
      ENDIF.
    ENDIF.
  END-OF-DEFINITION.

  DEFINE __SET_VALUE.
    READ TABLE GT_CHK_MAINTAIN INTO GS_CHK_MAINTAIN WITH KEY REPTEXT = &1.
    IF SY-SUBRC EQ 0.
      IF <LV_VALUE> IS ASSIGNED. UNASSIGN <LV_VALUE>. ENDIF.
      ASSIGN COMPONENT GS_CHK_MAINTAIN-FIELDNAME OF STRUCTURE <LS_MAIN> TO <LV_VALUE>.
      IF <LV_VALUE> IS ASSIGNED.
        <LV_VALUE> = &2.
      ENDIF.
    ENDIF.
  END-OF-DEFINITION.


  PERFORM GET_JOJANG_DATA.

* 신선공정 유/무 확인을 위한 데이터
  REFRESH LT_MATNR.
  LT_MATNR = VALUE #( FOR LW_2000 IN GT_MAIN_DISP WHERE ( MATNR IS NOT INITIAL )
                               ( SIGN = 'I' OPTION = 'EQ' LOW = LW_2000-MATNR ) ).

  SORT LT_MATNR BY LOW.
  DELETE ADJACENT DUPLICATES FROM LT_MATNR COMPARING LOW.

  SELECT *
    FROM ZGTCVMSTVAL
    INTO TABLE @DATA(LT_CVMSTVAL)
   WHERE WERKS = @P_WERKS
     AND MATNR IN @LT_MATNR.

  SORT LT_CVMSTVAL BY MATNR.
  DELETE ADJACENT DUPLICATES FROM LT_CVMSTVAL COMPARING MATNR.

  IF LT_CVMSTVAL[] IS NOT INITIAL.
    REFRESH GT_WRAPPING.

    WITH +NWS AS (
      SELECT A~MATNR AS MATNR_M,
              B~SUL_NO,
              B~REV_SEQ,
              D~MATNR_N AS MATNR,
              C~GONG_CD,
              B~GONG_SEQ
       FROM @LT_CVMSTVAL AS A
       INNER JOIN ZEDT1020 AS B ON B~SUL_NO = A~PDCADESIGNNO
                                          AND B~REV_SEQ = A~PDCADESIGNREVNO
       INNER JOIN ZEDT1010 AS C ON C~SUL_NO = B~SUL_NO
                                          AND C~REV_SEQ = B~REV_SEQ
                                          AND C~GONG_SEQ = B~GONG_SEQ
       INNER JOIN ZEDT1050 AS D ON D~SUL_NO = B~SUL_NO
                                          AND D~REV_SEQ = B~REV_SEQ
                                          AND D~GONG_SEQ = B~GONG_SEQ
      WHERE B~JACK_CD = 'NWS' )
      SELECT DISTINCT A~MATNR_M, A~SUL_NO, A~REV_SEQ, A~MATNR, A~GONG_CD, A~GONG_SEQ,
                              C~MATNR_N AS MATNR_BWD, B~GONG_SEQ AS BWD_SEQ
        FROM +NWS AS A
        INNER JOIN ZEDT1010 AS B ON  B~SUL_NO = A~SUL_NO
                                        AND B~REV_SEQ = A~REV_SEQ
                                        AND B~AFT_GONG_SEQ = A~GONG_SEQ
                                        AND B~GONG_CD = 'BWD'
        INNER JOIN ZEDT1050 AS C ON C~SUL_NO = B~SUL_NO
                                           AND C~REV_SEQ = B~REV_SEQ
                                           AND C~GONG_SEQ = B~GONG_SEQ
         INTO TABLE @GT_WRAPPING.

  ENDIF.

  SORT GT_WRAPPING BY MATNR_M.
  REFRESH LT_CHK_MATNR.
  LT_CHK_MATNR = VALUE #( FOR LW_WRAPPING IN GT_WRAPPING WHERE ( MATNR_M IS NOT INITIAL )
                                     ( SIGN = 'I' OPTION = 'EQ' LOW = LW_WRAPPING-MATNR_M ) ).

  SORT LT_CHK_MATNR BY LOW.
  DELETE ADJACENT DUPLICATES FROM LT_CHK_MATNR COMPARING LOW.

* 외장재 작업 대상건만 남기고 다른 조장 제외
  IF LT_CHK_MATNR[] IS NOT INITIAL.
    DELETE GT_MAIN_DISP WHERE MATNR NOT IN LT_CHK_MATNR.
  ENDIF.


* 판매오더정보 확인을 위해 오더 담아준다.
  REFRESH LT_MAIN_VBELN.
  LT_MAIN_VBELN = VALUE #( FOR LW_MAIN IN GT_MAIN_DISP WHERE ( GCATG = '판매오더'
                                                                                OR   GCATG = '견적'  )
                                      ( CORRESPONDING #( LW_MAIN ) ) ).

  SORT LT_MAIN_VBELN BY ORDNO POSNR.
  DELETE ADJACENT DUPLICATES FROM LT_MAIN_VBELN COMPARING ORDNO POSNR..
  IF LT_MAIN_VBELN[] IS NOT INITIAL.
    SELECT A~VBELN, A~POSNR, A~VRKME, A~KWMENG, A~CUOBJ
      FROM VBAP AS A
      INNER JOIN @LT_MAIN_VBELN AS C ON C~ORDNO = A~VBELN
                                                   AND C~POSNR = A~POSNR
      INTO TABLE @DATA(LT_VBAP).
  ENDIF.


* 신선공정 지시 유무를 위한 데이터 추출
  REFRESH LT_GRPNR.
  LT_GRPNR = VALUE #( FOR LW_2000 IN GT_MAIN_DISP WHERE ( GRPNR IS NOT INITIAL )
                               ( SIGN = 'I' OPTION = 'EQ' LOW = LW_2000-GRPNR ) ).
  SORT LT_GRPNR BY LOW.
  DELETE ADJACENT DUPLICATES FROM LT_GRPNR COMPARING LOW.

  REFRESH : GT_2010, GT_2011.
  IF LT_GRPNR[] IS NOT INITIAL.
    SELECT DISTINCT A~*
      FROM ZGTPPT2010 AS A
      INNER JOIN @GT_WRAPPING AS B ON B~MATNR = A~MATNR
                                                 AND B~GONG_CD = A~GONG_CD
     WHERE A~GRPNR IN @LT_GRPNR
        AND A~ORDTY NE 'PLN'
      INTO TABLE @GT_2010.

* 신선오더 연결정보
    SELECT DISTINCT A~*
      FROM ZGTPPT2013 AS A
      INNER JOIN ZGTPPT2011 AS B ON B~SGRPNR = A~SGRPNR
      INTO TABLE @GT_2013
     WHERE A~GRPNR IN @LT_GRPNR
        AND B~JOBTY = '2'.
  ENDIF.

* 신선오더 정보
  REFRESH LT_SGRPNR.
  LT_SGRPNR = VALUE #( FOR LW_2013 IN GT_2013 WHERE ( SGRPNR IS NOT INITIAL )
                               ( SIGN = 'I' OPTION = 'EQ' LOW = LW_2013-SGRPNR ) ).
  SORT LT_SGRPNR BY LOW.
  DELETE ADJACENT DUPLICATES FROM LT_SGRPNR COMPARING LOW.

  IF LT_SGRPNR[] IS NOT INITIAL.
    SELECT * FROM ZGTPPT2012
      INTO TABLE GT_2012
     WHERE SGRPNR IN LT_SGRPNR.

    SELECT * FROM ZGTPPT2011
      INTO TABLE GT_2011
     WHERE SGRPNR IN LT_SGRPNR.
  ENDIF.

* pr 정보 추출
  LT_EBAN_CHK = VALUE #( FOR LW_2012 IN GT_2012 WHERE ( ORDTY = 'PR' )
                                   ( BANFN = LW_2012-ORDNR BNFPO = LW_2012-POSNR+1(5) ) ).

  IF LT_EBAN_CHK IS NOT INITIAL.
    SORT LT_EBAN_CHK BY BANFN BNFPO.
    DELETE ADJACENT DUPLICATES FROM LT_EBAN_CHK COMPARING BANFN BNFPO.

    SELECT A~BANFN, A~BNFPO, A~LFDAT, A~STATU, A~MENGE, A~LIFNR, C~NAME1
      FROM EBAN AS A
      LEFT JOIN LFA1 AS C ON C~LIFNR = A~LIFNR
      FOR ALL ENTRIES IN @LT_EBAN_CHK
     WHERE A~BANFN = @LT_EBAN_CHK-BANFN
        AND A~BNFPO = @LT_EBAN_CHK-BNFPO
        AND A~LOEKZ = ''
      INTO CORRESPONDING FIELDS OF TABLE @GT_EBAN.

    SELECT B~LIFNR, A~EBELN, A~EBELP, A~BANFN, A~BNFPO, A~MENGE, C~NAME1
      FROM EKPO AS A
      INNER JOIN EKKO AS B ON B~EBELN = A~EBELN
      INNER JOIN LFA1 AS C ON C~LIFNR = B~LIFNR
      INNER JOIN @GT_EBAN AS D ON D~BANFN = A~BANFN
                                         AND D~BNFPO = A~BNFPO
      INTO CORRESPONDING FIELDS OF TABLE @GT_EKPO.

  ENDIF.

* 생산오더 정보
  LT_AUFNR = VALUE #( FOR LW_2012 IN GT_2012 WHERE ( ORDTY = 'PRD' )
                              ( SIGN = 'I' OPTION = 'EQ' LOW = LW_2012-ORDNR ) ).
  IF LT_AUFNR[] IS NOT INITIAL.
    SORT LT_AUFNR BY LOW.
    DELETE ADJACENT DUPLICATES FROM LT_AUFNR COMPARING LOW.
    SELECT * FROM ZGTCVORDSYVAL
      INTO TABLE GT_ORDSYVAL
     WHERE WERKS = P_WERKS
       AND AUFNR IN LT_AUFNR.
  ENDIF.


* 생산오더로 조장구성표 적용되었을 경우 차후에 인터널테이블 구성
  SORT GT_MAIN_DISP BY GRPNR.

  DATA : LV_ORDNO_C(12).
  DATA : LV_POSNR_C(6).

  LOOP AT GT_MAIN_DISP ASSIGNING FIELD-SYMBOL(<LS_MAIN>).
    LV_TABIX = SY-TABIX.

*  오더번호
    LV_ORDNO_C = <LS_MAIN>-ORDNO.
    LV_POSNR_C = <LS_MAIN>-POSNR.
    __ALPHA_OUT : LV_ORDNO_C, LV_POSNR_C.
    CONCATENATE LV_ORDNO_C LV_POSNR_C
                  INTO <LS_MAIN>-ORDNO_C SEPARATED BY '/'.

* 거래처
    SELECT SINGLE NAME1 FROM KNA1
      INTO <LS_MAIN>-NAME1
     WHERE KUNNR = <LS_MAIN>-KUNNR.
** 제품내역
*    <LS_MAIN>-MAKTX = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = <LS_MAIN>-MATNR  ).

    IF <LS_MAIN>-GCATG NE '생산오더'.
      READ TABLE LT_VBAP INTO DATA(LS_VBAP) WITH KEY VBELN = <LS_MAIN>-ORDNO
                                                                    POSNR = <LS_MAIN>-POSNR.
      IF SY-SUBRC EQ 0.
** 조장, 조장수, 판매조장
        ZGTPP_CL_COMMON=>GET_CHA_MILLCA(
          EXPORTING
            IV_CUOBJ      = LS_VBAP-CUOBJ                 " 구성
          IMPORTING
            EV_SO_INDLEN = <LS_MAIN>-SO_INLENGTH ).
        <LS_MAIN>-SO_WMENG = LS_VBAP-KWMENG.
        <LS_MAIN>-SO_VRKME = LS_VBAP-VRKME.
      ENDIF.

    ENDIF.

*    CHECK box
* 신선작업
    __SET_CHK '작업대상'.

    CLEAR : LV_MENGE01, LV_MENGE02, LV_MENGE03, LV_CHK.

    PERFORM CHK_GONG_WAR_STATUS USING <LS_MAIN> CHANGING LV_MENGE01 LV_MENGE02 LV_MENGE03 LV_CHK .

* 오더생성
    IF LV_MENGE02 > 0.
      __SET_CHK '오더생성'.
    ENDIF.


* 외장오더수
    __SET_VALUE '외장오더수' LV_MENGE01.

* 외장재 작업지시
    __SET_VALUE '외장재작업지시' LV_MENGE02.

* 조장확정
    IF LV_CHK = ABAP_TRUE.
      __SET_CHK '조장확정'.
    ENDIF.

    IF P_CHECK IS INITIAL AND LV_MENGE02 NE 0.
      IF LV_MENGE02 = LV_MENGE03.
        DELETE TABLE GT_MAIN_DISP FROM <LS_MAIN>.
      ENDIF.

    ENDIF.

  ENDLOOP.


  IF P_CHECK2 IS INITIAL.
    READ TABLE GT_CHK_MAINTAIN INTO GS_CHK_MAINTAIN WITH KEY REPTEXT = '조장확정'.
    DATA : LV_STRING TYPE STRING.
    LV_STRING = |{ GS_CHK_MAINTAIN-FIELDNAME } = ABAP_FALSE |.
    DELETE GT_MAIN_DISP WHERE (LV_STRING).
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_button
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_BUTTON .

  CLEAR GV_DYNTXT.
  GV_DYNTXT-ICON_ID = ICON_TABLE_SETTINGS.
  GV_DYNTXT-TEXT = '고정기준 권취'.
  GV_DYNTXT-QUICKINFO = '고정기준 권취'.
  SSCRFIELDS-FUNCTXT_01 = GV_DYNTXT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form call_maintain_view
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
      LV_TABNAME = 'ZGTPPT2260'.
      LV_TITLE = '고정기준 권취'.

  ENDCASE.

  CALL FUNCTION 'ZGTPP_UTILL_VIEW'
    DESTINATION 'NONE'
    EXPORTING
      IV_TABNAME = LV_TABNAME
      IV_TITLE   = LV_TITLE.

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

  GO_GRID_0104->SET_SELECTED_COLUMNS(
    IT_COL_TABLE             =  LT_COL_TABLE                " Selected Columns
  ).

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

  LOOP AT GT_FIELDCAT_0104 INTO DATA(LS_FCAT) WHERE FIELDNAME CP 'FIELDINFOR_*'.
    APPEND INITIAL LINE TO LT_COL_TABLE ASSIGNING FIELD-SYMBOL(<LS_COL_TABLE>).
    <LS_COL_TABLE>-FIELDNAME = LS_FCAT-FIELDNAME.
  ENDLOOP.

  GO_GRID_0104->SET_SELECTED_COLUMNS(
    IT_COL_TABLE             =  LT_COL_TABLE                " Selected Columns
  ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CHECK_BOX_ALL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM SET_CHECK_BOX_ALL  USING  P_VALUE.


  LOOP AT GT_MAIN_DISP ASSIGNING FIELD-SYMBOL(<LS_DISP_201>).
    <LS_DISP_201>-CHECK = P_VALUE.
  ENDLOOP.

  PERFORM REFRESH_GRID USING GO_GRID_0100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_AND_LOCK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM CHECK_AND_LOCK  CHANGING PV_CHK_ERR.

  DATA : LT_ENQ TYPE TABLE OF SEQG3.

  CALL FUNCTION 'ENQUEUE_EZGT_ZGTPPR2150'
    EXPORTING
      GRPNR          = GV_GRPNR
    EXCEPTIONS
      FOREIGN_LOCK   = 1
      SYSTEM_FAILURE = 2
      OTHERS         = 3.
  IF SY-SUBRC <> 0.
    PV_CHK_ERR = ABAP_TRUE.

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
*& Form CHK_GONG_WAR_STATUS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LS_MAIN>_GRPNR
*&      <-- LV_MENGE01
*&      <-- LV_MENGE02
*&      <-- LV_CHK
*&---------------------------------------------------------------------*
FORM CHK_GONG_WAR_STATUS  USING    PS_MAIN LIKE GS_MAIN_DISP
                          CHANGING PV_MENGE01 TYPE MENGE_D
                                   PV_MENGE02  TYPE MENGE_D
                                   PV_MENGE03  TYPE MENGE_D
                                   PV_CHK.

  DATA : LV_PLN_CHK.
  DATA : LV_EXIST_CHK.
  DATA : LT_AUFNR TYPE RANGE OF AUFNR.
  DATA : LT_EBELN TYPE RANGE OF EBELN.
  DATA : LT_2010 TYPE TABLE OF ZGTPPT2010.
  DATA : LV_COUNT TYPE I.
  DATA : LT_MAIN LIKE TABLE OF GS_MAIN_DISP_1100.
  DATA : LV_CHK_USE.

  LV_EXIST_CHK = ABAP_TRUE.

  READ TABLE GT_WRAPPING INTO DATA(LS_WRAPPING) WITH KEY MATNR_M = PS_MAIN-MATNR.

  LT_2010 = VALUE #( FOR LW_2010 IN GT_2010 WHERE ( GRPNR = PS_MAIN-GRPNR
                                                                    AND    GONG_CD = LS_WRAPPING-GONG_CD
                                                                    AND    MATNR = LS_WRAPPING-MATNR )
                            ( CORRESPONDING #( LW_2010 ) ) ).

  LV_COUNT = LINES( LT_2010 ).
  LOOP AT LT_2010 INTO DATA(LS_2010).
    CLEAR LV_EXIST_CHK.
    IF LS_2010-ORDTY = 'PLN'.
      LV_PLN_CHK = ABAP_TRUE.
      EXIT.
    ENDIF.
  ENDLOOP.

* 조장여부 WAR 공정내 PLN오더가 존재시 조장구성 안된것으로 판단
* WAR 미존재시 미확정
  IF LV_EXIST_CHK NE ABAP_TRUE AND LV_PLN_CHK IS INITIAL.
    PV_CHK = ABAP_TRUE.
    PV_MENGE01 = LV_COUNT.
  ELSE.
    PV_MENGE01 = LV_COUNT.
    RETURN.
  ENDIF.
* get bwd infor
  READ TABLE GT_2013 INTO DATA(LS_2013) WITH KEY GRPNR = PS_MAIN-GRPNR.
  IF SY-SUBRC EQ 0.
    READ TABLE GT_2011 INTO DATA(LS_2011) WITH KEY SGRPNR = LS_2013-SGRPNR
                                                                   JOBTY = '2'
                                                                    MATNR = PS_MAIN-MATNR.
    IF SY-SUBRC EQ 0.
      LOOP AT GT_2012 INTO DATA(LS_2012) WHERE SGRPNR = LS_2011-SGRPNR.
        ADD 1 TO PV_MENGE02.
      ENDLOOP.

      READ TABLE GT_2012 INTO LS_2012 WITH KEY SGRPNR = LS_2011-SGRPNR.
      PV_MENGE03 = LS_2012-ZTWSEQ.

    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_EXIST_TABLE_BWD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PS_2010
*&      <-- <LS_MAIN_CHK>_ZPITCHR
*&      <-- PV_MENGE01
*&---------------------------------------------------------------------*
FORM CHECK_EXIST_TABLE_BWD  USING    PS_2010 TYPE ZGTPPT2010
                                          PV_MATNR TYPE MATNR
                            CHANGING PV_ZPITCHR TYPE ZGTPPT2013-ZPITCHR
                                     PV_ADLENGTH TYPE ZGTPPT2013-ADLENGTH
                                     PV_SGRPNR   TYPE ZGTPPT2013-SGRPNR
                                     PV_MENGE02 TYPE MENGE_D
                                     PV_EXIST.

  DATA : LV_CHK_CONFIRM.

  LOOP AT GT_2013 INTO DATA(LS_2013) WHERE GRPNR = PS_2010-GRPNR
                                                       AND DMORD = PS_2010-ORDNR
                                                       AND DMLINE = PS_2010-POSNR
                                                       AND DMORDTY = PS_2010-ORDTY.
    READ TABLE GT_2011 INTO DATA(LS_2011) WITH KEY SGRPNR = LS_2013-SGRPNR
                                                                    JOBTY = '2'
                                                                    MATNR = PV_MATNR.
    IF SY-SUBRC EQ 0.
      PV_ZPITCHR = LS_2013-ZPITCHR.
      PV_ADLENGTH = LS_2013-ADLENGTH.
      PV_SGRPNR = LS_2011-SGRPNR.
      PERFORM CHK_CONFIRM_2012 USING LS_2011-SGRPNR CHANGING LV_CHK_CONFIRM.
      IF LV_CHK_CONFIRM = ABAP_TRUE.
        ADD 1 TO PV_MENGE02.
      ENDIF.
      PV_EXIST = ABAP_TRUE.
      EXIT.
    ENDIF.
  ENDLOOP.

  IF PV_EXIST IS INITIAL.
    PV_ZPITCHR = '5.9'.
    PV_ADLENGTH = 70.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_CONFIRM_2012
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_2011_SGRPNR
*&      <-- LV_CHK_CONFIRM
*&---------------------------------------------------------------------*
FORM CHK_CONFIRM_2012  USING    PV_SGRPNR TYPE ZGTPPT2011-SGRPNR
                       CHANGING PV_CHK_CONFIRM.



  LOOP AT GT_2012 INTO DATA(LS_2012) WHERE SGRPNR = PV_SGRPNR.
    CASE LS_2012-ORDTY .
      WHEN 'PR'.
        READ TABLE GT_EBAN INTO DATA(LS_EBAN) WITH KEY BANFN = LS_2012-ORDNR
                                                                       BNFPO = LS_2012-POSNR+1(5).
        IF SY-SUBRC EQ 0.
*          READ TABLE GT_EKPO TRANSPORTING NO FIELDS WITH KEY BANFN = LS_EBAN-BANFN
*                                                                                BNFPO = LS_EBAN-BNFPO.
*          IF SY-SUBRC EQ 0.
          PV_CHK_CONFIRM = ABAP_TRUE.
*          ELSE.
*            CLEAR PV_CHK_CONFIRM.
*            EXIT.
*          ENDIF.
        ELSE.
          CLEAR PV_CHK_CONFIRM.
          EXIT.
        ENDIF.
      WHEN 'PRD'.
        READ TABLE GT_ORDSYVAL INTO DATA(LS_ORDSYVAL) WITH KEY AUFNR = LS_2012-ORDNR.
        IF SY-SUBRC EQ 0.
          IF LS_ORDSYVAL-REL = ABAP_TRUE.
            PV_CHK_CONFIRM = ABAP_TRUE.
          ELSE.
            CLEAR PV_CHK_CONFIRM.
            EXIT.
          ENDIF.
        ELSE.
          CLEAR PV_CHK_CONFIRM.
          EXIT.
        ENDIF.
    ENDCASE.

  ENDLOOP.




ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_WORKING_WAR_SINSUN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_WORKING_WAR_SINSUN .

  DATA : LV_CHK_ERR.

  PERFORM CHK_PROC_WORKING_WAR CHANGING LV_CHK_ERR.

  IF LV_CHK_ERR IS NOT INITIAL.
    RETURN.
  ENDIF.
*  입력수량부분 초기화
  REFRESH GT_1101_MENGE.

  PERFORM SET_ITAB_1100.
  PERFORM SET_ITAB_1101.
  PERFORM SET_ITAB_1102.

  IF <GT_MAIN_DISP_1103> IS ASSIGNED.
    REFRESH <GT_MAIN_DISP_1103>.
  ENDIF.
  PERFORM SET_ITAB_1103.

  CALL SCREEN '1100'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_PROC_WORKING_WAR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM CHK_PROC_WORKING_WAR  CHANGING PV_CHK_ERR.

  IF NOT LINE_EXISTS( GT_MAIN_DISP[ CHECK = ABAP_TRUE ] ).
    MESSAGE S005 DISPLAY LIKE 'E' WITH '선택된 조장이 없습니다.'(e03).
    PV_CHK_ERR = ABAP_TRUE.
    RETURN.
  ENDIF.

  LOOP AT GT_MAIN_DISP INTO GS_MAIN_DISP WHERE CHECK = ABAP_TRUE.

* 조장구성표내 war공정 존재해야함
    READ TABLE GT_CHK_MAINTAIN INTO GS_CHK_MAINTAIN WITH KEY REPTEXT = '조장확정'.
    IF SY-SUBRC EQ 0.
      IF GS_MAIN_DISP-(GS_CHK_MAINTAIN-FIELDNAME) IS INITIAL.
        MESSAGE S005 DISPLAY LIKE 'E' WITH '외장재 작업지시는 조장 구성이 먼저 실행되어야 합니다. 선택 대상을 확인해 주세요.'(e18).
        PV_CHK_ERR = ABAP_TRUE.
        RETURN.
      ENDIF.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ITAB_1100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_ITAB_1100 .

  REFRESH GT_MAIN_DISP_1100.
  LOOP AT GT_MAIN_DISP INTO DATA(LS_MAIN) WHERE CHECK = ABAP_TRUE.
    CLEAR GS_MAIN_DISP_1100.
    MOVE-CORRESPONDING LS_MAIN TO GS_MAIN_DISP_1100.
    APPEND GS_MAIN_DISP_1100 TO GT_MAIN_DISP_1100.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ITAB_1101
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_ITAB_1101 .

  DATA : LT_GRPNR TYPE RANGE OF ZGTPPT2010-GRPNR.
  DATA : LV_ORDNR_C(12).
  DATA : LV_POSNR_C(6).
  DATA : LT_MATNR TYPE RANGE OF MATNR.
  DATA : LV_LENGTH TYPE MENGE_D.

  LT_GRPNR = VALUE #( FOR LW_MAIN IN GT_MAIN_DISP_1100 WHERE ( GRPNR IS NOT INITIAL )
                              ( SIGN = 'I' OPTION = 'EQ' LOW = LW_MAIN-GRPNR ) ).


  REFRESH GT_MAIN_DISP_1101.
  IF LT_GRPNR IS NOT INITIAL.
    SORT LT_GRPNR BY LOW.
    DELETE ADJACENT DUPLICATES FROM LT_GRPNR COMPARING LOW.

    LOOP AT GT_2010 INTO DATA(LS_2010) WHERE GRPNR IN LT_GRPNR AND ORDTY = 'PRD'.
      CLEAR GS_MAIN_DISP_1101.
      CLEAR : LV_ORDNR_C, LV_POSNR_C.
      GS_MAIN_DISP_1101-ORDNR = LV_ORDNR_C = LS_2010-ORDNR.
      GS_MAIN_DISP_1101-POSNR = LV_POSNR_C = LS_2010-POSNR.
      __ALPHA_OUT : LV_ORDNR_C, LV_POSNR_C.
      CONCATENATE LV_ORDNR_C LV_POSNR_C INTO GS_MAIN_DISP_1101-ORDNO_C SEPARATED BY '/'.
* 자재
      GS_MAIN_DISP_1101-MATNR = LS_2010-MATNR.
      GS_MAIN_DISP_1101-MAKTX = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = LS_2010-MATNR ).

* 외장조장(기본)
      GS_MAIN_DISP_1101-INLENGTH02 = ( LS_2010-INLENGTH + LS_2010-QLENGTH + LS_2010-CLENGTH +
                                                      LS_2010-SLENGTH + LS_2010-ELENGTH + LS_2010-ADLENGTH )
                                                    * LS_2010-INFACTOR.
* 외장조장(여장) = 이전공정의 여장 이전공정 자재 resb 수량(Max) - 기본외장조장
      SELECT B~*
       FROM AFKO AS A
       INNER JOIN RESB AS B ON B~RSNUM = A~RSNUM
       INNER JOIN MARA AS C ON C~MATNR = B~MATNR
       INNER JOIN MARC AS D ON D~MATNR = B~MATNR
       INTO TABLE @DATA(LT_RESB)
      WHERE A~AUFNR = @LS_2010-ORDNR
        AND B~STLTY = 'M' " BOM 대상
        AND B~DUMPS = '' " 가상품목이 아닌경우
        AND C~MTART = 'MCHF'
        AND D~WERKS = @P_WERKS
        AND D~BESKZ IN ('E', 'X').

      REFRESH LT_MATNR.
      LT_MATNR = VALUE #( FOR LW_RESB IN LT_RESB WHERE ( MATNR IS NOT INITIAL )
                        ( SIGN = 'I' OPTION = 'EQ' LOW = LW_RESB-MATNR ) ).
      SORT LT_MATNR BY LOW.
      DELETE ADJACENT DUPLICATES FROM LT_MATNR.

      IF LT_MATNR[] IS NOT INITIAL.
        SELECT * FROM ZGTCVMSTVAL
          INTO TABLE @DATA(LT_CVMVAL)
         WHERE WERKS = @P_WERKS
            AND MATNR IN @LT_MATNR
            AND PDCAPROCCODE NE 'BWD'.
      ENDIF.

      CLEAR LV_LENGTH.
      LOOP AT LT_RESB INTO DATA(LS_RESB).
        READ TABLE LT_CVMVAL TRANSPORTING NO FIELDS WITH KEY MATNR = LS_RESB-MATNR.
        IF SY-SUBRC EQ 0.
          IF LV_LENGTH < LS_RESB-BDMNG.
            LV_LENGTH = LS_RESB-BDMNG.
          ENDIF.

        ENDIF.
      ENDLOOP.

* 복조장 여부 확인
      SELECT DISTINCT B~AUFNR, C~POSNR, B~GAMNG
         FROM AUFK AS A
         INNER JOIN AFKO AS B
                                ON B~AUFNR = A~AUFNR
        INNER JOIN AFPO AS C ON C~AUFNR = A~AUFNR
           INTO TABLE @DATA(LT_AFPO)
        WHERE A~AUFNR = @LS_2010-ORDNR
            AND A~FLG_MLTPS = 'X'. " 복수품목
      IF SY-SUBRC EQ 0.
        SORT LT_AFPO BY POSNR.
        READ TABLE LT_AFPO INTO DATA(LS_AFPO) INDEX 1 .
        IF LS_2010-POSNR+2(4) = LS_AFPO-POSNR.
          GS_MAIN_DISP_1101-INLENGTH03 = LV_LENGTH - LS_AFPO-GAMNG.
        ELSE.
          GS_MAIN_DISP_1101-INLENGTH03 = 0.
        ENDIF.
      ELSE.
        GS_MAIN_DISP_1101-INLENGTH03 = LV_LENGTH - GS_MAIN_DISP_1101-INLENGTH02.
      ENDIF.

* 외장조장(합계)
      GS_MAIN_DISP_1101-INLENGTH01 = GS_MAIN_DISP_1101-INLENGTH02 + GS_MAIN_DISP_1101-INLENGTH03.

* 단위
      GS_MAIN_DISP_1101-MEINS = 'M'.
* 조장수
      GS_MAIN_DISP_1101-INFACTOR = LS_2010-INFACTOR.
* 공정연번
      GS_MAIN_DISP_1101-GONG_SEQ = LS_2010-GONG_SEQ.

      APPEND GS_MAIN_DISP_1101 TO GT_MAIN_DISP_1101.
    ENDLOOP.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_1100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GRID_1100 .

  CREATE OBJECT GO_DOCKING_1100
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

  CREATE OBJECT GO_SPLITTER_1100
    EXPORTING
      PARENT  = GO_DOCKING_1100
      ROWS    = 3
      COLUMNS = 1.

  GO_SPLITTER_1100->SET_ROW_HEIGHT(
    EXPORTING
      ID                =  1                " Row ID
      HEIGHT            =  30    ).            " Height

  GO_SPLITTER_1100->SET_ROW_HEIGHT(
      EXPORTING
        ID                =  2                " Row ID
        HEIGHT            =  30    ).            " Height

  CALL METHOD GO_SPLITTER_1100->GET_CONTAINER
    EXPORTING
      ROW       = 1
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_CONTAIN_1100_TOP.

  CALL METHOD GO_SPLITTER_1100->GET_CONTAINER
    EXPORTING
      ROW       = 2
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_CONTAIN_1102.

  CALL METHOD GO_SPLITTER_1100->GET_CONTAINER
    EXPORTING
      ROW       = 3
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_CONTAIN_1103.


  CREATE OBJECT GO_SPLITTER_1100_TOP
    EXPORTING
      PARENT  = GO_CONTAIN_1100_TOP
      ROWS    = 1
      COLUMNS = 2.

  GO_SPLITTER_1100_TOP->SET_COLUMN_WIDTH(
    EXPORTING
      ID                =  1                " Column ID
      WIDTH             = 50                 " NPlWidth
    EXCEPTIONS
      CNTL_ERROR        = 1                " See CL_GUI_CONTROL
      CNTL_SYSTEM_ERROR = 2                " See CL_GUI_CONTROL
      OTHERS            = 3
  ).

  CALL METHOD GO_SPLITTER_1100_TOP->GET_CONTAINER
    EXPORTING
      ROW       = 1
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_CONTAIN_1100.

  CALL METHOD GO_SPLITTER_1100_TOP->GET_CONTAINER
    EXPORTING
      ROW       = 1
      COLUMN    = 2
    RECEIVING
      CONTAINER = GO_CONTAIN_1101.


  CREATE OBJECT GO_GRID_1100
    EXPORTING
      I_PARENT      = GO_CONTAIN_1100
      I_APPL_EVENTS = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_1101
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GRID_1101 .

  CREATE OBJECT GO_GRID_1101
    EXPORTING
      I_PARENT      = GO_CONTAIN_1101
      I_APPL_EVENTS = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_1100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_1100 .

  CLEAR GS_LAYOUT_1100.
  GS_LAYOUT_1100-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYOUT_1100-NO_ROWMARK   = 'X'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_GRID_1100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_1100 .

  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR2150TOP'
      I_INTERNAL_TABNAME     = 'GS_MAIN_DISP_1100'
    CHANGING
      CT_FIELDCAT            = LT_FCAT_SLIS
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.

  REFRESH GT_FIELDCAT_1100.

*-- lt_fieldcat의 구조체를 pt_fcat의 구조체로 변경
  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT_SLIS
    IMPORTING
      ET_FIELDCAT_LVC = GT_FIELDCAT_1100[]
    TABLES
      IT_DATA         = GT_MAIN_DISP_1100
    EXCEPTIONS
      OTHERS          = 1.

  READ TABLE GT_FIELDCAT_1100 ASSIGNING FIELD-SYMBOL(<LS_FCAT>) WITH KEY FIELDNAME = 'ORDNO_C'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_1100 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'ORDNO_C'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '오더번호'(f17).
    <LS_FCAT>-COL_POS = 4.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '30'.
    <LS_FCAT>-JUST = 'C'.
    <LS_FCAT>-KEY = ABAP_TRUE.
  ENDIF.


  LOOP AT GT_FIELDCAT_1100 ASSIGNING <LS_FCAT>.
    CLEAR <LS_FCAT>-KEY.
    CASE   <LS_FCAT>-FIELDNAME.
      WHEN 'GRPNR' OR 'ORDNO' OR 'POSNR'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'GCATG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '범주'(F03).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-KEY = ABAP_TRUE.
      WHEN 'ZZYUSCD'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '영업소'(F04).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-KEY = ABAP_TRUE.
      WHEN 'ORDNO_C'.
        <LS_FCAT>-KEY = ABAP_TRUE.
      WHEN 'MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '제품'(F05).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-KEY = ABAP_TRUE.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '제품내역'(F06).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'INLENGTH'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '조장'(F10).
        <LS_FCAT>-JUST = 'R'.
      WHEN 'MEINS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '단위'(F11).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'INFACTOR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '조장수'(F12).
        <LS_FCAT>-JUST = 'R'.
    ENDCASE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_OF_TOOLBAR_GRID_1100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EXCLUDE_OF_TOOLBAR_GRID_1100 .

  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON TABLES GT_EXCLUDE_1100
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
*& Form SET_SORTTAB_GRID_1100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_SORTTAB_GRID_1100 .

  REFRESH GT_SORT_1100.

  PERFORM SET_SORT_TAB TABLES GT_SORT_1100
                            USING : 1 'GRPNR'  'X' '' 'X',
                                       2 'ORDNO_C'  'X' '' ''.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SORTTAB_GRID_1101
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_SORTTAB_GRID_1101 .

  REFRESH GT_SORT_1101.

  PERFORM SET_SORT_TAB TABLES GT_SORT_1101
                            USING : 1 'MATNR'  'X' '' 'X',
                                       2 'ORDNO_C' 'X' '' ''.
  .

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_GRID_1100_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_GRID_1100_DISPLAY .

  CALL METHOD GO_GRID_1100->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT_1100
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_1100
    CHANGING
      IT_OUTTAB            = GT_MAIN_DISP_1100
      IT_SORT              = GT_SORT_1100
      IT_FIELDCATALOG      = GT_FIELDCAT_1100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_1101
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_1101 .

  CLEAR GS_LAYOUT_1101.
  GS_LAYOUT_1101-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYOUT_1101-SEL_MODE = 'D'.
  GS_LAYOUT_1101-NO_ROWMARK   = 'X'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_GRID_1101
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_1101 .

  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR2150TOP'
      I_INTERNAL_TABNAME     = 'GS_MAIN_DISP_1101'
    CHANGING
      CT_FIELDCAT            = LT_FCAT_SLIS
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.

  REFRESH GT_FIELDCAT_1101.

*-- lt_fieldcat의 구조체를 pt_fcat의 구조체로 변경
  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT_SLIS
    IMPORTING
      ET_FIELDCAT_LVC = GT_FIELDCAT_1101[]
    TABLES
      IT_DATA         = GT_MAIN_DISP_1101
    EXCEPTIONS
      OTHERS          = 1.

  READ TABLE GT_FIELDCAT_1101 ASSIGNING FIELD-SYMBOL(<LS_FCAT>) WITH KEY FIELDNAME = 'ORDNO_C'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_1101 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'ORDNO_C'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '외장오더'(f55).
    <LS_FCAT>-COL_POS = 1.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '30'.
    <LS_FCAT>-JUST = 'C'.
  ENDIF.

  LOOP AT GT_FIELDCAT_1101 ASSIGNING <LS_FCAT>.
    CLEAR <LS_FCAT>-KEY.
    CASE   <LS_FCAT>-FIELDNAME.
      WHEN 'ORDNR' OR 'POSNR' .
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'ORDNO_C'.
        <LS_FCAT>-KEY = ABAP_TRUE.
      WHEN 'MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '외장반제품'(f85).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-KEY = ABAP_TRUE.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '반제품내역'(f86).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'INLENGTH01'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '외장조장(합계)'(f87).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-DO_SUM = ABAP_TRUE.
      WHEN 'INLENGTH02'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '외장조장(기본)'(f88).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-DO_SUM = ABAP_TRUE.
      WHEN 'INLENGTH03'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '외장조장(여장)'(f89).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-DO_SUM = ABAP_TRUE.
      WHEN 'MEINS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '단위'(F11).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'INFACTOR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '조장수'(F12).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-DECIMALS_O = '0'.
      WHEN 'GONG_SEQ'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '공정연번'(F90).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
    ENDCASE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_OF_TOOLBAR_GRID_1101
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EXCLUDE_OF_TOOLBAR_GRID_1101 .

  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON TABLES GT_EXCLUDE_1101
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
*& Form CALL_GRID_1101_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_GRID_1101_DISPLAY .

  CALL METHOD GO_GRID_1101->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT_1101
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_1101
    CHANGING
      IT_OUTTAB            = GT_MAIN_DISP_1101
      IT_SORT              = GT_SORT_1101
      IT_FIELDCATALOG      = GT_FIELDCAT_1101.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_WORKING_GAGONG_SINSUN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_WORKING_GAGONG_SINSUN .

  DATA : LV_CHK_ERR.

  PERFORM CHK_PROC_WORKING_SINSUN CHANGING LV_CHK_ERR.

  IF LV_CHK_ERR IS NOT INITIAL.
    RETURN.
  ENDIF.

  CLEAR GS_HEADER_400.
  CLEAR GV_ZTWSEQ.

  PERFORM SET_ITAB_101.
* 연선정보
  PERFORM SET_ITAB_402.

  IF GV_CHK_1130 IS NOT INITIAL.
    RETURN.
  ENDIF.

* 신선정보
  PERFORM SET_ITAB_403.
* 신선작업지시
  IF <GT_MAIN_DISP_404> IS ASSIGNED.
    REFRESH <GT_MAIN_DISP_404>.
  ENDIF.

  PERFORM SET_ITAB_404.

  PERFORM CHECK_AND_LOCK CHANGING LV_CHK_ERR.

  IF LV_CHK_ERR IS NOT INITIAL.
    RETURN.
  ENDIF.

  CALL SCREEN '0400'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ITAB_402
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_ITAB_402 .

  DATA : LT_2010 TYPE TABLE OF ZGTPPT2010.
  DATA : LT_CHK_MATNR TYPE RANGE OF MATNR.
  DATA : LV_ORDNR_C(12).
  DATA : LV_POSNR_C(6).
  DATA : LT_EXCEPT_JAEJIL TYPE RANGE OF CHAR20.
  DATA : LS_EXCEPT_JAEJIL LIKE LINE OF LT_EXCEPT_JAEJIL.

  DEFINE __EXCEPT_JAEJIL.
    CLEAR LS_EXCEPT_JAEJIL.
    LS_EXCEPT_JAEJIL-SIGN = 'I'.
    LS_EXCEPT_JAEJIL-OPTION = 'EQ'.
    LS_EXCEPT_JAEJIL-LOW = &1.
    APPEND LS_EXCEPT_JAEJIL TO LT_EXCEPT_JAEJIL.
  END-OF-DEFINITION.

* 선택에서 제외되는 재질 등록
  __EXCEPT_JAEJIL : 'AW', 'OP-UNIT', 'EAW', 'CC'.

  READ TABLE GT_MAIN_DISP INTO GS_MAIN_DISP WITH KEY CHECK = ABAP_TRUE.

  LT_2010 = VALUE #( FOR LW_2010 IN GT_2010 WHERE ( GRPNR = GS_MAIN_DISP-GRPNR )
                            ( CORRESPONDING #( LW_2010 ) ) ).

  LT_CHK_MATNR = VALUE #( FOR LW_2010 IN LT_2010 WHERE ( MATNR IS NOT INITIAL )
                            ( SIGN = 'I' OPTION = 'EQ' LOW = LW_2010-MATNR ) ).

  SORT LT_CHK_MATNR BY LOW.
  DELETE ADJACENT DUPLICATES FROM LT_CHK_MATNR COMPARING LOW.

  SELECT SINGLE *
    FROM ZGTCVMSTVAL
   WHERE WERKS = @P_WERKS
     AND MATNR = @GS_MAIN_DISP-MATNR
    INTO @DATA(LS_CVMSTVAL).

  SELECT *
    FROM ZGTCVMSTVAL
   WHERE WERKS = @P_WERKS
     AND MATNR IN @LT_CHK_MATNR
    INTO TABLE @DATA(LT_CVMSTVAL).

  REFRESH  GT_1130.
  SELECT * FROM ZEDT1130
    INTO TABLE GT_1130
   WHERE SUL_NO = LS_CVMSTVAL-PDCADESIGNNO
      AND REV_SEQ = LS_CVMSTVAL-PDCADESIGNREVNO.

  CLEAR GV_CHK_1130.
  IF GT_1130[] IS INITIAL.
    MESSAGE S006 DISPLAY LIKE 'E' WITH '가공선 층별 소선정보를 확인 할 수 없습니다.'.
    GV_CHK_1130 = ABAP_TRUE.
    RETURN.
  ENDIF.

  WITH +SULNO AS ( SELECT
              SUL_NO,
              REV_SEQ,
              GONG_CD,
              GONG_SEQ,
              BESKZ
      FROM ZEDT1010
     WHERE SUL_NO = @LS_CVMSTVAL-PDCADESIGNNO
       AND REV_SEQ = @LS_CVMSTVAL-PDCADESIGNREVNO
       AND GONG_CD = 'CST' )
   SELECT C~GONG_CD, C~GONG_SEQ, C~BESKZ,
           D~GONG_CD AS PRE_GONG_CD,
           D~GONG_SEQ AS PRE_GONG_SEQ
        FROM +SULNO AS C
        INNER JOIN ZEDT1010 AS D ON D~SUL_NO = C~SUL_NO
                                           AND D~REV_SEQ = C~REV_SEQ
                                           AND D~AFT_GONG_SEQ = C~GONG_SEQ
        WHERE D~GONG_CD IN ( 'BWD', 'CNF' )
        INTO TABLE @DATA(LT_TEMP).


  REFRESH GT_MAIN_DISP_402.
  REFRESH GT_COLLECT_ORDNR.
  LOOP AT LT_2010 INTO DATA(LS_2010).
    CLEAR GS_MAIN_DISP_402.
* 소선코드
    READ TABLE LT_TEMP INTO DATA(LS_TEMP) WITH KEY GONG_SEQ = LS_2010-GONG_SEQ.
    IF SY-SUBRC EQ 0.
      GS_MAIN_DISP_402-BESKZ = LS_TEMP-BESKZ.
      CASE GS_MAIN_DISP_402-BESKZ.
        WHEN 'EP'.
          GS_MAIN_DISP_402-BESKZ_T = '외주'.
        WHEN OTHERS.
          READ TABLE LT_CVMSTVAL INTO DATA(LS_JAJAC) WITH KEY MATNR = LS_2010-MATNR.
          IF SY-SUBRC EQ 0 AND LS_JAJAC-BESKZ = 'F' AND LS_JAJAC-SOBSL = ''.
            GS_MAIN_DISP_402-BESKZ_T = '외주'.
          ELSE.
            GS_MAIN_DISP_402-BESKZ_T = '자작'.
          ENDIF.

      ENDCASE.

      READ TABLE GT_1130 INTO DATA(LS_1130) WITH KEY GONG_SEQ = LS_TEMP-PRE_GONG_SEQ.
      IF SY-SUBRC EQ 0.
        GS_MAIN_DISP_402-JAEJIL = LS_1130-JAEJIL.
      ENDIF.

      IF GS_MAIN_DISP_402-JAEJIL IS INITIAL.
        READ TABLE LT_CVMSTVAL INTO DATA(LS_JAEJIL) WITH KEY MATNR = LS_2010-MATNR.
        IF SY-SUBRC EQ 0.
          GS_MAIN_DISP_402-JAEJIL = LS_JAEJIL-PDCACONDMAT.
        ENDIF.
        IF GS_MAIN_DISP_402-JAEJIL IS INITIAL.
          LOOP AT GT_1130 INTO LS_1130 WHERE JAEJIL NOT IN LT_EXCEPT_JAEJIL.
            GS_MAIN_DISP_402-JAEJIL = LS_1130-JAEJIL.
            EXIT.
          ENDLOOP.
        ENDIF.
      ENDIF.
    ENDIF.

*  오더번호
    LV_ORDNR_C = GS_MAIN_DISP_402-ORDNR = LS_2010-ORDNR.
    LV_POSNR_C = GS_MAIN_DISP_402-POSNR = LS_2010-POSNR.
    __ALPHA_OUT : LV_ORDNR_C, LV_POSNR_C.
    CONCATENATE LV_ORDNR_C LV_POSNR_C
                  INTO GS_MAIN_DISP_402-ORDNO_C SEPARATED BY '/'.

* 자재
    GS_MAIN_DISP_402-MATNR = LS_2010-MATNR.
    GS_MAIN_DISP_402-MAKTX = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = LS_2010-MATNR ).

* 연선조장(기본)
    GS_MAIN_DISP_402-INLENGTH03 = LS_2010-INLENGTH * LS_2010-INFACTOR.
* 연선조장(여장)
    GS_MAIN_DISP_402-INLENGTH04 = ( LS_2010-QLENGTH + LS_2010-CLENGTH +
                                                    LS_2010-SLENGTH + LS_2010-ELENGTH + LS_2010-ADLENGTH )
                                                  * LS_2010-INFACTOR.
* 연선조장(합계)
    GS_MAIN_DISP_402-INLENGTH02 = GS_MAIN_DISP_402-INLENGTH03 + GS_MAIN_DISP_402-INLENGTH04.

    CLEAR GS_COLLECT_ORDNR.
    GS_COLLECT_ORDNR-ORDNR = GS_MAIN_DISP_402-ORDNR.
    GS_COLLECT_ORDNR-JAEJIL = GS_MAIN_DISP_402-JAEJIL.
    GS_COLLECT_ORDNR-BESKZ_T = GS_MAIN_DISP_402-BESKZ_T.
    GS_COLLECT_ORDNR-MENGE = GS_MAIN_DISP_402-INLENGTH02.
    COLLECT GS_COLLECT_ORDNR INTO GT_COLLECT_ORDNR.

* 단위
    GS_MAIN_DISP_402-MEINS = 'M'.
* 조장수
    GS_MAIN_DISP_402-INFACTOR = LS_2010-INFACTOR.

    APPEND GS_MAIN_DISP_402 TO GT_MAIN_DISP_402.

  ENDLOOP.

* 구해준 합계수량 input
  LOOP AT GT_MAIN_DISP_402 ASSIGNING FIELD-SYMBOL(<LS_SUM_INPUT>).
    READ TABLE GT_COLLECT_ORDNR INTO GS_COLLECT_ORDNR WITH KEY ORDNR = <LS_SUM_INPUT>-ORDNR.
    IF SY-SUBRC EQ 0.
      <LS_SUM_INPUT>-INLENGTH01 = GS_COLLECT_ORDNR-MENGE.
    ENDIF.
  ENDLOOP.

  DELETE GT_COLLECT_ORDNR WHERE BESKZ_T NE '자작'.

  GS_HEADER_400-ZTWSEQ = GS_HEADER_400-ZTWSEQ2 = LINES( GT_COLLECT_ORDNR ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ITAB_403
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_ITAB_403 .

  DATA : BEGIN OF LS_SGRPNR,
           JAEJIL LIKE ZEDT1130-JAEJIL,
           SGRPNR TYPE ZGTPPT2011-SGRPNR,
         END OF LS_SGRPNR.
  DATA : LT_SGRPNR LIKE TABLE OF LS_SGRPNR.

  DATA : LT_2012 TYPE TABLE OF ZGTPPT2012.
  DATA : LV_MENGE TYPE MENGE_D.
  DATA : LV_LAYER TYPE ZGTPPT2012-ZCAGE.
  DATA : LV_GRPNR TYPE ZGTPPT2010-GRPNR.

  REFRESH GT_MAIN_DISP_403.

  DATA(LT_1130) = GT_1130.
  SORT LT_1130 BY GONG_SEQ DESCENDING.
  READ TABLE LT_1130 INTO DATA(LT_CHK_GONG_SEQ) INDEX 1.

  SORT GT_1130 BY GONG_SEQ YH_SEQ.
  REFRESH GT_2012_MAINTAIN.

  LOOP AT GT_MAIN_DISP_402 INTO DATA(LS_TEMP) WHERE BESKZ NE 'EP'.

    READ TABLE GT_2013 INTO DATA(LS_2013) WITH KEY DMORD = LS_TEMP-ORDNR
                                                                           DMLINE = LS_TEMP-POSNR.
    IF SY-SUBRC EQ 0.
      CLEAR LS_SGRPNR.
      LS_SGRPNR-JAEJIL = LS_TEMP-JAEJIL.
      LS_SGRPNR-SGRPNR = LS_2013-SGRPNR.

      READ TABLE GT_2012_MAINTAIN TRANSPORTING NO FIELDS WITH KEY SGRPNR = LS_SGRPNR-SGRPNR.
      IF SY-SUBRC NE 0.
        COLLECT LS_SGRPNR INTO LT_SGRPNR.

        REFRESH LT_2012.
        LT_2012 = VALUE #( FOR LW_2012 IN GT_2012 WHERE ( SGRPNR = LS_SGRPNR-SGRPNR )
                                  ( CORRESPONDING #( LW_2012 ) ) ).
        IF LT_2012[] IS NOT INITIAL.
          LOOP AT LT_2012 INTO DATA(LS_2012_TMP).
            APPEND INITIAL LINE TO GT_2012_MAINTAIN ASSIGNING FIELD-SYMBOL(<LS_2012>).
            MOVE-CORRESPONDING LS_2012_TMP TO <LS_2012>.
          ENDLOOP.
        ENDIF.

      ENDIF.

    ELSE.
      CLEAR LV_GRPNR.
      SELECT SINGLE GRPNR FROM ZGTPPT2020
        INTO LV_GRPNR
       WHERE GONG_CD = 'CST'
         AND ORDNR = LS_TEMP-ORDNR
         AND POSNR = LS_TEMP-POSNR.
      IF LV_GRPNR IS NOT INITIAL.
        READ TABLE GT_2013 INTO LS_2013 WITH KEY GRPNR = LV_GRPNR.
        IF SY-SUBRC EQ 0.
          READ TABLE GT_2011 INTO DATA(LS_2011) WITH KEY SGRPNR = LS_2013-SGRPNR
                                                                      COND_TYPE = LS_TEMP-JAEJIL.
          IF SY-SUBRC EQ 0.
            GT_2012_MAINTAIN = VALUE #( FOR LW_2013 IN GT_2012 WHERE ( SGRPNR = LS_2011-SGRPNR )
                                                    ( CORRESPONDING #( LW_2013 ) ) ).
          ENDIF.
        ENDIF.

      ENDIF.

    ENDIF.

  ENDLOOP.

  DATA(LT_SORT_2012) = GT_2012_MAINTAIN.
  SORT LT_SORT_2012 BY ZTWSEQ DESCENDING.

  READ TABLE LT_SORT_2012 INTO DATA(LS_SORT_2012) INDEX 1.
  IF SY-SUBRC EQ 0 AND GS_HEADER_400-ZTWSEQ2 <  LS_SORT_2012-ZTWSEQ.
    GS_HEADER_400-ZTWSEQ = GS_HEADER_400-ZTWSEQ2 = LS_SORT_2012-ZTWSEQ.
  ENDIF.

  LOOP AT GT_1130 INTO DATA(LS_1130) WHERE GONG_SEQ = LT_CHK_GONG_SEQ-GONG_SEQ.
    CLEAR GS_MAIN_DISP_403.
    MOVE-CORRESPONDING LS_1130 TO GS_MAIN_DISP_403.
* 조달유형
    READ TABLE GT_MAIN_DISP_402 TRANSPORTING NO FIELDS WITH KEY JAEJIL = LS_1130-JAEJIL
                                                                                          BESKZ_T = '외주'.
    IF SY-SUBRC EQ 0.
      GS_MAIN_DISP_403-BESKZ = 'EP'.
    ENDIF.


*  작업여장
    CLEAR LS_SGRPNR.
    READ TABLE LT_SGRPNR INTO LS_SGRPNR WITH KEY JAEJIL = LS_1130-JAEJIL.
    IF SY-SUBRC EQ 0.
      READ TABLE GT_2012_MAINTAIN INTO DATA(LS_2012_ADLENGTH) WITH KEY SGRPNR = LS_SGRPNR-SGRPNR
                                                                                           ZCAGE = LS_1130-BONSU.
      IF SY-SUBRC EQ 0.
        GS_MAIN_DISP_403-MENGE01 = LS_2012_ADLENGTH-ADLENGTH.
      ENDIF.
    ENDIF.

    GS_MAIN_DISP_403-MEINS = 'M'.

* 신선자재확인
    SELECT SINGLE MATNR FROM ZGTCVMSTVAL
      INTO GS_MAIN_DISP_403-MATNR
     WHERE WERKS = P_WERKS
        AND PDCACONDDIA = LS_1130-SOSUN_DIA
        AND PDCACONDMAT = LS_1130-JAEJIL
        AND PDCAPROCCODE IN ( 'BWD', 'CNF' )
        AND LVORMC = ''
        AND LVORMP = ''
        AND MMSTA = ''.

    GS_MAIN_DISP_403-MAKTX = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = GS_MAIN_DISP_403-MATNR ).
    APPEND GS_MAIN_DISP_403 TO GT_MAIN_DISP_403.

  ENDLOOP.

* 기준수량 세팅

  DATA(LT_BACKUP) = GT_MAINTAIN_LENGTH.
  REFRESH GT_MAINTAIN_LENGTH.

  DATA : LT_COLLECT_ORDNR LIKE TABLE OF GS_COLLECT_ORDNR.

  LOOP AT GT_MAIN_DISP_403 ASSIGNING FIELD-SYMBOL(<LS_TEMP>).

    REFRESH LT_COLLECT_ORDNR.
    LT_COLLECT_ORDNR = VALUE #( FOR LW_ORDNR IN GT_COLLECT_ORDNR WHERE ( JAEJIL = <LS_TEMP>-JAEJIL )
                                               ( CORRESPONDING #( LW_ORDNR ) ) ).

* 외주 가공은 수량 계산 필요없음
    READ TABLE LT_COLLECT_ORDNR TRANSPORTING NO FIELDS WITH KEY BESKZ_T = '외주'.
    IF SY-SUBRC EQ 0.
      CONTINUE.
    ENDIF.

    IF LT_COLLECT_ORDNR[] IS INITIAL.
      CONTINUE.
    ENDIF.

    CLEAR LV_MENGE.
    DO GS_HEADER_400-ZTWSEQ TIMES.
      ADD 1 TO LV_MENGE.

      APPEND INITIAL LINE TO GT_MAINTAIN_LENGTH ASSIGNING FIELD-SYMBOL(<LS_LENGTH>).
      <LS_LENGTH>-LAYER = <LS_TEMP>-BONSU.
      <LS_LENGTH>-ZTWSEQ = LV_MENGE.
      READ TABLE GT_2012_MAINTAIN ASSIGNING <LS_2012> WITH KEY ZCAGE = <LS_LENGTH>-LAYER
                                                                                       ZWSEQ = <LS_LENGTH>-ZTWSEQ.
      IF SY-SUBRC EQ 0.
        <LS_LENGTH>-MENGE = <LS_2012>-INLENGTH + <LS_2012>-ADLENGTH.
      ELSE.
        READ TABLE GT_2012_MAINTAIN ASSIGNING <LS_2012> WITH KEY ZWSEQ = <LS_LENGTH>-ZTWSEQ.
        IF SY-SUBRC EQ 0.
          <LS_LENGTH>-MENGE = 0.
        ELSE.
          READ TABLE LT_COLLECT_ORDNR INTO DATA(LS_MENGE) INDEX LV_MENGE.
          IF SY-SUBRC EQ 0.
            READ TABLE LT_BACKUP INTO DATA(LS_BACKUP) WITH KEY LAYER = <LS_TEMP>-BONSU
                                                                             ZTWSEQ = LV_MENGE.
            IF SY-SUBRC EQ 0.
              <LS_LENGTH>-MENGE = LS_BACKUP-MENGE - LS_BACKUP-MENGE02 + <LS_TEMP>-MENGE01.
              <LS_LENGTH>-MENGE02 = <LS_TEMP>-MENGE01.
            ELSE.
              <LS_LENGTH>-MENGE = ( LS_MENGE-MENGE + <LS_TEMP>-MENGE01 ) * <LS_TEMP>-YCOEF.
              PERFORM CONV_ROUND USING '1' CHANGING <LS_LENGTH>-MENGE.

              <LS_LENGTH>-MENGE02 = <LS_TEMP>-MENGE01.
            ENDIF.
          ELSE.
            READ TABLE LT_BACKUP INTO LS_BACKUP WITH KEY LAYER = <LS_TEMP>-BONSU
                                                                           ZTWSEQ = LV_MENGE.
            IF SY-SUBRC EQ 0.
              <LS_LENGTH>-MENGE = LS_BACKUP-MENGE - LS_BACKUP-MENGE02 + <LS_TEMP>-MENGE01.
              <LS_LENGTH>-MENGE02 = <LS_TEMP>-MENGE01.
            ELSE.
              <LS_LENGTH>-MENGE = 0.
              <LS_LENGTH>-MENGE02 = <LS_TEMP>-MENGE01.
            ENDIF.

          ENDIF.
        ENDIF.
      ENDIF.

    ENDDO.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ITAB_404
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_ITAB_404 .

  DATA : LV_NUM(2) TYPE N.
  DATA : LV_FIELDNAME TYPE FIELDNAME.
  DATA : LS_404_01 TYPE REF TO DATA. " 아이템 2줄로 추가를 위해 아이템 필드 2개 구성
  DATA : LS_404_02 TYPE REF TO DATA. " 아이템 2줄로 추가를 위해 아이템 필드 2개 구성
  DATA : LV_TABIX TYPE I.
  DATA : LV_LAYER TYPE ZGTPPT2012-ZCAGE.


  FIELD-SYMBOLS : <LS_LINE01> TYPE ANY,
                  <LS_LINE02> TYPE ANY.

  FIELD-SYMBOLS : <LV_VALUE01> TYPE ANY,
                  <LV_VALUE02> TYPE ANY.

  DEFINE __SET_FIELD_OF_LINE.
    IF <LV_VALUE01> IS ASSIGNED. UNASSIGN <LV_VALUE01>. ENDIF.
    ASSIGN COMPONENT &1 OF STRUCTURE <LS_LINE01> TO <LV_VALUE01>.
    IF <LV_VALUE02> IS ASSIGNED. UNASSIGN <LV_VALUE02>. ENDIF.
    ASSIGN COMPONENT &1 OF STRUCTURE <LS_LINE02> TO <LV_VALUE02>.
  END-OF-DEFINITION.

  CHECK GT_MAIN_DISP_403 IS NOT INITIAL.

  PERFORM INIT_404_SCREEN.

  CREATE DATA LS_404_01 LIKE LINE OF <GT_MAIN_DISP_404>.
  CREATE DATA LS_404_02 LIKE LINE OF <GT_MAIN_DISP_404>.
  ASSIGN LS_404_01->* TO <LS_LINE01>.
  ASSIGN LS_404_02->* TO <LS_LINE02>.


  LOOP AT GT_MAIN_DISP_403 INTO GS_MAIN_DISP_403.
    CLEAR : <LS_LINE01>, <LS_LINE02>.
    ADD 1 TO LV_TABIX.
*    CAGE
    __SET_FIELD_OF_LINE 'BONSU'.
    <LV_VALUE01> = <LV_VALUE02> = GS_MAIN_DISP_403-BONSU.
*    내부관리 순번( 인덱스)
    __SET_FIELD_OF_LINE 'SEQNO'.
    <LV_VALUE01> = <LV_VALUE02> = LV_TABIX.

*    내부관리 순번( 2라인 컨트롤 위한 순번)
    __SET_FIELD_OF_LINE 'LINE'.
    <LV_VALUE01> = 1.
    <LV_VALUE02> = 2.

*  차수별 데이터 입력
    CLEAR LV_NUM.
    DO GV_ZTWSEQ TIMES.
      ADD 1 TO LV_NUM.
      LV_FIELDNAME = 'FIELDINFOR_' && LV_NUM.
      __SET_FIELD_OF_LINE LV_FIELDNAME.
      LV_LAYER = GS_MAIN_DISP_403-BONSU.
      PERFORM SE_LINE_TEXT USING LV_LAYER LV_NUM GS_MAIN_DISP_403-MATNR
                                  CHANGING <LV_VALUE01> <LV_VALUE02>.
    ENDDO.

    APPEND <LS_LINE01> TO <GT_MAIN_DISP_404>.
    APPEND <LS_LINE02> TO <GT_MAIN_DISP_404>.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form INIT_404_SCREEN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM INIT_404_SCREEN .

  IF GV_ZTWSEQ = 0 OR GV_ZTWSEQ NE GS_HEADER_400-ZTWSEQ.
    GV_ZTWSEQ = GS_HEADER_400-ZTWSEQ.
    PERFORM SET_FIELDCAT_GRID_0404.
    IF GV_ZTWSEQ > 50.
      PERFORM MAKE_ITAB_FR_FCAT_404.

    ELSE.
      IF <GT_MAIN_DISP_404> IS ASSIGNED. UNASSIGN <GT_MAIN_DISP_404>. ENDIF.
      ASSIGN GT_MAIN_DISP_404 TO <GT_MAIN_DISP_404>.
    ENDIF.

    CREATE DATA GO_MAIN_DISP_404_NUM LIKE <GT_MAIN_DISP_404>.
    ASSIGN GO_MAIN_DISP_404_NUM->* TO <GT_MAIN_DISP_404_NUM>.

    IF GO_GRID_0404 IS BOUND.
      CALL METHOD GO_GRID_0404->SET_TABLE_FOR_FIRST_DISPLAY
        EXPORTING
          IS_LAYOUT            = GS_LAYOUT_0404
          IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0404
        CHANGING
          IT_OUTTAB            = <GT_MAIN_DISP_404>
          IT_SORT              = GT_SORT_0404
          IT_FIELDCATALOG      = GT_FIELDCAT_0404.
    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_ITAB_FR_FCAT_404
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MAKE_ITAB_FR_FCAT_404 .

  FREE GO_MAIN_DISP_404.
  IF <GT_MAIN_DISP_404> IS ASSIGNED. UNASSIGN <GT_MAIN_DISP_404>. ENDIF.

  CALL METHOD CL_ALV_TABLE_CREATE=>CREATE_DYNAMIC_TABLE
    EXPORTING
      I_STYLE_TABLE             = ABAP_TRUE
      IT_FIELDCATALOG           = GT_FIELDCAT_0404
    IMPORTING
      EP_TABLE                  = GO_MAIN_DISP_404
    EXCEPTIONS
      GENERATE_SUBPOOL_DIR_FULL = 1                " At Most 36 Subroutine Pools Can Be Generated Temporarily
      OTHERS                    = 2.
  IF SY-SUBRC <> 0.
    MESSAGE S005 DISPLAY LIKE 'E' WITH 'At Most 36 Subroutine Pools' 'Can Be Generated Temporarily'.
    LEAVE LIST-PROCESSING..
  ENDIF.

  ASSIGN GO_MAIN_DISP_404->* TO <GT_MAIN_DISP_404>.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_GRID_0404
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_0404 .

  DATA : LT_FCAT TYPE SLIS_T_FIELDCAT_ALV.
  DATA : LV_COL_POS TYPE I.
  DATA : LV_COL_POS2 TYPE I.
  DATA : LV_NUM(2) TYPE N.
  DATA : LV_SEQ TYPE I.
  DATA : LV_SEQ_C TYPE C LENGTH 11.
  DATA : LV_FIELDNAME TYPE FIELDNAME.
  DATA : LV_REPTXT TYPE REPTXT.


  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME     = SY-REPID
      I_INTERNAL_TABNAME = 'GS_MAIN_DISP_404'
      I_INCLNAME         = 'ZGTPPR2150TOP'
      I_BYPASSING_BUFFER = 'X'
    CHANGING
      CT_FIELDCAT        = LT_FCAT.

  REFRESH GT_FIELDCAT_0404.

  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT
    IMPORTING
      ET_FIELDCAT_LVC = GT_FIELDCAT_0404[]
    TABLES
      IT_DATA         = GT_MAIN_DISP_404.

* 추가필드 세팅

  READ TABLE GT_FIELDCAT_0404 TRANSPORTING NO FIELDS WITH KEY FIELDNAME = 'BONSU'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0404 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    <LS_FCAT>-COL_POS = 1.
    <LS_FCAT>-FIELDNAME = 'BONSU'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = 'CAGE'(F25).
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '10'.
    <LS_FCAT>-OUTPUTLEN = '6'.
    <LS_FCAT>-JUST = 'C'.
  ENDIF.

  READ TABLE GT_FIELDCAT_0404 TRANSPORTING NO FIELDS WITH KEY FIELDNAME = 'SEQNO'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0404 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-COL_POS = 2.
    <LS_FCAT>-FIELDNAME = 'SEQNO'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = <LS_FCAT>-FIELDNAME.
    <LS_FCAT>-DATATYPE = 'INT'.
    <LS_FCAT>-DD_OUTLEN = '10'.
    <LS_FCAT>-NO_OUT = ABAP_TRUE.
  ENDIF.

  READ TABLE GT_FIELDCAT_0404 TRANSPORTING NO FIELDS WITH KEY FIELDNAME = 'LINE'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0404 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-COL_POS = 3.
    <LS_FCAT>-FIELDNAME = 'LINE'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = <LS_FCAT>-FIELDNAME.
    <LS_FCAT>-DATATYPE = 'INT'.
    <LS_FCAT>-DD_OUTLEN = '10'.
    <LS_FCAT>-NO_OUT = ABAP_TRUE.
  ENDIF.

* 차수 필드 세팅
  LV_COL_POS = 100.
  LV_COL_POS2 = 400.
  DO GV_ZTWSEQ TIMES.
    ADD 1 TO LV_NUM.
    ADD 1 TO LV_SEQ.
    ADD 1 TO LV_COL_POS.
    ADD 1 TO LV_COL_POS2.
    LV_FIELDNAME = 'FIELDINFOR_' && LV_NUM.
    LV_SEQ_C = LV_SEQ.
    CONDENSE LV_SEQ_C.

    LV_REPTXT = LV_SEQ_C && '차'.

    READ TABLE GT_FIELDCAT_0404 TRANSPORTING NO FIELDS WITH KEY FIELDNAME = LV_FIELDNAME.
    IF SY-SUBRC NE 0.
      APPEND INITIAL LINE TO GT_FIELDCAT_0404 ASSIGNING <LS_FCAT>.
      <LS_FCAT>-COL_POS = LV_COL_POS.
      <LS_FCAT>-FIELDNAME = LV_FIELDNAME.
      <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = LV_REPTXT.
      <LS_FCAT>-DATATYPE = 'CHAR'.
      <LS_FCAT>-DD_OUTLEN = '50'.
      <LS_FCAT>-OUTPUTLEN = '17'.
      <LS_FCAT>-JUST = 'C'.
    ENDIF.


    LV_FIELDNAME = 'MENGE_' && LV_NUM.

    READ TABLE GT_FIELDCAT_0404 TRANSPORTING NO FIELDS WITH KEY FIELDNAME = LV_FIELDNAME.
    IF SY-SUBRC NE 0.
      APPEND INITIAL LINE TO GT_FIELDCAT_0404 ASSIGNING <LS_FCAT>.
      <LS_FCAT>-COL_POS = LV_COL_POS2.
      <LS_FCAT>-FIELDNAME = LV_FIELDNAME.
      <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = LV_REPTXT.
      <LS_FCAT>-REF_TABLE = 'MSEG'.
      <LS_FCAT>-REF_FIELD = 'MENGE'.
      <LS_FCAT>-QUANTITY = 'EA'.
      <LS_FCAT>-JUST = 'R'.
      <LS_FCAT>-NO_OUT = ABAP_TRUE.
    ENDIF.

  ENDDO.

  LOOP AT GT_FIELDCAT_0404 ASSIGNING <LS_FCAT>.
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'SEQNO' OR 'LINE'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
    ENDCASE.

  ENDLOOP.

  SORT GT_FIELDCAT_0404 BY COL_POS.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_0401
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GRID_0401 .

  CREATE OBJECT GO_CONTAIN_0400
    EXPORTING
      CONTAINER_NAME = 'CONTAINER400'.                 " Name of the Screen CustCtrl Name to Link Container To

  CREATE OBJECT GO_SPLITTER_0400
    EXPORTING
      PARENT  = GO_CONTAIN_0400
      ROWS    = 3
      COLUMNS = 1.

  GO_SPLITTER_0400->SET_ROW_HEIGHT(
  EXPORTING
    ID                =  1                " Row ID
    HEIGHT            =  30    ).            " Height

  GO_SPLITTER_0400->SET_ROW_HEIGHT(
    EXPORTING
      ID                =  2                " Row ID
      HEIGHT            =  30    ).            " Height
  GO_SPLITTER_0400->SET_ROW_HEIGHT(
    EXPORTING
      ID                =  3                " Row ID
      HEIGHT            =  40    ).            " Height

*&---------------------------------------------------------------------*
* 2열 컨테이너
  CALL METHOD GO_SPLITTER_0400->GET_CONTAINER
    EXPORTING
      ROW       = 1
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_SPLIT_CONTAINER_0401.

* 2열 스플릿
  CREATE OBJECT GO_SPLITTER_0401
    EXPORTING
      PARENT  = GO_SPLIT_CONTAINER_0401
      ROWS    = 1
      COLUMNS = 2.

  GO_SPLITTER_0401->SET_COLUMN_WIDTH(
    EXPORTING
      ID                = 1                 " Column ID
      WIDTH             = 50 ).                 " NPlWidth

  CALL METHOD GO_SPLITTER_0401->GET_CONTAINER
    EXPORTING
      ROW       = 1
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_CONTAIN_0401.

  CALL METHOD GO_SPLITTER_0401->GET_CONTAINER
    EXPORTING
      ROW       = 1
      COLUMN    = 2
    RECEIVING
      CONTAINER = GO_CONTAIN_0402.
*&---------------------------------------------------------------------*
* 2열 컨테이너
  CALL METHOD GO_SPLITTER_0400->GET_CONTAINER
    EXPORTING
      ROW       = 2
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_CONTAIN_0403.

*&---------------------------------------------------------------------*
* 3열 컨테이너
  CALL METHOD GO_SPLITTER_0400->GET_CONTAINER
    EXPORTING
      ROW       = 3
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_CONTAIN_0404.

  CREATE OBJECT GO_GRID_0401
    EXPORTING
      I_PARENT      = GO_CONTAIN_0401
      I_APPL_EVENTS = ABAP_TRUE.

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
  GS_LAYOUT_0401-NO_ROWMARK   = 'X'.

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
      I_INCLNAME             = 'ZGTPPR2150TOP'
      I_INTERNAL_TABNAME     = 'GS_MAIN_DISP_101'
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
      IT_DATA         = GT_MAIN_DISP_101
    EXCEPTIONS
      OTHERS          = 1.

  READ TABLE GT_FIELDCAT_0401 ASSIGNING FIELD-SYMBOL(<LS_FCAT>) WITH KEY FIELDNAME = 'ORDNO_C'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0401 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'ORDNO_C'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '오더번호'(f17).
    <LS_FCAT>-COL_POS = 3.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '30'.
    <LS_FCAT>-JUST = 'C'.
    <LS_FCAT>-KEY = ABAP_TRUE.
  ENDIF.


  LOOP AT GT_FIELDCAT_0401 ASSIGNING <LS_FCAT>.
    CLEAR <LS_FCAT>-KEY.
    CASE   <LS_FCAT>-FIELDNAME.
      WHEN 'GRPNR' OR 'ORDNO' OR 'POSNR'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'GCATG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '범주'(F03).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-KEY = ABAP_TRUE.
      WHEN 'ZZYUSCD'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '영업소'(F04).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-KEY = ABAP_TRUE.
      WHEN 'ORDNO_C'.
        <LS_FCAT>-KEY = ABAP_TRUE.
      WHEN 'MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '제품'(F05).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-KEY = ABAP_TRUE.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '제품내역'(F06).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'INLENGTH'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '조장'(F10).
        <LS_FCAT>-JUST = 'R'.
      WHEN 'MEINS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '단위'(F11).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'INFACTOR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '조장수'(F12).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-DECIMALS_O = '0'.
    ENDCASE.
  ENDLOOP.

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
    CHANGING
      IT_OUTTAB            = GT_MAIN_DISP_101
      IT_FIELDCATALOG      = GT_FIELDCAT_0401.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_0402
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GRID_0402 .

  CREATE OBJECT GO_GRID_0402
    EXPORTING
      I_PARENT      = GO_CONTAIN_0402
      I_APPL_EVENTS = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_0402
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_0402 .

  CLEAR GS_LAYOUT_0402.
  GS_LAYOUT_0402-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYOUT_0402-NO_ROWMARK   = 'X'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_GRID_0402
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_0402 .

  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR2150TOP'
      I_INTERNAL_TABNAME     = 'GS_MAIN_DISP_402'
    CHANGING
      CT_FIELDCAT            = LT_FCAT_SLIS
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.

  REFRESH GT_FIELDCAT_0402.

*-- lt_fieldcat의 구조체를 pt_fcat의 구조체로 변경
  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT_SLIS
    IMPORTING
      ET_FIELDCAT_LVC = GT_FIELDCAT_0402[]
    TABLES
      IT_DATA         = GT_MAIN_DISP_402
    EXCEPTIONS
      OTHERS          = 1.

  READ TABLE GT_FIELDCAT_0402 ASSIGNING FIELD-SYMBOL(<LS_FCAT>) WITH KEY FIELDNAME = 'ORDNO_C'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0402 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'ORDNO_C'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '연선오더번호'(f18).
    <LS_FCAT>-COL_POS = 2.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '30'.
    <LS_FCAT>-JUST = 'C'.
    <LS_FCAT>-KEY = ABAP_TRUE.
  ENDIF.

  READ TABLE GT_FIELDCAT_0402 ASSIGNING <LS_FCAT> WITH KEY FIELDNAME = 'BESKZ_T'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0402 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'BESKZ_T'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '조달유형'(f79).
    <LS_FCAT>-COL_POS = 8.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '30'.
    <LS_FCAT>-JUST = 'L'.
  ENDIF.


  LOOP AT GT_FIELDCAT_0402 ASSIGNING <LS_FCAT>.
    CLEAR <LS_FCAT>-KEY.
    CASE   <LS_FCAT>-FIELDNAME.
      WHEN 'JAEJIL'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '연선재질'(F78).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-KEY = ABAP_TRUE.
      WHEN 'ORDNO_C'.
        <LS_FCAT>-KEY = ABAP_TRUE.
      WHEN 'ORDNR'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'POSNR'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '연선(반)제품'(F76).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-KEY = ABAP_TRUE.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '(반)제품내역'(F77).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'BESKZ'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'BESKZ_T'.
      WHEN 'INLENGTH01'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '연선생산량'(F80).
        <LS_FCAT>-JUST = 'R'.
      WHEN 'INLENGTH02'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '연선조장(합계)'(F22).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-DO_SUM = ABAP_TRUE.
      WHEN 'INLENGTH03'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '연선조장(기본)'(F23).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-DO_SUM = ABAP_TRUE.
      WHEN 'INLENGTH04'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '연선조장(여장)'(F24).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-DO_SUM = ABAP_TRUE.
      WHEN 'MEINS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '단위'(F11).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'INFACTOR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '조장수'(F12).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-DECIMALS_O = '0'.
        <LS_FCAT>-DO_SUM = ABAP_TRUE.
    ENDCASE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SORTTAB_GRID_0402
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_SORTTAB_GRID_0402 .

  REFRESH GT_SORT_0402.

  PERFORM SET_SORT_TAB TABLES GT_SORT_0402
                            USING : 1 'JAEJIL'  'X' '' 'X'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_OF_TOOLBAR_GRID_0402
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EXCLUDE_OF_TOOLBAR_GRID_0402 .

  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON TABLES GT_EXCLUDE_0402
        USING : CL_GUI_ALV_GRID=>MC_FC_EXCL_ALL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_GRID_0402_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_GRID_0402_DISPLAY .

  CALL METHOD GO_GRID_0402->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT_0402
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0402
    CHANGING
      IT_OUTTAB            = GT_MAIN_DISP_402
      IT_SORT              = GT_SORT_0402
      IT_FIELDCATALOG      = GT_FIELDCAT_0402.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_0403
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GRID_0403 .

  CREATE OBJECT GO_GRID_0403
    EXPORTING
      I_PARENT      = GO_CONTAIN_0403
      I_APPL_EVENTS = ABAP_TRUE.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_0403
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_0403 .

  CLEAR GS_LAYOUT_0403.
  GS_LAYOUT_0403-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYOUT_0403-NO_ROWMARK   = 'X'.
  GS_LAYOUT_0403-STYLEFNAME = 'CELLTAB'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_GRID_0403
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_0403 .

  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.
  DATA : LV_COL_POS TYPE I.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR2150TOP'
      I_INTERNAL_TABNAME     = 'GS_MAIN_DISP_403'
    CHANGING
      CT_FIELDCAT            = LT_FCAT_SLIS
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.

  REFRESH GT_FIELDCAT_0403.

*-- lt_fieldcat의 구조체를 pt_fcat의 구조체로 변경
  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT_SLIS
    IMPORTING
      ET_FIELDCAT_LVC = GT_FIELDCAT_0403[]
    TABLES
      IT_DATA         = GT_MAIN_DISP_403
    EXCEPTIONS
      OTHERS          = 1.


  LOOP AT GT_FIELDCAT_0403 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CLEAR <LS_FCAT>-KEY.
    CASE   <LS_FCAT>-FIELDNAME.
      WHEN 'BONSU'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = 'CAGE'(F25).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'JAEJIL'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '도체재질'(F26).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'SOSUN_DIA'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '소선경'(F27).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'YCOEF'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '연입률'(F28).
        <LS_FCAT>-JUST = 'R'.
      WHEN 'BESKZ'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'MENGE01'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '작업여장'(F30).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-EDIT = ABAP_TRUE.
        <LS_FCAT>-QUANTITY = 'EA'.
      WHEN 'MEINS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '단위'(F11).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'LAY'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '연방향'(F36).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'SHAPE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '도체형상'(F39).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '신선자재'(F40).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '신선자재명'(F41).
        <LS_FCAT>-JUST = 'L'.
    ENDCASE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CELL_ATTRIBUTE_GRID_0403
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_CELL_ATTRIBUTE_GRID_0403 .

  DATA : LT_CELLTAB TYPE LVC_T_STYL.
  DATA : LS_CELLTAB TYPE LVC_S_STYL.
  FIELD-SYMBOLS <LT_CELLTAB> TYPE ANY.
  DATA : LV_BONSU TYPE ZGTPPT2012-ZCAGE.
* Macro
  DEFINE __SET_CELL_ATTRIBUTE.
    CLEAR LS_CELLTAB.
    LS_CELLTAB-FIELDNAME = &1.
    LS_CELLTAB-STYLE = &2.
    INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
  END-OF-DEFINITION.


  LOOP AT GT_MAIN_DISP_403 ASSIGNING FIELD-SYMBOL(<LS_MAIN>).
    CLEAR LS_CELLTAB.
    REFRESH LT_CELLTAB.

    __SET_CELL_ATTRIBUTE 'LAYER'  ALV_STYLE_COLOR_INT_KEY.
    __SET_CELL_ATTRIBUTE 'JAEJIL'  ALV_STYLE_COLOR_INT_KEY.
    __SET_CELL_ATTRIBUTE 'SOSUN_DIA'  ALV_STYLE_COLOR_INT_KEY.

    LV_BONSU = <LS_MAIN>-BONSU.
    READ TABLE GT_2012_MAINTAIN TRANSPORTING NO FIELDS WITH KEY ZCAGE = LV_BONSU.

    IF SY-SUBRC EQ 0.
      __SET_CELL_ATTRIBUTE 'MENGE01'  ALV_STYLE_DISABLED .
    ELSE.
      IF <LS_MAIN>-BESKZ = 'EP'.
        __SET_CELL_ATTRIBUTE 'MENGE01'  ALV_STYLE_DISABLED .
      ELSE.
        __SET_CELL_ATTRIBUTE 'MENGE01'  ALV_STYLE_ENABLED.
      ENDIF.
    ENDIF.

    IF <LT_CELLTAB> IS ASSIGNED. UNASSIGN <LT_CELLTAB>. ENDIF.
    ASSIGN COMPONENT 'CELLTAB' OF STRUCTURE <LS_MAIN> TO <LT_CELLTAB>.
    IF <LT_CELLTAB> IS ASSIGNED.
      <LT_CELLTAB> = LT_CELLTAB.
    ENDIF.

  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SORTTAB_GRID_0403
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_SORTTAB_GRID_0403 .

  REFRESH GT_SORT_0403.

  PERFORM SET_SORT_TAB TABLES GT_SORT_0403
                            USING : 1 'BONSU'  'X' '' ''.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_OF_TOOLBAR_GRID_0403
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EXCLUDE_OF_TOOLBAR_GRID_0403 .

  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON TABLES GT_EXCLUDE_0403
        USING : CL_GUI_ALV_GRID=>MC_FC_EXCL_ALL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_GRID_0403_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_GRID_0403_DISPLAY .

  CALL METHOD GO_GRID_0403->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT_0403
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0403
    CHANGING
      IT_OUTTAB            = GT_MAIN_DISP_403
      IT_SORT              = GT_SORT_0403
      IT_FIELDCATALOG      = GT_FIELDCAT_0403.

* 인풋이벤트 추가
  CALL METHOD GO_GRID_0403->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

  CALL METHOD GO_GRID_0403->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_0404
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GRID_0404 .

  CREATE OBJECT GO_GRID_0404
    EXPORTING
      I_PARENT      = GO_CONTAIN_0404
      I_APPL_EVENTS = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_0404
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_0404 .

  CLEAR GS_LAYOUT_0404.
  GS_LAYOUT_0404-SEL_MODE = 'D'.
  GS_LAYOUT_0404-STYLEFNAME = 'XYZSTYLEZYX'.
  GS_LAYOUT_0404-SMALLTITLE = 'X'.
  GS_LAYOUT_0404-GRID_TITLE = '신선작업 지시'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CELL_ATTRIBUTE_GRID_0404
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_CELL_ATTRIBUTE_GRID_0404 .

  DATA : LT_CELLTAB TYPE LVC_T_STYL.
  DATA : LS_CELLTAB TYPE LVC_S_STYL.

  DATA : LV_NUM(2) TYPE N.
  DATA : LV_FIELDNAME TYPE FIELDNAME.
  DATA : LV_INDEX TYPE I.
  DATA : LV_ZWSEQ TYPE ZGTPPT2012-ZTWSEQ.
  DATA : LV_STYLE TYPE LVC_STYLE.

  CONSTANTS : LC_STYLE01 TYPE LVC_STYLE VALUE ALV_STYLE_COLOR_INT_HEADING, " 계획오더(파랑)
              LC_STYLE02 TYPE LVC_STYLE VALUE ALV_STYLE_COLOR_INT_POSITIVE, "생산오더(초록)
              LC_STYLE03 TYPE LVC_STYLE VALUE ALV_STYLE_COLOR_POSITIVE, "판매오더(연초록)
              LC_STYLE04 TYPE LVC_STYLE VALUE ALV_STYLE_COLOR_INT_GROUP, "재고(주황)
              LC_STYLE05 TYPE LVC_STYLE VALUE CL_GUI_ALV_GRID=>MC_STYLE_ENABLED, "열 수정가능
              LC_STYLE06 TYPE LVC_STYLE VALUE ALV_STYLE_FONT_ITALIC, "이탤릭체
              LC_STYLE07 TYPE LVC_STYLE VALUE ALV_STYLE_COLOR_INV_GROUP. "생산완료 자재출고

  FIELD-SYMBOLS <LV_SEQNO> TYPE ANY.
  FIELD-SYMBOLS <LT_CELLTAB> TYPE ANY.

* Macro
  DEFINE __SET_CELL_ATTRIBUTE.
    CLEAR LS_CELLTAB.
    LS_CELLTAB-FIELDNAME = &1.
    LS_CELLTAB-STYLE = &2.
    INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
  END-OF-DEFINITION.

  DEFINE __ASSIGN_FIELD_SEQNO.
    IF <LV_SEQNO> IS ASSIGNED. UNASSIGN <LV_SEQNO>. ENDIF.
    ASSIGN COMPONENT 'SEQNO' OF STRUCTURE <LS_MAIN> TO <LV_SEQNO>.
  END-OF-DEFINITION.

  LOOP AT <GT_MAIN_DISP_404> ASSIGNING FIELD-SYMBOL(<LS_MAIN>).
    CLEAR LS_CELLTAB.
    REFRESH LT_CELLTAB.

    __SET_CELL_ATTRIBUTE 'BONSU'  ALV_STYLE_ALIGN_CENTER_CENTER.

    __ASSIGN_FIELD_SEQNO.
    READ TABLE GT_MAIN_DISP_403 INTO GS_MAIN_DISP_403 INDEX <LV_SEQNO>.
    CLEAR LV_ZWSEQ.
    CLEAR LV_NUM.
    DO GV_ZTWSEQ TIMES.
      ADD 1 TO LV_ZWSEQ.
      ADD 1 TO LV_NUM.
      CLEAR LV_STYLE.
      LV_STYLE = ALV_STYLE_ALIGN_LEFT_CENTER.
      CLEAR LV_FIELDNAME.
      LV_FIELDNAME = 'FIELDINFOR_' && LV_NUM.

      READ TABLE GT_2012_MAINTAIN ASSIGNING FIELD-SYMBOL(<LS_2012>) WITH KEY ZCAGE = GS_MAIN_DISP_403-BONSU
                                                                                                          ZWSEQ = LV_ZWSEQ.
      IF SY-SUBRC EQ 0.
        IF <LS_2012>-CHECK_JEGO IS NOT INITIAL AND <LS_2012>-CHECK_ZERO = ABAP_TRUE. " 생산완료, 자재 출고
          CLEAR LS_CELLTAB.
          LV_STYLE = LV_STYLE + LC_STYLE07 + LC_STYLE06.
          __SET_CELL_ATTRIBUTE LV_FIELDNAME LV_STYLE.
        ELSEIF  <LS_2012>-CHECK_JEGO IS NOT INITIAL AND <LS_2012>-CHECK_ZERO = ABAP_FALSE. "생산완료,재고상태
          IF <LS_2012>-CHECK_JEGO = 'Q'.
            LV_STYLE = LV_STYLE + ALV_STYLE_COLOR_POSITIVE.
            __SET_CELL_ATTRIBUTE LV_FIELDNAME LV_STYLE.
          ELSE.
            LV_STYLE = LV_STYLE + LC_STYLE04.
            __SET_CELL_ATTRIBUTE LV_FIELDNAME LV_STYLE.
          ENDIF.
        ELSE.
          LV_STYLE = LV_STYLE + LC_STYLE02.
          __SET_CELL_ATTRIBUTE LV_FIELDNAME LV_STYLE.
        ENDIF.

      ELSE.
        __SET_CELL_ATTRIBUTE LV_FIELDNAME LV_STYLE.
      ENDIF.

    ENDDO.


    IF <LT_CELLTAB> IS ASSIGNED. UNASSIGN <LT_CELLTAB>. ENDIF.
    ASSIGN COMPONENT 'XYZSTYLEZYX' OF STRUCTURE <LS_MAIN> TO <LT_CELLTAB>.
    IF <LT_CELLTAB> IS ASSIGNED.
      <LT_CELLTAB> = LT_CELLTAB.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SORTTAB_GRID_0404
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_SORTTAB_GRID_0404 .

  PERFORM SET_SORT_TAB TABLES GT_SORT_0404
                            USING : 1 'SEQNO' 'X' '' '',
                                       2 'LINE'  'X' '' '',
                                       3 'BONSU'  'X' '' ''.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_OF_TOOLBAR_GRID_0404
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EXCLUDE_OF_TOOLBAR_GRID_0404 .

  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON TABLES GT_EXCLUDE_0404
        USING : CL_GUI_ALV_GRID=>MC_FC_EXCL_ALL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_GRID_0404_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_GRID_0404_DISPLAY .

  CALL METHOD GO_GRID_0404->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT_0404
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0404
    CHANGING
      IT_OUTTAB            = <GT_MAIN_DISP_404>
      IT_SORT              = GT_SORT_0404
      IT_FIELDCATALOG      = GT_FIELDCAT_0404.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ZTWSEQ_400
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_ZTWSEQ_400 .

  IF GS_HEADER_400-ZTWSEQ < GS_HEADER_400-ZTWSEQ2.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '차수 변경은 권취개수보다 작을수 없습니다.'(E04).
    RETURN.
  ENDIF.

  IF <GT_MAIN_DISP_404> IS ASSIGNED.
    REFRESH <GT_MAIN_DISP_404>.
  ENDIF.

  PERFORM SET_ITAB_404.
  IF GO_GRID_0404 IS BOUND.

    IF GV_ZTWSEQ > 10.
      GO_GRID_0404->FREE( ).
      FREE GO_GRID_0404.
    ELSE.
      PERFORM REFRESH_GRID USING GO_GRID_0404.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_CHG_MENGE_400
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_CHG_MENGE_400 .

  DATA : LV_NUM(2) TYPE N.
  DATA : LV_FIELDNAME TYPE FIELDNAME.
  DATA : LS_404_01 TYPE REF TO DATA. " 아이템 2줄로 추가를 위해 아이템 필드 2개 구성
  DATA : LV_TABIX TYPE I..
  DATA : LV_ZWSEQ TYPE ZGTPPT2012-ZWSEQ.

  FIELD-SYMBOLS : <LS_LINE01> TYPE ANY.
  FIELD-SYMBOLS : <LV_VALUE01> TYPE ANY.

  DEFINE __SET_FIELD_OF_LINE.
    IF <LV_VALUE01> IS ASSIGNED. UNASSIGN <LV_VALUE01>. ENDIF.
    ASSIGN COMPONENT &1 OF STRUCTURE <LS_LINE01> TO <LV_VALUE01>.
  END-OF-DEFINITION.

  CREATE DATA LS_404_01 LIKE LINE OF <GT_MAIN_DISP_404_NUM>.
  ASSIGN LS_404_01->* TO <LS_LINE01>.

  REFRESH <GT_MAIN_DISP_404_NUM>.

  SORT GT_2012_MAINTAIN BY ZCAGE ZWSEQ.
  SORT GT_MAINTAIN_LENGTH BY LAYER ZTWSEQ.

  LOOP AT GT_MAIN_DISP_403 INTO GS_MAIN_DISP_403.
    CLEAR : <LS_LINE01>.
    ADD 1 TO LV_TABIX.
*    CAGE
    __SET_FIELD_OF_LINE 'BONSU'.
    <LV_VALUE01> = GS_MAIN_DISP_403-BONSU.
*    내부관리 순번( 인덱스)
    __SET_FIELD_OF_LINE 'SEQNO'.
    <LV_VALUE01> = LV_TABIX.

*    내부관리 순번( 2라인 컨트롤 위한 순번)
    __SET_FIELD_OF_LINE 'LINE'.
    <LV_VALUE01> = 1.

*  차수별 데이터 입력
    CLEAR LV_NUM.
    DO GV_ZTWSEQ TIMES.
      ADD 1 TO LV_NUM.
      LV_FIELDNAME = 'MENGE_' && LV_NUM.
      __SET_FIELD_OF_LINE LV_FIELDNAME.

      LV_ZWSEQ = LV_NUM + 0.

      READ TABLE GT_MAINTAIN_LENGTH INTO DATA(LS_MENGE) WITH KEY LAYER = GS_MAIN_DISP_403-BONSU
                                                                                 ZTWSEQ = LV_ZWSEQ.
      IF SY-SUBRC EQ 0.
        <LV_VALUE01> = LS_MENGE-MENGE.
      ENDIF.
    ENDDO.

    APPEND <LS_LINE01> TO <GT_MAIN_DISP_404_NUM>.
  ENDLOOP.

  CLEAR GV_CHK_CONFIRM_201.
  CALL SCREEN '0500' STARTING AT 5 5 ENDING AT 120 12.

  IF GV_CHK_CONFIRM_201 IS INITIAL.
    RETURN.
  ENDIF.

  LOOP AT <GT_MAIN_DISP_404_NUM> ASSIGNING <LS_LINE01>.
    CLEAR LV_NUM.
*    내부관리 순번( 인덱스)
    __SET_FIELD_OF_LINE 'SEQNO'.
    READ TABLE GT_MAIN_DISP_403 INTO GS_MAIN_DISP_403 INDEX <LV_VALUE01>.
    DO GV_ZTWSEQ TIMES.
      ADD 1 TO LV_NUM.
      LV_FIELDNAME = 'MENGE_' && LV_NUM.
      __SET_FIELD_OF_LINE LV_FIELDNAME.

      LV_ZWSEQ = LV_NUM + 0.

      READ TABLE GT_MAINTAIN_LENGTH ASSIGNING FIELD-SYMBOL(<LS_MENGE>) WITH KEY LAYER = GS_MAIN_DISP_403-BONSU
                                                                                 ZTWSEQ = LV_ZWSEQ.
      IF SY-SUBRC EQ 0.
        <LS_MENGE>-MENGE = <LV_VALUE01>.
      ELSE.
        IF <LV_VALUE01> NE 0.
          APPEND INITIAL LINE TO GT_MAINTAIN_LENGTH ASSIGNING <LS_MENGE>.
          <LS_MENGE>-LAYER = GS_MAIN_DISP_403-BONSU.
          <LS_MENGE>-ZTWSEQ = LV_ZWSEQ.
          <LS_MENGE>-MENGE = <LV_VALUE01>.
        ENDIF.
      ENDIF.
    ENDDO.

  ENDLOOP.

  REFRESH <GT_MAIN_DISP_404>.

  PERFORM SET_ITAB_404.

  IF GO_GRID_0404 IS BOUND.
    PERFORM REFRESH_GRID USING GO_GRID_0404.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_CREATE_ORDER_400
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_CREATE_ORDER_400 .

  DATA : LT_COLUMN TYPE LVC_T_COL.
  DATA : LV_STRING TYPE STRING.
  DATA : LV_NUM(2) TYPE N.
  DATA : LV_ZWSEQ TYPE ZGTPPT2012-ZWSEQ.
  DATA : BEGIN OF LS_CREATE,
           ZWSEQ TYPE ZGTPPT2012-ZWSEQ,
         END OF LS_CREATE.
  DATA : LT_CREATE LIKE TABLE OF LS_CREATE.
  DATA : LV_CHK_CREATE.
  DATA : LV_SGRPNR TYPE ZGTESGRPNR.
  DATA : LV_ZZBUNDLE TYPE AUFK-ZZBUNDLE.


  GO_GRID_0404->GET_SELECTED_COLUMNS(
    IMPORTING
      ET_INDEX_COLUMNS = LT_COLUMN ).                " Cell IDs

  IF LT_COLUMN[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '선택된 컬럼이 없습니다.'(E05).
    RETURN.
  ENDIF.

  LOOP AT LT_COLUMN INTO DATA(LS_COLUMN).
    CLEAR LV_CHK_CREATE.
    SPLIT LS_COLUMN-FIELDNAME AT  '_'  INTO TABLE DATA(LT_STRING).
    READ TABLE LT_STRING INTO DATA(LS_STRING) INDEX 1.
    LV_STRING = LS_STRING.
    IF LV_STRING NE 'FIELDINFOR'.
      MESSAGE S003 DISPLAY LIKE 'E' WITH '차수가 아닌 컬럼이 선택되었습니다.'(E06).
      RETURN.
    ENDIF.

    READ TABLE LT_STRING INTO LS_STRING INDEX 2.
    LV_NUM = LS_STRING.
    LV_ZWSEQ = LV_NUM + 0.

    LOOP AT GT_MAINTAIN_LENGTH INTO GS_MAINTAIN_LENGTH WHERE ZTWSEQ = LV_ZWSEQ.
      IF GS_MAINTAIN_LENGTH-MENGE > 0.
        LV_CHK_CREATE = ABAP_TRUE.
        EXIT.
      ENDIF.
    ENDLOOP.

    IF LV_CHK_CREATE IS INITIAL.
      MESSAGE S003 DISPLAY LIKE 'E' WITH '작업량이 입력되지 않은 내역이 있습니다.'(E07).
      RETURN.
    ENDIF.

    READ TABLE GT_2012_MAINTAIN TRANSPORTING NO FIELDS WITH KEY ZWSEQ = LV_ZWSEQ.
    IF SY-SUBRC NE 0.
      APPEND INITIAL LINE TO LT_CREATE ASSIGNING FIELD-SYMBOL(<LS_CREATE>).
      <LS_CREATE>-ZWSEQ = LV_ZWSEQ.
    ENDIF.
  ENDLOOP.

  IF LT_CREATE[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '생산오더 생성가능한 차수가 없습니다.'(E08).
    RETURN.
  ENDIF.


  CLEAR GV_ANSWER.
  PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
    ' '
    '선택된 차수의 생산오더 생성합니다. 계속 진행 하시겠습니까?'
    '생성확인'.
  IF GV_ANSWER NE 'J'.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
    RETURN.
  ENDIF.


* 오더 생성을 위한 데이터 생성
  DATA : LT_2011 TYPE TABLE OF ZGTPPT2011.
  DATA : LT_2012 TYPE TABLE OF ZGTPPT2012.
  DATA : LT_2013 TYPE TABLE OF ZGTPPT2013.
  DATA : LT_2014 TYPE TABLE OF ZGTPPT2014.
  DATA : LV_CHK_ERR.

  REFRESH GT_PRD_ORDERS.

  LOOP AT GT_MAIN_DISP_403 INTO GS_MAIN_DISP_403.
    IF GS_MAIN_DISP_403-BESKZ = 'EP'.
      CONTINUE.
    ENDIF.

    IF GS_MAIN_DISP_403-MATNR IS INITIAL.
      CONTINUE.
    ENDIF.

    CLEAR : LV_SGRPNR, LV_ZZBUNDLE.
    PERFORM MAKE_DATA_TO_SAVE01_400 TABLES LT_2011 LT_2013 LT_2014
                                                            USING GS_MAIN_DISP_403-JAEJIL
                                                     CHANGING LV_SGRPNR LV_ZZBUNDLE LV_CHK_ERR.

    IF LV_CHK_ERR IS INITIAL.
      LOOP AT LT_CREATE INTO LS_CREATE.
        PERFORM MAKE_DATA_TO_SAVE02_400 TABLES LT_2012 USING LS_CREATE-ZWSEQ LV_SGRPNR LV_ZZBUNDLE GS_MAIN_DISP_403
                                                       CHANGING LV_CHK_ERR.
        IF LV_CHK_ERR = ABAP_TRUE.
          EXIT.
        ENDIF.

      ENDLOOP.
    ENDIF.
  ENDLOOP.

  DATA(LV_SUCC_CNT) = LINES( GT_PRD_ORDERS ).

  IF LV_CHK_ERR = ABAP_TRUE.
    DATA : LS_RETURN2 TYPE BAPIRET2.
    DATA : LT_DETAIL_RETURN TYPE BAPI_ORDER_RETURN_TT.
    CALL FUNCTION 'BAPI_PRODORD_SET_DELETION_FLAG'
      IMPORTING
        RETURN        = LS_RETURN2
      TABLES
        ORDERS        = GT_PRD_ORDERS
        DETAIL_RETURN = LT_DETAIL_RETURN.
  ENDIF.

  MODIFY ZGTPPT2011 FROM TABLE LT_2011.
  IF SY-SUBRC NE 0.
    ROLLBACK WORK.
    CALL FUNCTION 'BAPI_PRODORD_SET_DELETION_FLAG'
      IMPORTING
        RETURN        = LS_RETURN2
      TABLES
        ORDERS        = GT_PRD_ORDERS
        DETAIL_RETURN = LT_DETAIL_RETURN.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '생산오더 생성중 오류 발생하였습니다.'(e12).
    RETURN.
  ENDIF.

  MODIFY ZGTPPT2012 FROM TABLE LT_2012.
  IF SY-SUBRC NE 0.
    ROLLBACK WORK.
    CALL FUNCTION 'BAPI_PRODORD_SET_DELETION_FLAG'
      IMPORTING
        RETURN        = LS_RETURN2
      TABLES
        ORDERS        = GT_PRD_ORDERS
        DETAIL_RETURN = LT_DETAIL_RETURN.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '생산오더 생성중 오류 발생하였습니다.'(e12).
    RETURN.
  ENDIF.

  IF LT_2013 IS NOT INITIAL.
    MODIFY ZGTPPT2013 FROM TABLE LT_2013.
    IF SY-SUBRC NE 0.
      ROLLBACK WORK.
      CALL FUNCTION 'BAPI_PRODORD_SET_DELETION_FLAG'
        IMPORTING
          RETURN        = LS_RETURN2
        TABLES
          ORDERS        = GT_PRD_ORDERS
          DETAIL_RETURN = LT_DETAIL_RETURN.
      MESSAGE S003 DISPLAY LIKE 'E' WITH '생산오더 생성중 오류 발생하였습니다.'(e12).
      RETURN.
    ENDIF.
  ENDIF.

  IF LT_2014 IS NOT INITIAL.
    MODIFY ZGTPPT2014 FROM TABLE LT_2014.
    IF SY-SUBRC NE 0.
      ROLLBACK WORK.
      CALL FUNCTION 'BAPI_PRODORD_SET_DELETION_FLAG'
        IMPORTING
          RETURN        = LS_RETURN2
        TABLES
          ORDERS        = GT_PRD_ORDERS
          DETAIL_RETURN = LT_DETAIL_RETURN.
      MESSAGE S003 DISPLAY LIKE 'E' WITH '생산오더 생성중 오류 발생하였습니다.'(e12).
      RETURN.
    ENDIF.
  ENDIF.

  LOOP AT LT_2011 INTO DATA(LS_DEL).
    DELETE GT_2011 WHERE SGRPNR = LS_DEL-SGRPNR.
  ENDLOOP.

  APPEND LINES OF LT_2011 TO GT_2011.
  APPEND LINES OF LT_2012 TO GT_2012.
  IF LT_2013[] IS NOT INITIAL.
    APPEND LINES OF LT_2013 TO GT_2013.
  ENDIF.

  REFRESH GT_ZZBUNDLE.
  LOOP AT LT_2011 INTO DATA(LS_2011_MODI).
    APPEND INITIAL LINE TO GT_ZZBUNDLE ASSIGNING FIELD-SYMBOL(<LS_ZZBUNDLE>).
    <LS_ZZBUNDLE>-SIGN = 'I'.
    <LS_ZZBUNDLE>-OPTION = 'EQ'.
    <LS_ZZBUNDLE>-LOW = LS_2011_MODI-ZZBUNDLE.
  ENDLOOP.

  SORT GT_ZZBUNDLE BY LOW.
  DELETE ADJACENT DUPLICATES FROM GT_ZZBUNDLE COMPARING LOW.
  PERFORM SENG_LOG_BWD.


  IF <GT_MAIN_DISP_404> IS ASSIGNED.
    REFRESH <GT_MAIN_DISP_404>.
  ENDIF.

  PERFORM SET_ITAB_403.
  PERFORM REFRESH_GRID USING GO_GRID_0403.
  PERFORM SET_ITAB_404.
  IF GO_GRID_0404 IS BOUND.
    PERFORM REFRESH_GRID USING GO_GRID_0404.
  ENDIF.

  MESSAGE S006 WITH '생산오더' LV_SUCC_CNT '건 생성되었습니다.'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_RELEASE_ORDER_400
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_RELEASE_ORDER_400 .

  DATA : LT_COLUMN TYPE LVC_T_COL.
  DATA : LV_STRING TYPE STRING.
  DATA : LV_NUM(2) TYPE N.
  DATA : LV_ZWSEQ TYPE ZGTPPT2012-ZWSEQ.

  GO_GRID_0404->GET_SELECTED_COLUMNS(
    IMPORTING
      ET_INDEX_COLUMNS = LT_COLUMN ).                " Cell IDs

  IF LT_COLUMN[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '선택된 컬럼이 없습니다.'(E05).
    RETURN.
  ENDIF.

  REFRESH GT_PRD_ORDERS.

  LOOP AT LT_COLUMN INTO DATA(LS_COLUMN).
    SPLIT LS_COLUMN-FIELDNAME AT  '_'  INTO TABLE DATA(LT_STRING).
    READ TABLE LT_STRING INTO DATA(LS_STRING) INDEX 1.
    LV_STRING = LS_STRING.
    IF LV_STRING NE 'FIELDINFOR'.
      MESSAGE S003 DISPLAY LIKE 'E' WITH '차수가 아닌 컬럼이 선택되었습니다.'(E06).
      RETURN.
    ENDIF.

    READ TABLE LT_STRING INTO LS_STRING INDEX 2.
    LV_NUM = LS_STRING.
    LV_ZWSEQ = LV_NUM + 0.

    LOOP AT GT_2012_MAINTAIN INTO DATA(LS_2012) WHERE ZWSEQ = LV_ZWSEQ.
      IF LS_2012-STATUS ='C'.

        APPEND INITIAL LINE TO GT_PRD_ORDERS ASSIGNING FIELD-SYMBOL(<LS_ORDER>).
        <LS_ORDER>-ORDER_NUMBER = LS_2012-ORDNR.
      ENDIF.
    ENDLOOP.

  ENDLOOP.

  IF GT_PRD_ORDERS[] IS INITIAL.
    RETURN.
  ENDIF.

  CLEAR GV_ANSWER.
  PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
    ' '
    '선택된 오더가 릴리즈 됩니다. 계속 진행 하시겠습니까?'
    '작업확인'.

  IF GV_ANSWER NE 'J'.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
    RETURN.
  ENDIF.

  DATA : LT_ERR_ORDER TYPE BAPI_ORDER_RETURN_TT.
  CALL FUNCTION 'BAPI_PRODORD_RELEASE'
    TABLES
      ORDERS        = GT_PRD_ORDERS
      DETAIL_RETURN = LT_ERR_ORDER.

  IF <GT_MAIN_DISP_404> IS ASSIGNED.
    REFRESH <GT_MAIN_DISP_404>.
  ENDIF.

  PERFORM SET_ITAB_403.
  PERFORM REFRESH_GRID USING GO_GRID_0403.
  PERFORM SET_ITAB_404.
  PERFORM REFRESH_GRID USING GO_GRID_0404.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_DELETE_ORDER_400
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_DELETE_ORDER_400 .

  DATA : LT_COLUMN TYPE LVC_T_COL.
  DATA : LV_STRING TYPE STRING.
  DATA : LV_NUM(2) TYPE N.
  DATA : LV_ZWSEQ TYPE ZGTPPT2012-ZWSEQ.
  DATA : LT_2012_DEL TYPE TABLE OF ZGTPPT2012.
  DATA : LS_2012_DEL TYPE ZGTPPT2012.

  REFRESH GT_PRD_ORDERS.

  GO_GRID_0404->GET_SELECTED_COLUMNS(
    IMPORTING
      ET_INDEX_COLUMNS = LT_COLUMN ).                " Cell IDs

  IF LT_COLUMN[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '선택된 컬럼이 없습니다.'(E05).
    RETURN.
  ENDIF.

  LOOP AT LT_COLUMN INTO DATA(LS_COLUMN).
    SPLIT LS_COLUMN-FIELDNAME AT  '_'  INTO TABLE DATA(LT_STRING).
    READ TABLE LT_STRING INTO DATA(LS_STRING) INDEX 1.
    LV_STRING = LS_STRING.
    IF LV_STRING NE 'FIELDINFOR'.
      MESSAGE S003 DISPLAY LIKE 'E' WITH '차수가 아닌 컬럼이 선택되었습니다.'(E06).
      RETURN.
    ENDIF.

    READ TABLE LT_STRING INTO LS_STRING INDEX 2.
    LV_NUM = LS_STRING.
    LV_ZWSEQ = LV_NUM + 0.

    LOOP AT GT_2012_MAINTAIN INTO DATA(LS_2012) WHERE ZWSEQ = LV_ZWSEQ.
      IF LS_2012-CHK_PRD IS NOT INITIAL.
        MESSAGE S005 DISPLAY LIKE 'E' WITH LS_2012-ORDNR '오더는 생산 진행 중으로 삭제 할 수 없습니다.'(E15).
        RETURN.
      ENDIF.

      APPEND INITIAL LINE TO GT_PRD_ORDERS ASSIGNING FIELD-SYMBOL(<LS_ORDER>).
      <LS_ORDER>-ORDER_NUMBER = LS_2012-ORDNR.
      CLEAR LS_2012_DEL.
      MOVE-CORRESPONDING LS_2012 TO LS_2012_DEL.
      APPEND LS_2012_DEL TO LT_2012_DEL.
    ENDLOOP.

  ENDLOOP.

  IF LT_2012_DEL[] IS INITIAL.
    RETURN.
  ENDIF.

  CLEAR GV_ANSWER.
  PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
    ' '
    '선택된 차수의 오더가 삭제 됩니다. 계속 진행 하시겠습니까?'
    '삭제확인'.
  IF GV_ANSWER NE 'J'.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
    RETURN.
  ENDIF.

  DATA : LS_RETURN2 TYPE BAPIRET2.
  DATA : LT_DETAIL_RETURN TYPE BAPI_ORDER_RETURN_TT.

  CALL FUNCTION 'BAPI_PRODORD_SET_DELETION_FLAG'
    IMPORTING
      RETURN        = LS_RETURN2
    TABLES
      ORDERS        = GT_PRD_ORDERS
      DETAIL_RETURN = LT_DETAIL_RETURN.

  DELETE ZGTPPT2012  FROM TABLE LT_2012_DEL.
  IF SY-SUBRC NE 0.
    ROLLBACK WORK.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '생산오더 삭제중 오류 발생하였습니다.'(e16).
    RETURN.
  ELSE.
    COMMIT WORK AND WAIT.
  ENDIF.

  DATA(LT_SGRPNR) = LT_2012_DEL.
  SORT LT_SGRPNR BY SGRPNR.
  DELETE ADJACENT DUPLICATES FROM LT_SGRPNR COMPARING SGRPNR.

  LOOP AT LT_SGRPNR INTO DATA(LS_SGRPNR).
    DELETE GT_2012 WHERE SGRPNR = LS_SGRPNR-SGRPNR.

    SELECT * FROM ZGTPPT2012
      INTO TABLE @DATA(LT_2012)
     WHERE SGRPNR = @LS_SGRPNR-SGRPNR.
    IF SY-SUBRC NE 0. " 신선재 오더 정보가 없다면
      DELETE FROM ZGTPPT2011 WHERE SGRPNR = LS_SGRPNR-SGRPNR.
      DELETE GT_2011 WHERE SGRPNR = LS_SGRPNR-SGRPNR.
      DELETE FROM ZGTPPT2013 WHERE SGRPNR = LS_SGRPNR-SGRPNR.
      DELETE GT_2013 WHERE SGRPNR = LS_SGRPNR-SGRPNR.
      DELETE FROM ZGTPPT2014 WHERE SGRPNR = LS_SGRPNR-SGRPNR.
      COMMIT WORK AND WAIT.
    ELSE.
      APPEND LINES OF LT_2012 TO GT_2012.
    ENDIF.
  ENDLOOP.

  IF <GT_MAIN_DISP_404> IS ASSIGNED.
    REFRESH <GT_MAIN_DISP_404>.
  ENDIF.

  PERFORM SET_ITAB_403.
  PERFORM REFRESH_GRID USING GO_GRID_0403.
  PERFORM SET_ITAB_404.
  PERFORM REFRESH_GRID USING GO_GRID_0404.


  MESSAGE S003 WITH '생산오더 삭제하였습니다.'(e17).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_ALLSELECT_400
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_ALLSELECT_400 .

  DATA : LT_COL_TABLE TYPE LVC_T_COL.

  LOOP AT GT_FIELDCAT_0404 INTO DATA(LS_FCAT) WHERE FIELDNAME CP 'FIELDINFOR_*'.
    APPEND INITIAL LINE TO LT_COL_TABLE ASSIGNING FIELD-SYMBOL(<LS_COL_TABLE>).
    <LS_COL_TABLE>-FIELDNAME = LS_FCAT-FIELDNAME.
  ENDLOOP.

  GO_GRID_0404->SET_SELECTED_COLUMNS(
    IT_COL_TABLE             =  LT_COL_TABLE                " Selected Columns
  ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_DESELECT_400
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_DESELECT_400 .

  DATA : LT_COL_TABLE TYPE LVC_T_COL.

  GO_GRID_0404->SET_SELECTED_COLUMNS(
    IT_COL_TABLE             =  LT_COL_TABLE                " Selected Columns
  ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_CHG_SULBI_400
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_CHG_SULBI_400 .

  DATA : LT_CELLS TYPE LVC_T_CENO.
  DATA : LV_STRING TYPE STRING.
  DATA : LV_NUM(2) TYPE N.
  DATA : LV_ZWSEQ TYPE ZGTPPT2012-ZWSEQ.
  DATA : LS_2012 TYPE ZGTPPT2012.
  DATA : LT_2012 TYPE TABLE OF ZGTPPT2012.
  DATA : LV_CHK_BUNSU TYPE ZEDT1130-BONSU.
  DATA : LT_BONSU TYPE RANGE OF ZEDT1130-BONSU.
  DATA : LV_ARBPL TYPE ZGTCVROUTING-ARBPL.
  DATA : LV_MATNR TYPE MATNR.
  DATA : LV_ORDER_NUMBER TYPE BAPI_ORDER_KEY-ORDER_NUMBER.
  DATA : LV_CHK_ERR.


  FIELD-SYMBOLS <LV_SEQNO> TYPE ANY.

  GO_GRID_0404->GET_SELECTED_CELLS_ID(
    IMPORTING
     ET_CELLS = LT_CELLS ).                " Cell IDs

  LOOP AT LT_CELLS INTO DATA(LS_CELLS).
    READ TABLE <GT_MAIN_DISP_404> ASSIGNING FIELD-SYMBOL(<LS_MAIN>) INDEX LS_CELLS-ROW_ID.
    IF <LV_SEQNO> IS ASSIGNED. UNASSIGN <LV_SEQNO>. ENDIF.
    ASSIGN COMPONENT 'SEQNO' OF STRUCTURE  <LS_MAIN> TO <LV_SEQNO>.

    READ TABLE GT_MAIN_DISP_403 INTO DATA(LS_MAIN) INDEX <LV_SEQNO>.
    APPEND INITIAL LINE TO LT_BONSU ASSIGNING FIELD-SYMBOL(<LS_BONSU>).
    <LS_BONSU>-LOW = LS_MAIN-BONSU.
  ENDLOOP.

  SORT LT_BONSU BY LOW.
  DELETE ADJACENT DUPLICATES FROM LT_BONSU COMPARING LOW.

  IF LINES( LT_BONSU ) > 1.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '동일한 Cage만 변경 가능합니다.'(E23).
    RETURN.
  ENDIF.

  LOOP AT LT_CELLS INTO LS_CELLS.
    READ TABLE GT_FIELDCAT_0404 INTO DATA(LS_FCAT) INDEX LS_CELLS-COL_ID.
    IF SY-SUBRC EQ 0.

      SPLIT LS_FCAT-FIELDNAME AT  '_'  INTO TABLE DATA(LT_STRING).
      READ TABLE LT_STRING INTO DATA(LS_STRING) INDEX 1.
      LV_STRING = LS_STRING.
      IF LV_STRING NE 'FIELDINFOR'.
        MESSAGE S003 DISPLAY LIKE 'E' WITH '차수가 아닌 컬럼이 선택되었습니다.'(E06).
        RETURN.
      ENDIF.

      READ TABLE LT_STRING INTO LS_STRING INDEX 2.
      LV_NUM = LS_STRING.
      LV_ZWSEQ = LV_NUM + 0.

      READ TABLE <GT_MAIN_DISP_404> ASSIGNING <LS_MAIN> INDEX LS_CELLS-ROW_ID.
      IF <LV_SEQNO> IS ASSIGNED. UNASSIGN <LV_SEQNO>. ENDIF.
      ASSIGN COMPONENT 'SEQNO' OF STRUCTURE  <LS_MAIN> TO <LV_SEQNO>.

      READ TABLE GT_MAIN_DISP_403 INTO LS_MAIN INDEX <LV_SEQNO>.

      LV_MATNR = LS_MAIN-MATNR.

      READ TABLE GT_2012_MAINTAIN INTO DATA(LS_CHK_2012) WITH KEY INFACTOR = LS_MAIN-BONSU
                                                                                          ZWSEQ = LV_ZWSEQ.
      IF SY-SUBRC EQ 0 AND LS_CHK_2012-STATUS = 'C' AND LS_CHK_2012-CHK_PRD IS INITIAL.
        CLEAR LS_2012.
        MOVE-CORRESPONDING LS_CHK_2012 TO LS_2012.
        APPEND LS_2012 TO LT_2012.
      ENDIF.
    ENDIF.

  ENDLOOP.



  IF LT_2012[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '설비변경 가능한 오더가 없습니다.'(E24).
    RETURN.
  ENDIF.

* 설비변경은 팝업대신 f4화면으로 대신함
  PERFORM GET_CHK_ARBPL USING LV_MATNR CHANGING LV_ARBPL.

  IF LV_ARBPL IS NOT INITIAL.
    LOOP AT LT_2012 INTO LS_2012.
      CLEAR LV_ORDER_NUMBER.
      LV_ORDER_NUMBER = LS_2012-ORDNR.
      LS_2012-ARBPL = LV_ARBPL.
      PERFORM SET_ARBPL_CHG_BY_BDC USING LV_ORDER_NUMBER LS_2012 CHANGING LV_CHK_ERR.
      IF LV_CHK_ERR = ABAP_TRUE.
        MESSAGE S003 DISPLAY LIKE 'E' WITH '설비변경 중 오류 발생하였습니다.'(E25).
        RETURN.
      ENDIF.

    ENDLOOP.

    MESSAGE S003 WITH '설비 변경되었습니다.'(E26).

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CAL_404
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CAL_404 .

  DATA : LV_MENGE TYPE MENGE_D.

* 기준수량 세팅

  DATA(LT_BACKUP) = GT_MAINTAIN_LENGTH.
  REFRESH GT_MAINTAIN_LENGTH.

  DATA : LT_COLLECT_ORDNR LIKE TABLE OF GS_COLLECT_ORDNR.

  LOOP AT GT_MAIN_DISP_403 ASSIGNING FIELD-SYMBOL(<LS_TEMP>).

    REFRESH LT_COLLECT_ORDNR.
    LT_COLLECT_ORDNR = VALUE #( FOR LW_ORDNR IN GT_COLLECT_ORDNR WHERE ( JAEJIL = <LS_TEMP>-JAEJIL )
                                               ( CORRESPONDING #( LW_ORDNR ) ) ).

* 외주 가공은 수량 계산 필요없음
    READ TABLE LT_COLLECT_ORDNR TRANSPORTING NO FIELDS WITH KEY BESKZ_T = '외주'.
    IF SY-SUBRC EQ 0.
      CONTINUE.
    ENDIF.

    IF LT_COLLECT_ORDNR[] IS INITIAL.
      CONTINUE.
    ENDIF.

    CLEAR LV_MENGE.
    DO GS_HEADER_400-ZTWSEQ TIMES.
      ADD 1 TO LV_MENGE.

      APPEND INITIAL LINE TO GT_MAINTAIN_LENGTH ASSIGNING FIELD-SYMBOL(<LS_LENGTH>).
      <LS_LENGTH>-LAYER = <LS_TEMP>-BONSU.
      <LS_LENGTH>-ZTWSEQ = LV_MENGE.
      READ TABLE GT_2012_MAINTAIN ASSIGNING FIELD-SYMBOL(<LS_2012>) WITH KEY ZCAGE = <LS_LENGTH>-LAYER
                                                                                                      ZWSEQ = <LS_LENGTH>-ZTWSEQ.
      IF SY-SUBRC EQ 0.
        <LS_LENGTH>-MENGE = <LS_2012>-INLENGTH + <LS_2012>-ADLENGTH.
      ELSE.
        READ TABLE GT_2012_MAINTAIN ASSIGNING <LS_2012> WITH KEY ZWSEQ = <LS_LENGTH>-ZTWSEQ.
        IF SY-SUBRC EQ 0.
          <LS_LENGTH>-MENGE = 0.
        ELSE.
          READ TABLE LT_COLLECT_ORDNR INTO DATA(LS_MENGE) INDEX LV_MENGE.
          IF SY-SUBRC EQ 0.
            READ TABLE LT_BACKUP INTO DATA(LS_BACKUP) WITH KEY LAYER = <LS_TEMP>-BONSU
                                                                             ZTWSEQ = LV_MENGE.
            IF SY-SUBRC EQ 0.
              <LS_LENGTH>-MENGE = LS_BACKUP-MENGE - LS_BACKUP-MENGE02 + <LS_TEMP>-MENGE01.
              <LS_LENGTH>-MENGE02 = <LS_TEMP>-MENGE01.
            ELSE.
              <LS_LENGTH>-MENGE = LS_MENGE-MENGE + <LS_TEMP>-MENGE01.
              <LS_LENGTH>-MENGE02 = <LS_TEMP>-MENGE01.
            ENDIF.
          ELSE.
            READ TABLE LT_BACKUP INTO LS_BACKUP WITH KEY LAYER = <LS_TEMP>-BONSU
                                                                           ZTWSEQ = LV_MENGE.
            IF SY-SUBRC EQ 0.
              <LS_LENGTH>-MENGE = LS_BACKUP-MENGE - LS_BACKUP-MENGE02 + <LS_TEMP>-MENGE01.
              <LS_LENGTH>-MENGE02 = <LS_TEMP>-MENGE01.
            ELSE.
              <LS_LENGTH>-MENGE = 0.
              <LS_LENGTH>-MENGE02 = <LS_TEMP>-MENGE01.
            ENDIF.

          ENDIF.
        ENDIF.
      ENDIF.

    ENDDO.

  ENDLOOP.

  IF <GT_MAIN_DISP_404> IS ASSIGNED.
    REFRESH <GT_MAIN_DISP_404>.
  ENDIF.

  PERFORM SET_ITAB_404.
  IF GO_GRID_0404 IS BOUND.
    PERFORM REFRESH_GRID USING GO_GRID_0404.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*&      Module  USER_COMMAND_0500  INPUT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
MODULE USER_COMMAND_0500 INPUT.

  CLEAR GV_OK_CODE7.
  GV_OK_CODE7 = SY-UCOMM.

  CASE GV_OK_CODE7.
    WHEN 'BACK' OR 'EXIT' OR 'CANC'.
*     종료
      CALL METHOD GO_CONTAIN_0500->FREE.
      FREE : GO_CONTAIN_0500, GO_GRID_0500.
      CALL METHOD CL_GUI_CFW=>FLUSH.
      LEAVE TO SCREEN 0.

    WHEN 'CONFIRM'.
      GV_CHK_CONFIRM_201 = ABAP_TRUE.
      CALL METHOD GO_CONTAIN_0500->FREE.
      FREE : GO_CONTAIN_0500, GO_GRID_0500.
      CALL METHOD CL_GUI_CFW=>FLUSH.
      LEAVE TO SCREEN 0.
  ENDCASE.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Form SET_CELL_ATTRIBUTE_GRID_0500
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_CELL_ATTRIBUTE_GRID_0500 .

  DATA : LT_CELLTAB TYPE LVC_T_STYL.
  DATA : LS_CELLTAB TYPE LVC_S_STYL.

  DATA : LV_NUM(2) TYPE N.
  DATA : LV_FIELDNAME TYPE FIELDNAME.
  DATA : LV_INDEX TYPE I.
  DATA : LV_ZWSEQ TYPE ZGTPPT2012-ZTWSEQ.

  FIELD-SYMBOLS <LV_SEQNO> TYPE ANY.
  FIELD-SYMBOLS <LT_CELLTAB> TYPE ANY.

* Macro
  DEFINE __SET_CELL_ATTRIBUTE.
    CLEAR LS_CELLTAB.
    LS_CELLTAB-FIELDNAME = &1.
    LS_CELLTAB-STYLE = &2.
    INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
  END-OF-DEFINITION.

  DEFINE __ASSIGN_FIELD_SEQNO.
    IF <LV_SEQNO> IS ASSIGNED. UNASSIGN <LV_SEQNO>. ENDIF.
    ASSIGN COMPONENT 'SEQNO' OF STRUCTURE <LS_MAIN> TO <LV_SEQNO>.
  END-OF-DEFINITION.

  DATA(LT_TEMP) = GT_2012_MAINTAIN.
  SORT LT_TEMP BY ZWSEQ DESCENDING.
  READ TABLE LT_TEMP INTO DATA(LS_TEMP) INDEX 1.

  LOOP AT <GT_MAIN_DISP_404_NUM> ASSIGNING FIELD-SYMBOL(<LS_MAIN>).
    CLEAR LS_CELLTAB.
    REFRESH LT_CELLTAB.

    __SET_CELL_ATTRIBUTE 'BONSU'  ALV_STYLE_ALIGN_CENTER_CENTER.

    __ASSIGN_FIELD_SEQNO.
    READ TABLE GT_MAIN_DISP_403 INTO GS_MAIN_DISP_403 INDEX <LV_SEQNO>.
    CLEAR LV_ZWSEQ.
    CLEAR LV_NUM.
    DO GV_ZTWSEQ TIMES.
      ADD 1 TO LV_ZWSEQ.
      ADD 1 TO LV_NUM.

      CLEAR LV_FIELDNAME.
      LV_FIELDNAME = 'MENGE_' && LV_NUM.

      READ TABLE GT_2012_MAINTAIN TRANSPORTING NO FIELDS WITH KEY ZWSEQ = LV_ZWSEQ.

      IF SY-SUBRC EQ 0.
        __SET_CELL_ATTRIBUTE LV_FIELDNAME ALV_STYLE_DISABLED.
      ELSE.
        IF GS_MAIN_DISP_403-BESKZ = 'EP'.
          __SET_CELL_ATTRIBUTE LV_FIELDNAME ALV_STYLE_DISABLED.
        ELSE.
          __SET_CELL_ATTRIBUTE LV_FIELDNAME ALV_STYLE_ENABLED.
        ENDIF.
      ENDIF.

    ENDDO.


    IF <LT_CELLTAB> IS ASSIGNED. UNASSIGN <LT_CELLTAB>. ENDIF.
    ASSIGN COMPONENT 'XYZSTYLEZYX' OF STRUCTURE <LS_MAIN> TO <LT_CELLTAB>.
    IF <LT_CELLTAB> IS ASSIGNED.
      <LT_CELLTAB> = LT_CELLTAB.
    ENDIF.

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

  PERFORM SET_SORT_TAB TABLES GT_SORT_0500
                            USING : 1 'SEQNO' 'X' '' '',
                                       2 'LINE'  'X' '' ''.

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

  REFRESH GT_FIELDCAT_0500.
  MOVE-CORRESPONDING GT_FIELDCAT_0404 TO GT_FIELDCAT_0500.

  LOOP AT GT_FIELDCAT_0500 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    IF <LS_FCAT>-COL_POS BETWEEN 100 AND 399.
      <LS_FCAT>-NO_OUT = ABAP_TRUE.
    ENDIF.

    IF <LS_FCAT>-COL_POS > 400.
      CLEAR <LS_FCAT>-NO_OUT.
      <LS_FCAT>-EDIT = ABAP_TRUE.
    ENDIF.

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

  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON TABLES GT_EXCLUDE_0500
        USING : CL_GUI_ALV_GRID=>MC_FC_EXCL_ALL.

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
      IS_LAYOUT            = GS_LAYOUT_0404
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0500
    CHANGING
      IT_OUTTAB            = <GT_MAIN_DISP_404_NUM>
      IT_SORT              = GT_SORT_0500
      IT_FIELDCATALOG      = GT_FIELDCAT_0500.

  GO_GRID_0500->SET_READY_FOR_INPUT( 1 ).

* 인풋이벤트 추가
  CALL METHOD GO_GRID_0500->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

  CALL METHOD GO_GRID_0500->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

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
      EXTENSION                   = 10000
    EXCEPTIONS
      CNTL_ERROR                  = 1
      CNTL_SYSTEM_ERROR           = 2
      CREATE_ERROR                = 3
      LIFETIME_ERROR              = 4
      LIFETIME_DYNPRO_DYNPRO_LINK = 5.

  CREATE OBJECT GO_GRID_0500
    EXPORTING
      I_PARENT      = GO_CONTAIN_0500
      I_APPL_EVENTS = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REFRESH_400
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM REFRESH_400 .

  CLEAR GS_HEADER_400.
  CLEAR GV_ZTWSEQ.
  REFRESH GT_MAINTAIN_LENGTH.

  PERFORM SET_ITAB_101.
* 연선정보
  PERFORM SET_ITAB_402.
* 신선정보
  PERFORM SET_ITAB_403.
* 신선작업지시
  REFRESH <GT_MAIN_DISP_404>.
  PERFORM SET_ITAB_404.

  PERFORM REFRESH_GRID USING GO_GRID_0401.
  PERFORM REFRESH_GRID USING GO_GRID_0402.
  PERFORM REFRESH_GRID USING GO_GRID_0403.

  IF GO_GRID_0404 IS BOUND.
    PERFORM REFRESH_GRID USING GO_GRID_0404.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_DATA_TO_SAVE01_400
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_2011
*&      --> LT_2013
*&      <-- LV_SGRPNR
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM MAKE_DATA_TO_SAVE01_400  TABLES   PT_2011 STRUCTURE ZGTPPT2011
                                   PT_2013 STRUCTURE ZGTPPT2013
                                   PT_2014 STRUCTURE ZGTPPT2014
                                        USING PV_JAEJIL TYPE ZEDT1130-JAEJIL
                                    CHANGING PV_SGRPNR TYPE ZGTESGRPNR
                                               PV_ZZBUNDLE TYPE AUFK-ZZBUNDLE
                                               PV_CHK_ERR.

  DATA : LT_2013 TYPE TABLE OF ZGTPPT2013.
  DATA : LT_2014 TYPE TABLE OF ZGTPPT2014.
  DATA : LT_2013_CHK TYPE TABLE OF ZGTPPT2013.
  DATA : LS_2013 TYPE ZGTPPT2013.
  DATA : LS_2014 TYPE ZGTPPT2014.
  DATA : LT_2011 TYPE TABLE OF ZGTPPT2011.
  DATA : LV_SGRPNR TYPE ZGTESGRPNR.

  READ TABLE GT_MAIN_DISP_101 INTO DATA(LS_101_TEMP) INDEX 1.

  LT_2013_CHK = VALUE #( FOR LW_2013 IN GT_2013 WHERE ( GRPNR = LS_101_TEMP-GRPNR )
                           ( CORRESPONDING #( LW_2013 ) ) ).

  IF LT_2013_CHK[] IS NOT INITIAL.
    SORT LT_2013_CHK BY SGRPNR.
    DELETE ADJACENT DUPLICATES FROM LT_2013_CHK COMPARING SGRPNR.

    LOOP AT LT_2013_CHK INTO LS_2013.
      READ TABLE GT_2011 INTO DATA(LS_2011) WITH KEY SGRPNR = LS_2013-SGRPNR
                                                                      COND_TYPE = PV_JAEJIL
                                                                      JOBTY = '1'.
      IF SY-SUBRC EQ 0.
        LV_SGRPNR = LS_2011-SGRPNR.
        PV_SGRPNR = LS_2011-SGRPNR.
        PV_ZZBUNDLE = LS_2011-ZZBUNDLE.
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDIF.

  IF LT_2013_CHK[] IS INITIAL.
    LT_2013_CHK = VALUE #( FOR LW_2013 IN PT_2013 WHERE ( GRPNR = LS_101_TEMP-GRPNR )
                              ( CORRESPONDING #( LW_2013 ) ) ).

    SORT LT_2013_CHK BY SGRPNR.
    DELETE ADJACENT DUPLICATES FROM LT_2013_CHK COMPARING SGRPNR.

    LOOP AT LT_2013_CHK INTO LS_2013.
      READ TABLE PT_2011 INTO LS_2011 WITH KEY SGRPNR = LS_2013-SGRPNR
                                                            COND_TYPE = PV_JAEJIL
                                                            JOBTY = '1'.
      IF SY-SUBRC EQ 0.
        LV_SGRPNR = LS_2011-SGRPNR.
        PV_SGRPNR = LS_2011-SGRPNR.
        PV_ZZBUNDLE = LS_2011-ZZBUNDLE.
        EXIT.
      ENDIF.

    ENDLOOP.
  ENDIF.

* 데이터 구성
  REFRESH LT_2013.

  LOOP AT GT_MAIN_DISP_402 INTO GS_MAIN_DISP_402 WHERE JAEJIL = PV_JAEJIL.
    READ TABLE GT_2010 INTO DATA(LS_2010) WITH KEY GRPNR = LS_101_TEMP-GRPNR
                                                                  ORDNR = GS_MAIN_DISP_402-ORDNR
                                                                  POSNR = GS_MAIN_DISP_402-POSNR.
    IF SY-SUBRC EQ 0.

      CLEAR LS_2013.
      LS_2013-DMORD = GS_MAIN_DISP_402-ORDNR.
      LS_2013-DMLINE = GS_MAIN_DISP_402-POSNR.
      LS_2013-DMORDTY = LS_2010-ORDTY.
      LS_2013-GRPNR = LS_2010-GRPNR.
      LS_2013-MATNR = LS_2010-MATNR.
      LS_2013-INLENGTH = GS_MAIN_DISP_102-INLENGTH02.
      LS_2013-INFACTOR = 1.
      APPEND LS_2013 TO LT_2013.
    ENDIF.

  ENDLOOP.

* 소선정보 데이터 구성
  LOOP AT GT_MAIN_DISP_403 INTO DATA(LS_403).
    CLEAR LS_2014.
    LS_2014-ZCAGE = LS_403-BONSU.
    LS_2014-JAEJIL = LS_403-JAEJIL.
    LS_2014-SOSUN_DIA = LS_403-SOSUN_DIA.
* 신선 조달유형 차후 적용예정
*    LS_2014-BESKZ = GS_MAIN_DISP_103-LAYER.
    LS_2014-YCOEF = LS_403-YCOEF.
    LS_2014-ADLENGTH = LS_403-MENGE01.
    LS_2014-MEINS = LS_403-MEINS.
    LS_2014-YUN = LS_403-LAY.
    LS_2014-SHAPE = LS_403-SHAPE.
    APPEND LS_2014 TO LT_2014.

  ENDLOOP.




  IF LV_SGRPNR IS NOT INITIAL. " 저장 정보가 있다는 의미
    READ TABLE PT_2011 TRANSPORTING NO FIELDS WITH KEY SGRPNR = LV_SGRPNR.
    IF SY-SUBRC NE 0. " 조회결과 없을 시에만 어팬드
      APPEND INITIAL LINE TO PT_2011 ASSIGNING FIELD-SYMBOL(<LS_2011>).
      READ TABLE GT_2011 INTO DATA(LS_2011_ORIGN) WITH KEY SGRPNR = LV_SGRPNR.
      MOVE-CORRESPONDING LS_2011_ORIGN TO <LS_2011>.
      <LS_2011>-AEDAT = SY-DATUM.
      <LS_2011>-AENAM = SY-UNAME.
    ENDIF.
  ELSE.
    APPEND INITIAL LINE TO PT_2011 ASSIGNING <LS_2011>.

    PERFORM GET_NUM_SGRPNR CHANGING LV_SGRPNR PV_CHK_ERR.
    IF PV_CHK_ERR = ABAP_TRUE.
      RETURN.
    ENDIF.

    <LS_2011>-SGRPNR = LV_SGRPNR.
    <LS_2011>-JOBTY = '1'.
    <LS_2011>-COND_TYPE = PV_JAEJIL.
    PERFORM GET_ZZBUNDLE_NO CHANGING <LS_2011>-ZZBUNDLE PV_CHK_ERR.
    IF PV_CHK_ERR = ABAP_TRUE.
      RETURN.
    ENDIF.

    <LS_2011>-ERNAM = SY-UNAME.
    <LS_2011>-AEDAT = SY-DATUM.
    <LS_2011>-AENAM = SY-UNAME.

    LOOP AT LT_2013 ASSIGNING FIELD-SYMBOL(<LS_2013>).
      <LS_2013>-SGRPNR = LV_SGRPNR.
    ENDLOOP.

    LOOP AT LT_2014 ASSIGNING FIELD-SYMBOL(<LS_2014>).
      <LS_2014>-SGRPNR = LV_SGRPNR.
    ENDLOOP.

    PV_SGRPNR = LV_SGRPNR.
    PV_ZZBUNDLE = <LS_2011>-ZZBUNDLE.

    APPEND LINES OF LT_2013 TO PT_2013[].
    APPEND LINES OF LT_2014 TO PT_2014[].

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_DATA_TO_SAVE02_400
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_2012
*&      --> LS_CREATE_ZWSEQ
*&      --> LV_SGRPNR
*&      --> LV_ZZBUNDLE
*&      --> GS_MAIN_DISP_403_BONSU
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM MAKE_DATA_TO_SAVE02_400  TABLES  PT_2012 STRUCTURE ZGTPPT2012
                          USING    PV_ZWSEQ TYPE ZGTPPT2012-ZWSEQ
                                   PV_SGRPNR TYPE ZGTESGRPNR
                                   PV_ZZBUNDLE TYPE AUFK-ZZBUNDLE
                                   PS_MAIN LIKE GS_MAIN_DISP_403
                       CHANGING PV_CHK_ERR.

  DATA : LS_2012 TYPE ZGTPPT2012.
  DATA : LT_2012 TYPE TABLE OF ZGTPPT2012.

  READ TABLE GT_MAINTAIN_LENGTH INTO GS_MAINTAIN_LENGTH WITH KEY LAYER =  PS_MAIN-BONSU
                                                                                       ZTWSEQ = PV_ZWSEQ.

  IF SY-SUBRC EQ 0 AND GS_MAINTAIN_LENGTH-MENGE NE 0.
    CLEAR LS_2012.
    LS_2012-SGRPNR = PV_SGRPNR.
    SELECT SINGLE PDCAPROCCODE FROM ZGTCVMSTVAL
       INTO LS_2012-GONG_CD
      WHERE WERKS = P_WERKS
         AND MATNR = PS_MAIN-MATNR.

    LS_2012-JOBTY = '1'.
    LS_2012-COND_TYPE = PS_MAIN-JAEJIL.
    LS_2012-POSNR = 1.
    LS_2012-ORDTY = 'PRD'.
    IF GS_MAINTAIN_LENGTH-MENGE02 NE 0.
      LS_2012-INLENGTH = GS_MAINTAIN_LENGTH-MENGE - GS_MAINTAIN_LENGTH-MENGE02.
      LS_2012-ADTYPE = 'C'.
      LS_2012-ADLENGTH = GS_MAINTAIN_LENGTH-MENGE02.
    ELSE.
      LS_2012-INLENGTH = GS_MAINTAIN_LENGTH-MENGE.
    ENDIF.
    LS_2012-INFACTOR = PS_MAIN-BONSU.
    LS_2012-ZCAGE = PS_MAIN-BONSU.
    LS_2012-ZTWSEQ = GS_HEADER_400-ZTWSEQ.
    LS_2012-ZWSEQ = PV_ZWSEQ.

  ELSE. " 작업수량이 0인건은 오더생성 저장 없음
    RETURN.
  ENDIF.


  DATA : LV_ZZPOSNR TYPE AUFK-ZZPOSNR.
  DATA : LV_FINDATE TYPE SY-DATUM.

  PERFORM GET_FINDATE_400 USING PS_MAIN-JAEJIL  CHANGING LV_FINDATE.
  LV_ZZPOSNR = PV_ZWSEQ + 0.

  APPEND INITIAL LINE TO PT_2012 ASSIGNING FIELD-SYMBOL(<LS_2012>).
  MOVE-CORRESPONDING LS_2012 TO <LS_2012>.

*    해당 정보로 생산오더 생성
  PERFORM CREATE_PRD_ORDER_404 USING <LS_2012> PS_MAIN-MATNR PV_ZZBUNDLE LV_ZZPOSNR LV_FINDATE CHANGING <LS_2012>-ORDNR PV_CHK_ERR.
  IF PV_CHK_ERR = ABAP_TRUE.
    RETURN.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_FINDATE_400
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_FINDATE
*&---------------------------------------------------------------------*
FORM GET_FINDATE_400  USING PV_JAEJIL TYPE ZEDT1130-JAEJIL
                        CHANGING PV_FINDATE TYPE SY-DATUM.

  DATA : LT_AUFNR TYPE RANGE OF AUFNR.

  LT_AUFNR = VALUE #( FOR LW_DATA IN GT_MAIN_DISP_402 WHERE ( JAEJIL = PV_JAEJIL
                                                                                     AND   ORDNR IS NOT INITIAL  )
                              ( SIGN = 'I' OPTION = 'EQ' LOW = LW_DATA-ORDNR ) ).

  SELECT SINGLE MIN( GSTRP ) AS GSTRP FROM ZGTCVORDSYVAL
    WHERE AUFNR IN @LT_AUFNR
     INTO @PV_FINDATE.

  PV_FINDATE = PV_FINDATE - 1.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_CHK_ARBPL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- LV_ARBPL
*&---------------------------------------------------------------------*
FORM GET_CHK_ARBPL   USING PV_MATNR TYPE MATNR
                     CHANGING PV_ARBPL TYPE ZGTCVROUTING-ARBPL.

  DATA : BEGIN OF LS_ARBPL,
           WERKS TYPE ZGTCVROUTING-WERKS,
           MATNR TYPE ZGTCVROUTING-MATNR,
           ARBPL TYPE ZGTCVROUTING-ARBPL,
           KTEXT TYPE ZGTCVROUTING-KTEXT,
         END OF LS_ARBPL.
  DATA : LT_ARBPL LIKE TABLE OF LS_ARBPL.

  DATA : LT_RETURN_TAB TYPE TABLE OF DDSHRETVAL,
         LS_RETURN_TAB LIKE LINE OF LT_RETURN_TAB.

  DATA : LV_LINE       LIKE SY-STEPL,
         LT_DYNPFIELDS LIKE TABLE OF DYNPREAD.

  SELECT WERKS, MATNR, ARBPL, KTEXT
     FROM ZGTCVROUTING
       INTO CORRESPONDING FIELDS OF TABLE @LT_ARBPL
     WHERE WERKS = @P_WERKS
       AND MATNR = @PV_MATNR.

  SORT LT_ARBPL BY ARBPL.
  DELETE ADJACENT DUPLICATES FROM LT_ARBPL COMPARING ARBPL.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'  "F4 창 띄움
    EXPORTING
      RETFIELD        = 'ARBPL'
*     DYNPPROG        = SY-CPROG                 "현재 프로그램명->ZTER0010
*     DYNPNR          = SY-DYNNR                 "현재 화면번호->0100
*     DYNPROFIELD     = 'GS_HEADER_200-ARBPL'           "F4누른 필드->DEPT_CD
      VALUE_ORG       = 'S'                      "가져오는 엔트리가 다수일 경우인 것 같음. 다수일 경우 C로 하면 F4 안뜸
      WINDOW_TITLE    = '설비 조회'   "Search Help 타이틀
      DISPLAY         = 'F'
    TABLES
      VALUE_TAB       = LT_ARBPL                  "부서코드, 부서명 가져온 인터널 테이블
      RETURN_TAB      = LT_RETURN_TAB            "F4에서 선택한 값이 들어옴
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  READ TABLE LT_RETURN_TAB INTO LS_RETURN_TAB INDEX 1.
  IF SY-SUBRC EQ 0.
    PV_ARBPL = LS_RETURN_TAB-FIELDVAL.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_PRD_ORDER_404
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LS_2012>
*&      --> PS_MAIN_MATNR
*&      --> PV_ZZBUNDLE
*&      --> LV_ZZPOSNR
*&      --> LV_FINDATE
*&      <-- <LS_2012>_ORDNR
*&      <-- PV_CHK_ERR
*&---------------------------------------------------------------------*
FORM CREATE_PRD_ORDER_404  USING    PS_2012 TYPE ZGTPPT2012
                                PV_MATNR TYPE MATNR
                                PV_ZZBUNDLE TYPE AUFK-ZZBUNDLE
                                PV_ZZPOSNR TYPE AUFK-ZZPOSNR
                                PV_FINDATE  TYPE SY-DATUM
                       CHANGING PV_ORDNR TYPE ZGTPPT2012-ORDNR
                                PV_CHK_ERR.

  DATA : LS_ORDER TYPE BAPI_PP_ORDER_CREATE.
  DATA : LS_RETURN TYPE BAPIRET2.
  DATA : LV_ORDER_NUMBER TYPE BAPI_ORDER_KEY-ORDER_NUMBER.
  DATA : LS_ORDER_KEY TYPE BAPI_ORDER_KEY.

  LS_ORDER-MATERIAL = PV_MATNR.
  LS_ORDER-PLANT = P_WERKS.
  LS_ORDER-BASIC_START_DATE = PV_FINDATE.
  LS_ORDER-BASIC_END_DATE = PV_FINDATE.
  LS_ORDER-ORDER_TYPE = 'PP01'.
  LS_ORDER-BASIC_SCHEDULING_TYPE = '3'.
  LS_ORDER-QUANTITY = ( PS_2012-INLENGTH + PS_2012-ADLENGTH ) * PS_2012-INFACTOR.

  PERFORM CHK_MATNR_INFOR2 CHANGING LS_ORDER PV_CHK_ERR.
  IF PV_CHK_ERR = ABAP_TRUE.
    RETURN.
  ENDIF.

* 생산오더 생성
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

    CLEAR LS_ORDER_KEY.
    LS_ORDER_KEY-ORDER_NUMBER = LV_ORDER_NUMBER.
    COLLECT LS_ORDER_KEY INTO GT_PRD_ORDERS.

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

  ELSE.
    PV_CHK_ERR = ABAP_TRUE.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '생산오더 생성중 오류 발생하였습니다.'(e12).
    RETURN.
  ENDIF.

  PERFORM SET_PRD_CHG_BY_BDC USING LV_ORDER_NUMBER PS_2012 PV_ZZBUNDLE PV_ZZPOSNR CHANGING PV_CHK_ERR.
  IF PV_CHK_ERR = ABAP_TRUE.
    RETURN.
  ENDIF.

  PV_ORDNR = LV_ORDER_NUMBER.

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

  DATA : LT_CELLS TYPE LVC_T_CENO.
  DATA: LT_STD_FCODES TYPE UI_FUNCTIONS,
        LT_OWN_FCODES TYPE UI_FUNCTIONS.
  DATA : LV_TEXT TYPE GUI_TEXT.

  CASE P_SENDER.
    WHEN GO_GRID_1101.

      GO_GRID_1101->GET_SELECTED_CELLS_ID(
        IMPORTING
         ET_CELLS = LT_CELLS ).                " Cell IDs

      IF LT_CELLS[] IS INITIAL.
        RETURN.
      ENDIF.

      P_OBJECT->CLEAR( ).

      LV_TEXT = '선택'.
      CALL METHOD P_OBJECT->ADD_FUNCTION
        EXPORTING
          FCODE = 'CHECK_LINE'
          TEXT  = LV_TEXT.

      CALL METHOD P_OBJECT->SHOW_FUNCTIONS
        EXPORTING
          FCODES = LT_OWN_FCODES.

      CALL METHOD CL_GUI_CFW=>FLUSH.

    WHEN OTHERS.
      RETURN.
  ENDCASE.

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
    MESSAGE S006 DISPLAY LIKE 'E' WITH LV_MATNR_C '생산버전을 찾을 수 없습니다.'.
    RETURN.
  ENDIF.

  LV_CHK_DATE = LS_MKAL-ADATU.
  LV_ORIGN_DATE = PS_ORDER-BASIC_START_DATE.

  IF LV_CHK_DATE > LV_ORIGN_DATE.
    PS_ORDER-BASIC_START_DATE = LS_MKAL-ADATU.
    PS_ORDER-BASIC_END_DATE = LS_MKAL-ADATU.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_ORDNO_BWD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LS_MAIN>
*&      <-- LV_CHK
*&---------------------------------------------------------------------*
FORM CHECK_ORDNO_BWD  USING    PS_MAIN LIKE GS_MAIN_DISP
                        CHANGING PV_CHK.

  DATA : LT_AUFNR TYPE RANGE OF AUFNR.
  DATA : LT_2013 TYPE TABLE OF ZGTPPT2013.

  LT_2013 = VALUE #( FOR LW_2013 IN GT_2013 WHERE ( GRPNR = PS_MAIN-GRPNR )
                            ( CORRESPONDING #( LW_2013 ) ) ).
  IF LT_2013[] IS INITIAL. " 조장번호 대상이 없으면 소선지시 미존재
    RETURN.
  ELSE.
    READ TABLE LT_2013 INTO DATA(LS_2013) INDEX 1.

    LT_AUFNR = VALUE #( FOR LW_2012 IN GT_2012 WHERE ( SGRPNR = LS_2013-SGRPNR
                                                                       AND   JOBTY = '1' )
                                ( SIGN = 'I' OPTION = 'EQ' LOW = LW_2012-ORDNR ) ).
    IF LT_AUFNR[] IS NOT INITIAL.
      PV_CHK = ABAP_TRUE.
    ELSE.
      RETURN.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_SET_ARBPL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LS_2012>_ORDNR
*&      <-- <LS_2012>_ARBPL
*&---------------------------------------------------------------------*
FORM CHECK_SET_ARBPL  USING    PV_ORDNR
                      CHANGING PV_ARBPL TYPE ARBPL.

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
   WHERE A~AUFNR = @PV_ORDNR
    AND  F~SPRAS = @SY-LANGU
   INTO TABLE @DATA(LT_ARBPL).

* 오더에 지정된 설비 찾아오기
  READ TABLE LT_ARBPL INTO DATA(LS_ARBPL) WITH KEY PLNFL = '000000'.
  PV_ARBPL = LS_ARBPL-ARBPL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_SET_ARBPL_TEXT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_CHK_ORDNR_ORDNR
*&      <-- LV_REPTXT
*&---------------------------------------------------------------------*
FORM CHECK_SET_ARBPL_TEXT  USING    PV_ORDNR
                           CHANGING PV_REPTXT.

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
   WHERE A~AUFNR = @PV_ORDNR
    AND  F~SPRAS = @SY-LANGU
   INTO TABLE @DATA(LT_ARBPL).

* 오더에 지정된 설비 찾아오기
  READ TABLE LT_ARBPL INTO DATA(LS_ARBPL) WITH KEY PLNFL = '000000'..
  PV_REPTXT = PV_REPTXT && '(' && LS_ARBPL-KTEXT && ')'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ITAB_1102
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_ITAB_1102 .

  DATA : LT_MATNR TYPE RANGE OF MATNR.
  DATA : LT_GRPNR TYPE RANGE OF ZGTPPT2010-GRPNR.
  DATA : LT_SGRPNR TYPE RANGE OF ZGTPPT2012-SGRPNR.
  DATA : LV_SEQNO TYPE I.
  DATA : LS_MSTVAL TYPE ZGTCVMSTVAL.
  DATA : LV_DATA_NUM TYPE ZEDT1030-DATA_NUM.
  DATA : LV_TABIX TYPE I.
  DATA : LS_2011 TYPE ZGTPPT2011.
  DATA : LV_ZWSEQ LIKE ZGTPPT2012-ZWSEQ.
  DATA : LV_CAL01 TYPE P LENGTH 16 DECIMALS 5, "외경
         LV_CAL02 TYPE P LENGTH 16 DECIMALS 5, " 점적률
         LV_CAL03 TYPE P LENGTH 16 DECIMALS 5, " 유효권취
         LV_CAL04 TYPE P LENGTH 16 DECIMALS 5, " 실제권취
         LV_CAL05 TYPE P LENGTH 16 DECIMALS 5. " 기준권취량
  CONSTANTS : LC_CON01 TYPE P LENGTH 16 DECIMALS 14 VALUE '3.14159265358979'. "보빈동경

  LT_MATNR = VALUE #( FOR LW_MAIN1101 IN GT_MAIN_DISP_1101 WHERE ( MATNR IS NOT INITIAL )
                          ( SIGN = 'I' OPTION = 'EQ' LOW = LW_MAIN1101-MATNR ) ).

  SORT LT_MATNR BY LOW.
  DELETE ADJACENT DUPLICATES FROM LT_MATNR COMPARING LOW.

  REFRESH GT_BOBIN.
  SELECT * FROM ZGTPPT1010
    INTO TABLE GT_BOBIN
   WHERE MODULE_KIND = 'PP'
     AND CODEGRP = '2120'
     AND FLD_01 = P_WERKS.

  REFRESH GT_2012_MAINTAIN.

  LT_GRPNR = VALUE #( FOR LW_MAIN_1100 IN GT_MAIN_DISP_1100 WHERE ( GRPNR IS NOT INITIAL )
                               ( SIGN = 'I' OPTION = 'EQ' LOW = LW_MAIN_1100-GRPNR ) ).

  IF LT_GRPNR[] IS NOT INITIAL.
    SORT LT_GRPNR BY LOW.
    DELETE ADJACENT DUPLICATES FROM LT_GRPNR COMPARING LOW.

    LT_SGRPNR = VALUE #( FOR LW_2013 IN GT_2013 WHERE ( GRPNR IN LT_GRPNR )
                                  ( SIGN = 'I' OPTION = 'EQ' LOW = LW_2013-SGRPNR ) ).

    IF LT_SGRPNR[] IS NOT INITIAL.
      SORT LT_SGRPNR BY LOW.
      DELETE ADJACENT DUPLICATES FROM LT_SGRPNR COMPARING LOW.

      GT_2012_MAINTAIN = VALUE #( FOR LW_2012 IN GT_2012 WHERE ( SGRPNR IN LT_SGRPNR )
                                              ( CORRESPONDING #( LW_2012 ) ) ).

    ENDIF.
  ENDIF.

  REFRESH GT_MAIN_DISP_1102.

  CLEAR LV_SEQNO.
  LOOP AT LT_MATNR INTO DATA(LS_MATNR).
    CLEAR GS_MAIN_DISP_1102.
    ADD 1 TO LV_SEQNO.
    GS_MAIN_DISP_1102-SEQNO = LV_SEQNO.

    READ TABLE GT_WRAPPING INTO DATA(LS_WRAPPING) WITH KEY MATNR = LS_MATNR-LOW.
    IF SY-SUBRC EQ 0.
* 외장재
      GS_MAIN_DISP_1102-MATNR_O = LS_WRAPPING-MATNR.
* 외장재명
      GS_MAIN_DISP_1102-MAKTX_O = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = LS_WRAPPING-MATNR ).

      CLEAR LS_MSTVAL.
      SELECT SINGLE * FROM ZGTCVMSTVAL
        INTO LS_MSTVAL
       WHERE WERKS = P_WERKS
         AND MATNR = LS_WRAPPING-MATNR_BWD.
* 재질
      GS_MAIN_DISP_1102-JAEJIL = LS_MSTVAL-PDCACONDMAT.
* 소선경
      GS_MAIN_DISP_1102-SOSUN_DIA = LS_MSTVAL-PDCACONDDIA + 0..
* 외장조장
      CLEAR LV_TABIX.
      CLEAR LS_2011.
      LOOP AT GT_MAIN_DISP_1101 INTO DATA(LS_MAIN) WHERE MATNR = LS_WRAPPING-MATNR.
        ADD 1 TO LV_TABIX.
        IF LV_TABIX = 1.
          READ TABLE GT_2010 INTO DATA(LS_2010) WITH KEY ORDNR = LS_MAIN-ORDNR
                                                                       POSNR = LS_MAIN-POSNR.
          IF SY-SUBRC EQ 0.
            READ TABLE GT_2013 INTO DATA(LS_2013) WITH KEY GRPNR = LS_2010-GRPNR.
            IF SY-SUBRC EQ 0.
              READ TABLE GT_2011 INTO LS_2011 WITH KEY SGRPNR = LS_2013-SGRPNR
                                                                      MATNR = LS_MATNR-LOW.
              IF SY-SUBRC EQ 0.
                GS_MAIN_DISP_1102-SGRPNR = LS_2011-SGRPNR.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
        ADD LS_MAIN-INLENGTH01 TO GS_MAIN_DISP_1102-MENGE01.
      ENDLOOP.

* 본수
      CLEAR LV_DATA_NUM.
      SELECT SINGLE DATA_NUM FROM ZEDT1030
       INTO LV_DATA_NUM
       WHERE SUL_NO = LS_WRAPPING-SUL_NO
         AND REV_SEQ = LS_WRAPPING-REV_SEQ
         AND GONG_SEQ = LS_WRAPPING-GONG_SEQ
         AND ATTRIBUTE = 'BONSU'.

      GS_MAIN_DISP_1102-LAYER = LV_DATA_NUM + 0.
* 적용보빈(입력)
      IF LS_2011-BOBIN_SPEC IS NOT INITIAL.
        GS_MAIN_DISP_1102-MENGE02 = LS_2011-BOBIN_SPEC.
        READ TABLE GT_BOBIN INTO DATA(LS_BOBIN) WITH KEY FLD_02 = LS_2011-BOBIN_SPEC.
      ELSE.
        GS_MAIN_DISP_1102-MENGE02 = '610'.
        READ TABLE GT_BOBIN INTO LS_BOBIN WITH KEY FLD_02 = GS_MAIN_DISP_1102-MENGE02.
      ENDIF.

* 연입률(입력)
* 신선재 작업여장(입력)
      READ TABLE GT_2012 INTO DATA(LS_2012) WITH KEY SGRPNR = LS_2011-SGRPNR.
      IF SY-SUBRC EQ 0.

        GS_MAIN_DISP_1102-CHK_EXIST = ABAP_TRUE.
        GS_MAIN_DISP_1102-YCOEF = LS_2012-YCOEF.
        GS_MAIN_DISP_1102-MENGE03 = LS_2012-ADLENGTH.
      ELSE.
        GS_MAIN_DISP_1102-MENGE03 = 70.

* 연입률(입력)
        CLEAR LV_DATA_NUM.
        SELECT SINGLE DATA_NUM FROM ZEDT1030
         INTO LV_DATA_NUM
         WHERE SUL_NO = LS_WRAPPING-SUL_NO
           AND REV_SEQ = LS_WRAPPING-REV_SEQ
           AND GONG_SEQ = LS_WRAPPING-GONG_SEQ
           AND ATTRIBUTE = 'YRATE'.

        GS_MAIN_DISP_1102-YCOEF = LV_DATA_NUM + 0.

      ENDIF.
* 작업량
      GS_MAIN_DISP_1102-MENGE04 = GS_MAIN_DISP_1102-MENGE01 * GS_MAIN_DISP_1102-YCOEF
*      GS_MAIN_DISP_1102-MENGE04 = GS_MAIN_DISP_1102-MENGE01 * GS_MAIN_DISP_1102-LAYER * GS_MAIN_DISP_1102-YCOEF
                                                  + GS_MAIN_DISP_1102-MENGE03.

* 기준권취량(신선의 소선 정보 계산식 동일)
      SELECT SINGLE BASE_WD FROM ZGTPPT2260
        INTO @DATA(LV_BASE_WD)
       WHERE SOSUN_DIA = @GS_MAIN_DISP_1102-SOSUN_DIA.
      IF SY-SUBRC EQ 0 AND LV_BASE_WD IS NOT INITIAL.
        GS_MAIN_DISP_1102-MENGE05 = LV_BASE_WD.
      ELSE. " 관리테이블에 없으면 계산

* ① 외경 = 보빈 내폭 / 소선경
        LV_CAL01 = LS_BOBIN-FLD_04 / GS_MAIN_DISP_1102-SOSUN_DIA.

* ② 점적률 = ROUND(INT(외경-1)/외경,4), 소수점 4자리 반올림
        LV_CAL02 = ( LV_CAL01 - 1 ) / LV_CAL01.
        PERFORM CONV_ROUND USING '0.01' CHANGING LV_CAL02.

* ③ 유효권취 = ((악경 - 2 * 15) - 보빈동경) / 2 / 소선경
        LV_CAL03 = ( ( LS_BOBIN-FLD_02 - 30 ) - LS_BOBIN-FLD_03 ) / 2 / GS_MAIN_DISP_1102-SOSUN_DIA.

* ④ 실제권취 = INT(유효 권취 + 0.99) -1, 소수점 버림
        LV_CAL04 = ( LV_CAL03 + '0.99' ).
        PERFORM CONV_TRUNCATE USING 1 CHANGING LV_CAL04.
        LV_CAL04 = LV_CAL04 - 1.

* ⑤ 기준권취량 = ROUND(원주율 * 보빈내폭 * 점적율 * 실제권취 * (실제권취 * 소선경 + 보빈동경) / 소선경 / 1000,0)
        LV_CAL05 =  LC_CON01 * LS_BOBIN-FLD_04 * LV_CAL02 * LV_CAL04 *
                        ( LV_CAL04 * GS_MAIN_DISP_1102-SOSUN_DIA + LS_BOBIN-FLD_03 ) / GS_MAIN_DISP_1102-SOSUN_DIA / 1000.
        PERFORM CONV_ROUND USING 1 CHANGING LV_CAL05.

        GS_MAIN_DISP_1102-MENGE05 = LV_CAL05.

      ENDIF.
* 권취개수
      GS_MAIN_DISP_1102-MENGE06 = GS_MAIN_DISP_1102-MENGE04 / GS_MAIN_DISP_1102-MENGE05.
      PERFORM CONV_UPPPER_ROUND USING 1 CHANGING GS_MAIN_DISP_1102-MENGE06.

* 실권취량
      GS_MAIN_DISP_1102-MENGE07 = GS_MAIN_DISP_1102-MENGE04 / GS_MAIN_DISP_1102-MENGE06.
* 올림처리
      PERFORM CONV_UPPPER_ROUND USING 1 CHANGING GS_MAIN_DISP_1102-MENGE07.
* 작업지시량
      GS_MAIN_DISP_1102-MENGE08 = GS_MAIN_DISP_1102-MENGE07 * GS_MAIN_DISP_1102-MENGE06.
* 올림처리
      PERFORM CONV_UPPPER_ROUND USING 1 CHANGING GS_MAIN_DISP_1102-MENGE08.

      SELECT SINGLE MEINS FROM MARA
        INTO GS_MAIN_DISP_1102-MEINS
        WHERE MATNR = LS_WRAPPING-MATNR_BWD.
      IF GS_MAIN_DISP_1102-MEINS IS INITIAL.
        GS_MAIN_DISP_1102-MEINS = 'M'.
      ENDIF.
      GS_MAIN_DISP_1102-MATNR = LS_WRAPPING-MATNR_BWD.
      GS_MAIN_DISP_1102-MAKTX = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = LS_WRAPPING-MATNR_BWD ).

      APPEND GS_MAIN_DISP_1102 TO GT_MAIN_DISP_1102.
    ENDIF.
  ENDLOOP.

  DATA(LT_CHK_MAXSEQ) = GT_MAIN_DISP_1102.
  SORT LT_CHK_MAXSEQ BY MENGE06 DESCENDING.
  READ TABLE LT_CHK_MAXSEQ INTO DATA(LS_CHK_MAXSEQ) INDEX 1.
  CLEAR GV_MAX_ZTWSEQ.
  GV_MAX_ZTWSEQ = LS_CHK_MAXSEQ-MENGE06.

* 1103 테이블 수량 세팅을 위한 테이블 생성
  REFRESH GT_1101_MENGE.
  DATA : LV_CHK_EXISTS_BWD.

  LOOP AT GT_MAIN_DISP_1102 ASSIGNING FIELD-SYMBOL(<LS_MAIN>).
    CLEAR GS_1101_MENGE.
    CLEAR LV_ZWSEQ.
    GS_1101_MENGE-SEQNO = <LS_MAIN>-SEQNO.
    GS_1101_MENGE-MATNR_O = <LS_MAIN>-MATNR_O.
    GS_1101_MENGE-SGRPNR = <LS_MAIN>-SGRPNR.
    GS_1101_MENGE-MENGE07 = <LS_MAIN>-MENGE07.
    <LS_MAIN>-CURRENT_ZWSEQ = <LS_MAIN>-MENGE06.
    <LS_MAIN>-INPUT_ZWSEQ = <LS_MAIN>-MENGE06.

    CLEAR LV_ZWSEQ.
    CLEAR LV_CHK_EXISTS_BWD.
    READ TABLE GT_2012_MAINTAIN INTO DATA(LS_2012_CHK) WITH KEY SGRPNR = <LS_MAIN>-SGRPNR.
    IF SY-SUBRC EQ 0.
      LV_CHK_EXISTS_BWD = ABAP_TRUE.
*      <LS_MAIN>-CURRENT_ZWSEQ = LS_2012_CHK-ZTWSEQ.
*      <LS_MAIN>-INPUT_ZWSEQ = LS_2012_CHK-ZTWSEQ.

      IF GV_MAX_ZTWSEQ < LS_2012_CHK-ZTWSEQ.
        GV_MAX_ZTWSEQ = LS_2012_CHK-ZTWSEQ.
      ENDIF.
    ENDIF.

    DO GV_MAX_ZTWSEQ TIMES.
      ADD 1 TO LV_ZWSEQ.

      GS_1101_MENGE-ZWSEQ = LV_ZWSEQ.
      READ TABLE GT_2012_MAINTAIN INTO DATA(LS_2012_MAINTAIN) WITH KEY SGRPNR = <LS_MAIN>-SGRPNR
                                                                                                ZWSEQ = LV_ZWSEQ.
      IF SY-SUBRC EQ 0.
        GS_1101_MENGE-MENGE07 = LS_2012_MAINTAIN-INLENGTH + LS_2012_MAINTAIN-ADLENGTH.
        GS_1101_MENGE-DO_NOT_CHG = ABAP_TRUE.
        APPEND GS_1101_MENGE TO GT_1101_MENGE.
      ELSE.
        IF LV_CHK_EXISTS_BWD = ABAP_TRUE.
          IF LV_ZWSEQ <= LS_2012_CHK-ZTWSEQ.
            GS_1101_MENGE-MENGE07 = 0.
          ELSE.
            EXIT.
          ENDIF.
        ELSE.
          APPEND GS_1101_MENGE TO GT_1101_MENGE.
        ENDIF.
      ENDIF.
    ENDDO.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_ITAB_1103
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_ITAB_1103 .

  DATA : LV_NUM(2) TYPE N.
  DATA : LV_FIELDNAME TYPE FIELDNAME.
  DATA : LS_1103_01 TYPE REF TO DATA. " 아이템 2줄로 추가를 위해 아이템 필드 2개 구성
  DATA : LS_1103_02 TYPE REF TO DATA. " 아이템 2줄로 추가를 위해 아이템 필드 2개 구성
  DATA : LV_TABIX TYPE I..

  FIELD-SYMBOLS : <LS_LINE01> TYPE ANY,
                  <LS_LINE02> TYPE ANY.

  FIELD-SYMBOLS : <LV_VALUE01> TYPE ANY,
                  <LV_VALUE02> TYPE ANY.

  DEFINE __SET_FIELD_OF_LINE.
    IF <LV_VALUE01> IS ASSIGNED. UNASSIGN <LV_VALUE01>. ENDIF.
    ASSIGN COMPONENT &1 OF STRUCTURE <LS_LINE01> TO <LV_VALUE01>.
    IF <LV_VALUE02> IS ASSIGNED. UNASSIGN <LV_VALUE02>. ENDIF.
    ASSIGN COMPONENT &1 OF STRUCTURE <LS_LINE02> TO <LV_VALUE02>.
  END-OF-DEFINITION.

  CHECK GT_MAIN_DISP_1102 IS NOT INITIAL.
  CHECK GV_MAX_ZTWSEQ NE 0.

  PERFORM INIT_1103_SCREEN.

  CREATE DATA LS_1103_01 LIKE LINE OF <GT_MAIN_DISP_1103>.
  CREATE DATA LS_1103_02 LIKE LINE OF <GT_MAIN_DISP_1103>.
  ASSIGN LS_1103_01->* TO <LS_LINE01>.
  ASSIGN LS_1103_02->* TO <LS_LINE02>.

  LOOP AT GT_MAIN_DISP_1102 INTO GS_MAIN_DISP_1102.
    CLEAR : <LS_LINE01>, <LS_LINE02>.
    ADD 1 TO LV_TABIX.
*    CAGE
    __SET_FIELD_OF_LINE 'SEQNO'.
    <LV_VALUE01> = <LV_VALUE02> = GS_MAIN_DISP_1102-SEQNO.
    __SET_FIELD_OF_LINE 'SEQNO_C'.
    <LV_VALUE01> = <LV_VALUE02> = GS_MAIN_DISP_1102-SEQNO.
    CONDENSE : <LV_VALUE01>, <LV_VALUE02>.

*
    __SET_FIELD_OF_LINE 'MATNR_O'.
    <LV_VALUE01> = <LV_VALUE02> = GS_MAIN_DISP_1102-MATNR_O.

*    내부관리 순번( 2라인 컨트롤 위한 순번)
    __SET_FIELD_OF_LINE 'LINE'.
    <LV_VALUE01> = 1.
    <LV_VALUE02> = 2.

* 작업차수
    __SET_FIELD_OF_LINE 'ZTWSEQ'.
    <LV_VALUE01> =  GS_MAIN_DISP_1102-INPUT_ZWSEQ.

* 작업차수변경
    __SET_FIELD_OF_LINE 'CHANGE'.
    <LV_VALUE01> =  ICON_CHANGE.


*  차수별 데이터 입력
    CLEAR LV_NUM.
    DO GV_CURRENT_ZTWSEQ TIMES.
      ADD 1 TO LV_NUM.
      LV_FIELDNAME = 'FIELDINFOR_' && LV_NUM.
      __SET_FIELD_OF_LINE LV_FIELDNAME.
      PERFORM SE_LINE_TEXT_1103 USING GS_MAIN_DISP_1102 LV_NUM
                                  CHANGING <LV_VALUE01> <LV_VALUE02>.
    ENDDO.

    APPEND <LS_LINE01> TO <GT_MAIN_DISP_1103>.
    APPEND <LS_LINE02> TO <GT_MAIN_DISP_1103>.

  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form INIT_1103_SCREEN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM INIT_1103_SCREEN .

  IF GV_CURRENT_ZTWSEQ = 0 OR GV_CURRENT_ZTWSEQ NE GV_MAX_ZTWSEQ.
    GV_CURRENT_ZTWSEQ = GV_MAX_ZTWSEQ.
    PERFORM SET_FIELDCAT_GRID_1103.
    IF GV_CURRENT_ZTWSEQ > 50.
      PERFORM MAKE_ITAB_FR_FCAT_1103.
    ELSE.
      IF <GT_MAIN_DISP_1103> IS ASSIGNED. UNASSIGN <GT_MAIN_DISP_1103>. ENDIF.
      ASSIGN GT_MAIN_DISP_1103 TO <GT_MAIN_DISP_1103>.
    ENDIF.

    FREE GO_MAIN_DISP_1103_NUM.
    CREATE DATA GO_MAIN_DISP_1103_NUM LIKE <GT_MAIN_DISP_1103>.
    ASSIGN GO_MAIN_DISP_1103_NUM->* TO <GT_MAIN_DISP_1104_NUM>.

    IF GO_GRID_1103 IS BOUND.

      CALL METHOD GO_GRID_1103->SET_TABLE_FOR_FIRST_DISPLAY
        EXPORTING
          IS_LAYOUT            = GS_LAYOUT_1103
          IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_1103
        CHANGING
          IT_OUTTAB            = <GT_MAIN_DISP_1103>
          IT_SORT              = GT_SORT_1103
          IT_FIELDCATALOG      = GT_FIELDCAT_1103.

    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_GRID_1103
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_1103 .

  DATA : LT_FCAT TYPE SLIS_T_FIELDCAT_ALV.
  DATA : LV_COL_POS TYPE I.
  DATA : LV_COL_POS2 TYPE I.
  DATA : LV_NUM(2) TYPE N.
  DATA : LV_SEQ TYPE I.
  DATA : LV_SEQ_C TYPE C LENGTH 11.
  DATA : LV_FIELDNAME TYPE FIELDNAME.
  DATA : LV_REPTXT TYPE REPTXT.
  DATA : LV_ZWSEQ TYPE ZGTPPT2012-ZWSEQ.

  REFRESH GT_FIELDCAT_1103.
* 필드 세팅
  READ TABLE GT_FIELDCAT_1103 TRANSPORTING NO FIELDS WITH KEY FIELDNAME = 'SEQNO'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_1103 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    <LS_FCAT>-COL_POS = 1.
    <LS_FCAT>-FIELDNAME = 'SEQNO'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = <LS_FCAT>-FIELDNAME.
    <LS_FCAT>-DATATYPE = 'INT'.
    <LS_FCAT>-DD_OUTLEN = '10'.
    <LS_FCAT>-OUTPUTLEN = '6'.
    <LS_FCAT>-NO_OUT = ABAP_TRUE.
  ENDIF.

  READ TABLE GT_FIELDCAT_1103 TRANSPORTING NO FIELDS WITH KEY FIELDNAME = 'SEQNO_C'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_1103 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-COL_POS = 2.
    <LS_FCAT>-FIELDNAME = 'SEQNO_C'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '순번'(f83).
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '10'.
    <LS_FCAT>-OUTPUTLEN = '4'.
    <LS_FCAT>-JUST = 'C'.

  ENDIF.

  READ TABLE GT_FIELDCAT_1103 TRANSPORTING NO FIELDS WITH KEY FIELDNAME = 'MATNR_O'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_1103 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-COL_POS = 3.
    <LS_FCAT>-FIELDNAME = 'MATNR_O'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = <LS_FCAT>-FIELDNAME.
    <LS_FCAT>-REF_TABLE = 'MARA'.
    <LS_FCAT>-REF_FIELD = 'MATNR'.
    <LS_FCAT>-JUST = 'C'.
    <LS_FCAT>-NO_OUT = ABAP_TRUE.
  ENDIF.

  READ TABLE GT_FIELDCAT_1103 TRANSPORTING NO FIELDS WITH KEY FIELDNAME = 'LINE'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_1103 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-COL_POS = 4.
    <LS_FCAT>-FIELDNAME = 'LINE'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = <LS_FCAT>-FIELDNAME.
    <LS_FCAT>-DATATYPE = 'INT'.
    <LS_FCAT>-DD_OUTLEN = '10'.
    <LS_FCAT>-JUST = 'C'.
  ENDIF.

  READ TABLE GT_FIELDCAT_1103 TRANSPORTING NO FIELDS WITH KEY FIELDNAME = 'ZTWSEQ'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_1103 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-COL_POS = 5.
    <LS_FCAT>-FIELDNAME = 'ZTWSEQ'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '작업차수'(F84).
    <LS_FCAT>-REF_TABLE = 'ZGTPPT2012'.
    <LS_FCAT>-REF_FIELD = 'ZTWSEQ'.
    <LS_FCAT>-DECIMALS_O = 0.
    <LS_FCAT>-JUST = 'R'.
  ENDIF.

  READ TABLE GT_FIELDCAT_1103 TRANSPORTING NO FIELDS WITH KEY FIELDNAME = 'CHANGE'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_1103 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-COL_POS = 6.
    <LS_FCAT>-FIELDNAME = 'CHANGE'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '　　'.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '5'.
    <LS_FCAT>-OUTPUTLEN = '2'.
    <LS_FCAT>-HOTSPOT = ABAP_TRUE.
    <LS_FCAT>-ICON = 'C'.
    <LS_FCAT>-JUST = 'C'.
  ENDIF.

* 차수 필드 세팅
  LV_COL_POS = 100.
  LV_COL_POS2 = 400.
  DO GV_CURRENT_ZTWSEQ TIMES.
    ADD 1 TO LV_NUM.
    ADD 1 TO LV_SEQ.
    ADD 1 TO LV_COL_POS.
    ADD 1 TO LV_COL_POS2.
    LV_FIELDNAME = 'FIELDINFOR_' && LV_NUM.
    LV_SEQ_C = LV_SEQ.
    CONDENSE LV_SEQ_C.

    LV_REPTXT = LV_SEQ_C && '차'.
    CLEAR LV_ZWSEQ.
    LV_ZWSEQ = LV_SEQ.
    READ TABLE GT_FIELDCAT_1103 TRANSPORTING NO FIELDS WITH KEY FIELDNAME = LV_FIELDNAME.
    IF SY-SUBRC NE 0.
      APPEND INITIAL LINE TO GT_FIELDCAT_1103 ASSIGNING <LS_FCAT>.
      <LS_FCAT>-COL_POS = LV_COL_POS.
      <LS_FCAT>-FIELDNAME = LV_FIELDNAME.
      <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = LV_REPTXT.
      <LS_FCAT>-DATATYPE = 'CHAR'.
      <LS_FCAT>-DD_OUTLEN = '50'.
      <LS_FCAT>-OUTPUTLEN = '17'.
      <LS_FCAT>-JUST = 'C'.
    ENDIF.


    LV_FIELDNAME = 'MENGE_' && LV_NUM.

    READ TABLE GT_FIELDCAT_1103 TRANSPORTING NO FIELDS WITH KEY FIELDNAME = LV_FIELDNAME.
    IF SY-SUBRC NE 0.
      APPEND INITIAL LINE TO GT_FIELDCAT_1103 ASSIGNING <LS_FCAT>.
      <LS_FCAT>-COL_POS = LV_COL_POS2.
      <LS_FCAT>-FIELDNAME = LV_FIELDNAME.
      <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = LV_REPTXT.
      <LS_FCAT>-REF_TABLE = 'MSEG'.
      <LS_FCAT>-REF_FIELD = 'MENGE'.
      <LS_FCAT>-QUANTITY = 'EA'.
      <LS_FCAT>-JUST = 'R'.
      <LS_FCAT>-NO_OUT = ABAP_TRUE.
    ENDIF.

  ENDDO.

  LOOP AT GT_FIELDCAT_1103 ASSIGNING <LS_FCAT>.
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'SEQNO' OR 'LINE'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
    ENDCASE.

  ENDLOOP.

  SORT GT_FIELDCAT_1103 BY COL_POS.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_ITAB_FR_FCAT_1103
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MAKE_ITAB_FR_FCAT_1103 .

  FREE GO_MAIN_DISP_1103.
  IF <GT_MAIN_DISP_1103> IS ASSIGNED. UNASSIGN <GT_MAIN_DISP_1103>. ENDIF.

  CALL METHOD CL_ALV_TABLE_CREATE=>CREATE_DYNAMIC_TABLE
    EXPORTING
      I_STYLE_TABLE             = ABAP_TRUE
      IT_FIELDCATALOG           = GT_FIELDCAT_1103
    IMPORTING
      EP_TABLE                  = GO_MAIN_DISP_1103
    EXCEPTIONS
      GENERATE_SUBPOOL_DIR_FULL = 1                " At Most 36 Subroutine Pools Can Be Generated Temporarily
      OTHERS                    = 2.
  IF SY-SUBRC <> 0.
    MESSAGE S005 DISPLAY LIKE 'E' WITH 'At Most 36 Subroutine Pools' 'Can Be Generated Temporarily'.
    LEAVE LIST-PROCESSING..
  ENDIF.

  ASSIGN GO_MAIN_DISP_1103->* TO <GT_MAIN_DISP_1103>.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SE_LINE_TEXT_1103
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_MAIN_DISP_1102
*&      --> LV_NUM
*&      <-- <LV_VALUE01>
*&      <-- <LV_VALUE02>
*&---------------------------------------------------------------------*
FORM SE_LINE_TEXT_1103  USING    PS_MAIN LIKE GS_MAIN_DISP_1102
                                 PV_NUM
                        CHANGING PV_VALUE01
                                 PV_VALUE02.

  DATA : LV_ZWSEQ TYPE ZGTPPT2012-ZWSEQ.
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
  DATA : LV_MENGE_C(30).

  LV_ZWSEQ =   PV_NUM + 0.

  READ TABLE GT_2012_MAINTAIN ASSIGNING FIELD-SYMBOL(<LS_2012>) WITH KEY SGRPNR = PS_MAIN-SGRPNR
                                                                                                       ZWSEQ = LV_ZWSEQ.
  IF SY-SUBRC EQ 0. " 오더 존재 해당 생산오더 내용 매핑
*    1번 라인 매핑
    CASE <LS_2012>-ORDTY.
      WHEN 'PR'. "구매요청
        PV_VALUE01 = '구매요청'.

        CLEAR LV_STRING.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
          EXPORTING
            INPUT  = <LS_2012>-POSNR
          IMPORTING
            OUTPUT = LV_STRING.

        LV_ORDNR = <LS_2012>-ORDNR.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
          EXPORTING
            INPUT  = LV_ORDNR
          IMPORTING
            OUTPUT = LV_ORDNR.

        LV_STRING = LV_ORDNR && '/' && LV_STRING.
        CONCATENATE PV_VALUE01 LV_STRING INTO PV_VALUE01 SEPARATED BY SPACE.

        SELECT SINGLE EBELN, EBELP, ELIKZ FROM EKPO
             INTO @DATA(LS_CHK_EKKO)
             WHERE BANFN = @<LS_2012>-ORDNR
               AND BNFPO = @<LS_2012>-POSNR+1(5).
        IF SY-SUBRC EQ 0.
          <LS_2012>-CHK_PRD = ABAP_TRUE.
          IF LS_CHK_EKKO-ELIKZ IS NOT INITIAL.
            <LS_2012>-CHECK_JEGO = ABAP_TRUE.
          ENDIF.
        ENDIF.

      WHEN 'PRD'. " 생산오더
*    Prd(생산오더): 오더 상태 조회 "CRTD" 상태 "(C)", "REL" 상태 "(R)", user status "PAYO" Payoff 장착 상태 "(P/O)"
        PV_VALUE01 = '생산오더'.

        LV_AUFNR = <LS_2012>-ORDNR.
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

        <LS_2012>-STATUS = LV_STCD.

        CASE LV_STCD.
          WHEN 'Z'.
            PV_VALUE01 = PV_VALUE01 && '(E)'.
            <LS_2012>-STATUS = 'E'.
          WHEN 'A'.
            PV_VALUE01 = PV_VALUE01 && '(C)'.
            <LS_2012>-STATUS = 'C'.
          WHEN OTHERS.
            PV_VALUE01 = PV_VALUE01 && '(R)'.
            <LS_2012>-STATUS = 'R'.

*           오더가 작업 완료 상태일때 재고조회
            CASE LV_STCD.
              WHEN 'D' OR 'G' OR 'F' OR 'C'.
                <LS_2012>-CHK_PRD = ABAP_TRUE.
            ENDCASE.

            DATA : BEGIN OF LS_SUM_MSEG,
                     AUFNR LIKE MSEG-AUFNR,
                     AUFPS LIKE MSEG-AUFPS,
                     MENGE LIKE MSEG-MENGE,
                   END OF LS_SUM_MSEG.
            DATA : LT_SUM_MSEG LIKE TABLE OF LS_SUM_MSEG.

            SELECT AUFNR, AUFPS, BWART, CHARG, MENGE
               FROM MSEG
              WHERE MATNR = @PS_MAIN-MATNR
                  AND BWART IN ('101', '102')
                  AND AUFNR = @LV_AUFNR
                  AND AUFPS = @<LS_2012>-POSNR+2(4)
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
                  AND POSNR = @<LS_2012>-POSNR+2(4)
                  AND CHARG NE 'GR_ZERO1'
                 INTO @DATA(LS_AFPO).
* 오더의 자재입고 완료 여부
              READ TABLE LT_SUM_MSEG INTO LS_SUM_MSEG INDEX 1. " 한건만 존재
              LS_AFPO-PSMNG  = LS_AFPO-PSMNG  + LS_AFPO-PSAMG.
              "입고된 자재수량과 생산오더의 총수량이 같으면 재고 완료 처리.
              IF LS_SUM_MSEG-MENGE > 0.
                <LS_2012>-CHECK_JEGO = ABAP_TRUE.
              ENDIF.
* 자재가 이후공정으로 옮겨갔는지 확인.
              IF LS_AFPO-KDAUF IS NOT INITIAL. " 완제품 수량
                SELECT SINGLE SUM( KALAB ) AS KALAB, SUM( KAINS ) AS KAINS, SUM( KASPE ) AS KASPE
                  FROM MSKA
                  WHERE MATNR = @PS_MAIN-MATNR
                     AND WERKS = @P_WERKS
                     AND CHARG IN @LT_CHARG
                     AND VBELN = @LS_AFPO-KDAUF
                     AND POSNR = @LS_AFPO-KDPOS
                  GROUP BY MATNR, WERKS
                   INTO (@DATA(LV_KALAB), @DATA(LV_KAINS), @DATA(LV_KASPE)).
                IF LV_KALAB = 0 AND LV_KAINS = 0 AND LV_KASPE = 0.
                  <LS_2012>-CHECK_ZERO = ABAP_TRUE.
                ENDIF.

              ELSE. " 반제품 수량체크
                SELECT SINGLE SUM( CLABS ) AS CLABS, SUM( CINSM ) AS CINSM, SUM( CSPEM ) AS CSPEM
                  FROM MCHB
                  WHERE MATNR = @PS_MAIN-MATNR
                     AND WERKS = @P_WERKS
                     AND LGORT = @LS_AFPO-LGORT
                     AND CHARG IN @LT_CHARG
                   GROUP BY MATNR, WERKS
                   INTO (@DATA(LV_CLABS),@DATA(LV_CINSM), @DATA(LV_CSPEM)).
                IF LV_CLABS = 0 AND LV_CINSM = 0 AND LV_CSPEM = 0.
                  <LS_2012>-CHECK_ZERO = ABAP_TRUE.
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
          IF <LS_2012>-CHECK_JEGO IS INITIAL AND <LS_2012>-CHECK_ZERO IS INITIAL.
            PV_VALUE01 = PV_VALUE01 && '(P/O)'.
          ENDIF.
          <LS_2012>-CHK_PRD = ABAP_TRUE.
        ENDIF.

        CLEAR LV_STRING.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
          EXPORTING
            INPUT  = <LS_2012>-POSNR
          IMPORTING
            OUTPUT = LV_STRING.

        LV_ORDNR = <LS_2012>-ORDNR.
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
            INPUT  = <LS_2012>-POSNR
          IMPORTING
            OUTPUT = LV_STRING.

        LV_ORDNR = <LS_2012>-ORDNR.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
          EXPORTING
            INPUT  = LV_ORDNR
          IMPORTING
            OUTPUT = LV_ORDNR.

        LV_STRING = LV_ORDNR && '/' && LV_STRING.
        CONCATENATE PV_VALUE01 LV_STRING INTO PV_VALUE01 SEPARATED BY SPACE.

* 상태확인
        LV_EBELN = <LS_2012>-ORDNR.
        LV_EBELP = <LS_2012>-POSNR + 0.

        SELECT EBELN, EBELP, BWART, SHKZG, MENGE FROM MSEG
          INTO TABLE @DATA(LT_EKKO_MSEG)
         WHERE EBELN = @LV_EBELN
          AND EBELP = @LV_EBELP
          AND MATNR = @PS_MAIN-MATNR.

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
          <LS_2012>-CHECK_JEGO = ABAP_TRUE.
          <LS_2012>-CHK_PRD = ABAP_TRUE.
        ELSE.

          IF LV_MENGE > 0.
            <LS_2012>-CHK_PRD = ABAP_TRUE.
          ENDIF.

        ENDIF.

    ENDCASE.


*    2번 라인
    IF <LS_2012>-CHECK_JEGO IS INITIAL.
      CLEAR LV_VALUE.

      LV_VALUE3 = <LS_2012>-INLENGTH.
      LV_VALUE = LV_VALUE3.

      CONDENSE LV_VALUE.
      CONCATENATE '(' LV_VALUE INTO PV_VALUE02.
      IF <LS_2012>-ADLENGTH = 0.
      ELSE.
* 추가여장
        LV_VALUE3 = <LS_2012>-ADLENGTH.
        LV_VALUE = LV_VALUE3.
        CONDENSE LV_VALUE.
        CONCATENATE PV_VALUE02  LV_VALUE  INTO PV_VALUE02.
      ENDIF.
* 조장수
      LV_VALUE3 = <LS_2012>-INFACTOR.
      LV_VALUE = LV_VALUE3.
      CONDENSE LV_VALUE.

      CONCATENATE PV_VALUE02 ')X' LV_VALUE INTO PV_VALUE02.

    ELSE.
      <LS_2012>-CHECK_JEGO = ABAP_TRUE.
      IF <LS_2012>-CHECK_ZERO = ABAP_TRUE.
        LV_VALUE2 = 0.
      ELSE.
        IF <LS_2012>-ORDTY = 'PO'.
          IF LV_MENGE > 0.
            <LS_2012>-CHECK_JEGO = 'Q'.
            LV_VALUE2 = LV_MENGE.
          ELSE.
            LV_VALUE2 = 0.
          ENDIF.
        ELSE.
          IF LS_AFPO-KDAUF IS NOT INITIAL. " 완제품 수량
            IF LV_KAINS > 0.
              <LS_2012>-CHECK_JEGO = 'Q'.
              LV_VALUE2 = LV_KAINS.
            ELSEIF LV_KASPE > 0.
              <LS_2012>-CHECK_JEGO = 'B'.
              LV_VALUE2 = LV_KASPE.
            ELSE.
              LV_VALUE2 = LV_KALAB.
            ENDIF.
          ELSE.
            IF LV_CINSM > 0.
              <LS_2012>-CHECK_JEGO = 'Q'.
              LV_VALUE2 = LV_CINSM.
            ELSEIF LV_CSPEM > 0.
              <LS_2012>-CHECK_JEGO = 'B'.
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
      IF <LS_2012>-CHECK_JEGO = 'Q'.
        CONCATENATE '( QI Stock' LV_VALUE ')' INTO PV_VALUE02 SEPARATED BY SPACE.
      ELSEIF <LS_2012>-CHECK_JEGO = 'B'.
        CONCATENATE '( Block Stock' LV_VALUE ')' INTO PV_VALUE02 SEPARATED BY SPACE.
      ELSE.
        CONCATENATE '( Stock' LV_VALUE ')' INTO PV_VALUE02 SEPARATED BY SPACE.
      ENDIF.
    ENDIF.

  ELSE.

    CLEAR LV_VALUE.



    READ TABLE GT_1101_MENGE INTO GS_1101_MENGE WITH KEY SEQNO = PS_MAIN-SEQNO
                                                                                 ZWSEQ = LV_ZWSEQ.
    IF SY-SUBRC EQ 0.

      CLEAR LV_VALUE.

      LV_VALUE3 = GS_1101_MENGE-MENGE07.
      LV_VALUE = LV_VALUE3.

      CONDENSE LV_VALUE.
      CONCATENATE '(' LV_VALUE INTO PV_VALUE02.
* 조장수
      LV_VALUE3 = PS_MAIN-LAYER.
      LV_VALUE = LV_VALUE3.
      CONDENSE LV_VALUE.

      CONCATENATE PV_VALUE02 ')X' LV_VALUE INTO PV_VALUE02.

    ELSE.
      IF PS_MAIN-INPUT_ZWSEQ >= LV_ZWSEQ.
        PV_VALUE02 = '0'.
      ENDIF.
    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_1102
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GRID_1102 .

  CREATE OBJECT GO_GRID_1102
    EXPORTING
      I_PARENT      = GO_CONTAIN_1102
      I_APPL_EVENTS = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_1102
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_1102 .

  CLEAR GS_LAYOUT_1102.
  GS_LAYOUT_1102-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYOUT_1102-NO_ROWMARK   = 'X'.
  GS_LAYOUT_1102-STYLEFNAME = 'CELLTAB'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_GRID_1102
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_1102 .

  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.
  DATA : LV_COL_POS TYPE I.

  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR2150TOP'
      I_INTERNAL_TABNAME     = 'GS_MAIN_DISP_1102'
    CHANGING
      CT_FIELDCAT            = LT_FCAT_SLIS
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.

  REFRESH GT_FIELDCAT_1102.

*-- lt_fieldcat의 구조체를 pt_fcat의 구조체로 변경
  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT_SLIS
    IMPORTING
      ET_FIELDCAT_LVC = GT_FIELDCAT_1102[]
    TABLES
      IT_DATA         = GT_MAIN_DISP_1102
    EXCEPTIONS
      OTHERS          = 1.

  READ TABLE GT_FIELDCAT_1102 ASSIGNING FIELD-SYMBOL(<LS_FCAT>) WITH KEY FIELDNAME = 'SEQNO'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_1102 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'SEQNO'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '순번'(f83).
    <LS_FCAT>-COL_POS = 1.
    <LS_FCAT>-DATATYPE = 'INT'.
    <LS_FCAT>-DD_OUTLEN = '10'.
    <LS_FCAT>-JUST = 'C'.
  ENDIF.

  READ TABLE GT_FIELDCAT_1102 ASSIGNING <LS_FCAT> WITH KEY FIELDNAME = 'CHK_EXIST'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_1102 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'CHK_EXIST'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = <LS_FCAT>-FIELDNAME.
    <LS_FCAT>-COL_POS = 19.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '1'.
  ENDIF.


  LOOP AT GT_FIELDCAT_1102 ASSIGNING <LS_FCAT>.
    CLEAR <LS_FCAT>-KEY.
    CASE   <LS_FCAT>-FIELDNAME.
      WHEN 'COND_TYPE' OR 'SGRPNR' OR 'CURRENT_ZWSEQ' OR 'INPUT_ZWSEQ' OR 'CHK_EXIST'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '외장재'(F49).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '외장재명'(F50).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'JAEJIL'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '재질'(F47).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'SOSUN_DIA'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '소선경'(F27).
        <LS_FCAT>-JUST = 'R'.
      WHEN 'MENGE01'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '외장조장'(F91).
        <LS_FCAT>-JUST = 'R'.
      WHEN 'LAYER'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '본수'(F92).
        <LS_FCAT>-JUST = 'R'.
      WHEN 'MENGE02'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '적용보빈'(F93).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-DRDN_HNDL = '1'.
        <LS_FCAT>-EDIT = ABAP_TRUE.
      WHEN 'YCOEF'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '연입률'(F28).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-EDIT = ABAP_TRUE.
      WHEN 'MENGE03'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '작업여장'(F30).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-EDIT = ABAP_TRUE.
      WHEN 'MENGE04'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '작업량'(F31).
        <LS_FCAT>-JUST = 'R'.
      WHEN 'MENGE05'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '기준권취량'(F32).
        <LS_FCAT>-JUST = 'R'.
      WHEN 'MENGE06'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '권취개수'(F33).
        <LS_FCAT>-JUST = 'R'.
      WHEN 'MENGE07'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '실권취량'(F34).
        <LS_FCAT>-JUST = 'R'.
      WHEN 'MENGE08'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '작업지시량'(F35).
        <LS_FCAT>-JUST = 'R'.
      WHEN 'MEINS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '단위'(F11).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'MATNR_O'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '외장반제품'(F94).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'MAKTX_O'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '반제품내역'(F86).
        <LS_FCAT>-JUST = 'L'.

    ENDCASE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_OF_TOOLBAR_GRID_1102
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EXCLUDE_OF_TOOLBAR_GRID_1102 .

  REFRESH GT_EXCLUDE_1102.
  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON TABLES GT_EXCLUDE_1102
        USING : CL_GUI_ALV_GRID=>MC_FC_EXCL_ALL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SORTTAB_GRID_1102
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_SORTTAB_GRID_1102 .

  REFRESH GT_SORT_1102.

  PERFORM SET_SORT_TAB TABLES GT_SORT_1102
                            USING : 1 'SEQNO'  'X' '' ''.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CELL_ATTRIBUTE_GRID_1102
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_CELL_ATTRIBUTE_GRID_1102 .

  DATA : LT_CELLTAB TYPE LVC_T_STYL.
  DATA : LS_CELLTAB TYPE LVC_S_STYL.
  FIELD-SYMBOLS <LT_CELLTAB> TYPE ANY.
* Macro
  DEFINE __SET_CELL_ATTRIBUTE.
    CLEAR LS_CELLTAB.
    LS_CELLTAB-FIELDNAME = &1.
    LS_CELLTAB-STYLE = &2.
    INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
  END-OF-DEFINITION.


  LOOP AT GT_MAIN_DISP_1102 ASSIGNING FIELD-SYMBOL(<LS_MAIN>).
    CLEAR LS_CELLTAB.
    REFRESH LT_CELLTAB.

    __SET_CELL_ATTRIBUTE 'SEQNO'  ALV_STYLE_COLOR_INT_KEY.
    __SET_CELL_ATTRIBUTE 'MATNR'  ALV_STYLE_COLOR_INT_KEY.
    __SET_CELL_ATTRIBUTE 'MAKTX'  ALV_STYLE_COLOR_INT_KEY.
    __SET_CELL_ATTRIBUTE 'JAEJIL'  ALV_STYLE_COLOR_INT_KEY.
    __SET_CELL_ATTRIBUTE 'SOSUN_DIA'  ALV_STYLE_COLOR_INT_KEY.


    IF <LS_MAIN>-CHK_EXIST = ABAP_TRUE.
      __SET_CELL_ATTRIBUTE 'MENGE02'  ALV_STYLE_DISABLED.
      __SET_CELL_ATTRIBUTE 'YCOEF'  ALV_STYLE_DISABLED.
      __SET_CELL_ATTRIBUTE 'MENGE03'  ALV_STYLE_DISABLED.
    ELSE.
      __SET_CELL_ATTRIBUTE 'MENGE02'  ALV_STYLE_ENABLED.
      __SET_CELL_ATTRIBUTE 'YCOEF'  ALV_STYLE_ENABLED.
      __SET_CELL_ATTRIBUTE 'MENGE03'  ALV_STYLE_ENABLED.
    ENDIF.

    IF <LT_CELLTAB> IS ASSIGNED. UNASSIGN <LT_CELLTAB>. ENDIF.
    ASSIGN COMPONENT 'CELLTAB' OF STRUCTURE <LS_MAIN> TO <LT_CELLTAB>.
    IF <LT_CELLTAB> IS ASSIGNED.
      <LT_CELLTAB> = LT_CELLTAB.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_GRID_1102_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_GRID_1102_DISPLAY .

  CALL METHOD GO_GRID_1102->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT_1102
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_1102
    CHANGING
      IT_OUTTAB            = GT_MAIN_DISP_1102
      IT_SORT              = GT_SORT_1102
      IT_FIELDCATALOG      = GT_FIELDCAT_1102.

* 인풋이벤트 추가
  CALL METHOD GO_GRID_1102->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

  CALL METHOD GO_GRID_1102->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_1103
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GRID_1103 .

  CREATE OBJECT GO_GRID_1103
    EXPORTING
      I_PARENT      = GO_CONTAIN_1103
      I_APPL_EVENTS = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_1103
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_1103 .

  CLEAR GS_LAYOUT_1103.
*  GS_LAYOUT_1103-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYOUT_1103-NO_ROWMARK   = 'X'.
  GS_LAYOUT_1103-SEL_MODE = 'D'.
  GS_LAYOUT_1103-STYLEFNAME = 'XYZSTYLEZYX'.
  GS_LAYOUT_1103-SMALLTITLE = 'X'.
  GS_LAYOUT_1103-GRID_TITLE = '외장재 작업지시'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SORTTAB_GRID_1103
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_SORTTAB_GRID_1103 .

  REFRESH GT_SORT_1103.

  PERFORM SET_SORT_TAB TABLES GT_SORT_1103
                            USING : 1 'SEQNO'  'X' '' '',
                                       2 'SEQNO_C' 'X' '' '',
                                       3 'LINE' 'X' '' ''.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_OF_TOOLBAR_GRID_1103
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EXCLUDE_OF_TOOLBAR_GRID_1103 .

  REFRESH GT_EXCLUDE_1103.
  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON TABLES GT_EXCLUDE_1103
        USING : CL_GUI_ALV_GRID=>MC_FC_EXCL_ALL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_GRID_1103_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_GRID_1103_DISPLAY .

  CALL METHOD GO_GRID_1103->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT_1103
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_1103
    CHANGING
      IT_OUTTAB            = <GT_MAIN_DISP_1103>
      IT_SORT              = GT_SORT_1103
      IT_FIELDCATALOG      = GT_FIELDCAT_1103.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CELL_ATTRIBUTE_GRID_1103
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_CELL_ATTRIBUTE_GRID_1103 .

  DATA : LT_CELLTAB TYPE LVC_T_STYL.
  DATA : LS_CELLTAB TYPE LVC_S_STYL.
  FIELD-SYMBOLS <LT_CELLTAB> TYPE ANY.
  FIELD-SYMBOLS <LV_LINE> TYPE ANY.
  FIELD-SYMBOLS <LV_SEQNO> TYPE ANY.

  DATA : LV_NUM(2) TYPE N.
  DATA : LV_FIELDNAME TYPE FIELDNAME.
  DATA : LV_INDEX TYPE I.
  DATA : LV_ZWSEQ TYPE ZGTPPT2012-ZTWSEQ.
  DATA : LV_STYLE TYPE LVC_STYLE.

  CONSTANTS : LC_STYLE01 TYPE LVC_STYLE VALUE ALV_STYLE_COLOR_INT_HEADING, " 계획오더(파랑)
              LC_STYLE02 TYPE LVC_STYLE VALUE ALV_STYLE_COLOR_INT_POSITIVE, "생산오더(초록)
              LC_STYLE03 TYPE LVC_STYLE VALUE ALV_STYLE_COLOR_POSITIVE, "판매오더(연초록)
              LC_STYLE04 TYPE LVC_STYLE VALUE ALV_STYLE_COLOR_INT_GROUP, "재고(주황)
              LC_STYLE05 TYPE LVC_STYLE VALUE CL_GUI_ALV_GRID=>MC_STYLE_ENABLED, "열 수정가능
              LC_STYLE06 TYPE LVC_STYLE VALUE ALV_STYLE_FONT_ITALIC, "이탤릭체
              LC_STYLE07 TYPE LVC_STYLE VALUE ALV_STYLE_COLOR_INV_GROUP. "생산완료 자재출고

* Macro
  DEFINE __SET_CELL_ATTRIBUTE.
    CLEAR LS_CELLTAB.
    LS_CELLTAB-FIELDNAME = &1.
    LS_CELLTAB-STYLE = &2.
    INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
  END-OF-DEFINITION.

  DEFINE __GET_LINE_FIELDS.
    IF <LV_SEQNO> IS ASSIGNED. UNASSIGN <LV_SEQNO>. ENDIF.
    ASSIGN COMPONENT 'SEQNO' OF STRUCTURE <LS_MAIN> TO <LV_SEQNO>.
    IF <LV_LINE> IS ASSIGNED. UNASSIGN <LV_LINE>. ENDIF.
    ASSIGN COMPONENT 'LINE' OF STRUCTURE <LS_MAIN> TO <LV_LINE>.
  END-OF-DEFINITION.

  LOOP AT <GT_MAIN_DISP_1103> ASSIGNING FIELD-SYMBOL(<LS_MAIN>).
    CLEAR LS_CELLTAB.
    REFRESH LT_CELLTAB.
    __SET_CELL_ATTRIBUTE 'SEQNO_C'  ALV_STYLE_COLOR_INT_KEY.
    __GET_LINE_FIELDS.

    READ TABLE GT_MAIN_DISP_1102 INTO GS_MAIN_DISP_1102 WITH KEY SEQNO =  <LV_SEQNO>.
    IF SY-SUBRC EQ 0 AND GS_MAIN_DISP_1102-SGRPNR IS NOT INITIAL.
      CLEAR LV_ZWSEQ.
      CLEAR LV_NUM.
      DO GV_MAX_ZTWSEQ TIMES.
        ADD 1 TO LV_ZWSEQ.
        ADD 1 TO LV_NUM.
        CLEAR LV_STYLE.
        CLEAR LV_FIELDNAME.
        LV_FIELDNAME = 'FIELDINFOR_' && LV_NUM.
        LV_STYLE = ALV_STYLE_ALIGN_LEFT_CENTER.

        READ TABLE GT_2012_MAINTAIN ASSIGNING FIELD-SYMBOL(<LS_2012>) WITH KEY SGRPNR = GS_MAIN_DISP_1102-SGRPNR
                                                                                                            ZWSEQ = LV_ZWSEQ.
        IF SY-SUBRC EQ 0.
          CASE <LS_2012>-ORDTY.
            WHEN 'PRD'.
              LV_STYLE = LV_STYLE + LC_STYLE02.
              __SET_CELL_ATTRIBUTE LV_FIELDNAME LV_STYLE.
            WHEN 'PO' OR 'PR'.
              LV_STYLE = LV_STYLE + LC_STYLE04.
              __SET_CELL_ATTRIBUTE LV_FIELDNAME LV_STYLE.
          ENDCASE.

        ELSE.
          __SET_CELL_ATTRIBUTE LV_FIELDNAME LV_STYLE.
        ENDIF.

      ENDDO.

    ENDIF.


    IF <LT_CELLTAB> IS ASSIGNED. UNASSIGN <LT_CELLTAB>. ENDIF.
    ASSIGN COMPONENT 'XYZSTYLEZYX' OF STRUCTURE <LS_MAIN> TO <LT_CELLTAB>.
    IF <LT_CELLTAB> IS ASSIGNED.
      <LT_CELLTAB> = LT_CELLTAB.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HOTSPOT_CLICK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      --> E_ROW_ID
*&      --> E_COLUMN_ID
*&---------------------------------------------------------------------*
FORM HOTSPOT_CLICK  USING    PO_SENDER TYPE REF TO CL_GUI_ALV_GRID
                             PS_ROW TYPE LVC_S_ROW
                             PS_COLUMN TYPE LVC_S_COL.

  FIELD-SYMBOLS <LV_LINE> TYPE ANY.
  FIELD-SYMBOLS <LV_SEQNO> TYPE ANY.
  DATA : LV_CHK_ERR.
  DATA : LV_ZTWSEQ TYPE ZGTPPT2012-ZTWSEQ.

  DEFINE __GET_LINE_FIELDS.
    IF <LV_SEQNO> IS ASSIGNED. UNASSIGN <LV_SEQNO>. ENDIF.
    ASSIGN COMPONENT 'SEQNO' OF STRUCTURE <LS_MAIN> TO <LV_SEQNO>.
    IF <LV_LINE> IS ASSIGNED. UNASSIGN <LV_LINE>. ENDIF.
    ASSIGN COMPONENT 'LINE' OF STRUCTURE <LS_MAIN> TO <LV_LINE>.
  END-OF-DEFINITION.

  CHECK PS_ROW-INDEX NE 0.

  CASE PO_SENDER.
    WHEN GO_GRID_1103.
      CASE PS_COLUMN-FIELDNAME.
        WHEN 'CHANGE'.
          READ TABLE <GT_MAIN_DISP_1103> ASSIGNING FIELD-SYMBOL(<LS_MAIN>) INDEX PS_ROW-INDEX.
          __GET_LINE_FIELDS.
          IF <LV_LINE> = 1.
            READ TABLE GT_MAIN_DISP_1102 ASSIGNING FIELD-SYMBOL(<LS_MAIN_1102>) WITH KEY SEQNO = <LV_SEQNO>.
* 유저 지정 계획수량
            PERFORM GET_ZTWSEQ_POPUP CHANGING <LS_MAIN_1102> LV_CHK_ERR.
            IF LV_CHK_ERR IS NOT INITIAL.
              RETURN.
            ENDIF.

* 유효작업차수보다 큰 수량관리 내역은 삭제
            DELETE GT_1101_MENGE WHERE SEQNO =  <LS_MAIN_1102>-SEQNO
                                               AND ZWSEQ > <LS_MAIN_1102>-INPUT_ZWSEQ.

            CLEAR LV_ZTWSEQ.
            DO <LS_MAIN_1102>-INPUT_ZWSEQ TIMES.
              ADD 1 TO LV_ZTWSEQ.
              READ TABLE GT_1101_MENGE ASSIGNING FIELD-SYMBOL(<LS_MENGE>) WITH KEY SEQNO =  <LS_MAIN_1102>-SEQNO
                                                                                                               ZWSEQ = LV_ZTWSEQ.
              IF SY-SUBRC NE 0.
                APPEND INITIAL LINE TO  GT_1101_MENGE ASSIGNING <LS_MENGE>.
                <LS_MENGE>-SEQNO = <LS_MAIN_1102>-SEQNO.
                <LS_MENGE>-MATNR_O = <LS_MAIN_1102>-MATNR_O.
                <LS_MENGE>-SGRPNR = <LS_MAIN_1102>-SGRPNR.
                <LS_MENGE>-ZWSEQ = LV_ZTWSEQ.
                <LS_MENGE>-MENGE07 = 0.
              ENDIF.
            ENDDO.

            IF <LS_MAIN_1102>-INPUT_ZWSEQ > GV_MAX_ZTWSEQ.
              GV_MAX_ZTWSEQ = <LS_MAIN_1102>-INPUT_ZWSEQ.
            ENDIF.

          ENDIF.

          IF <GT_MAIN_DISP_1103> IS ASSIGNED.
            REFRESH <GT_MAIN_DISP_1103>.
          ENDIF.

          PERFORM SET_ITAB_1103.
          IF GO_GRID_1103 IS BOUND.
            PERFORM REFRESH_GRID USING GO_GRID_1103.
          ENDIF.

      ENDCASE.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_ZTWSEQ_POPUP
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- <LS_MAIN_1102>
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM GET_ZTWSEQ_POPUP  CHANGING PS_MAIN_1102 LIKE GS_MAIN_DISP_1102
                                            PV_CHK_ERR.

  DATA : LV_RETURN_CODE TYPE C.
  DATA : LT_FIELD TYPE TABLE OF SVAL.
  DATA : LV_CHK_ZWSEQ TYPE ZGTPPT2012-ZTWSEQ.
  DATA : LV_CHK_EXISTS.

  APPEND INITIAL LINE TO LT_FIELD ASSIGNING FIELD-SYMBOL(<LS_FIELD>).
  <LS_FIELD>-FIELDTEXT = '작업차수'.
  <LS_FIELD>-TABNAME = 'ZGTPPT2012'.
  <LS_FIELD>-FIELDNAME = 'ZTWSEQ'.
  <LS_FIELD>-VALUE = PS_MAIN_1102-INPUT_ZWSEQ.
  <LS_FIELD>-FIELD_OBL = ABAP_TRUE.

  DO.
    CALL FUNCTION 'POPUP_GET_VALUES'
      EXPORTING
        POPUP_TITLE     = '작업차수 변경'
*       START_COLUMN    = '5'
*       START_ROW       = '5'
      IMPORTING
        RETURNCODE      = LV_RETURN_CODE
      TABLES
        FIELDS          = LT_FIELD
      EXCEPTIONS
        ERROR_IN_FIELDS = 1
        OTHERS          = 2.
    IF SY-SUBRC <> 0.
      PV_CHK_ERR = ABAP_TRUE.
      CONTINUE.
    ENDIF.

    IF LV_RETURN_CODE = 'A'. " 취소로 종료시
      PV_CHK_ERR = ABAP_TRUE.
      RETURN.
    ENDIF.

    READ TABLE LT_FIELD INTO DATA(LS_FIELD) INDEX 1.
    CLEAR LV_CHK_ZWSEQ.
    LV_CHK_ZWSEQ = LS_FIELD-VALUE.
    IF LV_CHK_ZWSEQ < PS_MAIN_1102-MENGE06.
      MESSAGE S006 DISPLAY LIKE 'E' WITH '작업차수 변경은 기준권취량보다 작을 수 없습니다.'.
      CONTINUE.
    ENDIF.

    CLEAR LV_CHK_EXISTS.
    IF PS_MAIN_1102-SGRPNR IS NOT INITIAL.
      LOOP AT GT_2012_MAINTAIN INTO DATA(LS_2012) WHERE SGRPNR = PS_MAIN_1102-SGRPNR
                                                                   AND ZWSEQ > LV_CHK_ZWSEQ.
        LV_CHK_EXISTS = ABAP_TRUE.
        EXIT.
      ENDLOOP.
      IF LV_CHK_EXISTS = ABAP_TRUE.
        MESSAGE S006 DISPLAY LIKE 'E' WITH '변경된 작업차수보다 큰 작업차수에 작업지시가 존재합니다.'.
        CONTINUE.
      ENDIF.
    ENDIF.

    PS_MAIN_1102-INPUT_ZWSEQ = LV_CHK_ZWSEQ.
    IF PS_MAIN_1102-CURRENT_ZWSEQ < PS_MAIN_1102-INPUT_ZWSEQ.
      PS_MAIN_1102-CURRENT_ZWSEQ = PS_MAIN_1102-INPUT_ZWSEQ.
    ENDIF.

    EXIT.

  ENDDO.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_CHG_MENGE_1100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_CHG_MENGE_1100 .

  DATA : LV_NUM(2) TYPE N.
  DATA : LV_FIELDNAME TYPE FIELDNAME.
  DATA : LS_1103_01 TYPE REF TO DATA. " 아이템 2줄로 추가를 위해 아이템 필드 2개 구성
  DATA : LV_TABIX TYPE I..
  DATA : LV_ZWSEQ TYPE ZGTPPT2012-ZWSEQ.

  FIELD-SYMBOLS : <LS_LINE01> TYPE ANY.
  FIELD-SYMBOLS : <LV_VALUE01> TYPE ANY.

  DEFINE __SET_FIELD_OF_LINE.
    IF <LV_VALUE01> IS ASSIGNED. UNASSIGN <LV_VALUE01>. ENDIF.
    ASSIGN COMPONENT &1 OF STRUCTURE <LS_LINE01> TO <LV_VALUE01>.
  END-OF-DEFINITION.

  CREATE DATA LS_1103_01 LIKE LINE OF <GT_MAIN_DISP_1104_NUM>.
  ASSIGN LS_1103_01->* TO <LS_LINE01>.

  REFRESH <GT_MAIN_DISP_1104_NUM>.

  SORT GT_2012_MAINTAIN BY SGRPNR ZWSEQ.
  SORT GT_1101_MENGE BY SEQNO ZWSEQ.

  LOOP AT GT_MAIN_DISP_1102 INTO GS_MAIN_DISP_1102.
    CLEAR : <LS_LINE01>.
*    CAGE
    __SET_FIELD_OF_LINE 'SEQNO'.
    <LV_VALUE01> = GS_MAIN_DISP_1102-SEQNO.
*    내부관리 순번( 인덱스)
    __SET_FIELD_OF_LINE 'SEQNO_C'.
    <LV_VALUE01> = GS_MAIN_DISP_1102-SEQNO.
    CONDENSE <LV_VALUE01>.

*    내부관리 순번( 2라인 컨트롤 위한 순번)
    __SET_FIELD_OF_LINE 'LINE'.
    <LV_VALUE01> = 1.

*  차수별 데이터 입력
    CLEAR LV_NUM.
    DO GS_MAIN_DISP_1102-INPUT_ZWSEQ TIMES.
      ADD 1 TO LV_NUM.
      LV_FIELDNAME = 'MENGE_' && LV_NUM.
      __SET_FIELD_OF_LINE LV_FIELDNAME.

      LV_ZWSEQ = LV_NUM + 0.

      READ TABLE GT_1101_MENGE INTO DATA(LS_MENGE) WITH KEY SEQNO = GS_MAIN_DISP_1102-SEQNO
                                                                                 ZWSEQ = LV_ZWSEQ.
      IF SY-SUBRC EQ 0.
        <LV_VALUE01> = LS_MENGE-MENGE07.
      ENDIF.
    ENDDO.

    APPEND <LS_LINE01> TO <GT_MAIN_DISP_1104_NUM>.
  ENDLOOP.

  CLEAR GV_CHK_CONFIRM_1200.
  CALL SCREEN '1200' STARTING AT 5 5 ENDING AT 120 12.

  IF GV_CHK_CONFIRM_1200 IS INITIAL.
    RETURN.
  ENDIF.

  LOOP AT <GT_MAIN_DISP_1104_NUM> ASSIGNING <LS_LINE01>.
    CLEAR LV_NUM.
*    내부관리 순번( 인덱스)
    __SET_FIELD_OF_LINE 'SEQNO'.
    READ TABLE GT_MAIN_DISP_1102 INTO GS_MAIN_DISP_1102 WITH KEY SEQNO = <LV_VALUE01>.
    DO GS_MAIN_DISP_1102-INPUT_ZWSEQ TIMES.
      ADD 1 TO LV_NUM.
      LV_FIELDNAME = 'MENGE_' && LV_NUM.
      __SET_FIELD_OF_LINE LV_FIELDNAME.

      LV_ZWSEQ = LV_NUM + 0.

      READ TABLE GT_1101_MENGE ASSIGNING FIELD-SYMBOL(<LS_MENGE>) WITH KEY SEQNO = GS_MAIN_DISP_1102-SEQNO
                                                                                 ZWSEQ = LV_ZWSEQ.
      IF SY-SUBRC EQ 0.
        <LS_MENGE>-MENGE07 = <LV_VALUE01>.
      ELSE.
        IF <LV_VALUE01> NE 0.
          APPEND INITIAL LINE TO GT_1101_MENGE ASSIGNING <LS_MENGE>.
          <LS_MENGE>-SEQNO = GS_MAIN_DISP_1102-SEQNO.
          <LS_MENGE>-MATNR_O = GS_MAIN_DISP_1102-MATNR_O.
          <LS_MENGE>-SGRPNR = GS_MAIN_DISP_1102-SGRPNR.
          <LS_MENGE>-MENGE07 = <LV_VALUE01>.
          <LS_MENGE>-ZWSEQ = LV_ZWSEQ.
        ENDIF.
      ENDIF.
    ENDDO.

  ENDLOOP.

  IF <GT_MAIN_DISP_1103> IS ASSIGNED.
    REFRESH <GT_MAIN_DISP_1103>.
  ENDIF.

  PERFORM SET_ITAB_1103.

  IF GO_GRID_1103 IS BOUND.
    PERFORM REFRESH_GRID USING GO_GRID_1103.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_1200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GRID_1200 .

  CREATE OBJECT GO_CONTAIN_1200
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

  CREATE OBJECT GO_GRID_1200
    EXPORTING
      I_PARENT      = GO_CONTAIN_1200
      I_APPL_EVENTS = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CELL_ATTRIBUTE_GRID_1200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_CELL_ATTRIBUTE_GRID_1200 .

  DATA : LT_CELLTAB TYPE LVC_T_STYL.
  DATA : LS_CELLTAB TYPE LVC_S_STYL.

  DATA : LV_NUM(2) TYPE N.
  DATA : LV_FIELDNAME TYPE FIELDNAME.
  DATA : LV_INDEX TYPE I.
  DATA : LV_ZWSEQ TYPE ZGTPPT2012-ZTWSEQ.

  FIELD-SYMBOLS <LV_SEQNO> TYPE ANY.
  FIELD-SYMBOLS <LT_CELLTAB> TYPE ANY.

* Macro
  DEFINE __SET_CELL_ATTRIBUTE.
    CLEAR LS_CELLTAB.
    LS_CELLTAB-FIELDNAME = &1.
    LS_CELLTAB-STYLE = &2.
    INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
  END-OF-DEFINITION.

  DEFINE __ASSIGN_FIELD_SEQNO.
    IF <LV_SEQNO> IS ASSIGNED. UNASSIGN <LV_SEQNO>. ENDIF.
    ASSIGN COMPONENT 'SEQNO' OF STRUCTURE <LS_MAIN> TO <LV_SEQNO>.
  END-OF-DEFINITION.

  LOOP AT <GT_MAIN_DISP_1104_NUM> ASSIGNING FIELD-SYMBOL(<LS_MAIN>).
    CLEAR LS_CELLTAB.
    REFRESH LT_CELLTAB.

    __SET_CELL_ATTRIBUTE 'SEQNO_C'  ALV_STYLE_ALIGN_CENTER_CENTER.
    __ASSIGN_FIELD_SEQNO.
    READ TABLE GT_MAIN_DISP_1102 INTO GS_MAIN_DISP_1102 WITH KEY SEQNO = <LV_SEQNO>.
    CLEAR LV_ZWSEQ.
    CLEAR LV_NUM.
    DO GS_MAIN_DISP_1102-INPUT_ZWSEQ TIMES.
      ADD 1 TO LV_ZWSEQ.
      ADD 1 TO LV_NUM.

      CLEAR LV_FIELDNAME.
      LV_FIELDNAME = 'MENGE_' && LV_NUM.

      READ TABLE GT_2012_MAINTAIN TRANSPORTING NO FIELDS WITH KEY SGRPNR = GS_MAIN_DISP_1102-SGRPNR
                                                                                  ZWSEQ = LV_ZWSEQ.

      IF SY-SUBRC EQ 0.
        __SET_CELL_ATTRIBUTE LV_FIELDNAME ALV_STYLE_DISABLED.
      ELSE.
        __SET_CELL_ATTRIBUTE LV_FIELDNAME ALV_STYLE_ENABLED.
      ENDIF.

    ENDDO.


    IF <LT_CELLTAB> IS ASSIGNED. UNASSIGN <LT_CELLTAB>. ENDIF.
    ASSIGN COMPONENT 'XYZSTYLEZYX' OF STRUCTURE <LS_MAIN> TO <LT_CELLTAB>.
    IF <LT_CELLTAB> IS ASSIGNED.
      <LT_CELLTAB> = LT_CELLTAB.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SORTTAB_GRID_1200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_SORTTAB_GRID_1200 .

  PERFORM SET_SORT_TAB TABLES GT_SORT_1200
                            USING : 1 'SEQNO_C' 'X' '' '',
                                       2 'LINE'  'X' '' ''.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_GRID_1200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_1200 .

  REFRESH GT_FIELDCAT_1200.
  MOVE-CORRESPONDING GT_FIELDCAT_1103 TO GT_FIELDCAT_1200.

  LOOP AT GT_FIELDCAT_1200 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'ZTWSEQ' OR 'CHANGE'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
    ENDCASE.

    IF <LS_FCAT>-COL_POS BETWEEN 100 AND 399.
      <LS_FCAT>-NO_OUT = ABAP_TRUE.
    ENDIF.

    IF <LS_FCAT>-COL_POS > 400.
      CLEAR <LS_FCAT>-NO_OUT.
      <LS_FCAT>-EDIT = ABAP_TRUE.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_OF_TOOLBAR_GRID_1200
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM EXCLUDE_OF_TOOLBAR_GRID_1200 .

  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON TABLES GT_EXCLUDE_1200
        USING : CL_GUI_ALV_GRID=>MC_FC_EXCL_ALL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_GRID_1200_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_GRID_1200_DISPLAY .

  CALL METHOD GO_GRID_1200->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT_1103
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_1200
    CHANGING
      IT_OUTTAB            = <GT_MAIN_DISP_1104_NUM>
      IT_SORT              = GT_SORT_1200
      IT_FIELDCATALOG      = GT_FIELDCAT_1200.

  GO_GRID_1200->SET_READY_FOR_INPUT( 1 ).

* 인풋이벤트 추가
  CALL METHOD GO_GRID_1200->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_ENTER.

  CALL METHOD GO_GRID_1200->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_CREATE_ORDER_1100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_CREATE_ORDER_1100 .

  DATA : LT_COLUMN TYPE LVC_T_COL.
  DATA : LT_CELLS TYPE LVC_T_CENO.
  DATA : LV_NUM(2) TYPE N.
  DATA : LV_STRING TYPE STRING.
  DATA : LV_ZWSEQ TYPE ZGTPPT2012-ZWSEQ.
  FIELD-SYMBOLS <LV_LINE> TYPE ANY.
  FIELD-SYMBOLS <LV_SEQNO> TYPE ANY.

  DATA : BEGIN OF LS_CREATE,
           SEQNO TYPE I,
           ZWSEQ TYPE ZGTPPT2012-ZWSEQ,
         END OF LS_CREATE.
  DATA : LT_CREATE LIKE TABLE OF LS_CREATE.
  DATA : LT_CREATE_SORTED LIKE TABLE OF LS_CREATE.

  DEFINE __GET_LINE_FIELDS.
    IF <LV_SEQNO> IS ASSIGNED. UNASSIGN <LV_SEQNO>. ENDIF.
    ASSIGN COMPONENT 'SEQNO' OF STRUCTURE <LS_MAIN> TO <LV_SEQNO>.
    IF <LV_LINE> IS ASSIGNED. UNASSIGN <LV_LINE>. ENDIF.
    ASSIGN COMPONENT 'LINE' OF STRUCTURE <LS_MAIN> TO <LV_LINE>.
  END-OF-DEFINITION.

  GO_GRID_1103->GET_SELECTED_COLUMNS(
    IMPORTING
      ET_INDEX_COLUMNS = LT_COLUMN ).                " Cell IDs

  GO_GRID_1103->GET_SELECTED_CELLS_ID(
      IMPORTING
       ET_CELLS = LT_CELLS ).                " Cell IDs

  IF LT_COLUMN[] IS INITIAL AND LT_CELLS[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '선택된 컬럼 또는 Cell이 없습니다.'(e27).
    RETURN.
  ENDIF.

  LOOP AT LT_COLUMN INTO DATA(LS_COLUMN).
    SPLIT LS_COLUMN-FIELDNAME AT  '_'  INTO TABLE DATA(LT_STRING).
    READ TABLE LT_STRING INTO DATA(LS_STRING) INDEX 1.
    LV_STRING = LS_STRING.
    IF LV_STRING NE 'FIELDINFOR'.
      MESSAGE S003 DISPLAY LIKE 'E' WITH '차수가 아닌 컬럼이 선택되었습니다.'(E06).
      RETURN.
    ENDIF.

    READ TABLE LT_STRING INTO LS_STRING INDEX 2.
    LV_NUM = LS_STRING.
    LV_ZWSEQ = LV_NUM + 0.

    LOOP AT  <GT_MAIN_DISP_1103> ASSIGNING FIELD-SYMBOL(<LS_MAIN>).

      __GET_LINE_FIELDS.
      IF <LV_LINE> = 2.
        CONTINUE.
      ENDIF.


      READ TABLE GT_1101_MENGE INTO GS_1101_MENGE WITH KEY SEQNO = <LV_SEQNO>
                                                                                      ZWSEQ = LV_ZWSEQ.
      IF SY-SUBRC EQ 0 AND GS_1101_MENGE-MENGE07 > 0.
        IF GS_1101_MENGE-SGRPNR IS NOT INITIAL.
          READ TABLE GT_2012_MAINTAIN TRANSPORTING NO FIELDS WITH KEY SGRPNR = GS_1101_MENGE-SGRPNR
                                                                                             ZWSEQ = LV_ZWSEQ.
          IF SY-SUBRC EQ 0.
            CONTINUE.
          ENDIF.
        ENDIF.

        APPEND INITIAL LINE TO LT_CREATE ASSIGNING FIELD-SYMBOL(<LS_CREATE>).
        <LS_CREATE>-SEQNO = <LV_SEQNO>.
        <LS_CREATE>-ZWSEQ = LV_ZWSEQ.

      ENDIF.

    ENDLOOP.
  ENDLOOP.

  LOOP AT LT_CELLS INTO DATA(LS_CELLS).
    READ TABLE GT_FIELDCAT_1103 INTO DATA(LS_FCAT) INDEX LS_CELLS-COL_ID.
    IF SY-SUBRC EQ 0.

      SPLIT LS_FCAT-FIELDNAME AT  '_'  INTO TABLE LT_STRING.
      READ TABLE LT_STRING INTO LS_STRING INDEX 1.
      LV_STRING = LS_STRING.
      IF LV_STRING NE 'FIELDINFOR'.
        MESSAGE S003 DISPLAY LIKE 'E' WITH '차수가 아닌 컬럼이 선택되었습니다.'(E06).
        RETURN.
      ENDIF.

      READ TABLE LT_STRING INTO LS_STRING INDEX 2.
      LV_NUM = LS_STRING.
      LV_ZWSEQ = LV_NUM + 0.

      READ TABLE <GT_MAIN_DISP_1103> ASSIGNING <LS_MAIN> INDEX LS_CELLS-ROW_ID.

      __GET_LINE_FIELDS.

      READ TABLE GT_1101_MENGE INTO GS_1101_MENGE WITH KEY SEQNO = <LV_SEQNO>
                                                                                      ZWSEQ = LV_ZWSEQ.
      IF SY-SUBRC EQ 0 AND GS_1101_MENGE-MENGE07 > 0.
        IF GS_1101_MENGE-SGRPNR IS NOT INITIAL.
          READ TABLE GT_2012_MAINTAIN TRANSPORTING NO FIELDS WITH KEY SGRPNR = GS_1101_MENGE-SGRPNR
                                                                                             ZWSEQ = LV_ZWSEQ.
          IF SY-SUBRC EQ 0.
            CONTINUE.
          ENDIF.
        ENDIF.

        READ TABLE LT_CREATE TRANSPORTING NO FIELDS WITH KEY SEQNO  = <LV_SEQNO>
                                                                                    ZWSEQ = LV_ZWSEQ.
        IF SY-SUBRC NE 0.

          APPEND INITIAL LINE TO LT_CREATE ASSIGNING <LS_CREATE>.
          <LS_CREATE>-SEQNO = <LV_SEQNO>.
          <LS_CREATE>-ZWSEQ = LV_ZWSEQ.
        ENDIF.

      ENDIF.

    ENDIF.
  ENDLOOP.

  IF LT_CREATE[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '생산오더 생성가능한 차수가 선택되지 않았습니다.'(E28).
    RETURN.
  ENDIF.

  CLEAR GV_ANSWER.
  PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
    ' '
    '선택된 구간의 생산오더 생성합니다. 계속 진행 하시겠습니까?'
    '생성확인'.
  IF GV_ANSWER NE 'J'.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
    RETURN.
  ENDIF.

* 오더 생성을 위한 데이터 생성
  DATA : LT_2011 TYPE TABLE OF ZGTPPT2011.
  DATA : LS_2011 TYPE ZGTPPT2011.
  DATA : LT_2012 TYPE TABLE OF ZGTPPT2012.
  DATA : LS_2012 TYPE ZGTPPT2012.
  DATA : LT_2012_TMP TYPE TABLE OF ZGTPPT2012.
  DATA : LT_2012_MODI TYPE TABLE OF ZGTPPT2012.
  DATA : LT_2013 TYPE TABLE OF ZGTPPT2013.
  DATA : LT_2013_MODI TYPE TABLE OF ZGTPPT2013.
  DATA : LT_2014 TYPE TABLE OF ZGTPPT2014.
  DATA : LT_2014_MODI TYPE TABLE OF ZGTPPT2014.
  DATA : LV_CHK_ERR.

  REFRESH GT_2013_DEL.

  REFRESH GT_PRD_ORDERS.

  LT_CREATE_SORTED = LT_CREATE.
  SORT LT_CREATE_SORTED BY SEQNO.
  DELETE ADJACENT DUPLICATES FROM LT_CREATE_SORTED COMPARING SEQNO.

  LOOP AT LT_CREATE_SORTED INTO DATA(LS_CREATE_SORTED).
    REFRESH : LT_2012, LT_2013.
    CLEAR LS_2011.

    READ TABLE GT_MAIN_DISP_1102 ASSIGNING FIELD-SYMBOL(<LS_MAIN_1102>) WITH KEY SEQNO = LS_CREATE_SORTED-SEQNO.
    IF SY-SUBRC EQ 0.
      PERFORM MAKE_DATA_TO_SAVE01_1101 TABLES LT_2013 LT_2014
                                                          CHANGING LS_2011 <LS_MAIN_1102> LV_CHK_ERR.

      LOOP AT LT_CREATE INTO LS_CREATE WHERE SEQNO = LS_CREATE_SORTED-SEQNO.
        CLEAR LS_2012.
        PERFORM MAKE_DATA_TO_SAVE02_1101 USING LS_CREATE-ZWSEQ LS_2011 <LS_MAIN_1102>
                                                     CHANGING LS_2012 LV_CHK_ERR.

        IF LV_CHK_ERR = ABAP_TRUE.
          EXIT.
        ENDIF.
        APPEND LS_2012 TO LT_2012.
      ENDLOOP.

      IF LV_CHK_ERR = ABAP_TRUE.
        EXIT.
      ENDIF.

      IF LS_2011-SGRPNR IS INITIAL.
        PERFORM GET_NUM_SGRPNR CHANGING LS_2011-SGRPNR LV_CHK_ERR.
        IF LV_CHK_ERR = ABAP_TRUE.
          RETURN.
        ENDIF.

* 소선오더 그룹번호 세팅
        LOOP AT LT_2013 ASSIGNING FIELD-SYMBOL(<LS_2013_CHG>).
          <LS_2013_CHG>-SGRPNR = LS_2011-SGRPNR.
        ENDLOOP.

* 소선정보 그룹번호 세팅
        LOOP AT LT_2014 ASSIGNING FIELD-SYMBOL(<LS_2014_CHG>).
          <LS_2014_CHG>-SGRPNR = LS_2011-SGRPNR.
        ENDLOOP.

      ELSE.
        REFRESH LT_2012_TMP.
        LT_2012_TMP = VALUE #( FOR LW_2012 IN GT_2012 WHERE ( SGRPNR = LS_2011-SGRPNR )
                                         ( CORRESPONDING #( LW_2012 ) ) ).

        IF LT_2012_TMP[] IS NOT INITIAL.
          APPEND LINES OF LT_2012_TMP TO LT_2012.
        ENDIF.

      ENDIF.

* 저장 테이블 반영(2011)
      APPEND LS_2011 TO LT_2011.

      <LS_MAIN_1102>-SGRPNR = LS_2011-SGRPNR.

*    신선오더의 최종 차수 변경
      SORT LT_2012 BY ZTWSEQ DESCENDING.
      READ TABLE LT_2012 INTO DATA(LS_2012_MAX) INDEX 1.
      LOOP AT LT_2012 ASSIGNING FIELD-SYMBOL(<LS_2012_CHG>).
        IF <LS_2012_CHG>-SGRPNR IS INITIAL.
          <LS_2012_CHG>-SGRPNR = LS_2011-SGRPNR.
        ENDIF.

        <LS_2012_CHG>-ZTWSEQ = LS_2012_MAX-ZTWSEQ.
      ENDLOOP.

* 저장 테이블 반영
      IF LT_2012 IS NOT INITIAL.
        APPEND LINES OF LT_2012 TO LT_2012_MODI.
      ENDIF.
      IF LT_2013 IS NOT INITIAL.
        APPEND LINES OF LT_2013 TO LT_2013_MODI.
      ENDIF.

      IF LT_2014 IS NOT INITIAL.
        APPEND LINES OF LT_2014 TO LT_2014_MODI.
      ENDIF.

    ENDIF.
  ENDLOOP.

  IF LV_CHK_ERR = ABAP_TRUE.
    DATA : LS_RETURN2 TYPE BAPIRET2.
    DATA : LT_DETAIL_RETURN TYPE BAPI_ORDER_RETURN_TT.
    CALL FUNCTION 'BAPI_PRODORD_SET_DELETION_FLAG'
      IMPORTING
        RETURN        = LS_RETURN2
      TABLES
        ORDERS        = GT_PRD_ORDERS
        DETAIL_RETURN = LT_DETAIL_RETURN.

    MESSAGE S003 DISPLAY LIKE 'E' WITH '생산오더 생성중 오류 발생하였습니다.'(e12).
    RETURN.

  ENDIF.

* DB저장
  IF GT_2013_DEL IS NOT INITIAL.
    DELETE ZGTPPT2013 FROM TABLE GT_2013_DEL.
    IF SY-SUBRC NE 0.
      ROLLBACK WORK.
      CALL FUNCTION 'BAPI_PRODORD_SET_DELETION_FLAG'
        IMPORTING
          RETURN        = LS_RETURN2
        TABLES
          ORDERS        = GT_PRD_ORDERS
          DETAIL_RETURN = LT_DETAIL_RETURN.
      MESSAGE S003 DISPLAY LIKE 'E' WITH '생산오더 생성중 오류 발생하였습니다.'(e12).
      RETURN.

    ENDIF.
  ENDIF.

  MODIFY ZGTPPT2011 FROM TABLE LT_2011.
  IF SY-SUBRC NE 0.
    ROLLBACK WORK.
    CALL FUNCTION 'BAPI_PRODORD_SET_DELETION_FLAG'
      IMPORTING
        RETURN        = LS_RETURN2
      TABLES
        ORDERS        = GT_PRD_ORDERS
        DETAIL_RETURN = LT_DETAIL_RETURN.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '생산오더 생성중 오류 발생하였습니다.'(e12).
    RETURN.
  ENDIF.

  MODIFY ZGTPPT2012 FROM TABLE LT_2012_MODI.
  IF SY-SUBRC NE 0.
    ROLLBACK WORK.
    CALL FUNCTION 'BAPI_PRODORD_SET_DELETION_FLAG'
      IMPORTING
        RETURN        = LS_RETURN2
      TABLES
        ORDERS        = GT_PRD_ORDERS
        DETAIL_RETURN = LT_DETAIL_RETURN.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '생산오더 생성중 오류 발생하였습니다.'(e12).
    RETURN.
  ENDIF.

  MODIFY ZGTPPT2013 FROM TABLE LT_2013_MODI.
  IF SY-SUBRC NE 0.
    ROLLBACK WORK.
    CALL FUNCTION 'BAPI_PRODORD_SET_DELETION_FLAG'
      IMPORTING
        RETURN        = LS_RETURN2
      TABLES
        ORDERS        = GT_PRD_ORDERS
        DETAIL_RETURN = LT_DETAIL_RETURN.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '생산오더 생성중 오류 발생하였습니다.'(e12).
    RETURN.
  ENDIF.

  MODIFY ZGTPPT2014 FROM TABLE LT_2014_MODI.
  IF SY-SUBRC NE 0.
    ROLLBACK WORK.
    CALL FUNCTION 'BAPI_PRODORD_SET_DELETION_FLAG'
      IMPORTING
        RETURN        = LS_RETURN2
      TABLES
        ORDERS        = GT_PRD_ORDERS
        DETAIL_RETURN = LT_DETAIL_RETURN.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '생산오더 생성중 오류 발생하였습니다.'(e12).
    RETURN.
  ENDIF.

  COMMIT WORK AND WAIT.

  LOOP AT LT_CREATE_SORTED INTO LS_CREATE_SORTED.

    READ TABLE GT_MAIN_DISP_1102 ASSIGNING <LS_MAIN_1102> WITH KEY SEQNO = LS_CREATE_SORTED-SEQNO.
    IF SY-SUBRC EQ 0.
      DELETE GT_2011 WHERE SGRPNR = <LS_MAIN_1102>-SGRPNR.
      DELETE GT_2012 WHERE SGRPNR = <LS_MAIN_1102>-SGRPNR.
      DELETE GT_2013 WHERE SGRPNR = <LS_MAIN_1102>-SGRPNR.
    ENDIF.
  ENDLOOP.

  APPEND LINES OF LT_2011 TO GT_2011.
  APPEND LINES OF LT_2012_MODI TO GT_2012.
  APPEND LINES OF LT_2013_MODI TO GT_2013.

  REFRESH GT_ZZBUNDLE.
  LOOP AT LT_2011 INTO DATA(LS_2011_MODI).
    APPEND INITIAL LINE TO GT_ZZBUNDLE ASSIGNING FIELD-SYMBOL(<LS_ZZBUNDLE>).
    <LS_ZZBUNDLE>-SIGN = 'I'.
    <LS_ZZBUNDLE>-OPTION = 'EQ'.
    <LS_ZZBUNDLE>-LOW = LS_2011_MODI-ZZBUNDLE.
  ENDLOOP.

  SORT GT_ZZBUNDLE BY LOW.
  DELETE ADJACENT DUPLICATES FROM GT_ZZBUNDLE COMPARING LOW.
  PERFORM SENG_LOG_BWD.

  IF <GT_MAIN_DISP_1103> IS ASSIGNED.
    REFRESH <GT_MAIN_DISP_1103>.
  ENDIF.

  PERFORM SET_ITAB_1102.
  PERFORM REFRESH_GRID USING GO_GRID_1102.
  PERFORM SET_ITAB_1103.
  IF GO_GRID_1103 IS BOUND.
    PERFORM REFRESH_GRID USING GO_GRID_1103.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_DATA_TO_SAVE01_1101
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_2011
*&      --> LT_2013
*&      <-- <LS_MAIN>
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM MAKE_DATA_TO_SAVE01_1101  TABLES   PT_2013 STRUCTURE ZGTPPT2013
                                              PT_2014 STRUCTURE ZGTPPT2014
                               CHANGING  PS_2011 TYPE ZGTPPT2011
                                        PS_MAIN LIKE GS_MAIN_DISP_1102
                                        PV_CHK_ERR.

  DATA : LT_2013 TYPE TABLE OF ZGTPPT2013.
  DATA : LS_2013 TYPE ZGTPPT2013.
  DATA : LT_2014 TYPE TABLE OF ZGTPPT2014.
  DATA : LS_2014 TYPE ZGTPPT2014.
  DATA : LV_SGRPNR TYPE ZGTESGRPNR.
  DATA : LT_GRPNR TYPE RANGE OF ZGTPPT2013-GRPNR.
  DATA : LT_MOSU_1101 LIKE TABLE OF GS_MAIN_DISP_1101.

  LT_MOSU_1101 = VALUE #( FOR LW_MAIN IN GT_MAIN_DISP_1101 WHERE ( MATNR = PS_MAIN-MATNR_O )
                              ( CORRESPONDING #( LW_MAIN ) ) ).


  IF PS_MAIN-SGRPNR IS NOT INITIAL.
    LT_2013 = VALUE #( FOR LW_2013 IN GT_2013 WHERE ( SGRPNR = PS_MAIN-SGRPNR )
                             ( CORRESPONDING #( LW_2013 ) ) ).

    IF LT_2013 IS NOT INITIAL.
      APPEND LINES OF LT_2013 TO GT_2013_DEL.
    ENDIF.

  ENDIF.

* 데이터 구성
  REFRESH LT_2013.

  LOOP AT LT_MOSU_1101 INTO DATA(LS_MOSU).
    READ TABLE GT_2010 INTO DATA(LS_2010) WITH KEY ORDNR = LS_MOSU-ORDNR
                                                                  POSNR = LS_MOSU-POSNR.
    IF SY-SUBRC EQ 0.

      CLEAR LS_2013.
      LS_2013-DMORD = LS_2010-ORDNR.
      LS_2013-DMLINE = LS_2010-POSNR.
      LS_2013-DMORDTY = LS_2010-ORDTY.
      LS_2013-GRPNR = LS_2010-GRPNR.
      LS_2013-MATNR = LS_2010-MATNR.
      LS_2013-INLENGTH = LS_MOSU-INLENGTH01.
      LS_2013-INFACTOR = 1.
      APPEND LS_2013 TO LT_2013.
    ENDIF.

  ENDLOOP.

  CLEAR LS_2014.
  LS_2014-ZCAGE = PS_MAIN-LAYER.
  LS_2014-JAEJIL = PS_MAIN-JAEJIL.
  LS_2014-SOSUN_DIA = PS_MAIN-SOSUN_DIA.
* 신선 조달유형 차후 적용예정
*    LS_2014-BESKZ = GS_MAIN_DISP_103-LAYER.
  LS_2014-YCOEF = PS_MAIN-YCOEF.
  LS_2014-ADLENGTH = PS_MAIN-MENGE03.
* 작업수량
  LS_2014-BSMENGE = PS_MAIN-MENGE04.
* 기준권취량
  LS_2014-BSLENGTH = PS_MAIN-MENGE05.
* 권취개수
  LS_2014-INFACTOR = PS_MAIN-MENGE06.
* 실권취량
  LS_2014-INLENGTH = PS_MAIN-MENGE07.
* 작업지시량
  LS_2014-MENGE = PS_MAIN-MENGE08.
  LS_2014-MEINS = PS_MAIN-MEINS.
  LS_2014-YUN = GS_MAIN_DISP_103-YUN.
  APPEND LS_2014 TO LT_2014.


  IF PS_MAIN-SGRPNR IS NOT INITIAL. " 저장 정보가 있다는 의미
    READ TABLE GT_2011 INTO PS_2011 WITH KEY SGRPNR = PS_MAIN-SGRPNR.
    PS_2011-AEDAT = SY-DATUM.
    PS_2011-AENAM = SY-UNAME.

    LOOP AT LT_2013 ASSIGNING FIELD-SYMBOL(<LS_2013>).
      <LS_2013>-SGRPNR = PS_MAIN-SGRPNR.
    ENDLOOP.

    LOOP AT LT_2014 ASSIGNING FIELD-SYMBOL(<LS_2014>).
      <LS_2014>-SGRPNR = PS_MAIN-SGRPNR.
    ENDLOOP.

  ELSE.
    CLEAR PS_2011.

    PS_2011-JOBTY = '2'.
    PS_2011-MATNR = PS_MAIN-MATNR_O.
    PS_2011-BOBIN_SPEC = PS_MAIN-MENGE02.
    PS_2011-YCOEF = PS_MAIN-YCOEF.
    PS_2011-ADLENGTH = PS_MAIN-MENGE03.
    PERFORM GET_ZZBUNDLE_NO CHANGING PS_2011-ZZBUNDLE PV_CHK_ERR.
    IF PV_CHK_ERR = ABAP_TRUE.
      RETURN.
    ENDIF.

    PS_2011-ERNAM = SY-UNAME.
    PS_2011-AEDAT = SY-DATUM.
    PS_2011-AENAM = SY-UNAME.

  ENDIF.

  APPEND LINES OF LT_2013 TO PT_2013[].
  APPEND LINES OF LT_2014 TO PT_2014[].


ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_DATA_TO_SAVE02_1101
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_2012
*&      --> LS_CREATE_ZWSEQ
*&      --> LS_2011
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM MAKE_DATA_TO_SAVE02_1101  USING    PV_ZWSEQ TYPE ZGTPPT2012-ZWSEQ
                                      PS_2011 TYPE ZGTPPT2011
                                      PS_MAIN LIKE GS_MAIN_DISP_1102
                               CHANGING PS_2012 TYPE ZGTPPT2012
                                      PV_CHK_ERR.

  DATA : LV_ZZPOSNR TYPE AUFK-ZZPOSNR.
  DATA : LV_FINDATE TYPE SY-DATUM.


  READ TABLE GT_1101_MENGE INTO GS_1101_MENGE WITH KEY SEQNO = PS_MAIN-SEQNO
                                                                              ZWSEQ = PV_ZWSEQ.
  IF SY-SUBRC EQ 0.
    CLEAR PS_2012.
    IF PS_MAIN-SGRPNR IS NOT INITIAL.
      PS_2012-SGRPNR = PS_MAIN-SGRPNR.
    ENDIF.
    PS_2012-GONG_CD = 'BWD'.
    PS_2012-JOBTY = '2'.
    PS_2012-POSNR = 1.
    PS_2012-ORDTY = 'PRD'.
    PS_2012-INLENGTH = GS_1101_MENGE-MENGE07.
    PS_2012-INFACTOR = PS_MAIN-LAYER.
    PS_2012-ZCAGE = PS_MAIN-LAYER.
    PS_2012-ZWSEQ = PV_ZWSEQ.
* 총차수
    IF PV_ZWSEQ > PS_MAIN-MENGE06.
      PS_2012-ZTWSEQ = PV_ZWSEQ.
    ELSE.
      PS_2012-ZTWSEQ = PS_MAIN-MENGE06.
    ENDIF.

    PS_2012-ZWSEQ = PV_ZWSEQ.

* 연입률 세팅
    PS_2012-YCOEF = PS_MAIN-YCOEF.

    PERFORM GET_FINDATE_1101 USING PS_2011-MATNR CHANGING LV_FINDATE.
    LV_ZZPOSNR = PV_ZWSEQ + 0.

*    해당 정보로 생산오더 생성
    PERFORM CREATE_PRD_ORDER_1100 USING PS_2012 PS_2011 LV_ZZPOSNR LV_FINDATE CHANGING PS_2012-ORDNR PV_CHK_ERR.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_FINDATE_1101
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PS_2011_MATNR
*&      <-- LV_FINDATE
*&---------------------------------------------------------------------*
FORM GET_FINDATE_1101  USING    PV_MATNR TYPE MATNR
                       CHANGING PV_FINDATE TYPE SY-DATUM.

  DATA : LT_AUFNR TYPE RANGE OF AUFNR.

  LT_AUFNR = VALUE #( FOR LW_DATA IN GT_MAIN_DISP_1101 WHERE ( MATNR = PV_MATNR
                                                                                     AND   ORDNR IS NOT INITIAL  )
                              ( SIGN = 'I' OPTION = 'EQ' LOW = LW_DATA-ORDNR ) ).

  SELECT SINGLE MIN( GSTRP ) AS GSTRP FROM AFKO
    WHERE AUFNR IN @LT_AUFNR
     INTO @PV_FINDATE.

  PV_FINDATE = PV_FINDATE - 1.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_PRD_ORDER_1100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PS_2012
*&      --> PS_2011_ZZBUNDLE
*&      --> LV_ZZPOSNR
*&      --> LV_FINDATE
*&      <-- <LS_2012>_ORDNR
*&      <-- PV_CHK_ERR
*&---------------------------------------------------------------------*
FORM CREATE_PRD_ORDER_1100  USING    PS_2012 TYPE ZGTPPT2012
                                PS_2011 TYPE ZGTPPT2011
                                PV_ZZPOSNR TYPE AUFK-ZZPOSNR
                                PV_FINDATE  TYPE SY-DATUM
                       CHANGING PV_ORDNR TYPE ZGTPPT2012-ORDNR
                                PV_CHK_ERR.

  DATA : LS_ORDER TYPE BAPI_PP_ORDER_CREATE.
  DATA : LS_RETURN TYPE BAPIRET2.
  DATA : LV_ORDER_NUMBER TYPE BAPI_ORDER_KEY-ORDER_NUMBER.
  DATA : LS_ORDER_KEY TYPE BAPI_ORDER_KEY.


  READ TABLE GT_WRAPPING INTO DATA(LS_WRAPPING) WITH KEY MATNR = PS_2011-MATNR.
  IF SY-SUBRC EQ 0.
    LS_ORDER-MATERIAL = LS_WRAPPING-MATNR_BWD.
  ELSE.
    PV_CHK_ERR = ABAP_TRUE.
    RETURN.
  ENDIF.
  LS_ORDER-PLANT = P_WERKS.
  LS_ORDER-BASIC_START_DATE = PV_FINDATE.
  LS_ORDER-BASIC_END_DATE = PV_FINDATE.
  LS_ORDER-ORDER_TYPE = 'PP01'.
  LS_ORDER-BASIC_SCHEDULING_TYPE = '3'.
  LS_ORDER-QUANTITY = ( PS_2012-INLENGTH + PS_2012-ADLENGTH ) * PS_2012-INFACTOR.

  PERFORM CHK_MATNR_INFOR2 CHANGING LS_ORDER PV_CHK_ERR.
  IF PV_CHK_ERR = ABAP_TRUE.
    RETURN.
  ENDIF.

* 생산오더 생성
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

    CLEAR LS_ORDER_KEY.
    LS_ORDER_KEY-ORDER_NUMBER = LV_ORDER_NUMBER.
    COLLECT LS_ORDER_KEY INTO GT_PRD_ORDERS.

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

  ELSE.
    PV_CHK_ERR = ABAP_TRUE.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '생산오더 생성중 오류 발생하였습니다.'(e12).
    RETURN.
  ENDIF.

  PERFORM SET_PRD_CHG_BY_BDC USING LV_ORDER_NUMBER PS_2012 PS_2011-ZZBUNDLE PV_ZZPOSNR CHANGING PV_CHK_ERR.
  IF PV_CHK_ERR = ABAP_TRUE.
    RETURN.
  ENDIF.

  PV_ORDNR = LV_ORDER_NUMBER.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_CREATE_PR_1100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_CREATE_PR_1100 .

  DATA : LT_COLUMN TYPE LVC_T_COL.
  DATA : LT_CELLS TYPE LVC_T_CENO.
  DATA : LV_NUM(2) TYPE N.
  DATA : LV_STRING TYPE STRING.
  DATA : LV_ZWSEQ TYPE ZGTPPT2012-ZWSEQ.
  FIELD-SYMBOLS <LV_LINE> TYPE ANY.
  FIELD-SYMBOLS <LV_SEQNO> TYPE ANY.

  DATA : BEGIN OF LS_CREATE,
           SEQNO TYPE I,
           ZWSEQ TYPE ZGTPPT2012-ZWSEQ,
         END OF LS_CREATE.
  DATA : LT_CREATE LIKE TABLE OF LS_CREATE.
  DATA : LT_CREATE_SORTED LIKE TABLE OF LS_CREATE.

  DEFINE __GET_LINE_FIELDS.
    IF <LV_SEQNO> IS ASSIGNED. UNASSIGN <LV_SEQNO>. ENDIF.
    ASSIGN COMPONENT 'SEQNO' OF STRUCTURE <LS_MAIN> TO <LV_SEQNO>.
    IF <LV_LINE> IS ASSIGNED. UNASSIGN <LV_LINE>. ENDIF.
    ASSIGN COMPONENT 'LINE' OF STRUCTURE <LS_MAIN> TO <LV_LINE>.
  END-OF-DEFINITION.

  GO_GRID_1103->GET_SELECTED_COLUMNS(
    IMPORTING
      ET_INDEX_COLUMNS = LT_COLUMN ).                " Cell IDs

  GO_GRID_1103->GET_SELECTED_CELLS_ID(
      IMPORTING
       ET_CELLS = LT_CELLS ).                " Cell IDs

  IF LT_COLUMN[] IS INITIAL AND LT_CELLS[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '선택된 컬럼 또는 Cell이 없습니다.'(e27).
    RETURN.
  ENDIF.

  LOOP AT LT_COLUMN INTO DATA(LS_COLUMN).
    SPLIT LS_COLUMN-FIELDNAME AT  '_'  INTO TABLE DATA(LT_STRING).
    READ TABLE LT_STRING INTO DATA(LS_STRING) INDEX 1.
    LV_STRING = LS_STRING.
    IF LV_STRING NE 'FIELDINFOR'.
      MESSAGE S003 DISPLAY LIKE 'E' WITH '차수가 아닌 컬럼이 선택되었습니다.'(E06).
      RETURN.
    ENDIF.

    READ TABLE LT_STRING INTO LS_STRING INDEX 2.
    LV_NUM = LS_STRING.
    LV_ZWSEQ = LV_NUM + 0.

    LOOP AT  <GT_MAIN_DISP_1103> ASSIGNING FIELD-SYMBOL(<LS_MAIN>).

      __GET_LINE_FIELDS.
      IF <LV_LINE> = 2.
        CONTINUE.
      ENDIF.


      READ TABLE GT_1101_MENGE INTO GS_1101_MENGE WITH KEY SEQNO = <LV_SEQNO>
                                                                                      ZWSEQ = LV_ZWSEQ.
      IF SY-SUBRC EQ 0 AND GS_1101_MENGE-MENGE07 > 0.
        IF GS_1101_MENGE-SGRPNR IS NOT INITIAL.
          READ TABLE GT_2012_MAINTAIN TRANSPORTING NO FIELDS WITH KEY SGRPNR = GS_1101_MENGE-SGRPNR
                                                                                             ZWSEQ = LV_ZWSEQ.
          IF SY-SUBRC EQ 0.
            CONTINUE.
          ENDIF.
        ENDIF.

        APPEND INITIAL LINE TO LT_CREATE ASSIGNING FIELD-SYMBOL(<LS_CREATE>).
        <LS_CREATE>-SEQNO = <LV_SEQNO>.
        <LS_CREATE>-ZWSEQ = LV_ZWSEQ.

      ENDIF.

    ENDLOOP.
  ENDLOOP.

  LOOP AT LT_CELLS INTO DATA(LS_CELLS).
    READ TABLE GT_FIELDCAT_1103 INTO DATA(LS_FCAT) INDEX LS_CELLS-COL_ID.
    IF SY-SUBRC EQ 0.

      SPLIT LS_FCAT-FIELDNAME AT  '_'  INTO TABLE LT_STRING.
      READ TABLE LT_STRING INTO LS_STRING INDEX 1.
      LV_STRING = LS_STRING.
      IF LV_STRING NE 'FIELDINFOR'.
        MESSAGE S003 DISPLAY LIKE 'E' WITH '차수가 아닌 컬럼이 선택되었습니다.'(E06).
        RETURN.
      ENDIF.

      READ TABLE LT_STRING INTO LS_STRING INDEX 2.
      LV_NUM = LS_STRING.
      LV_ZWSEQ = LV_NUM + 0.

      READ TABLE <GT_MAIN_DISP_1103> ASSIGNING <LS_MAIN> INDEX LS_CELLS-ROW_ID.

      __GET_LINE_FIELDS.

      READ TABLE GT_1101_MENGE INTO GS_1101_MENGE WITH KEY SEQNO = <LV_SEQNO>
                                                                                      ZWSEQ = LV_ZWSEQ.
      IF SY-SUBRC EQ 0 AND GS_1101_MENGE-MENGE07 > 0.
        IF GS_1101_MENGE-SGRPNR IS NOT INITIAL.
          READ TABLE GT_2012_MAINTAIN TRANSPORTING NO FIELDS WITH KEY SGRPNR = GS_1101_MENGE-SGRPNR
                                                                                             ZWSEQ = LV_ZWSEQ.
          IF SY-SUBRC EQ 0.
            CONTINUE.
          ENDIF.
        ENDIF.

        READ TABLE LT_CREATE TRANSPORTING NO FIELDS WITH KEY SEQNO  = <LV_SEQNO>
                                                                                    ZWSEQ = LV_ZWSEQ.
        IF SY-SUBRC NE 0.

          APPEND INITIAL LINE TO LT_CREATE ASSIGNING <LS_CREATE>.
          <LS_CREATE>-SEQNO = <LV_SEQNO>.
          <LS_CREATE>-ZWSEQ = LV_ZWSEQ.
        ENDIF.

      ENDIF.

    ENDIF.
  ENDLOOP.

  IF LT_CREATE[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '구매요청 생성가능한 차수가 선택되지 않았습니다.'(E29).
    RETURN.
  ENDIF.

  CLEAR GV_ANSWER.
  PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
    ' '
    '선택된 구간의 구매요청 생성합니다. 계속 진행 하시겠습니까?'
    '생성확인'.
  IF GV_ANSWER NE 'J'.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
    RETURN.
  ENDIF.

* 오더 생성을 위한 데이터 생성
  DATA : LT_2011 TYPE TABLE OF ZGTPPT2011.
  DATA : LS_2011 TYPE ZGTPPT2011.
  DATA : LT_2012 TYPE TABLE OF ZGTPPT2012.
  DATA : LS_2012 TYPE ZGTPPT2012.
  DATA : LT_2012_TMP TYPE TABLE OF ZGTPPT2012.
  DATA : LT_2012_MODI TYPE TABLE OF ZGTPPT2012.
  DATA : LT_2013 TYPE TABLE OF ZGTPPT2013.
  DATA : LT_2013_MODI TYPE TABLE OF ZGTPPT2013.
  DATA : LT_2014 TYPE TABLE OF ZGTPPT2014.
  DATA : LT_2014_MODI TYPE TABLE OF ZGTPPT2014.
  DATA : LV_CHK_ERR.

  REFRESH GT_2013_DEL.

  REFRESH GT_PR_ORDERS.

  LT_CREATE_SORTED = LT_CREATE.
  SORT LT_CREATE_SORTED BY SEQNO.
  DELETE ADJACENT DUPLICATES FROM LT_CREATE_SORTED COMPARING SEQNO.

  LOOP AT LT_CREATE_SORTED INTO DATA(LS_CREATE_SORTED).
    REFRESH : LT_2012, LT_2013.
    CLEAR LS_2011.

    READ TABLE GT_MAIN_DISP_1102 ASSIGNING FIELD-SYMBOL(<LS_MAIN_1102>) WITH KEY SEQNO = LS_CREATE_SORTED-SEQNO.
    IF SY-SUBRC EQ 0.
      PERFORM MAKE_DATA_TO_SAVE01_1101 TABLES LT_2013 LT_2014
                                                          CHANGING LS_2011 <LS_MAIN_1102> LV_CHK_ERR.

      LOOP AT LT_CREATE INTO LS_CREATE WHERE SEQNO = LS_CREATE_SORTED-SEQNO.
        CLEAR LS_2012.
        PERFORM MAKE_DATA_TO_SAVE03_1101 USING LS_CREATE-ZWSEQ LS_2011 <LS_MAIN_1102>
                                                     CHANGING LS_2012 LV_CHK_ERR.

        IF LV_CHK_ERR = ABAP_TRUE.
          EXIT.
        ENDIF.
        APPEND LS_2012 TO LT_2012.
      ENDLOOP.

      IF LV_CHK_ERR = ABAP_TRUE.
        EXIT.
      ENDIF.

      IF LS_2011-SGRPNR IS INITIAL.
        PERFORM GET_NUM_SGRPNR CHANGING LS_2011-SGRPNR LV_CHK_ERR.
        IF LV_CHK_ERR = ABAP_TRUE.
          RETURN.
        ENDIF.

* 소선오더 그룹번호 세팅
        LOOP AT LT_2013 ASSIGNING FIELD-SYMBOL(<LS_2013_CHG>).
          <LS_2013_CHG>-SGRPNR = LS_2011-SGRPNR.
        ENDLOOP.

* 소선정보 그룹번호 세팅
        LOOP AT LT_2014 ASSIGNING FIELD-SYMBOL(<LS_2014_CHG>).
          <LS_2014_CHG>-SGRPNR = LS_2011-SGRPNR.
        ENDLOOP.

      ELSE.
        REFRESH LT_2012_TMP.
        LT_2012_TMP = VALUE #( FOR LW_2012 IN GT_2012 WHERE ( SGRPNR = LS_2011-SGRPNR )
                                         ( CORRESPONDING #( LW_2012 ) ) ).

        IF LT_2012_TMP[] IS NOT INITIAL.
          APPEND LINES OF LT_2012_TMP TO LT_2012.
        ENDIF.

      ENDIF.
* 저장 테이블 반영(2011)
      APPEND LS_2011 TO LT_2011.

      <LS_MAIN_1102>-SGRPNR = LS_2011-SGRPNR.

*    신선오더의 최종 차수 변경
      SORT LT_2012 BY ZTWSEQ DESCENDING.
      READ TABLE LT_2012 INTO DATA(LS_2012_MAX) INDEX 1.
      LOOP AT LT_2012 ASSIGNING FIELD-SYMBOL(<LS_2012_CHG>).
        IF <LS_2012_CHG>-SGRPNR IS INITIAL.
          <LS_2012_CHG>-SGRPNR = LS_2011-SGRPNR.
        ENDIF.

        <LS_2012_CHG>-ZTWSEQ = LS_2012_MAX-ZTWSEQ.
      ENDLOOP.

* 저장 테이블 반영
      IF LT_2012 IS NOT INITIAL.
        APPEND LINES OF LT_2012 TO LT_2012_MODI.
      ENDIF.
      IF LT_2013 IS NOT INITIAL.
        APPEND LINES OF LT_2013 TO LT_2013_MODI.
      ENDIF.

      IF LT_2014 IS NOT INITIAL.
        APPEND LINES OF LT_2014 TO LT_2014_MODI.
      ENDIF.

    ENDIF.
  ENDLOOP.

  IF LV_CHK_ERR = ABAP_TRUE.
    PERFORM DEL_PR_PRDERS TABLES GT_PR_ORDERS.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '구매요청 중 오류 발생하였습니다.'(e21).
    RETURN.

  ENDIF.

* DB저장
  IF GT_2013_DEL IS NOT INITIAL.
    DELETE ZGTPPT2013 FROM TABLE GT_2013_DEL.
    IF SY-SUBRC NE 0.
      ROLLBACK WORK.
      PERFORM DEL_PR_PRDERS TABLES GT_PR_ORDERS.
      MESSAGE S003 DISPLAY LIKE 'E' WITH '구매요청 중 오류 발생하였습니다.'(e21).
      RETURN.
    ENDIF.
  ENDIF.

  MODIFY ZGTPPT2011 FROM TABLE LT_2011.
  IF SY-SUBRC NE 0.
    ROLLBACK WORK.
    PERFORM DEL_PR_PRDERS TABLES GT_PR_ORDERS.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '구매요청 중 오류 발생하였습니다.'(e21).
    RETURN.
  ENDIF.

  MODIFY ZGTPPT2012 FROM TABLE LT_2012_MODI.
  IF SY-SUBRC NE 0.
    ROLLBACK WORK.
    PERFORM DEL_PR_PRDERS TABLES GT_PR_ORDERS.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '구매요청 중 오류 발생하였습니다.'(e21).
    RETURN.
  ENDIF.

  MODIFY ZGTPPT2013 FROM TABLE LT_2013_MODI.
  IF SY-SUBRC NE 0.
    ROLLBACK WORK.
    PERFORM DEL_PR_PRDERS TABLES GT_PR_ORDERS.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '구매요청 중 오류 발생하였습니다.'(e21).
    RETURN.
  ENDIF.

  MODIFY ZGTPPT2014 FROM TABLE LT_2014_MODI.
  IF SY-SUBRC NE 0.
    ROLLBACK WORK.
    PERFORM DEL_PR_PRDERS TABLES GT_PR_ORDERS.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '구매요청 중 오류 발생하였습니다.'(e21).
    RETURN.
  ENDIF.

  COMMIT WORK AND WAIT.

  LOOP AT LT_CREATE_SORTED INTO LS_CREATE_SORTED.

    READ TABLE GT_MAIN_DISP_1102 ASSIGNING <LS_MAIN_1102> WITH KEY SEQNO = LS_CREATE_SORTED-SEQNO.
    IF SY-SUBRC EQ 0.
      DELETE GT_2011 WHERE SGRPNR = <LS_MAIN_1102>-SGRPNR.
      DELETE GT_2012 WHERE SGRPNR = <LS_MAIN_1102>-SGRPNR.
      DELETE GT_2013 WHERE SGRPNR = <LS_MAIN_1102>-SGRPNR.
    ENDIF.
  ENDLOOP.

  APPEND LINES OF LT_2011 TO GT_2011.
  APPEND LINES OF LT_2012_MODI TO GT_2012.
  APPEND LINES OF LT_2013_MODI TO GT_2013.

  REFRESH GT_ZZBUNDLE.
  LOOP AT LT_2011 INTO DATA(LS_2011_MODI).
    APPEND INITIAL LINE TO GT_ZZBUNDLE ASSIGNING FIELD-SYMBOL(<LS_ZZBUNDLE>).
    <LS_ZZBUNDLE>-SIGN = 'I'.
    <LS_ZZBUNDLE>-OPTION = 'EQ'.
    <LS_ZZBUNDLE>-LOW = LS_2011_MODI-ZZBUNDLE.
  ENDLOOP.

  SORT GT_ZZBUNDLE BY LOW.
  DELETE ADJACENT DUPLICATES FROM GT_ZZBUNDLE COMPARING LOW.
  PERFORM SENG_LOG_BWD.


  IF <GT_MAIN_DISP_1103> IS ASSIGNED.
    REFRESH <GT_MAIN_DISP_1103>.
  ENDIF.

  PERFORM SET_ITAB_1102.
  PERFORM REFRESH_GRID USING GO_GRID_1102.
  PERFORM SET_ITAB_1103.
  IF GO_GRID_1103 IS BOUND.
    PERFORM REFRESH_GRID USING GO_GRID_1103.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_DATA_TO_SAVE03_1101
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_CREATE_ZWSEQ
*&      --> LS_2011
*&      --> <LS_MAIN_1102>
*&      <-- LS_2012
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM MAKE_DATA_TO_SAVE03_1101  USING   PV_ZWSEQ TYPE ZGTPPT2012-ZWSEQ
                                      PS_2011 TYPE ZGTPPT2011
                                      PS_MAIN LIKE GS_MAIN_DISP_1102
                               CHANGING PS_2012 TYPE ZGTPPT2012
                                      PV_CHK_ERR.

  DATA : LV_ZZPOSNR TYPE AUFK-ZZPOSNR.
  DATA : LV_FINDATE TYPE SY-DATUM.


  READ TABLE GT_1101_MENGE INTO GS_1101_MENGE WITH KEY SEQNO = PS_MAIN-SEQNO
                                                                              ZWSEQ = PV_ZWSEQ.
  IF SY-SUBRC EQ 0.
    CLEAR PS_2012.
    IF PS_MAIN-SGRPNR IS NOT INITIAL.
      PS_2012-SGRPNR = PS_MAIN-SGRPNR.
    ENDIF.
    PS_2012-GONG_CD = 'BWD'.
    PS_2012-JOBTY = '2'.
    PS_2012-POSNR = 10.
    PS_2012-ORDTY = 'PR'.
    PS_2012-INLENGTH = GS_1101_MENGE-MENGE07.
    PS_2012-INFACTOR = 1.
    PS_2012-ZCAGE = PS_MAIN-LAYER.
    PS_2012-ZWSEQ = PV_ZWSEQ.
* 총차수
    IF PV_ZWSEQ > PS_MAIN-MENGE06.
      PS_2012-ZTWSEQ = PV_ZWSEQ.
    ELSE.
      PS_2012-ZTWSEQ = PS_MAIN-MENGE06.
    ENDIF.

    PS_2012-ZWSEQ = PV_ZWSEQ.

* 연입률 세팅
    PS_2012-YCOEF = PS_MAIN-YCOEF.

    PERFORM GET_FINDATE_1101 USING PS_2011-MATNR CHANGING LV_FINDATE.
    LV_ZZPOSNR = PV_ZWSEQ + 0.

*    해당 정보로 생산오더 생성
    PERFORM CREATE_PR_ORDER_1100 USING PS_2012 PS_2011 LV_ZZPOSNR LV_FINDATE CHANGING PS_2012-ORDNR PV_CHK_ERR.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_PR_ORDER_1100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PS_2012
*&      --> PS_2011
*&      --> LV_ZZPOSNR
*&      --> LV_FINDATE
*&      <-- PS_2012_ORDNR
*&      <-- PV_CHK_ERR
*&---------------------------------------------------------------------*
FORM CREATE_PR_ORDER_1100  USING    PS_2012 TYPE ZGTPPT2012
                                PS_2011 TYPE ZGTPPT2011
                                PV_ZZPOSNR TYPE AUFK-ZZPOSNR
                                PV_FINDATE  TYPE SY-DATUM
                       CHANGING PV_ORDNR TYPE ZGTPPT2012-ORDNR
                                PV_CHK_ERR.

  DATA : LV_INLENGTH TYPE I.
  DATA : LV_INLENGTH_C(10) TYPE C.
  DATA : LV_INFACTOR TYPE I.
  DATA : LV_INFACTOR_C(10) TYPE C.
  DATA : LS_PR_INFOR TYPE ZGTPPS0004.
  DATA : LT_CHART TYPE ZGTPPY0005.
  DATA : LV_PSMNG_C(30) TYPE C.
  DATA : LV_PSMNG TYPE MENGE_D.
  DATA : LV_BANFN TYPE BANFN.
  DATA : LV_RESULT TYPE CHAR01.


  SELECT SINGLE FLD_02 AS WERKS, FLD_03 AS EKORG, FLD_04 AS EKGRP
    FROM ZGTPPT1010
    INTO @DATA(LS_EKORG)
   WHERE MODULE_KIND = 'PP'
     AND CODEGRP = '2090'
     AND FLD_01 = ' '
     AND FLD_02 = @P_WERKS.

  LV_PSMNG_C = PS_2012-INLENGTH * PS_2012-INFACTOR.
  CONDENSE : LV_PSMNG_C.

  CLEAR LS_PR_INFOR.
  LS_PR_INFOR-BSART = 'NB'.

*        입력값 세팅
  LS_PR_INFOR-EEIND = PV_FINDATE.
  LS_PR_INFOR-LPEIN = 'T'.
  LS_PR_INFOR-WERKS = P_WERKS.
  LS_PR_INFOR-EKGRP = LS_EKORG-EKGRP.
  LS_PR_INFOR-AFNAM = SY-UNAME.
  READ TABLE GT_WRAPPING INTO DATA(LS_WRAPPING) WITH KEY MATNR = PS_2011-MATNR.
  IF SY-SUBRC EQ 0.
    LS_PR_INFOR = LS_WRAPPING-MATNR_BWD.
  ELSE.
    PV_CHK_ERR = ABAP_TRUE.
    RETURN.
  ENDIF.
  LS_PR_INFOR-EKORG = LS_EKORG-EKORG.
  LS_PR_INFOR-MENGE = LV_PSMNG_C.

  REFRESH LT_CHART.


  CALL FUNCTION 'ZGTPP_CREATE_PR_BY_BDC'
    EXPORTING
      IS_PR_INFOR = LS_PR_INFOR
    IMPORTING
      EV_RESULT   = LV_RESULT
      EV_BANFN    = LV_BANFN
    TABLES
      IT_CHART    = LT_CHART.

  IF LV_RESULT NE 'S'.
    PV_CHK_ERR = 'X'.
    RETURN.
  ENDIF.

  PS_2012-ORDNR = LV_BANFN.

  APPEND INITIAL LINE TO GT_PR_ORDERS ASSIGNING FIELD-SYMBOL(<LS_BANFN>).
  <LS_BANFN>-BANFN = LV_BANFN.
  <LS_BANFN>-BNFPO = 10.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DEL_PR_PRDERS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_PR_ORDERS
*&---------------------------------------------------------------------*
FORM DEL_PR_PRDERS  TABLES   PT_PR_ORDERS STRUCTURE GS_PR_ORDERS.

  DATA : LV_NUMBER TYPE BAPIMEREQHEADER-PREQ_NO.
  DATA : LT_RETURN TYPE TABLE OF BAPIRET2.
  DATA : LT_PRITEM TYPE TABLE OF BAPIMEREQITEMIMP.
  DATA : LT_PRITEMX TYPE TABLE OF BAPIMEREQITEMX.

  LOOP AT PT_PR_ORDERS INTO DATA(LS_PR_ORDERS).
    REFRESH : LT_PRITEM, LT_PRITEMX.
* ITEM 정보 입력
    APPEND INITIAL LINE TO LT_PRITEM ASSIGNING FIELD-SYMBOL(<LS_PRITEM>).
    <LS_PRITEM>-PREQ_ITEM = LS_PR_ORDERS-BNFPO.
    <LS_PRITEM>-DELETE_IND = 'X'.

* ItemX 정보 입력
    APPEND INITIAL LINE TO LT_PRITEMX ASSIGNING FIELD-SYMBOL(<LS_PRITEMX>).
    <LS_PRITEMX>-PREQ_ITEM = LS_PR_ORDERS-BNFPO.
    <LS_PRITEMX>-DELETE_IND = 'X'.

    CALL FUNCTION 'BAPI_PR_CHANGE'
      EXPORTING
        NUMBER  = LS_PR_ORDERS-BANFN
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
*& Form PROC_DELETE_ORDER_1100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_DELETE_ORDER_1100 .

  DATA : LT_2012_DEL TYPE TABLE OF ZGTPPT2012.
  DATA : LS_2012_DEL TYPE ZGTPPT2012.

  DATA : LT_COLUMN TYPE LVC_T_COL.
  DATA : LT_CELLS TYPE LVC_T_CENO.
  DATA : LV_NUM(2) TYPE N.
  DATA : LV_STRING TYPE STRING.
  DATA : LV_ZWSEQ TYPE ZGTPPT2012-ZWSEQ.
  FIELD-SYMBOLS <LV_LINE> TYPE ANY.
  FIELD-SYMBOLS <LV_SEQNO> TYPE ANY.

  DATA : BEGIN OF LS_CREATE,
           SEQNO TYPE I,
           ZWSEQ TYPE ZGTPPT2012-ZWSEQ,
         END OF LS_CREATE.
  DATA : LT_CREATE LIKE TABLE OF LS_CREATE.
  DATA : LT_CREATE_SORTED LIKE TABLE OF LS_CREATE.

  DEFINE __GET_LINE_FIELDS.
    IF <LV_SEQNO> IS ASSIGNED. UNASSIGN <LV_SEQNO>. ENDIF.
    ASSIGN COMPONENT 'SEQNO' OF STRUCTURE <LS_MAIN> TO <LV_SEQNO>.
    IF <LV_LINE> IS ASSIGNED. UNASSIGN <LV_LINE>. ENDIF.
    ASSIGN COMPONENT 'LINE' OF STRUCTURE <LS_MAIN> TO <LV_LINE>.
  END-OF-DEFINITION.

  GO_GRID_1103->GET_SELECTED_COLUMNS(
    IMPORTING
      ET_INDEX_COLUMNS = LT_COLUMN ).                " Cell IDs

  GO_GRID_1103->GET_SELECTED_CELLS_ID(
      IMPORTING
       ET_CELLS = LT_CELLS ).                " Cell IDs

  IF LT_COLUMN[] IS INITIAL AND LT_CELLS[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '선택된 컬럼 또는 Cell이 없습니다.'(e27).
    RETURN.
  ENDIF.

  LOOP AT LT_COLUMN INTO DATA(LS_COLUMN).
    SPLIT LS_COLUMN-FIELDNAME AT  '_'  INTO TABLE DATA(LT_STRING).
    READ TABLE LT_STRING INTO DATA(LS_STRING) INDEX 1.
    LV_STRING = LS_STRING.
    IF LV_STRING NE 'FIELDINFOR'.
      MESSAGE S003 DISPLAY LIKE 'E' WITH '차수가 아닌 컬럼이 선택되었습니다.'(E06).
      RETURN.
    ENDIF.

    READ TABLE LT_STRING INTO LS_STRING INDEX 2.
    LV_NUM = LS_STRING.
    LV_ZWSEQ = LV_NUM + 0.

    LOOP AT  <GT_MAIN_DISP_1103> ASSIGNING FIELD-SYMBOL(<LS_MAIN>).

      __GET_LINE_FIELDS.
      IF <LV_LINE> = 2.
        CONTINUE.
      ENDIF.

      READ TABLE GT_MAIN_DISP_1102 INTO GS_MAIN_DISP_1102 WITH KEY SEQNO = <LV_SEQNO>.

      IF GS_MAIN_DISP_1102-SGRPNR IS INITIAL.
        CONTINUE.
      ENDIF.


      READ TABLE GT_2012_MAINTAIN TRANSPORTING NO FIELDS WITH KEY SGRPNR = GS_1101_MENGE-SGRPNR
                                                                                         ZWSEQ = LV_ZWSEQ.
      IF SY-SUBRC EQ 0.
        APPEND INITIAL LINE TO LT_CREATE ASSIGNING FIELD-SYMBOL(<LS_CREATE>).
        <LS_CREATE>-SEQNO = <LV_SEQNO>.
        <LS_CREATE>-ZWSEQ = LV_ZWSEQ.
      ENDIF.

    ENDLOOP.
  ENDLOOP.

  LOOP AT LT_CELLS INTO DATA(LS_CELLS).
    READ TABLE GT_FIELDCAT_1103 INTO DATA(LS_FCAT) INDEX LS_CELLS-COL_ID.
    IF SY-SUBRC EQ 0.

      SPLIT LS_FCAT-FIELDNAME AT  '_'  INTO TABLE LT_STRING.
      READ TABLE LT_STRING INTO LS_STRING INDEX 1.
      LV_STRING = LS_STRING.
      IF LV_STRING NE 'FIELDINFOR'.
        MESSAGE S003 DISPLAY LIKE 'E' WITH '차수가 아닌 컬럼이 선택되었습니다.'(E06).
        RETURN.
      ENDIF.

      READ TABLE LT_STRING INTO LS_STRING INDEX 2.
      LV_NUM = LS_STRING.
      LV_ZWSEQ = LV_NUM + 0.

      READ TABLE <GT_MAIN_DISP_1103> ASSIGNING <LS_MAIN> INDEX LS_CELLS-ROW_ID.

      __GET_LINE_FIELDS.

      READ TABLE GT_MAIN_DISP_1102 INTO GS_MAIN_DISP_1102 WITH KEY SEQNO = <LV_SEQNO>.

      IF GS_MAIN_DISP_1102-SGRPNR IS INITIAL.
        CONTINUE.
      ENDIF.

      READ TABLE GT_2012_MAINTAIN TRANSPORTING NO FIELDS WITH KEY SGRPNR = GS_1101_MENGE-SGRPNR
                                                                                         ZWSEQ = LV_ZWSEQ.
      IF SY-SUBRC EQ 0.
        READ TABLE LT_CREATE TRANSPORTING NO FIELDS WITH KEY SEQNO  = <LV_SEQNO>
                                                                                ZWSEQ = LV_ZWSEQ.
        IF SY-SUBRC NE 0.

          APPEND INITIAL LINE TO LT_CREATE ASSIGNING <LS_CREATE>.
          <LS_CREATE>-SEQNO = <LV_SEQNO>.
          <LS_CREATE>-ZWSEQ = LV_ZWSEQ.
        ENDIF.
      ENDIF.

    ENDIF.

  ENDLOOP.

  IF LT_CREATE[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '삭제 가능한 차수가 선택되지 않았습니다.'(E30).
    RETURN.
  ENDIF.

  CLEAR GV_ANSWER.
  PERFORM POPUP_TO_CONFIRM_STEP USING 'N'
    ' '
    '선택된 구간의 오더를 삭제합니다. 계속 진행 하시겠습니까?'
    '삭제확인'.
  IF GV_ANSWER NE 'J'.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '작업이 취소 되었습니다.'.
    RETURN.
  ENDIF.

  REFRESH GT_PRD_ORDERS.
  REFRESH GT_PR_ORDERS.
  REFRESH GT_PO_ORDERS.

  LT_CREATE_SORTED = LT_CREATE.
  SORT LT_CREATE_SORTED BY SEQNO.
  DELETE ADJACENT DUPLICATES FROM LT_CREATE_SORTED COMPARING SEQNO.

  LOOP AT LT_CREATE_SORTED INTO DATA(LS_CREATE_SORTED).

    READ TABLE GT_MAIN_DISP_1102 ASSIGNING FIELD-SYMBOL(<LS_MAIN_1102>) WITH KEY SEQNO = LS_CREATE_SORTED-SEQNO.
    IF SY-SUBRC EQ 0.
      LOOP AT LT_CREATE INTO LS_CREATE WHERE SEQNO = LS_CREATE_SORTED-SEQNO.
        READ TABLE GT_2012_MAINTAIN INTO DATA(LS_2012) WITH KEY SGRPNR = <LS_MAIN_1102>-SGRPNR
                                                                             ZWSEQ = LS_CREATE-ZWSEQ.
        IF SY-SUBRC EQ 0.
          CLEAR LS_2012_DEL.
          MOVE-CORRESPONDING LS_2012 TO LS_2012_DEL.
          APPEND LS_2012_DEL TO LT_2012_DEL.

          CASE LS_2012-ORDTY.
            WHEN 'PRD'.
              APPEND INITIAL LINE TO GT_PRD_ORDERS ASSIGNING FIELD-SYMBOL(<LS_PRD_ORDERS>).
              <LS_PRD_ORDERS>-ORDER_NUMBER = LS_2012-ORDNR.
            WHEN 'PR'.
              APPEND INITIAL LINE TO GT_PR_ORDERS ASSIGNING FIELD-SYMBOL(<LS_PR_ORDERS>).
              <LS_PR_ORDERS>-BNFPO = LS_2012-POSNR + 0.
              <LS_PR_ORDERS>-BANFN = LS_2012-ORDNR.
            WHEN 'PO'.
              APPEND INITIAL LINE TO GT_PO_ORDERS ASSIGNING FIELD-SYMBOL(<LS_PO_ORDERS>).
              <LS_PO_ORDERS>-EBELP = LS_2012-POSNR + 0.
              <LS_PO_ORDERS>-EBELN = LS_2012-ORDNR.
          ENDCASE.

        ENDIF.
      ENDLOOP.
    ENDIF.
  ENDLOOP.

  IF GT_PRD_ORDERS[] IS NOT INITIAL.
    DATA : LS_RETURN2 TYPE BAPIRET2.
    DATA : LT_DETAIL_RETURN TYPE BAPI_ORDER_RETURN_TT.

    CALL FUNCTION 'BAPI_PRODORD_SET_DELETION_FLAG'
      IMPORTING
        RETURN        = LS_RETURN2
      TABLES
        ORDERS        = GT_PRD_ORDERS
        DETAIL_RETURN = LT_DETAIL_RETURN.
  ENDIF.

  IF GT_PR_ORDERS IS NOT INITIAL.
    PERFORM DEL_PR_PRDERS TABLES GT_PR_ORDERS.
  ENDIF.

  IF GT_PO_ORDERS IS NOT INITIAL.
    PERFORM DEL_PO_PRDERS TABLES GT_PO_ORDERS.
  ENDIF.

  DELETE ZGTPPT2012  FROM TABLE LT_2012_DEL.
  IF SY-SUBRC NE 0.
    ROLLBACK WORK.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '오더 삭제중 오류 발생하였습니다.'(e31).
    RETURN.
  ELSE.
    COMMIT WORK AND WAIT.
  ENDIF.

  LOOP AT LT_CREATE_SORTED INTO LS_CREATE_SORTED.

    READ TABLE GT_MAIN_DISP_1102 ASSIGNING <LS_MAIN_1102> WITH KEY SEQNO = LS_CREATE_SORTED-SEQNO.
    IF SY-SUBRC EQ 0.

      DELETE GT_2012 WHERE SGRPNR = <LS_MAIN_1102>-SGRPNR.

      SELECT * FROM ZGTPPT2012
        INTO TABLE @DATA(LT_2012)
       WHERE SGRPNR = @<LS_MAIN_1102>-SGRPNR.
      IF SY-SUBRC NE 0. " 신선재 오더 정보가 없다면
        DELETE GT_2011 WHERE SGRPNR = <LS_MAIN_1102>-SGRPNR.
        DELETE GT_2013 WHERE SGRPNR = <LS_MAIN_1102>-SGRPNR.
        DELETE FROM ZGTPPT2011 WHERE SGRPNR = <LS_MAIN_1102>-SGRPNR.
        DELETE FROM ZGTPPT2013 WHERE SGRPNR = <LS_MAIN_1102>-SGRPNR.
        DELETE FROM ZGTPPT2014 WHERE SGRPNR = <LS_MAIN_1102>-SGRPNR.
        COMMIT WORK AND WAIT.
      ELSE.
        APPEND LINES OF LT_2012 TO GT_2012.
      ENDIF.
    ENDIF.

  ENDLOOP.

  IF <GT_MAIN_DISP_1103> IS ASSIGNED.
    REFRESH <GT_MAIN_DISP_1103>.
  ENDIF.

  PERFORM SET_ITAB_1102.
  PERFORM REFRESH_GRID USING GO_GRID_1102.
  PERFORM SET_ITAB_1103.
  IF GO_GRID_1103 IS BOUND.
    PERFORM REFRESH_GRID USING GO_GRID_1103.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form DEL_PO_PRDERS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_PO_ORDERS
*&---------------------------------------------------------------------*
FORM DEL_PO_PRDERS  TABLES   PT_PO_ORDERS STRUCTURE GS_PO_ORDERS.

  DATA : LV_PURCHASEORDER   TYPE BAPIMEPOHEADER-PO_NUMBER.
  DATA : LT_RETURN TYPE TABLE OF BAPIRET2.
  DATA : LT_POITEM   TYPE TABLE OF BAPIMEPOITEM.
  DATA : LT_POITEMX   TYPE TABLE OF BAPIMEPOITEMX.

  LOOP AT PT_PO_ORDERS INTO DATA(LS_PO_ORDERS).

    LV_PURCHASEORDER = LS_PO_ORDERS-EBELN.

    APPEND INITIAL LINE TO LT_POITEM ASSIGNING FIELD-SYMBOL(<LS_POITEM>).
    <LS_POITEM>-PO_ITEM = LS_PO_ORDERS-EBELP.
    <LS_POITEM>-DELETE_IND = ABAP_TRUE.

    APPEND INITIAL LINE TO LT_POITEMX ASSIGNING FIELD-SYMBOL(<LS_POITEMX>).
    <LS_POITEMX>-PO_ITEM = LS_PO_ORDERS-EBELP.
    <LS_POITEMX>-PO_ITEMX = ABAP_TRUE.
    <LS_POITEMX>-DELETE_IND = ABAP_TRUE.

    CALL FUNCTION 'BAPI_PO_CHANGE'
      EXPORTING
        PURCHASEORDER = LV_PURCHASEORDER
      TABLES
        RETURN        = LT_RETURN
        POITEM        = LT_POITEM
        POITEMX       = LT_POITEMX.

    READ TABLE LT_RETURN TRANSPORTING NO FIELDS WITH KEY TYPE = 'E'.
    IF SY-SUBRC NE 0.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = 'X'.
    ELSE.
      ROLLBACK WORK.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_CREATE_PO_1100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_CREATE_PO_1100 .

  DATA : LT_COLUMN TYPE LVC_T_COL.
  DATA : LT_CELLS TYPE LVC_T_CENO.
  DATA : LV_NUM(2) TYPE N.
  DATA : LV_STRING TYPE STRING.
  DATA : LV_ZWSEQ TYPE ZGTPPT2012-ZWSEQ.
  FIELD-SYMBOLS <LV_LINE> TYPE ANY.
  FIELD-SYMBOLS <LV_SEQNO> TYPE ANY.
  DATA : LV_SEQ_C TYPE C LENGTH 11.

  DATA : BEGIN OF LS_CREATE,
           SEQNO TYPE I,
           ZWSEQ TYPE ZGTPPT2012-ZWSEQ,
         END OF LS_CREATE.
  DATA : LT_CREATE LIKE TABLE OF LS_CREATE.
  DATA : LT_CREATE_SORTED LIKE TABLE OF LS_CREATE.

  DEFINE __GET_LINE_FIELDS.
    IF <LV_SEQNO> IS ASSIGNED. UNASSIGN <LV_SEQNO>. ENDIF.
    ASSIGN COMPONENT 'SEQNO' OF STRUCTURE <LS_MAIN> TO <LV_SEQNO>.
    IF <LV_LINE> IS ASSIGNED. UNASSIGN <LV_LINE>. ENDIF.
    ASSIGN COMPONENT 'LINE' OF STRUCTURE <LS_MAIN> TO <LV_LINE>.
  END-OF-DEFINITION.

  GO_GRID_1103->GET_SELECTED_COLUMNS(
    IMPORTING
      ET_INDEX_COLUMNS = LT_COLUMN ).                " Cell IDs

  GO_GRID_1103->GET_SELECTED_CELLS_ID(
      IMPORTING
       ET_CELLS = LT_CELLS ).                " Cell IDs

  IF LT_COLUMN[] IS INITIAL AND LT_CELLS[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '선택된 컬럼 또는 Cell이 없습니다.'(e27).
    RETURN.
  ENDIF.

  LOOP AT LT_COLUMN INTO DATA(LS_COLUMN).
    SPLIT LS_COLUMN-FIELDNAME AT  '_'  INTO TABLE DATA(LT_STRING).
    READ TABLE LT_STRING INTO DATA(LS_STRING) INDEX 1.
    LV_STRING = LS_STRING.
    IF LV_STRING NE 'FIELDINFOR'.
      MESSAGE S003 DISPLAY LIKE 'E' WITH '차수가 아닌 컬럼이 선택되었습니다.'(E06).
      RETURN.
    ENDIF.

    READ TABLE LT_STRING INTO LS_STRING INDEX 2.
    LV_NUM = LS_STRING.
    LV_ZWSEQ = LV_NUM + 0.

    LOOP AT  <GT_MAIN_DISP_1103> ASSIGNING FIELD-SYMBOL(<LS_MAIN>).

      __GET_LINE_FIELDS.
      IF <LV_LINE> = 2.
        CONTINUE.
      ENDIF.


      READ TABLE GT_1101_MENGE INTO GS_1101_MENGE WITH KEY SEQNO = <LV_SEQNO>
                                                                                      ZWSEQ = LV_ZWSEQ.
      IF SY-SUBRC EQ 0 AND GS_1101_MENGE-MENGE07 > 0.
        IF GS_1101_MENGE-SGRPNR IS NOT INITIAL.
          READ TABLE GT_2012_MAINTAIN TRANSPORTING NO FIELDS WITH KEY SGRPNR = GS_1101_MENGE-SGRPNR
                                                                                             ZWSEQ = LV_ZWSEQ.
          IF SY-SUBRC EQ 0.
            CONTINUE.
          ENDIF.
        ENDIF.

        APPEND INITIAL LINE TO LT_CREATE ASSIGNING FIELD-SYMBOL(<LS_CREATE>).
        <LS_CREATE>-SEQNO = <LV_SEQNO>.
        <LS_CREATE>-ZWSEQ = LV_ZWSEQ.

      ENDIF.

    ENDLOOP.
  ENDLOOP.

  LOOP AT LT_CELLS INTO DATA(LS_CELLS).
    READ TABLE GT_FIELDCAT_1103 INTO DATA(LS_FCAT) INDEX LS_CELLS-COL_ID.
    IF SY-SUBRC EQ 0.

      SPLIT LS_FCAT-FIELDNAME AT  '_'  INTO TABLE LT_STRING.
      READ TABLE LT_STRING INTO LS_STRING INDEX 1.
      LV_STRING = LS_STRING.
      IF LV_STRING NE 'FIELDINFOR'.
        MESSAGE S003 DISPLAY LIKE 'E' WITH '차수가 아닌 컬럼이 선택되었습니다.'(E06).
        RETURN.
      ENDIF.

      READ TABLE LT_STRING INTO LS_STRING INDEX 2.
      LV_NUM = LS_STRING.
      LV_ZWSEQ = LV_NUM + 0.

      READ TABLE <GT_MAIN_DISP_1103> ASSIGNING <LS_MAIN> INDEX LS_CELLS-ROW_ID.

      __GET_LINE_FIELDS.

      READ TABLE GT_1101_MENGE INTO GS_1101_MENGE WITH KEY SEQNO = <LV_SEQNO>
                                                                                      ZWSEQ = LV_ZWSEQ.
      IF SY-SUBRC EQ 0 AND GS_1101_MENGE-MENGE07 > 0.
        IF GS_1101_MENGE-SGRPNR IS NOT INITIAL.
          READ TABLE GT_2012_MAINTAIN TRANSPORTING NO FIELDS WITH KEY SGRPNR = GS_1101_MENGE-SGRPNR
                                                                                             ZWSEQ = LV_ZWSEQ.
          IF SY-SUBRC EQ 0.
            CONTINUE.
          ENDIF.
        ENDIF.

        READ TABLE LT_CREATE TRANSPORTING NO FIELDS WITH KEY SEQNO  = <LV_SEQNO>
                                                                                    ZWSEQ = LV_ZWSEQ.
        IF SY-SUBRC NE 0.

          APPEND INITIAL LINE TO LT_CREATE ASSIGNING <LS_CREATE>.
          <LS_CREATE>-SEQNO = <LV_SEQNO>.
          <LS_CREATE>-ZWSEQ = LV_ZWSEQ.
        ENDIF.

      ENDIF.

    ENDIF.
  ENDLOOP.

  IF LT_CREATE[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '구매오더 생성가능한 차수가 선택되지 않았습니다.'(E32).
    RETURN.
  ENDIF.

  REFRESH GT_2013_DEL.

  REFRESH GT_PO_ORDERS.
  REFRESH : GT_POPUP_1300, GT_POPUP_1301, GT_POPUP_1302.

  LT_CREATE_SORTED = LT_CREATE.
  SORT LT_CREATE_SORTED BY SEQNO.
  DELETE ADJACENT DUPLICATES FROM LT_CREATE_SORTED COMPARING SEQNO.

* 구매오더 생성을 위한 화면 구성 테이블 구성
  LOOP AT LT_CREATE_SORTED INTO DATA(LS_CREATE_SORTED).

    READ TABLE GT_MAIN_DISP_1102 ASSIGNING FIELD-SYMBOL(<LS_MAIN_1102>) WITH KEY SEQNO = LS_CREATE_SORTED-SEQNO.
    IF SY-SUBRC EQ 0.
      APPEND INITIAL LINE TO GT_POPUP_1300 ASSIGNING FIELD-SYMBOL(<LS_1300>).
      <LS_1300>-SEQNO = <LS_1300>-SEQNO_C = LS_CREATE_SORTED-SEQNO.
      CONDENSE <LS_1300>-SEQNO_C.
      <LS_1300>-MATNR = <LS_MAIN_1102>-MATNR.
      <LS_1300>-MAKTX = <LS_MAIN_1102>-MAKTX.
* 입고위치 추가
      SELECT SINGLE LGFSB
        FROM MARC
        INTO <LS_1300>-LGFSB
       WHERE WERKS = P_WERKS
         AND MATNR = <LS_MAIN_1102>-MATNR.

* 공급업체, 공급일자는 입력 값으로 세팅

      LOOP AT LT_CREATE INTO LS_CREATE WHERE SEQNO = LS_CREATE_SORTED-SEQNO.
* 외장재 정보세팅
        APPEND INITIAL LINE TO GT_POPUP_1301 ASSIGNING FIELD-SYMBOL(<LS_1301>).
        <LS_1301>-SEQNO = <LS_1301>-SEQNO_C = LS_CREATE_SORTED-SEQNO.
        CONDENSE <LS_1301>-SEQNO_C.

        <LS_1301>-ZTWSEQ = LV_SEQ_C = LS_CREATE-ZWSEQ.
        CONDENSE LV_SEQ_C.
        <LS_1301>-PHASE_C = LV_SEQ_C && '차'.

        READ TABLE GT_1101_MENGE INTO GS_1101_MENGE WITH KEY SEQNO = LS_CREATE-SEQNO
                                                                                     ZWSEQ = LS_CREATE-ZWSEQ.
        IF SY-SUBRC EQ 0.
          <LS_1301>-MENGE = GS_1101_MENGE-MENGE07.
          SELECT SINGLE MEINS FROM MARA
            INTO <LS_1301>-MEINS
           WHERE MATNR = <LS_MAIN_1102>-MATNR.
        ENDIF.

* 외장재 반제품 사급자재 정보
        PERFORM SET_RESB_INFOR USING <LS_1301> <LS_MAIN_1102>-MATNR.
      ENDLOOP.

    ENDIF.
  ENDLOOP.

  CLEAR GS_EKORG.
  SELECT SINGLE FLD_02 AS WERKS, FLD_03 AS EKORG, FLD_04 AS EKGRP
    FROM ZGTPPT1010
      INTO @GS_EKORG
   WHERE MODULE_KIND = 'PP'
       AND CODEGRP = '2090'
       AND FLD_01 = 'L'
       AND FLD_02 = @P_WERKS.

  CLEAR GV_CHK_CONFIRM_1300.
  CALL SCREEN '1300' STARTING AT 5 5 ENDING AT 95 15.

  IF GV_CHK_CONFIRM_1300 NE 'S'.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '구매오더 생성이 취소되었습니다.'(E33).
    RETURN.
  ENDIF.

* 구매오더 생성 및 저장테이블 구성
  DATA : LT_2011 TYPE TABLE OF ZGTPPT2011.
  DATA : LS_2011 TYPE ZGTPPT2011.
  DATA : LT_2012 TYPE TABLE OF ZGTPPT2012.
  DATA : LS_2012 TYPE ZGTPPT2012.
  DATA : LT_2012_TMP TYPE TABLE OF ZGTPPT2012.
  DATA : LT_2012_MODI TYPE TABLE OF ZGTPPT2012.
  DATA : LT_2013 TYPE TABLE OF ZGTPPT2013.
  DATA : LT_2013_MODI TYPE TABLE OF ZGTPPT2013.
  DATA : LT_2014 TYPE TABLE OF ZGTPPT2014.
  DATA : LT_2014_MODI TYPE TABLE OF ZGTPPT2014.
  DATA : LV_CHK_ERR.

  REFRESH GT_2013_DEL.

  REFRESH GT_PO_ORDERS.

  LOOP AT LT_CREATE_SORTED INTO LS_CREATE_SORTED.
    REFRESH : LT_2012, LT_2013.
    CLEAR LS_2011.

    READ TABLE GT_MAIN_DISP_1102 ASSIGNING <LS_MAIN_1102> WITH KEY SEQNO = LS_CREATE_SORTED-SEQNO.
    IF SY-SUBRC EQ 0.
      PERFORM MAKE_DATA_TO_SAVE01_1101 TABLES LT_2013 LT_2014
                                                          CHANGING LS_2011 <LS_MAIN_1102> LV_CHK_ERR.

      LOOP AT LT_CREATE INTO LS_CREATE WHERE SEQNO = LS_CREATE_SORTED-SEQNO.
        CLEAR LS_2012.
        PERFORM MAKE_DATA_TO_SAVE04_1101 USING LS_CREATE-ZWSEQ LS_2011 <LS_MAIN_1102>
                                                     CHANGING LS_2012 LV_CHK_ERR.

        IF LV_CHK_ERR = ABAP_TRUE.
          EXIT.
        ENDIF.
        APPEND LS_2012 TO LT_2012.
      ENDLOOP.

      IF LV_CHK_ERR = ABAP_TRUE.
        EXIT.
      ENDIF.

      IF LS_2011-SGRPNR IS INITIAL.
        PERFORM GET_NUM_SGRPNR CHANGING LS_2011-SGRPNR LV_CHK_ERR.
        IF LV_CHK_ERR = ABAP_TRUE.
          RETURN.
        ENDIF.

* 소선오더 그룹번호 세팅
        LOOP AT LT_2013 ASSIGNING FIELD-SYMBOL(<LS_2013_CHG>).
          <LS_2013_CHG>-SGRPNR = LS_2011-SGRPNR.
        ENDLOOP.

* 소선정보 그룹번호 세팅
        LOOP AT LT_2014 ASSIGNING FIELD-SYMBOL(<LS_2014_CHG>).
          <LS_2014_CHG>-SGRPNR = LS_2011-SGRPNR.
        ENDLOOP.

      ELSE.
        REFRESH LT_2012_TMP.
        LT_2012_TMP = VALUE #( FOR LW_2012 IN GT_2012 WHERE ( SGRPNR = LS_2011-SGRPNR )
                                         ( CORRESPONDING #( LW_2012 ) ) ).

        IF LT_2012_TMP[] IS NOT INITIAL.
          APPEND LINES OF LT_2012_TMP TO LT_2012.
        ENDIF.

      ENDIF.
* 저장 테이블 반영(2011)
      APPEND LS_2011 TO LT_2011.

      <LS_MAIN_1102>-SGRPNR = LS_2011-SGRPNR.

*    신선오더의 최종 차수 변경
      SORT LT_2012 BY ZTWSEQ DESCENDING.
      READ TABLE LT_2012 INTO DATA(LS_2012_MAX) INDEX 1.
      LOOP AT LT_2012 ASSIGNING FIELD-SYMBOL(<LS_2012_CHG>).
        IF <LS_2012_CHG>-SGRPNR IS INITIAL.
          <LS_2012_CHG>-SGRPNR = LS_2011-SGRPNR.
        ENDIF.

        <LS_2012_CHG>-ZTWSEQ = LS_2012_MAX-ZTWSEQ.
      ENDLOOP.

* 저장 테이블 반영
      IF LT_2012 IS NOT INITIAL.
        APPEND LINES OF LT_2012 TO LT_2012_MODI.
      ENDIF.
      IF LT_2013 IS NOT INITIAL.
        APPEND LINES OF LT_2013 TO LT_2013_MODI.
      ENDIF.

      IF LT_2014 IS NOT INITIAL.
        APPEND LINES OF LT_2014 TO LT_2014_MODI.
      ENDIF.

    ENDIF.
  ENDLOOP.

* 에러시 구매오더 삭제처리후 종료
  IF LV_CHK_ERR = ABAP_TRUE.

    IF GT_PO_ORDERS IS NOT INITIAL.
      PERFORM DEL_PO_PRDERS TABLES GT_PO_ORDERS.
    ENDIF.

    MESSAGE S003 DISPLAY LIKE 'E' WITH '구매 생성중 오류 발생하였습니다.'(e34).
    RETURN.

  ENDIF.


* DB저장
  IF GT_2013_DEL IS NOT INITIAL.
    DELETE ZGTPPT2013 FROM TABLE GT_2013_DEL.
    IF SY-SUBRC NE 0.
      ROLLBACK WORK.
      IF GT_PO_ORDERS IS NOT INITIAL.
        PERFORM DEL_PO_PRDERS TABLES GT_PO_ORDERS.
      ENDIF.
      MESSAGE S003 DISPLAY LIKE 'E' WITH '구매 생성중 오류 발생하였습니다.'(e34).
      RETURN.

    ENDIF.
  ENDIF.

  MODIFY ZGTPPT2011 FROM TABLE LT_2011.
  IF SY-SUBRC NE 0.
    ROLLBACK WORK.
    IF GT_PO_ORDERS IS NOT INITIAL.
      PERFORM DEL_PO_PRDERS TABLES GT_PO_ORDERS.
    ENDIF.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '구매 생성중 오류 발생하였습니다.'(e34).
    RETURN.
  ENDIF.

  MODIFY ZGTPPT2012 FROM TABLE LT_2012_MODI.
  IF SY-SUBRC NE 0.
    ROLLBACK WORK.
    IF GT_PO_ORDERS IS NOT INITIAL.
      PERFORM DEL_PO_PRDERS TABLES GT_PO_ORDERS.
    ENDIF.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '구매 생성중 오류 발생하였습니다.'(e34).
    RETURN.
  ENDIF.

  MODIFY ZGTPPT2013 FROM TABLE LT_2013_MODI.
  IF SY-SUBRC NE 0.
    ROLLBACK WORK.
    IF GT_PO_ORDERS IS NOT INITIAL.
      PERFORM DEL_PO_PRDERS TABLES GT_PO_ORDERS.
    ENDIF.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '구매 생성중 오류 발생하였습니다.'(e34).
    RETURN.
  ENDIF.

  MODIFY ZGTPPT2014 FROM TABLE LT_2014_MODI.
  IF SY-SUBRC NE 0.
    ROLLBACK WORK.
    IF GT_PO_ORDERS IS NOT INITIAL.
      PERFORM DEL_PO_PRDERS TABLES GT_PO_ORDERS.
    ENDIF.
    MESSAGE S003 DISPLAY LIKE 'E' WITH '구매 생성중 오류 발생하였습니다.'(e34).
    RETURN.
  ENDIF.

  COMMIT WORK AND WAIT.

  LOOP AT LT_CREATE_SORTED INTO LS_CREATE_SORTED.

    READ TABLE GT_MAIN_DISP_1102 ASSIGNING <LS_MAIN_1102> WITH KEY SEQNO = LS_CREATE_SORTED-SEQNO.
    IF SY-SUBRC EQ 0.
      DELETE GT_2011 WHERE SGRPNR = <LS_MAIN_1102>-SGRPNR.
      DELETE GT_2012 WHERE SGRPNR = <LS_MAIN_1102>-SGRPNR.
      DELETE GT_2013 WHERE SGRPNR = <LS_MAIN_1102>-SGRPNR.
    ENDIF.
  ENDLOOP.

  APPEND LINES OF LT_2011 TO GT_2011.
  APPEND LINES OF LT_2012_MODI TO GT_2012.
  APPEND LINES OF LT_2013_MODI TO GT_2013.

  REFRESH GT_ZZBUNDLE.
  LOOP AT LT_2011 INTO DATA(LS_2011_MODI).
    APPEND INITIAL LINE TO GT_ZZBUNDLE ASSIGNING FIELD-SYMBOL(<LS_ZZBUNDLE>).
    <LS_ZZBUNDLE>-SIGN = 'I'.
    <LS_ZZBUNDLE>-OPTION = 'EQ'.
    <LS_ZZBUNDLE>-LOW = LS_2011_MODI-ZZBUNDLE.
  ENDLOOP.

  SORT GT_ZZBUNDLE BY LOW.
  DELETE ADJACENT DUPLICATES FROM GT_ZZBUNDLE COMPARING LOW.
  PERFORM SENG_LOG_BWD.

  IF <GT_MAIN_DISP_1103> IS ASSIGNED.
    REFRESH <GT_MAIN_DISP_1103>.
  ENDIF.

  PERFORM SET_ITAB_1102.
  PERFORM REFRESH_GRID USING GO_GRID_1102.
  PERFORM SET_ITAB_1103.
  IF GO_GRID_1103 IS BOUND.
    PERFORM REFRESH_GRID USING GO_GRID_1103.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_RESB_INFOR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LS_1301>
*&---------------------------------------------------------------------*
FORM SET_RESB_INFOR  USING    PS_1301 LIKE GS_POPUP_1301
                                     PV_MATNR TYPE MATNR.

  DATA : LS_TOPMAT TYPE CSTMAT.
  DATA : LT_STB TYPE TABLE OF STPOX.
  DATA : LT_CSCMAT TYPE TABLE OF CSCMAT.
  DATA : LV_EMENG TYPE STKO-BMENG.
  DATA : BEGIN OF LS_COLLECT_MATNR,
           MATNR TYPE MATNR,
           MENGE TYPE MENGE_D,
           MEINS TYPE MEINS,
         END OF LS_COLLECT_MATNR.
  DATA : LT_COLLECT_MATNR LIKE TABLE OF LS_COLLECT_MATNR.

  LV_EMENG = PS_1301-MENGE.

* BOM 하위전개
  CALL FUNCTION 'CS_BOM_EXPL_MAT_V2'
    EXPORTING
      CAPID                 = 'PP01'
      DATUV                 = SY-DATUM
      MKTLS                 = ABAP_ON
      MMORY                 = '1'
      MTNRV                 = PV_MATNR
      WERKS                 = P_WERKS
      EMENG                 = LV_EMENG
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

  REFRESH LT_COLLECT_MATNR.

  SORT LT_STB BY IDNRK.

  LOOP AT LT_STB INTO DATA(LS_STB).
    CLEAR LS_COLLECT_MATNR.
    LS_COLLECT_MATNR-MATNR = LS_STB-IDNRK.
    LS_COLLECT_MATNR-MENGE = LS_STB-MNGLG.
    LS_COLLECT_MATNR-MEINS = LS_STB-MEINS.
    COLLECT LS_COLLECT_MATNR INTO LT_COLLECT_MATNR.
  ENDLOOP.

  LOOP AT LT_COLLECT_MATNR INTO LS_COLLECT_MATNR.
    CLEAR GS_POPUP_1302.
    MOVE-CORRESPONDING PS_1301 TO GS_POPUP_1302.
    GS_POPUP_1302-MATNR = LS_COLLECT_MATNR-MATNR.
    GS_POPUP_1302-MAKTX = ZGTPP_CL_COMMON=>GET_MAKTX( IV_MATNR = LS_COLLECT_MATNR-MATNR ).
    GS_POPUP_1302-MENGE = LS_COLLECT_MATNR-MENGE.
    GS_POPUP_1302-MEINS = LS_COLLECT_MATNR-MEINS.
    APPEND GS_POPUP_1302 TO GT_POPUP_1302.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_1300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GRID_1300 .

  CREATE OBJECT GO_DOCKING_1300
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

  CREATE OBJECT GO_SPLITTER_1300
    EXPORTING
      PARENT  = GO_DOCKING_1300
      ROWS    = 2
      COLUMNS = 1.

  GO_SPLITTER_1300->SET_ROW_HEIGHT(
    EXPORTING
      ID                =  1                " Row ID
      HEIGHT            =  30    ).            " Height


  CALL METHOD GO_SPLITTER_1300->GET_CONTAINER
    EXPORTING
      ROW       = 1
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_CONTAIN_1300.

  CALL METHOD GO_SPLITTER_1300->GET_CONTAINER
    EXPORTING
      ROW       = 2
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_CONTAIN_1300_UNDER.


  CREATE OBJECT GO_SPLITTER_1300_UNDER
    EXPORTING
      PARENT  = GO_CONTAIN_1300_UNDER
      ROWS    = 1
      COLUMNS = 2.

  GO_SPLITTER_1300_UNDER->SET_COLUMN_WIDTH(
    EXPORTING
      ID                =  1                " Column ID
      WIDTH             = 35                 " NPlWidth
    EXCEPTIONS
      CNTL_ERROR        = 1                " See CL_GUI_CONTROL
      CNTL_SYSTEM_ERROR = 2                " See CL_GUI_CONTROL
      OTHERS            = 3
  ).

  CALL METHOD GO_SPLITTER_1300_UNDER->GET_CONTAINER
    EXPORTING
      ROW       = 1
      COLUMN    = 1
    RECEIVING
      CONTAINER = GO_CONTAIN_1301.

  CALL METHOD GO_SPLITTER_1300_UNDER->GET_CONTAINER
    EXPORTING
      ROW       = 1
      COLUMN    = 2
    RECEIVING
      CONTAINER = GO_CONTAIN_1302.


  CREATE OBJECT GO_GRID_1300
    EXPORTING
      I_PARENT      = GO_CONTAIN_1300
      I_APPL_EVENTS = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_1300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_1300 .

  CLEAR GS_LAYOUT_1300.
  GS_LAYOUT_1300-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYOUT_1300-NO_ROWMARK   = 'X'.
  GS_LAYOUT_1300-NO_TOOLBAR   = 'X'.
  GS_LAYOUT_1300-STYLEFNAME = 'CELLTAB'.
  GS_LAYOUT_1300-SMALLTITLE = 'X'.
  GS_LAYOUT_1300-GRID_TITLE = '공급업체 지정'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_GRID_1300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_1300 .

  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR2150TOP'
      I_INTERNAL_TABNAME     = 'GS_POPUP_1300'
    CHANGING
      CT_FIELDCAT            = LT_FCAT_SLIS
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.

  REFRESH GT_FIELDCAT_1300.

*-- lt_fieldcat의 구조체를 pt_fcat의 구조체로 변경
  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT_SLIS
    IMPORTING
      ET_FIELDCAT_LVC = GT_FIELDCAT_1300[]
    TABLES
      IT_DATA         = GT_POPUP_1300
    EXCEPTIONS
      OTHERS          = 1.

  READ TABLE GT_FIELDCAT_1300 ASSIGNING FIELD-SYMBOL(<LS_FCAT>) WITH KEY FIELDNAME = 'SEQNO'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_1300 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'SEQNO'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = <LS_FCAT>-FIELDNAME.
    <LS_FCAT>-COL_POS = 1.
    <LS_FCAT>-DATATYPE = 'INT'.
    <LS_FCAT>-DD_OUTLEN = '10'.
    <LS_FCAT>-NO_OUT = ABAP_TRUE.
  ENDIF.

  READ TABLE GT_FIELDCAT_1300 ASSIGNING <LS_FCAT> WITH KEY FIELDNAME = 'SEQNO_C'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_1300 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'SEQNO_C'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '순번'(F83).
    <LS_FCAT>-COL_POS = 2.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '10'.
    <LS_FCAT>-JUST = 'C'.
  ELSE.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '순번'(F83).
    <LS_FCAT>-COL_POS = 2.
    <LS_FCAT>-JUST = 'C'.
  ENDIF.


  LOOP AT GT_FIELDCAT_1300 ASSIGNING <LS_FCAT>.
    CLEAR <LS_FCAT>-KEY.
    CASE   <LS_FCAT>-FIELDNAME.
      WHEN 'SEQNO'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '제품코드'(P01).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '제품내역'(P02).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'LIFNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '공급업체'(P03).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-F4AVAILABL = ABAP_TRUE.
        <LS_FCAT>-EDIT = ABAP_TRUE.
      WHEN 'NAME1'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '공급업체명'(P04).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'EINDT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '납품예정일'(P05).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-EDIT = ABAP_TRUE.
      WHEN 'LGFSB'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '입고위치'(P09).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-F4AVAILABL = ABAP_TRUE.
        <LS_FCAT>-EDIT = ABAP_TRUE.
    ENDCASE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SORTTAB_GRID_1300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_SORTTAB_GRID_1300 .

  REFRESH GT_SORT_1300.

  PERFORM SET_SORT_TAB TABLES GT_SORT_1300
                            USING : 1 'SEQNO'  'X' '' ''.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CELL_ATTRIBUTE_GRID_1300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_CELL_ATTRIBUTE_GRID_1300 .

  DATA : LT_CELLTAB TYPE LVC_T_STYL.
  DATA : LS_CELLTAB TYPE LVC_S_STYL.
  FIELD-SYMBOLS <LT_CELLTAB> TYPE ANY.
* Macro
  DEFINE __SET_CELL_ATTRIBUTE.
    CLEAR LS_CELLTAB.
    LS_CELLTAB-FIELDNAME = &1.
    LS_CELLTAB-STYLE = &2.
    INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
  END-OF-DEFINITION.


  LOOP AT GT_POPUP_1300 ASSIGNING FIELD-SYMBOL(<LS_MAIN>).
    CLEAR LS_CELLTAB.
    REFRESH LT_CELLTAB.

    __SET_CELL_ATTRIBUTE 'SEQNO_C'  ALV_STYLE_COLOR_INT_KEY.
    __SET_CELL_ATTRIBUTE 'MATNR'  ALV_STYLE_COLOR_INT_KEY.
    __SET_CELL_ATTRIBUTE 'MAKTX'  ALV_STYLE_COLOR_INT_KEY.

    IF <LT_CELLTAB> IS ASSIGNED. UNASSIGN <LT_CELLTAB>. ENDIF.
    ASSIGN COMPONENT 'CELLTAB' OF STRUCTURE <LS_MAIN> TO <LT_CELLTAB>.
    IF <LT_CELLTAB> IS ASSIGNED.
      <LT_CELLTAB> = LT_CELLTAB.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_GRID_1300_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_GRID_1300_DISPLAY .

  CALL METHOD GO_GRID_1300->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT       = GS_LAYOUT_1300
    CHANGING
      IT_OUTTAB       = GT_POPUP_1300
      IT_SORT         = GT_SORT_1300
      IT_FIELDCATALOG = GT_FIELDCAT_1300.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_F4_FIELD_GRID_1300
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_F4_FIELD_GRID_1300 .

  DATA : LT_F4 TYPE LVC_T_F4,
         LS_F4 TYPE LVC_S_F4.

  CLEAR : LT_F4.

  LS_F4-FIELDNAME = 'LIFNR'.  "F4적용 필드
  LS_F4-REGISTER  = 'X'.        "이 부분을 X해줘야 사용할 수 있음
  LS_F4-GETBEFORE = ''.         "F4하기 전에 데이터 체인지 이벤트를 먼저 탐
  LS_F4-CHNGEAFTER = ''.         "F4에서 값 선택 후 데이터 체인지 이벤트 탐

  APPEND LS_F4 TO LT_F4.

  LS_F4-FIELDNAME = 'LGFSB'.  "F4적용 필드
  LS_F4-REGISTER  = 'X'.        "이 부분을 X해줘야 사용할 수 있음
  LS_F4-GETBEFORE = ''.         "F4하기 전에 데이터 체인지 이벤트를 먼저 탐
  LS_F4-CHNGEAFTER = ''.         "F4에서 값 선택 후 데이터 체인지 이벤트 탐

  APPEND LS_F4 TO LT_F4.

  CALL METHOD GO_GRID_1300->REGISTER_F4_FOR_FIELDS
    EXPORTING
      IT_F4 = LT_F4.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_1301
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GRID_1301 .

  CREATE OBJECT GO_GRID_1301
    EXPORTING
      I_PARENT      = GO_CONTAIN_1301
      I_APPL_EVENTS = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_1301
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_1301 .

  CLEAR GS_LAYOUT_1301.
  GS_LAYOUT_1301-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYOUT_1301-NO_ROWMARK   = 'X'.
  GS_LAYOUT_1301-NO_TOOLBAR   = 'X'.
  GS_LAYOUT_1301-SMALLTITLE = 'X'.
  GS_LAYOUT_1301-GRID_TITLE = '공급자재 정보'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_GRID_1301
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_1301 .

  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR2150TOP'
      I_INTERNAL_TABNAME     = 'GS_POPUP_1301'
    CHANGING
      CT_FIELDCAT            = LT_FCAT_SLIS
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.

  REFRESH GT_FIELDCAT_1301.

*-- lt_fieldcat의 구조체를 pt_fcat의 구조체로 변경
  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT_SLIS
    IMPORTING
      ET_FIELDCAT_LVC = GT_FIELDCAT_1301[]
    TABLES
      IT_DATA         = GT_POPUP_1301
    EXCEPTIONS
      OTHERS          = 1.

  READ TABLE GT_FIELDCAT_1301 ASSIGNING FIELD-SYMBOL(<LS_FCAT>) WITH KEY FIELDNAME = 'SEQNO'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_1301 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'SEQNO'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = <LS_FCAT>-FIELDNAME.
    <LS_FCAT>-COL_POS = 1.
    <LS_FCAT>-DATATYPE = 'INT'.
    <LS_FCAT>-DD_OUTLEN = '10'.
    <LS_FCAT>-NO_OUT = ABAP_TRUE.
  ENDIF.

  READ TABLE GT_FIELDCAT_1301 ASSIGNING <LS_FCAT> WITH KEY FIELDNAME = 'SEQNO_C'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_1301 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'SEQNO_C'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '순번'(f83).
    <LS_FCAT>-COL_POS = 2.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '10'.
    <LS_FCAT>-KEY = ABAP_TRUE.
  ELSE.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '순번'(f83).
    <LS_FCAT>-COL_POS = 2.
    <LS_FCAT>-JUST = 'C'.
    <LS_FCAT>-KEY = ABAP_TRUE.
  ENDIF.

  READ TABLE GT_FIELDCAT_1301 ASSIGNING <LS_FCAT> WITH KEY FIELDNAME = 'PHASE_C'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_1301 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'PHASE_C'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '차수'(F57).
    <LS_FCAT>-COL_POS = 4.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '10'.
    <LS_FCAT>-KEY = ABAP_TRUE.
  ELSE.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '차수'(F57).
    <LS_FCAT>-COL_POS = 4.
    <LS_FCAT>-JUST = 'C'.
    <LS_FCAT>-KEY = ABAP_TRUE.
  ENDIF.


  LOOP AT GT_FIELDCAT_1301 ASSIGNING <LS_FCAT>.
    CLEAR <LS_FCAT>-KEY.
    CASE   <LS_FCAT>-FIELDNAME.
      WHEN 'SEQNO' OR 'ZTWSEQ'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'SEQNO_C' OR 'PHASE_C'.
        <LS_FCAT>-KEY = ABAP_TRUE.
      WHEN 'MENGE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '구매오더수량'(F74).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-QFIELDNAME = 'MEINS'.
      WHEN 'MEINS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '단위'(F11).
        <LS_FCAT>-JUST = 'C'.
    ENDCASE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SORTTAB_GRID_1301
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_SORTTAB_GRID_1301 .

  REFRESH GT_SORT_1301.

  PERFORM SET_SORT_TAB TABLES GT_SORT_1301
                            USING : 1 'SEQNO'  'X' '' '',
                                       2 'SEQNO_C' 'X' '' ''.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_GRID_1301_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_GRID_1301_DISPLAY .

  CALL METHOD GO_GRID_1301->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT       = GS_LAYOUT_1301
    CHANGING
      IT_OUTTAB       = GT_POPUP_1301
      IT_SORT         = GT_SORT_1301
      IT_FIELDCATALOG = GT_FIELDCAT_1301.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_OBJECT_GRID_1302
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_OBJECT_GRID_1302 .

  CREATE OBJECT GO_GRID_1302
    EXPORTING
      I_PARENT      = GO_CONTAIN_1302
      I_APPL_EVENTS = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_LAYOUT_GRID_1302
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_1302 .

  CLEAR GS_LAYOUT_1302.
  GS_LAYOUT_1302-CWIDTH_OPT = ABAP_TRUE.
  GS_LAYOUT_1302-NO_ROWMARK   = 'X'.
  GS_LAYOUT_1302-NO_TOOLBAR   = 'X'.
  GS_LAYOUT_1302-STYLEFNAME = 'CELLTAB'.
  GS_LAYOUT_1302-SMALLTITLE = 'X'.
  GS_LAYOUT_1302-GRID_TITLE = '사급자재 관리'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_GRID_1302
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_1302 .

  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR2150TOP'
      I_INTERNAL_TABNAME     = 'GS_POPUP_1302'
    CHANGING
      CT_FIELDCAT            = LT_FCAT_SLIS
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.

  REFRESH GT_FIELDCAT_1302.

*-- lt_fieldcat의 구조체를 pt_fcat의 구조체로 변경
  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT_SLIS
    IMPORTING
      ET_FIELDCAT_LVC = GT_FIELDCAT_1302[]
    TABLES
      IT_DATA         = GT_POPUP_1302
    EXCEPTIONS
      OTHERS          = 1.

  READ TABLE GT_FIELDCAT_1302 ASSIGNING FIELD-SYMBOL(<LS_FCAT>) WITH KEY FIELDNAME = 'SEQNO'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_1302 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'SEQNO'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = <LS_FCAT>-FIELDNAME.
    <LS_FCAT>-COL_POS = 1.
    <LS_FCAT>-DATATYPE = 'INT'.
    <LS_FCAT>-DD_OUTLEN = '10'.
    <LS_FCAT>-NO_OUT = ABAP_TRUE.
  ENDIF.

  READ TABLE GT_FIELDCAT_1302 ASSIGNING <LS_FCAT> WITH KEY FIELDNAME = 'SEQNO_C'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_1302 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'SEQNO_C'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '순번'(f83).
    <LS_FCAT>-COL_POS = 2.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '10'.
  ELSE.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '순번'(f83).
    <LS_FCAT>-COL_POS = 2.
    <LS_FCAT>-JUST = 'C'.
  ENDIF.

  READ TABLE GT_FIELDCAT_1302 ASSIGNING <LS_FCAT> WITH KEY FIELDNAME = 'PHASE_C'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_1302 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'PHASE_C'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '차수'(F57).
    <LS_FCAT>-COL_POS = 4.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '10'.
  ELSE.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '차수'(F57).
    <LS_FCAT>-COL_POS = 4.
    <LS_FCAT>-JUST = 'C'.
  ENDIF.


  LOOP AT GT_FIELDCAT_1302 ASSIGNING <LS_FCAT>.
    CLEAR <LS_FCAT>-KEY.
    CASE   <LS_FCAT>-FIELDNAME.
      WHEN 'SEQNO' OR 'ZTWSEQ'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '사급자재'(P06).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-KEY = ABAP_TRUE.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '사급자재명'(P07).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-KEY = ABAP_TRUE.
      WHEN 'MENGE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '사급자재수량'(P08).
        <LS_FCAT>-JUST = 'R'.
        <LS_FCAT>-QFIELDNAME = 'MEINS'.
        <LS_FCAT>-EDIT = ABAP_TRUE.
      WHEN 'MEINS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '단위'(F11).
        <LS_FCAT>-JUST = 'C'.
        <LS_FCAT>-EDIT = ABAP_TRUE.
    ENDCASE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_CELL_ATTRIBUTE_GRID_1302
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_CELL_ATTRIBUTE_GRID_1302 .

  DATA : LT_CELLTAB TYPE LVC_T_STYL.
  DATA : LS_CELLTAB TYPE LVC_S_STYL.
  FIELD-SYMBOLS <LT_CELLTAB> TYPE ANY.
* Macro
  DEFINE __SET_CELL_ATTRIBUTE.
    CLEAR LS_CELLTAB.
    LS_CELLTAB-FIELDNAME = &1.
    LS_CELLTAB-STYLE = &2.
    INSERT LS_CELLTAB INTO TABLE LT_CELLTAB.
  END-OF-DEFINITION.


  LOOP AT GT_POPUP_1302 ASSIGNING FIELD-SYMBOL(<LS_MAIN>).
    CLEAR LS_CELLTAB.
    REFRESH LT_CELLTAB.

    __SET_CELL_ATTRIBUTE 'SEQNO_C'  ALV_STYLE_COLOR_INT_KEY.
    __SET_CELL_ATTRIBUTE 'PHASE_C'  ALV_STYLE_COLOR_INT_KEY.

    IF <LT_CELLTAB> IS ASSIGNED. UNASSIGN <LT_CELLTAB>. ENDIF.
    ASSIGN COMPONENT 'CELLTAB' OF STRUCTURE <LS_MAIN> TO <LT_CELLTAB>.
    IF <LT_CELLTAB> IS ASSIGNED.
      <LT_CELLTAB> = LT_CELLTAB.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SORTTAB_GRID_1302
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_SORTTAB_GRID_1302 .

  REFRESH GT_SORT_1302.

  PERFORM SET_SORT_TAB TABLES GT_SORT_1302
                            USING : 1 'SEQNO'  'X' '' '',
                                       2 'SEQNO_C' 'X' '' '',
                                       3 'ZTWSEQ' 'X' '' '',
                                       4 'PHASE_C' 'X' '' '',
                                       5 'MATNR' 'X' '' ''.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_GRID_1302_DISPLAY
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_GRID_1302_DISPLAY .

  CALL METHOD GO_GRID_1302->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT       = GS_LAYOUT_1302
    CHANGING
      IT_OUTTAB       = GT_POPUP_1302
      IT_SORT         = GT_SORT_1302
      IT_FIELDCATALOG = GT_FIELDCAT_1302.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_BEFORE_CRT_PO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_BEFORE_CRT_PO .

  DATA : LV_MESSAGE(100).
  DATA : LV_CHK_ERR.
  DATA : LV_STRING TYPE STRING.

*  공급업체 확인
  LOOP AT GT_POPUP_1300 INTO GS_POPUP_1300.
    IF GS_POPUP_1300-LIFNR IS INITIAL.
      LV_MESSAGE = '공급업체가 지정되지 않은 라인이 존재합니다.'(m01).
      LV_CHK_ERR = ABAP_TRUE.
      EXIT.
    ELSE.
* 공급업체 정보 확인
      SELECT DISTINCT A~MATNR, A~INFNR, A~LIFNR, C~NAME1
        FROM EINA AS A
        INNER JOIN EINE AS B ON B~INFNR = A~INFNR
        INNER JOIN LFA1 AS C ON C~LIFNR = A~LIFNR
      WHERE A~MATNR = @GS_POPUP_1300-MATNR
         AND A~LOEKZ = ''
         AND B~EKORG = @GS_EKORG-EKORG
         AND A~LIFNR = @GS_POPUP_1300-LIFNR
        INTO TABLE @DATA(LT_LIFNR).
      IF SY-SUBRC NE 0 OR LT_LIFNR[] IS INITIAL.
        LV_MESSAGE = '유효한 공급업체가 지정되지 않았습니다.'(m04).
        LV_CHK_ERR = ABAP_TRUE.
        EXIT.
      ENDIF.

    ENDIF.

    IF GS_POPUP_1300-LGFSB IS INITIAL.
      LV_MESSAGE = '구매 입고 저장위치를 입력해 주세요.'(m07).
      LV_CHK_ERR = ABAP_TRUE.
      EXIT.

    ENDIF.

    IF GS_POPUP_1300-EINDT IS INITIAL OR GS_POPUP_1300-EINDT = '00000000'.
      LV_MESSAGE = '납품예정일이 지정되지 않은 라인이 존재합니다.'(m02).
      LV_CHK_ERR = ABAP_TRUE.
      EXIT.
    ELSE.
      IF GS_POPUP_1300-EINDT < SY-DATUM.
        LV_MESSAGE = '납품예정일은 현재일보다 작을 수 없습니다.'(m03).
        LV_CHK_ERR = ABAP_TRUE.
        EXIT.
      ENDIF.
    ENDIF.

  ENDLOOP.

  IF LV_CHK_ERR = ABAP_TRUE.
    MESSAGE I003 WITH LV_MESSAGE.
    RETURN.
  ENDIF.

*  사급자재 관리
  LOOP AT GT_POPUP_1302 INTO GS_POPUP_1302.
    IF GS_POPUP_1302-MENGE <= 0.
      LV_MESSAGE = '유효한 사급자재 수량이 입력되지 않았습니다.'(m05).
      LV_CHK_ERR = ABAP_TRUE.
      EXIT.
    ENDIF.

    IF GS_POPUP_1302-MEINS IS INITIAL.
      LV_MESSAGE = '단위가 입력되지 않았습니다.'(m06).
      LV_CHK_ERR = ABAP_TRUE.
      EXIT.
    ENDIF.

  ENDLOOP.

  IF LV_CHK_ERR = ABAP_TRUE.
    MESSAGE I003 WITH LV_MESSAGE.
    RETURN.
  ENDIF.

  GV_CHK_CONFIRM_1300 = 'S'.

*     종료
  CALL METHOD GO_DOCKING_1300->FREE.
  FREE : GO_SPLITTER_1300, GO_SPLITTER_1300_UNDER, GO_CONTAIN_1300_UNDER,
           GO_CONTAIN_1300, GO_GRID_1300, GO_CONTAIN_1301,
           GO_GRID_1301, GO_CONTAIN_1302, GO_GRID_1302.

  CALL METHOD CL_GUI_CFW=>FLUSH.
  LEAVE TO SCREEN 0.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form MAKE_DATA_TO_SAVE04_1101
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_CREATE_ZWSEQ
*&      --> LS_2011
*&      --> <LS_MAIN_1102>
*&      <-- LS_2012
*&      <-- LV_CHK_ERR
*&---------------------------------------------------------------------*
FORM MAKE_DATA_TO_SAVE04_1101  USING    PV_ZWSEQ TYPE ZGTPPT2012-ZWSEQ
                                      PS_2011 TYPE ZGTPPT2011
                                      PS_MAIN LIKE GS_MAIN_DISP_1102
                               CHANGING PS_2012 TYPE ZGTPPT2012
                                      PV_CHK_ERR.

  READ TABLE GT_1101_MENGE INTO GS_1101_MENGE WITH KEY SEQNO = PS_MAIN-SEQNO
                                                                              ZWSEQ = PV_ZWSEQ.
  IF SY-SUBRC EQ 0.
    CLEAR PS_2012.
    IF PS_MAIN-SGRPNR IS NOT INITIAL.
      PS_2012-SGRPNR = PS_MAIN-SGRPNR.
    ENDIF.
    PS_2012-GONG_CD = 'BWD'.
    PS_2012-JOBTY = '2'.
    PS_2012-POSNR = 10.
    PS_2012-ORDTY = 'PO'.
    PS_2012-INLENGTH = GS_1101_MENGE-MENGE07.
    PS_2012-INFACTOR = 1.
    PS_2012-ZCAGE = PS_MAIN-LAYER.
    PS_2012-ZWSEQ = PV_ZWSEQ.
* 총차수
    IF PV_ZWSEQ > PS_MAIN-MENGE06.
      PS_2012-ZTWSEQ = PV_ZWSEQ.
    ELSE.
      PS_2012-ZTWSEQ = PS_MAIN-MENGE06.
    ENDIF.

    PS_2012-ZWSEQ = PV_ZWSEQ.

* 연입률 세팅
    PS_2012-YCOEF = PS_MAIN-YCOEF.

*    해당 정보로 생산오더 생성
    PERFORM CREATE_PO_ORDER_1100 USING PS_2012 PS_2011 PS_MAIN-SEQNO CHANGING PS_2012-ORDNR PV_CHK_ERR.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_PO_ORDER_1100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PS_2012
*&      --> PS_2011
*&      --> PS_MAIN_SEQNO
*&      <-- PS_2012_ORDNR
*&      <-- PV_CHK_ERR
*&---------------------------------------------------------------------*
FORM CREATE_PO_ORDER_1100  USING    PS_2012 TYPE ZGTPPT2012
                                    PS_2011 TYPE ZGTPPT2011
                                    PV_SEQNO TYPE I
                           CHANGING PV_ORDNR
                                    PV_CHK_ERR.

  DATA : LV_FIELDNAME TYPE FNAM_____4.
  DATA : LV_NUM(2) TYPE N.
  DATA : LV_POSNR(4) TYPE N.
  DATA : LV_POSNR2(4) TYPE N.
  DATA : LV_PSMNG_C(30) TYPE C.

  REFRESH : GT_BDCDATA, GT_MESSTAB.
  __SETTING_BDC_PARAMS.

* 메인정보 입력
  CLEAR GS_POPUP_1300.
  READ TABLE GT_POPUP_1300 INTO GS_POPUP_1300 WITH KEY SEQNO = PV_SEQNO.

  __BDC_DYNPRO 'SAPMM06E' '0100'.
  __BDC_FIELD : 'BDC_OKCODE' '/00',
                      'EKKO-LIFNR' GS_POPUP_1300-LIFNR,
                      'RM06E-BSART' 'NB',
                      'RM06E-BEDAT' GS_POPUP_1300-EINDT,
                      'EKKO-EKORG' GS_EKORG-EKORG,
                      'EKKO-EKGRP' GS_EKORG-EKGRP,
                      'RM06E-EPSTP' 'L',
                      'RM06E-EEIND' GS_POPUP_1300-EINDT,
                      'RM06E-LGORT' GS_POPUP_1300-LGFSB,
                      'RM06E-LPEIN' 'T',
                      'RM06E-WERKS' P_WERKS.

  __BDC_DYNPRO 'SAPMM06E' '0101'.
  __BDC_FIELD : 'BDC_OKCODE' '=AB',
                      'EKKO-EKGRP' GS_EKORG-EKGRP,
                      'EKKO-PINCR' '10',
                      'EKKO-SPRAS' 'KO'.

* 품목정보입력
  CLEAR GS_POPUP_1301.
  READ TABLE GT_POPUP_1301 INTO GS_POPUP_1301 WITH KEY SEQNO = PV_SEQNO
                                                                                 ZTWSEQ = PS_2012-ZWSEQ.

  LV_PSMNG_C = GS_POPUP_1301-MENGE.
  CONDENSE LV_PSMNG_C.

  __BDC_DYNPRO 'SAPMM06E' '0120'.
  __BDC_FIELD : 'BDC_OKCODE' '/00',
                      'EKPO-EMATN(01)' GS_POPUP_1300-MATNR,
                      'EKPO-MEINS(01)'  GS_POPUP_1301-MEINS,
                      'EKPO-MENGE(01)'  LV_PSMNG_C.

* 사급자재정보
  LV_POSNR = 10.
  __BDC_DYNPRO 'SAPMM06E' '0120'.
  __BDC_FIELD : 'BDC_OKCODE' '/00',
                      'RM06E-EBELP' LV_POSNR.

  __BDC_DYNPRO 'SAPMM06E' '0120'.
  __BDC_FIELD : 'BDC_OKCODE' '=LB',
                      'RM06E-EBELP' LV_POSNR.

  __BDC_DYNPRO 'SAPLM61Q' '0115'.
  __BDC_FIELD : 'BDC_OKCODE' '=MALL'.

  __BDC_DYNPRO 'SAPLM61Q' '0115'.
  __BDC_FIELD : 'BDC_OKCODE' '=DELE'.

  __BDC_DYNPRO 'SAPLM61Q' '0115'.
  __BDC_FIELD : 'BDC_OKCODE' '=POS1'.

  __BDC_DYNPRO 'SAPLM61Q' '0110'.
  __BDC_FIELD : 'BDC_OKCODE' '/00'.

  CLEAR LV_NUM.
  CLEAR LV_POSNR2.
  LOOP AT GT_POPUP_1302 INTO GS_POPUP_1302 WHERE SEQNO = PV_SEQNO
                                                                   AND ZTWSEQ = PS_2012-ZWSEQ.

    ADD 1 TO LV_NUM.
    ADD 10 TO LV_POSNR2.
*     자재코드
    CLEAR LV_FIELDNAME.
    LV_FIELDNAME = |MDPM-MATNR({ LV_NUM })|.
    __BDC_FIELD : LV_FIELDNAME GS_POPUP_1302-MATNR.
*     단위
    CLEAR LV_FIELDNAME.
    LV_FIELDNAME = |MDPM-ERFME({ LV_NUM })|.
    __BDC_FIELD : LV_FIELDNAME GS_POPUP_1302-MEINS.

*     플랜트
    CLEAR LV_FIELDNAME.
    LV_FIELDNAME = |MDPM-WERKS({ LV_NUM })|.
    __BDC_FIELD : LV_FIELDNAME P_WERKS.

*     구성부품 소요일

    CLEAR LV_FIELDNAME.
    LV_FIELDNAME = |MDPM-BDTER({ LV_NUM })|.
    __BDC_FIELD : LV_FIELDNAME GS_POPUP_1300-EINDT.

*     구성부품 품목
    CLEAR LV_FIELDNAME.
    LV_FIELDNAME = |MDPM-POSNR({ LV_NUM })|.
    __BDC_FIELD : LV_FIELDNAME LV_POSNR2.

*     수량
    CLEAR LV_FIELDNAME.
    LV_FIELDNAME = |MDPM-ERFMG({ LV_NUM })|.
    CLEAR LV_PSMNG_C.
    LV_PSMNG_C = GS_POPUP_1302-MENGE.
    CONDENSE LV_PSMNG_C.
    __BDC_FIELD : LV_FIELDNAME LV_PSMNG_C.

  ENDLOOP.

  __BDC_DYNPRO 'SAPMM06E' '0120'.
  __BDC_FIELD : 'BDC_OKCODE' '=BU'.

  __BDC_TRANSACTION 'ME21'.

  LOOP AT GT_MESSTAB INTO DATA(LS_MESSTAB) WHERE MSGTYP = 'S'
                                                         AND MSGID = '06'
                                                         AND MSGNR = '017'.

    PV_ORDNR = LS_MESSTAB-MSGV2.
  ENDLOOP.

  IF PV_ORDNR IS NOT INITIAL.
    APPEND INITIAL LINE TO GT_PO_ORDERS ASSIGNING FIELD-SYMBOL(<LS_PO_ORDERS>).
    <LS_PO_ORDERS>-EBELN = PV_ORDNR.
    <LS_PO_ORDERS>-EBELP = 10.
  ENDIF.

  READ TABLE GT_MESSTAB INTO LS_MESSTAB WITH KEY MSGTYP = 'E'.
  IF SY-SUBRC EQ 0.
    PV_CHK_ERR = ABAP_TRUE.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ALV_ONF4
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      --> E_FIELDNAME
*&      --> E_FIELDVALUE
*&      --> ES_ROW_NO
*&      --> ER_EVENT_DATA
*&      --> ET_BAD_CELLS
*&      --> E_DISPLAY
*&---------------------------------------------------------------------*
FORM ALV_ONF4  USING   PO_SENDER TYPE REF TO CL_GUI_ALV_GRID
                        PV_FIELDNAME TYPE LVC_FNAME
                        PV_FIELDVALUE TYPE LVC_VALUE
                        PS_ROW_NO  TYPE LVC_S_ROID
                        PR_EVENT_DATA TYPE REF TO CL_ALV_EVENT_DATA
                        PT_BAD_CELLS TYPE LVC_T_MODI
                        PV_DISPLAY TYPE CHAR01.

  FIELD-SYMBOLS : <LT_DATA> TYPE TABLE.
  FIELD-SYMBOLS : <LV_VALUE> TYPE ANY.


  CASE PO_SENDER.
    WHEN GO_GRID_1300.
      CASE PV_FIELDNAME.
        WHEN 'LIFNR'.
          PERFORM F4_LIFNR USING PV_FIELDNAME PS_ROW_NO
                                   CHANGING PV_FIELDVALUE.

          PR_EVENT_DATA->M_EVENT_HANDLED = 'X'.   "스탠다드 F4는 무시
          IF PV_FIELDVALUE IS INITIAL.
            RETURN.
          ENDIF.

          ASSIGN PR_EVENT_DATA->M_DATA->* TO <LT_DATA>.
          APPEND INITIAL LINE TO <LT_DATA> ASSIGNING FIELD-SYMBOL(<FS_F4>).
          IF <LV_VALUE> IS ASSIGNED. UNASSIGN <LV_VALUE>. ENDIF.
          ASSIGN COMPONENT 'ROW_ID' OF STRUCTURE <FS_F4> TO <LV_VALUE>.
          IF <LV_VALUE> IS ASSIGNED.
            <LV_VALUE> = PS_ROW_NO-ROW_ID.
          ENDIF.
          IF <LV_VALUE> IS ASSIGNED. UNASSIGN <LV_VALUE>. ENDIF.
          ASSIGN COMPONENT 'FIELDNAME' OF STRUCTURE <FS_F4> TO <LV_VALUE>.
          IF <LV_VALUE> IS ASSIGNED.
            <LV_VALUE> = PV_FIELDNAME.
          ENDIF.
          IF <LV_VALUE> IS ASSIGNED. UNASSIGN <LV_VALUE>. ENDIF.
          ASSIGN COMPONENT 'VALUE' OF STRUCTURE <FS_F4> TO <LV_VALUE>.
          IF <LV_VALUE> IS ASSIGNED.
            <LV_VALUE> = PV_FIELDVALUE.
          ENDIF.

      ENDCASE.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_LIFNR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PV_FIELDNAME
*&      <-- PV_FIELDVALUE
*&---------------------------------------------------------------------*
FORM F4_LIFNR  USING   PV_FIELDNAME TYPE LVC_FNAME
                             PS_ROW_NO  TYPE LVC_S_ROID
               CHANGING PV_FIELDVALUE TYPE LVC_VALUE.

  DATA : BEGIN OF LS_TABLE,
           LIFNR TYPE LFA1-LIFNR,
           NAME1 TYPE LFA1-NAME1,
         END OF LS_TABLE.
  DATA : LT_TABLE LIKE TABLE OF LS_TABLE.
  DATA : LV_FIELDNAME TYPE  LVC_FNAME.

  DATA : LT_RETURN_TAB TYPE TABLE OF DDSHRETVAL,
         LS_RETURN_TAB LIKE LINE OF LT_RETURN_TAB.

  READ TABLE GT_POPUP_1300 INTO DATA(LS_MAIN) INDEX PS_ROW_NO-ROW_ID.
  CHECK SY-SUBRC EQ 0.

* 공급업체 정보 추출
  SELECT DISTINCT A~LIFNR, C~NAME1
    FROM EINA AS A
    INNER JOIN EINE AS B ON B~INFNR = A~INFNR
    INNER JOIN LFA1 AS C ON C~LIFNR = A~LIFNR
  WHERE A~MATNR = @LS_MAIN-MATNR
     AND A~LOEKZ = ''
     AND B~EKORG = @GS_EKORG-EKORG
    INTO CORRESPONDING FIELDS OF TABLE @LT_TABLE.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'  "F4 창 띄움
    EXPORTING
      RETFIELD        = PV_FIELDNAME
*     DYNPPROG        = SY-CPROG                 "현재 프로그램명->ZTER0010
*     DYNPNR          = SY-DYNNR                 "현재 화면번호->0100
      DYNPROFIELD     = 'LIFNR'           "F4누른 필드->DEPT_CD
      VALUE_ORG       = 'S'                      "가져오는 엔트리가 다수일 경우인 것 같음. 다수일 경우 C로 하면 F4 안뜸
      WINDOW_TITLE    = '공급업체조회'   "Search Help 타이틀
      DISPLAY         = 'F'
    TABLES
      VALUE_TAB       = LT_TABLE                  "부서코드, 부서명 가져온 인터널 테이블
      RETURN_TAB      = LT_RETURN_TAB            "F4에서 선택한 값이 들어옴
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  READ TABLE LT_RETURN_TAB INTO LS_RETURN_TAB INDEX 1.
  PV_FIELDVALUE = LS_RETURN_TAB-FIELDVAL.   "F4에서 선택한 값을 다시 넣어줌

ENDFORM.
*&---------------------------------------------------------------------*
*& Form VALIDATION_LIFNR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_MOD_CELLS_VALUE
*&      <-- LV_CHK_ERR
*&      <-- LV_NAME1
*&---------------------------------------------------------------------*
FORM VALIDATION_LIFNR  USING    PV_MATNR TYPE MATNR
                                PV_VALUE
                       CHANGING PV_CHK_ERR
                                PV_NAME1 TYPE LFA1-NAME1.

  DATA : LV_LIFNR TYPE LFA1-NAME1.

  LV_LIFNR = PV_VALUE.
  __ALPHA_INPUT LV_LIFNR.

* 공급업체 정보 확인
  SELECT DISTINCT A~MATNR, A~INFNR, A~LIFNR, C~NAME1
    FROM EINA AS A
    INNER JOIN EINE AS B ON B~INFNR = A~INFNR
    INNER JOIN LFA1 AS C ON C~LIFNR = A~LIFNR
  WHERE A~MATNR = @PV_MATNR
     AND A~LOEKZ = ''
     AND B~EKORG = @GS_EKORG-EKORG
     AND A~LIFNR = @LV_LIFNR
    INTO TABLE @DATA(LT_LIFNR).

  IF SY-SUBRC EQ 0 AND LT_LIFNR IS NOT INITIAL.
    READ TABLE LT_LIFNR INTO DATA(LS_LIFNR) WITH KEY LIFNR = LV_LIFNR.
    PV_NAME1 = LS_LIFNR-NAME1.

  ELSE.
    PV_CHK_ERR = ABAP_TRUE.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_DROPDOWN_GRID_1102
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_DROPDOWN_GRID_1102 .

  DATA: LT_DRAL TYPE LVC_T_DRAL,                            "#EC NEEDED
        LS_DRAL TYPE LVC_S_DRAL.                            "#EC NEEDED

  LOOP AT GT_BOBIN INTO DATA(LS_BOBIN).

    LS_DRAL-HANDLE = '1'.
    LS_DRAL-INT_VALUE = ''.
    LS_DRAL-VALUE = LS_BOBIN-FLD_02.
    APPEND LS_DRAL TO LT_DRAL.

  ENDLOOP.

  GO_GRID_1102->SET_DROP_DOWN_TABLE(
    IT_DROP_DOWN_ALIAS = LT_DRAL ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHANGE_ITAB_1102
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHANGE_ITAB_1102 .

  DATA : LV_CAL01 TYPE P LENGTH 16 DECIMALS 5, "외경
         LV_CAL02 TYPE P LENGTH 16 DECIMALS 5, " 점적률
         LV_CAL03 TYPE P LENGTH 16 DECIMALS 5, " 유효권취
         LV_CAL04 TYPE P LENGTH 16 DECIMALS 5, " 실제권취
         LV_CAL05 TYPE P LENGTH 16 DECIMALS 5. " 기준권취량
  CONSTANTS : LC_CON01 TYPE P LENGTH 16 DECIMALS 14 VALUE '3.14159265358979'. "보빈동경

  LOOP AT GT_MAIN_DISP_1102 ASSIGNING FIELD-SYMBOL(<LS_MAIN>) WHERE SGRPNR IS INITIAL..

    READ TABLE GT_BOBIN INTO DATA(LS_BOBIN) WITH KEY FLD_02 = <LS_MAIN>-MENGE02.

* 작업량
    <LS_MAIN>-MENGE04 = <LS_MAIN>-MENGE01 * <LS_MAIN>-YCOEF
*    <LS_MAIN>-MENGE04 = <LS_MAIN>-MENGE01 * <LS_MAIN>-LAYER * <LS_MAIN>-YCOEF
                                  + <LS_MAIN>-MENGE03.

* 기준권취량(신선의 소선 정보 계산식 동일)
    SELECT SINGLE BASE_WD FROM ZGTPPT2260
      INTO @DATA(LV_BASE_WD)
     WHERE SOSUN_DIA = @<LS_MAIN>-SOSUN_DIA.
    IF SY-SUBRC EQ 0 AND LV_BASE_WD IS NOT INITIAL.
      <LS_MAIN>-MENGE05 = LV_BASE_WD.
    ELSE. " 관리테이블에 없으면 계산

* ① 외경 = 보빈 내폭 / 소선경
      LV_CAL01 = LS_BOBIN-FLD_04 / <LS_MAIN>-SOSUN_DIA.

* ② 점적률 = ROUND(INT(외경-1)/외경,4), 소수점 4자리 반올림
      LV_CAL02 = ( LV_CAL01 - 1 ) / LV_CAL01.
      PERFORM CONV_ROUND USING '0.01' CHANGING LV_CAL02.

* ③ 유효권취 = ((악경 - 2 * 15) - 보빈동경) / 2 / 소선경
      LV_CAL03 = ( ( LS_BOBIN-FLD_02 - 30 ) - LS_BOBIN-FLD_03 ) / 2 / <LS_MAIN>-SOSUN_DIA.

* ④ 실제권취 = INT(유효 권취 + 0.99) -1, 소수점 버림
      LV_CAL04 = ( LV_CAL03 + '0.99' ).
      PERFORM CONV_TRUNCATE USING 1 CHANGING LV_CAL04.
      LV_CAL04 = LV_CAL04 - 1.

* ⑤ 기준권취량 = ROUND(원주율 * 보빈내폭 * 점적율 * 실제권취 * (실제권취 * 소선경 + 보빈동경) / 소선경 / 1000,0)
      LV_CAL05 =  LC_CON01 * LS_BOBIN-FLD_04 * LV_CAL02 * LV_CAL04 *
                      ( LV_CAL04 * <LS_MAIN>-SOSUN_DIA + LS_BOBIN-FLD_03 ) / <LS_MAIN>-SOSUN_DIA / 1000.
      PERFORM CONV_ROUND USING 1 CHANGING LV_CAL05.

      <LS_MAIN>-MENGE05 = LV_CAL05.

    ENDIF.
* 권취개수
    <LS_MAIN>-MENGE06 = <LS_MAIN>-MENGE04 / <LS_MAIN>-MENGE05.
    PERFORM CONV_UPPPER_ROUND USING 1 CHANGING <LS_MAIN>-MENGE06.

* 실권취량
    <LS_MAIN>-MENGE07 = <LS_MAIN>-MENGE04 / <LS_MAIN>-MENGE06.
* 올림처리
    PERFORM CONV_UPPPER_ROUND USING 1 CHANGING <LS_MAIN>-MENGE07.
* 작업지시량
    <LS_MAIN>-MENGE08 = <LS_MAIN>-MENGE07 * <LS_MAIN>-MENGE06.
* 올림처리
    PERFORM CONV_UPPPER_ROUND USING 1 CHANGING <LS_MAIN>-MENGE08.

    <LS_MAIN>-CURRENT_ZWSEQ = <LS_MAIN>-MENGE06.
    <LS_MAIN>-INPUT_ZWSEQ = <LS_MAIN>-CURRENT_ZWSEQ.
  ENDLOOP.

  DATA(LT_CHK_MAXSEQ) = GT_MAIN_DISP_1102.
  DATA : LV_ZTWSEQ TYPE ZGTPPT2012-ZTWSEQ.

  SORT LT_CHK_MAXSEQ BY MENGE06 DESCENDING.
  READ TABLE LT_CHK_MAXSEQ INTO DATA(LS_CHK_MAXSEQ) INDEX 1.
  CLEAR GV_MAX_ZTWSEQ.
  GV_MAX_ZTWSEQ = LS_CHK_MAXSEQ-MENGE06.

  LOOP AT GT_MAIN_DISP_1102 ASSIGNING <LS_MAIN> WHERE SGRPNR IS INITIAL..

    CLEAR LV_ZTWSEQ.
    DO <LS_MAIN>-INPUT_ZWSEQ TIMES.
      ADD 1 TO LV_ZTWSEQ.
      READ TABLE GT_1101_MENGE ASSIGNING FIELD-SYMBOL(<LS_MENGE>) WITH KEY SEQNO =  <LS_MAIN>-SEQNO
                                                                                                       ZWSEQ = LV_ZTWSEQ.
      IF SY-SUBRC NE 0.
        APPEND INITIAL LINE TO  GT_1101_MENGE ASSIGNING <LS_MENGE>.
        <LS_MENGE>-SEQNO = <LS_MAIN>-SEQNO.
        <LS_MENGE>-MATNR_O = <LS_MAIN>-MATNR_O.
        <LS_MENGE>-SGRPNR = <LS_MAIN>-SGRPNR.
        <LS_MENGE>-ZWSEQ = LV_ZTWSEQ.
        IF <LS_MAIN>-MENGE06 >= LV_ZTWSEQ.
          <LS_MENGE>-MENGE07 = <LS_MAIN>-MENGE07.
        ELSE.
          <LS_MENGE>-MENGE07 = 0.
        ENDIF.
      ELSE.
        IF <LS_MAIN>-MENGE06 >= LV_ZTWSEQ.
          <LS_MENGE>-MENGE07 = <LS_MAIN>-MENGE07.
        ENDIF.

      ENDIF.
    ENDDO.

    DELETE GT_1101_MENGE WHERE SEQNO =  <LS_MAIN>-SEQNO
                                      AND  ZWSEQ > <LS_MAIN>-INPUT_ZWSEQ.


  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_ORDNO_BWD_GAGONG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <LS_MAIN>
*&      <-- LV_CHK
*&---------------------------------------------------------------------*
FORM CHECK_ORDNO_BWD_GAGONG  USING    PS_MAIN LIKE GS_MAIN_DISP
                        CHANGING PV_CHK.

  DATA : LT_AUFNR TYPE RANGE OF AUFNR.
  DATA : LT_2013 TYPE TABLE OF ZGTPPT2013.

  LT_2013 = VALUE #( FOR LW_2013 IN GT_2013 WHERE ( GRPNR = PS_MAIN-GRPNR )
                            ( CORRESPONDING #( LW_2013 ) ) ).
  IF LT_2013[] IS INITIAL. " 조장번호 대상이 없으면 소선지시 미존재
    RETURN.
  ELSE.
    READ TABLE LT_2013 INTO DATA(LS_2013) INDEX 1.

    LT_AUFNR = VALUE #( FOR LW_2012 IN GT_2012 WHERE ( SGRPNR = LS_2013-SGRPNR
                                                                       AND   JOBTY = '1' )
                                ( SIGN = 'I' OPTION = 'EQ' LOW = LW_2012-ORDNR ) ).
    IF LT_AUFNR[] IS NOT INITIAL.
      PV_CHK = ABAP_TRUE.
    ELSE.
      RETURN.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SENG_LOG_BWD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SENG_LOG_BWD .

  CHECK GT_ZZBUNDLE IS NOT INITIAL.

  DATA : LV_JOBNAME  TYPE TBTCJOB-JOBNAME VALUE 'ZGTPPI2040',
         LV_JOBNAME2 TYPE TBTCJOB-JOBNAME,
         LV_JOBCOUNT TYPE TBTCJOB-JOBCOUNT,
         LV_RELEASED TYPE  BTCH0000-CHAR1,
         LV_UZEIT    TYPE SY-UZEIT.
  DATA : LV_TARGET TYPE ZGTPPT1070-ZSYSTEM_ID.
  DATA : LT_ERDAT TYPE RANGE OF AUFK-ERDAT.

  CLEAR : LV_JOBNAME2, LV_JOBCOUNT, LV_RELEASED, LV_UZEIT.

  CLEAR LV_JOBNAME2.
  CONCATENATE LV_JOBNAME '_' SY-DATUM '_' SY-UZEIT INTO LV_JOBNAME2.

  SELECT SINGLE * FROM ZGTPPT1010
    INTO @DATA(LS_1010)
   WHERE MODULE_KIND = 'PP'
      AND CODEGRP = '0010'
      AND FLD_03 = @P_WERKS.

  LV_TARGET = LS_1010-FLD_01.

  CHECK LV_TARGET IS NOT INITIAL.

  CLEAR LV_JOBCOUNT.
  DO.
    CALL FUNCTION 'JOB_OPEN'
      EXPORTING
        JOBNAME          = LV_JOBNAME2
      IMPORTING
        JOBCOUNT         = LV_JOBCOUNT
      EXCEPTIONS
        CANT_CREATE_JOB  = 1
        INVALID_JOB_DATA = 2
        JOBNAME_MISSING  = 3
        OTHERS           = 4.
    IF SY-SUBRC = 0.
      EXIT.
    ENDIF.
  ENDDO.

* 대상 MES 전송
  SUBMIT ZGTPPI2040 VIA JOB LV_JOBNAME2
                             NUMBER LV_JOBCOUNT
                             WITH P_TARGET EQ LV_TARGET
                             WITH S_BUNDL IN GT_ZZBUNDLE
                             WITH S_ERDAT IN LT_ERDAT
                             WITH P_SEND EQ ABAP_TRUE
                             WITH P_BATCH EQ 'X'
                             AND RETURN.

*  DATA: sv_uzeit  LIKE sy-uzeit.
  CLEAR LV_UZEIT.
  LV_UZEIT = SY-UZEIT + 10.
  CALL FUNCTION 'JOB_CLOSE'
    EXPORTING
      JOBCOUNT             = LV_JOBCOUNT
      JOBNAME              = LV_JOBNAME2
      SDLSTRTDT            = SY-DATUM
      SDLSTRTTM            = LV_UZEIT
      STRTIMMED            = 'X'  "즉시 기동
    IMPORTING
      JOB_WAS_RELEASED     = LV_RELEASED
    EXCEPTIONS
      CANT_START_IMMEDIATE = 1
      INVALID_STARTDATE    = 2
      JOBNAME_MISSING      = 3
      JOB_CLOSE_FAILED     = 4
      JOB_NOSTEPS          = 5
      JOB_NOTEX            = 6
      LOCK_FAILED          = 7
      OTHERS               = 8.
  IF SY-SUBRC <> 0.
* MESSAGE ID SY-MSGID TYPE SY-MSGTY NUMBER SY-MSGNO
*         WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_SOSUN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_CHECKED_SOSUN
*&      --> LT_CHECKING_SOSUN
*&      <-- LV_ERR_CODE
*&---------------------------------------------------------------------*
FORM CHK_SOSUN  TABLES   PT_CHECKED_SOSUN STRUCTURE GS_CHK_SOSUN
                         PT_CHECKING_SOSUN STRUCTURE GS_CHK_SOSUN
                CHANGING PV_CHK_ERR.

  DATA : LT_CHKECK_SOSUN LIKE TABLE OF GS_CHK_SOSUN.
  DATA : LS_SOSUN_REPLACE LIKE GS_SOSUN_REPLACE.
  DATA : LT_SORT_REPLACE LIKE TABLE OF GS_SOSUN_REPLACE.
  DATA : LT_SOSUN_REPLACE2 LIKE TABLE OF GS_SOSUN_REPLACE.
  DATA : BEGIN OF LS_0051,
           BONSU     TYPE ZGTEDT0051G-BONSU,
           JAEJIL    TYPE ZGTEDT0051G-JAEJIL,
           SOSUN_DIA TYPE ZGTEDT0051G-SOSUN_DIA,
           YCOEF     TYPE ZGTEDT0051G-YCOEF,
         END OF LS_0051.
  DATA : LT_0051_ORIGN LIKE TABLE OF LS_0051.
  DATA : LT_0051_CHK LIKE TABLE OF LS_0051.

  LT_CHKECK_SOSUN = PT_CHECKING_SOSUN[].

* 소선 정보 일치 점검.

  IF GT_SOSUN_REPLACE[] IS NOT INITIAL.

    LT_SORT_REPLACE = GT_SOSUN_REPLACE.
    LT_SOSUN_REPLACE2 = GT_SOSUN_REPLACE.

    SORT LT_SORT_REPLACE BY TOBE.
    DELETE ADJACENT DUPLICATES FROM LT_SORT_REPLACE COMPARING TOBE.


    LOOP AT LT_SORT_REPLACE INTO DATA(LS_ORIGN_REPLACE).

      REFRESH LT_0051_ORIGN.

      LOOP AT LT_CHKECK_SOSUN INTO DATA(LS_SOSUN_CHK).
        READ TABLE GT_SOSUN_REPLACE TRANSPORTING NO FIELDS WITH KEY SOSUNCD =  LS_SOSUN_CHK-SOSUNCD.
        IF SY-SUBRC EQ 0. " 기존 소선대체 테이블에 저장되어 있을경우 체크 필요없음
          DELETE LT_CHKECK_SOSUN.
          CONTINUE.
        ELSE.

          IF LT_0051_ORIGN IS INITIAL.
            SELECT BONSU, JAEJIL, SOSUN_DIA, YCOEF FROM ZGTEDT0051G
              INTO TABLE @LT_0051_ORIGN
             WHERE SOSUNCD = @LS_ORIGN_REPLACE-TOBE.

            SORT LT_0051_ORIGN BY BONSU.
          ENDIF.

          REFRESH LT_0051_CHK.
          SELECT BONSU, JAEJIL, SOSUN_DIA, YCOEF FROM ZGTEDT0051G
            INTO TABLE @LT_0051_CHK
           WHERE SOSUNCD = @LS_SOSUN_CHK-SOSUNCD.

          SORT LT_0051_CHK BY BONSU.

* 조회된 소선 정보가 같다면 전환테이블에 업로드후 종료
          IF LT_0051_ORIGN[] = LT_0051_CHK[].
            CLEAR LS_SOSUN_REPLACE.
            LS_SOSUN_REPLACE-SOSUNCD = LS_SOSUN_CHK-SOSUNCD.
            LS_SOSUN_REPLACE-TOBE = LS_ORIGN_REPLACE-TOBE.
            APPEND LS_SOSUN_REPLACE TO LT_SOSUN_REPLACE2.

            DELETE LT_CHKECK_SOSUN.
            CONTINUE.
          ENDIF.
        ENDIF.
      ENDLOOP.

    ENDLOOP.

    IF LT_CHKECK_SOSUN IS NOT INITIAL.
      PV_CHK_ERR = ABAP_TRUE.
      RETURN.
    ELSE.
      REFRESH GT_SOSUN_REPLACE.
      GT_SOSUN_REPLACE = LT_SOSUN_REPLACE2.

* 가장작은 소선번호로 대표 번호 설정
      SORT LT_SOSUN_REPLACE2 BY TOBE SOSUNCD.
      DELETE ADJACENT DUPLICATES FROM LT_SOSUN_REPLACE2 COMPARING TOBE.
      LOOP AT LT_SOSUN_REPLACE2 INTO DATA(LS_MODI).
        LOOP AT GT_SOSUN_REPLACE ASSIGNING FIELD-SYMBOL(<LS_MODI>) WHERE TOBE = LS_MODI-TOBE.
          <LS_MODI>-TOBE = LS_MODI-SOSUNCD.
        ENDLOOP.
      ENDLOOP.

    ENDIF.
  ELSE.
    LOOP AT PT_CHECKED_SOSUN.
      LOOP AT LT_CHKECK_SOSUN INTO LS_SOSUN_CHK.

        REFRESH LT_0051_ORIGN.

        IF PT_CHECKED_SOSUN-SOSUNCD = LS_SOSUN_CHK-SOSUNCD.

          CLEAR LS_SOSUN_REPLACE.
          LS_SOSUN_REPLACE-SOSUNCD = LS_SOSUN_CHK-SOSUNCD.
          LS_SOSUN_REPLACE-TOBE = LS_SOSUN_CHK-SOSUNCD.
          APPEND LS_SOSUN_REPLACE TO LT_SOSUN_REPLACE2.

          DELETE LT_CHKECK_SOSUN.
          CONTINUE.
        ELSE.
          IF LT_0051_ORIGN IS INITIAL.
            SELECT BONSU, JAEJIL, SOSUN_DIA, YCOEF FROM ZGTEDT0051G
              INTO TABLE @LT_0051_ORIGN
             WHERE SOSUNCD = @PT_CHECKED_SOSUN-SOSUNCD.

            SORT LT_0051_ORIGN BY BONSU.
          ENDIF.

          REFRESH LT_0051_CHK.
          SELECT BONSU, JAEJIL, SOSUN_DIA, YCOEF FROM ZGTEDT0051G
            INTO TABLE @LT_0051_CHK
           WHERE SOSUNCD = @LS_SOSUN_CHK-SOSUNCD.

          SORT LT_0051_CHK BY BONSU.

* 조회된 소선 정보가 같다면 전환테이블에 업로드후 종료
          IF LT_0051_ORIGN[] = LT_0051_CHK[].

            CLEAR LS_SOSUN_REPLACE.
            LS_SOSUN_REPLACE-SOSUNCD = LS_SOSUN_CHK-SOSUNCD.
            LS_SOSUN_REPLACE-TOBE = PT_CHECKED_SOSUN-SOSUNCD.
            APPEND LS_SOSUN_REPLACE TO LT_SOSUN_REPLACE2.

            DELETE LT_CHKECK_SOSUN.
            CONTINUE.
          ENDIF.
        ENDIF.

      ENDLOOP.
    ENDLOOP.

    IF LT_CHKECK_SOSUN IS NOT INITIAL.
      PV_CHK_ERR = ABAP_TRUE.
      RETURN.
    ELSE.
      REFRESH GT_SOSUN_REPLACE.
      GT_SOSUN_REPLACE = LT_SOSUN_REPLACE2.

* 가장작은 소선번호로 대표 번호 설정
      SORT LT_SOSUN_REPLACE2 BY TOBE SOSUNCD.
      DELETE ADJACENT DUPLICATES FROM LT_SOSUN_REPLACE2 COMPARING TOBE.
      LOOP AT LT_SOSUN_REPLACE2 INTO LS_MODI.
        LOOP AT GT_SOSUN_REPLACE ASSIGNING <LS_MODI> WHERE TOBE = LS_MODI-TOBE.
          <LS_MODI>-TOBE = LS_MODI-SOSUNCD.
        ENDLOOP.
      ENDLOOP.

    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SOSUN_REPLACE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_SOSUN_REPLACE .

  DATA : LS_SOSUN_REPLACE LIKE GS_SOSUN_REPLACE.
  DATA : LT_SOSUN_REPLACE LIKE TABLE OF GS_SOSUN_REPLACE.

  REFRESH GT_SOSUN_REPLACE.

* 소선정보는 1번과 2번에 세팅되어 있다 1번먼저 확인
  LOOP AT GT_MAIN_DISP INTO DATA(LS_MAIN) WHERE CHECK = ABAP_TRUE.
    CLEAR LS_SOSUN_REPLACE.
    LS_SOSUN_REPLACE-SOSUNCD = LS_MAIN-SOSUNCD1.
    COLLECT LS_SOSUN_REPLACE INTO LT_SOSUN_REPLACE.
  ENDLOOP.

  SORT LT_SOSUN_REPLACE BY SOSUNCD.
  DELETE ADJACENT DUPLICATES FROM LT_SOSUN_REPLACE COMPARING SOSUNCD.

  READ TABLE LT_SOSUN_REPLACE INTO LS_SOSUN_REPLACE INDEX 1.
  LOOP AT LT_SOSUN_REPLACE ASSIGNING FIELD-SYMBOL(<LS_MODI>).
    <LS_MODI>-TOBE = LS_SOSUN_REPLACE-SOSUNCD.
  ENDLOOP.

  IF LT_SOSUN_REPLACE[] IS NOT INITIAL.
    APPEND LINES OF LT_SOSUN_REPLACE TO GT_SOSUN_REPLACE.
  ENDIF.


* 2번소선정보 확인
  REFRESH LT_SOSUN_REPLACE.
  LOOP AT GT_MAIN_DISP INTO LS_MAIN WHERE CHECK = ABAP_TRUE.
    CLEAR LS_SOSUN_REPLACE.
    LS_SOSUN_REPLACE-SOSUNCD = LS_MAIN-SOSUNCD2.
    COLLECT LS_SOSUN_REPLACE INTO LT_SOSUN_REPLACE.
  ENDLOOP.

  CHECK LT_SOSUN_REPLACE IS NOT INITIAL.
  SORT LT_SOSUN_REPLACE BY SOSUNCD.
  DELETE ADJACENT DUPLICATES FROM LT_SOSUN_REPLACE COMPARING SOSUNCD.

  READ TABLE LT_SOSUN_REPLACE INTO LS_SOSUN_REPLACE INDEX 1.
  LOOP AT LT_SOSUN_REPLACE ASSIGNING <LS_MODI>.
    <LS_MODI>-TOBE = LS_SOSUN_REPLACE-SOSUNCD.
  ENDLOOP.

  IF LT_SOSUN_REPLACE[] IS NOT INITIAL.
    APPEND LINES OF LT_SOSUN_REPLACE TO GT_SOSUN_REPLACE.
  ENDIF.


ENDFORM.
