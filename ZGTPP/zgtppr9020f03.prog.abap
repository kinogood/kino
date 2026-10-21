*&---------------------------------------------------------------------*
*&  Include           ZPPR1000F03                                      *
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  SELECT_matdoc_N_T0149
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TEMP1_WERKS  text
*      -->P_TEMP1_MATNR  text
*      -->P_TEMP1_LGORT  text
*      -->P_TEMP1_CHARG  text
*----------------------------------------------------------------------*
FORM SELECT_MATDOC_N_T0149  USING    P_WERKS
                                    P_MATNR
                                    P_LGORT
                                    P_CHARG.
  DATA : LT_MATDOC   LIKE TEMP_MATDOC OCCURS 0 WITH HEADER LINE.
  "matdoc 조회

  DATA : LV_WERKS TYPE  WERKS,
         LV_SUM   LIKE  MATDOC-MENGE.
  DATA:  LV_CHK     TYPE C.

  CLEAR : LV_WERKS.

  IF STRLEN( TEMP_ACT-LGORT ) <= 4.   "사내 일 경우
*20250618
    IF P_MATNR EQ '000000000002163193' OR
       P_MATNR EQ '000000000002163194' OR
       P_MATNR EQ '000000000002163195'.
        SELECT WERKS    "플랜트
               MATNR    "자재번호
               CHARG    "배치번호
               BUDAT    "전기일
               MENGE    "전기수량(=체류일수량)
               MEINS    "단위
               MBLNR    "자재문서번호
               ZEILE
               BWART    "이동유형
               EBELN
               UMWRK
        INTO CORRESPONDING FIELDS OF TABLE TEMP_MATDOC
          FROM MATDOC
         WHERE BUDAT <= P_DATE
           AND WERKS = P_WERKS
           AND MATNR = P_MATNR
           AND CHARG = P_CHARG
           AND ( BWART IN ('131', '501', '511', '521', '561',
*-{기능개선_194560 161제외, 459,455,457 추가
                          '459', '455', '457', '657') OR
*                           '122', '161', '657') OR
               ( BWART IN ('309','903', '301', '453', '413') AND SHKZG = 'S')
               OR
               ( BWART = '101' AND SOBKZ NE 'O') )
           AND SMBLN = SPACE
           %_HINTS ORACLE 'INDEX("matdoc" "matdoc~Z03")'.

    ELSE.
*20250618
        SELECT WERKS    "플랜트
               MATNR    "자재번호
               CHARG    "배치번호
               BUDAT    "전기일
               MENGE    "전기수량(=체류일수량)
               MEINS    "단위
               MBLNR    "자재문서번호
               ZEILE
               BWART    "이동유형
               EBELN
               UMWRK
        INTO CORRESPONDING FIELDS OF TABLE TEMP_MATDOC
          FROM MATDOC
         WHERE BUDAT <= P_DATE
           AND WERKS = P_WERKS
           AND MATNR = P_MATNR
           AND CHARG = P_CHARG
           AND ( BWART IN ('131', '501', '511', '521', '561',
*-{기능개선_194560 161제외, 459,455,457 추가
                          '459', '455', '457', '657') OR
*                           '122', '161', '657') OR
               ( BWART IN ('309','903', '301', '453') AND SHKZG = 'S')
               OR
               ( BWART = '101' AND SOBKZ NE 'O') )
           AND SMBLN = SPACE
           %_HINTS ORACLE 'INDEX("matdoc" "matdoc~Z03")'.

    ENDIF.                                                  "20250618

    IF TEMP_MATDOC[] IS INITIAL.  "없을 경우 werks 조건 제외
*20250618
      IF P_MATNR EQ '000000000002163193' OR
         P_MATNR EQ '000000000002163194' OR
         P_MATNR EQ '000000000002163195'.
        SELECT WERKS    "플랜트
               MATNR    "자재번호
               CHARG    "배치번호
               BUDAT    "전기일
               MENGE    "전기수량(=체류일수량)
               MEINS    "단위
               MBLNR    "자재문서번호
               ZEILE
               BWART    "이동유형
               EBELN
               UMWRK
        INTO CORRESPONDING FIELDS OF TABLE TEMP_MATDOC
          FROM MATDOC
         WHERE BUDAT <= P_DATE
           AND MATNR = P_MATNR
           AND CHARG = P_CHARG
           AND ( BWART IN ('131', '501', '511', '521', '561',
*-{기능개선_194560 161제외, 459,455,457 추가
                        '459', '455', '457', '657') OR
*                           '122', '161', '657') OR
             ( BWART IN ('309','903', '301', '453', '413') AND SHKZG = 'S')
             OR
             ( BWART = '101' AND SOBKZ NE 'O') )
           AND SMBLN = SPACE
           %_HINTS ORACLE 'INDEX("matdoc" "matdoc~Z03")'.

      ELSE.
*20250618
        SELECT WERKS    "플랜트
               MATNR    "자재번호
               CHARG    "배치번호
               BUDAT    "전기일
               MENGE    "전기수량(=체류일수량)
               MEINS    "단위
               MBLNR    "자재문서번호
               ZEILE
               BWART    "이동유형
               EBELN
               UMWRK
        INTO CORRESPONDING FIELDS OF TABLE TEMP_MATDOC
          FROM MATDOC
         WHERE BUDAT <= P_DATE
           AND MATNR = P_MATNR
           AND CHARG = P_CHARG
           AND ( BWART IN ('131', '501', '511', '521', '561',
*-{기능개선_194560 161제외, 459,455,457 추가
                        '459', '455', '457', '657') OR
*                           '122', '161', '657') OR
             ( BWART IN ('309','903', '301', '453') AND SHKZG = 'S')
             OR
             ( BWART = '101' AND SOBKZ NE 'O') )
           AND SMBLN = SPACE
           %_HINTS ORACLE 'INDEX("matdoc" "matdoc~Z03")'.

      ENDIF.                                                "20250618

    ENDIF.

  ELSE.   "외주 일 경우

    SELECT WERKS    "플랜트
           MATNR    "자재번호
           CHARG    "배치번호
           BUDAT    "전기일
           MENGE    "전기수량(=체류일수량)
           MEINS    "단위
           MBLNR    "자재문서번호
           ZEILE
           BWART    "이동유형
    INTO CORRESPONDING FIELDS OF TABLE TEMP_MATDOC
      FROM MATDOC
     WHERE BUDAT <= P_DATE
       AND WERKS = P_WERKS
       AND MATNR = P_MATNR
       AND CHARG = P_CHARG
       AND SHKZG = 'S'
       AND BWART = '541'
       AND LIFNR = P_LGORT
       AND SMBLN = SPACE
       %_HINTS ORACLE 'INDEX("matdoc" "matdoc~Z03")'.

*& 2008.04.30 외주 직납분 추가
    SELECT WERKS    "플랜트
           MATNR    "자재번호
           CHARG    "배치번호
           BUDAT    "전기일
           MENGE    "전기수량(=체류일수량)
           MEINS    "단위
           MBLNR    "자재문서번호
           ZEILE
           BWART    "이동유형
    APPENDING CORRESPONDING FIELDS OF TABLE TEMP_MATDOC
      FROM MATDOC
     WHERE BUDAT <= P_DATE
       AND WERKS = P_WERKS
       AND MATNR = P_MATNR
       AND CHARG = P_CHARG
       AND SHKZG = 'S'
       AND BWART = '101'
       AND SOBKZ = 'O'
       AND EMLIF = P_LGORT
       AND SMBLN = SPACE
       %_HINTS ORACLE 'INDEX("matdoc" "matdoc~Z03")'.


    IF TEMP_MATDOC[] IS INITIAL.  "없을 경우 werks 조건 제외

      SELECT WERKS    "플랜트
             MATNR    "자재번호
             CHARG    "배치번호
             BUDAT    "전기일
             MENGE    "전기수량(=체류일수량)
             MEINS    "단위
             MBLNR    "자재문서번호
             ZEILE
             BWART    "이동유형
      INTO CORRESPONDING FIELDS OF TABLE TEMP_MATDOC
        FROM MATDOC
       WHERE BUDAT <= P_DATE
         AND MATNR = P_MATNR
         AND CHARG = P_CHARG
         AND SHKZG = 'S'
         AND BWART = '541'
         AND LIFNR = P_LGORT
         AND SMBLN = SPACE
         %_HINTS ORACLE 'INDEX("matdoc" "matdoc~Z03")'.

*& 2008.04.30 외주 직납분 추가
      SELECT WERKS    "플랜트
             MATNR    "자재번호
             CHARG    "배치번호
             BUDAT    "전기일
             MENGE    "전기수량(=체류일수량)
             MEINS    "단위
             MBLNR    "자재문서번호
             ZEILE
             BWART    "이동유형
      APPENDING CORRESPONDING FIELDS OF TABLE TEMP_MATDOC
        FROM MATDOC
       WHERE BUDAT <= P_DATE
         AND MATNR = P_MATNR
         AND CHARG = P_CHARG
         AND SHKZG = 'S'
         AND BWART = '101'
         AND SOBKZ = 'O'
         AND EMLIF = P_LGORT
         AND SMBLN = SPACE
         %_HINTS ORACLE 'INDEX("matdoc" "matdoc~Z03")'.
    ENDIF.
  ENDIF.

* 2023.12.08 HANA 마이그레이션 반영
  DELETE TEMP_MATDOC WHERE BWART = '561'
                                    AND BUDAT BETWEEN '20231228' AND '20240105'.

* 2024.02.08 1301->1407 이전 반영
  DELETE TEMP_MATDOC WHERE BWART = '301'
                                    AND ( BUDAT = '20240301' OR BUDAT = '20240304' )
                                    AND WERKS = '1407'
                                    AND UMWRK = '1301'.

  DELETE TEMP_MATDOC WHERE BWART = '541'
                                    AND BUDAT = '20240301'
                                    AND WERKS = '1407'.

*20250327
*-플랜트 1306 인 경우 BUDAT->LWEDT(전기일->최종입고일)로 전환
  DATA: LV_LWEDT LIKE MCH1-LWEDT,
        LV_CHARG LIKE MATDOC-CHARG.
  FIELD-SYMBOLS: <FS> LIKE TEMP_MATDOC.

  IF P_WERKS = '1306'.
    IF TEMP_MATDOC[] IS NOT INITIAL.
      CLEAR: LV_LWEDT, LV_CHARG.

      IF P_CHARG IS NOT INITIAL.
        SELECT MIN( O_LWEDT )
          FROM ZGTPPT9020
         WHERE N_MATNR EQ @P_MATNR
           AND N_CHARG EQ @P_CHARG
          INTO @LV_LWEDT.

        IF SY-SUBRC EQ 0 AND LV_LWEDT IS NOT INITIAL.
          LOOP AT TEMP_MATDOC ASSIGNING <FS>.
            <FS>-BUDAT = LV_LWEDT.
          ENDLOOP.

        ELSE.
          SELECT SINGLE LWEDT
            FROM MCH1
           WHERE MATNR EQ @P_MATNR
             AND CHARG EQ @P_CHARG
            INTO @LV_LWEDT.

          IF SY-SUBRC EQ 0 AND LV_LWEDT IS NOT INITIAL.
            LOOP AT TEMP_MATDOC ASSIGNING <FS>.
              <FS>-BUDAT = LV_LWEDT.
            ENDLOOP.
          ENDIF.
        ENDIF.

      ELSEIF P_CHARG IS INITIAL.
        READ TABLE TEMP_MATDOC INDEX 1.

        SELECT SINGLE CHARG
          FROM MATDOC
         WHERE MBLNR EQ @TEMP_MATDOC-MBLNR
           AND WERKS EQ @P_WERKS
           AND MATNR EQ @P_MATNR
          INTO @LV_CHARG.

        IF SY-SUBRC EQ 0 AND LV_CHARG IS NOT INITIAL.
          SELECT SINGLE LWEDT
            FROM MCH1
           WHERE MATNR EQ @P_MATNR
             AND CHARG EQ @LV_CHARG
            INTO @LV_LWEDT.

          IF SY-SUBRC EQ 0 AND LV_LWEDT IS NOT INITIAL.
            LOOP AT TEMP_MATDOC ASSIGNING <FS>.
              <FS>-BUDAT = LV_LWEDT.
            ENDLOOP.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.
  ENDIF.
*20250327

ENDFORM.                    " SELECT_matdoc_N_T0149
*&---------------------------------------------------------------------*
*&      Form  SELECT_matdoc_Y_T0149
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TEMP_COLLECT_WERKS  text
*      -->P_TEMP_COLLECT_MATNR  text
*      -->P_TEMP_COLLECT_CHARG  text
*      -->P_GV_DATE  text
*----------------------------------------------------------------------*
FORM SELECT_MATDOC_Y_T0149  USING    P_WERKS
                                    P_MATNR
                                    P_LGORT
                                    P_CHARG
                                    GV_DATE.

  DATA : LV_ZEILE   LIKE    MSEG-ZEILE.           "자체개선_142736_추가


* 2014.02.11 CSR:기능개선_9945
* 플랜트별 최종 아카이빙 데이터 확인
  IF GV_WERKS NE P_WERKS.
    GV_WERKS = P_WERKS.

* 플랜트에 최종 아카이빙된 날짜 조회
    SELECT MAX( BUDAT )
      INTO GV_ADATE
      FROM ZARIXMM1
     WHERE WERKS = GV_WERKS
       AND BWART IN ('101','131')
       AND BUDAT < SY-DATUM.

  ENDIF.

* 2014.02.11 CSR:기능개선_9945
* 배치 유무에 따라 matdoc,zarixmm1 조회 로직 분기
  IF P_CHARG IS NOT INITIAL.
    PERFORM GET_MATDOC_ZARIXMM1_CHARG USING P_WERKS
                                           P_MATNR
                                           P_LGORT
                                           P_CHARG.

  ELSE.
    PERFORM GET_MATDOC_ZARIXMM1_NOCHARG USING P_WERKS
                                             P_MATNR
                                             P_LGORT.
  ENDIF.


*& matdoc와 zppt0149 중복 자재문서가 아닌 경우만 append
  LOOP AT TEMP_MATDOC1.

    READ TABLE TEMP_MATDOC WITH KEY MBLNR = TEMP_MATDOC1-MBLNR
                                   MATNR = TEMP_MATDOC1-MATNR
                                   CHARG = TEMP_MATDOC1-CHARG
                                   MENGE = TEMP_MATDOC1-MENGE.
*-}자체개선_142736_변경
    IF SY-SUBRC EQ 0.
      DELETE TEMP_MATDOC1.
    ENDIF.
  ENDLOOP.

  LOOP AT TEMP_MATDOC1.

    LV_ZEILE = LV_ZEILE + 1.
    TEMP_MATDOC1-ZEILE = LV_ZEILE.
    MOVE-CORRESPONDING TEMP_MATDOC1 TO TEMP_MATDOC.

    APPEND TEMP_MATDOC.
  ENDLOOP.

*    IF sy-subrc NE 0.    "zppt0149에 동일한 자재문서가 없을 경우만
*
*      MOVE-CORRESPONDING temp_matdoc1 TO temp_matdoc.
*
*      APPEND temp_matdoc.
*
*    ENDIF.
*
*  ENDLOOP.
*-}자체개선_142736_2016.06.27

* 2023.12.08 HANA 마이그레이션 반영
  DELETE TEMP_MATDOC WHERE BWART = '561'
                                    AND BUDAT BETWEEN '20231228' AND '20240105'.

  SORT TEMP_MATDOC BY MBLNR ZEILE MATNR CHARG MENGE.
  DELETE ADJACENT DUPLICATES FROM TEMP_MATDOC COMPARING MBLNR ZEILE
         MATNR CHARG MENGE.

ENDFORM.                    " SELECT_matdoc_Y_T0149
*&---------------------------------------------------------------------*
*&      Form  SELECT_0149_MAXD
*&---------------------------------------------------------------------*
*       text : zppt0149의 가장 최근 생성일의 데이터 검색
*----------------------------------------------------------------------*
*      -->P_WERKS  text 플랜트
*      -->P_MATNR  text 자재번호
*      -->P_CHARG  text 배치번호
*      -->P_LGORT  text 저장위치
*----------------------------------------------------------------------*
FORM SELECT_0149_MAXD  USING    P_WERKS
                                P_MATNR
                                P_LGORT
                                P_CHARG.

  DATA : BEGIN OF LT_MDATE OCCURS 0,
           MENGE LIKE TEMP_0149-MENGE,
           MEINS LIKE TEMP_0149-MEINS,
           MBLNR LIKE TEMP_0149-MBLNR,
           PRCTR LIKE TEMP_0149-PRCTR,
           BWART LIKE TEMP_0149-BWART,
           MDATE LIKE TEMP_0149-MDATE,
         END OF LT_MDATE.

  CLEAR : LT_MDATE, LT_MDATE[].

  IF STRLEN( TEMP_ACT-LGORT ) <= 4.   "사내 일 경우

*& 2012.10.11 CSR:C20121010_96873
*& 생성일자를 멀티로 조회해서 최근 생성일자를 사용
    SELECT   MENGE                     "전기수량
             MEINS                     "단위
             MBLNR                     "자재문서번호
             PRCTR                     "손익센터
             BWART                     "이동유형
             MAX( MDATE ) AS MDATE     "생성일자
     INTO CORRESPONDING FIELDS OF TABLE LT_MDATE
     FROM ZPPT0149
    WHERE WERKS = P_WERKS
      AND MATNR = P_MATNR
      AND CHARG = P_CHARG
      AND LGORT = P_LGORT
      AND MDATE < P_DATE
  GROUP BY MENGE MEINS MBLNR PRCTR BWART.

    SORT LT_MDATE BY MDATE DESCENDING.

    READ TABLE LT_MDATE INDEX 1.

    IF SY-SUBRC EQ 0.
      TEMP_0149-MENGE = LT_MDATE-MENGE.
      TEMP_0149-MEINS = LT_MDATE-MEINS.
      TEMP_0149-MBLNR = LT_MDATE-MBLNR.
      TEMP_0149-PRCTR = LT_MDATE-PRCTR.
      TEMP_0149-BWART = LT_MDATE-BWART.
      TEMP_0149-MDATE = LT_MDATE-MDATE.
    ENDIF.

    SELECT SINGLE MAX( BUDAT )
      INTO TEMP_0149-BUDAT
    FROM ZPPT0149
    WHERE WERKS = P_WERKS
      AND MATNR = P_MATNR
      AND CHARG = P_CHARG
      AND LGORT = P_LGORT
      AND MDATE = TEMP_0149-MDATE.

    IF NOT ( TEMP_0149-BUDAT = '' OR TEMP_0149-BUDAT IS INITIAL )
     OR NOT ( TEMP_0149-MBLNR = '' OR TEMP_0149-MBLNR IS INITIAL ).

      APPEND TEMP_0149.
      CLEAR  TEMP_0149.
    ENDIF.

  ELSE.           "외주일경우

*& 2012.10.11 CSR:C20121010_96873
*& 생성일자를 멀티로 조회해서 최근 생성일자를 사용
    SELECT  MENGE                     "전기수량
            MEINS                     "단위
            MBLNR                     "자재문서번호
            PRCTR                     "손익센터
            BWART                     "이동유형
            MAX( MDATE ) AS MDATE     "생성일자
      INTO CORRESPONDING FIELDS OF TABLE LT_MDATE
      FROM ZPPT0149
     WHERE WERKS = P_WERKS
       AND MATNR = P_MATNR
       AND CHARG = P_CHARG
       AND LGORT = P_LGORT
       AND MDATE < P_DATE
     GROUP BY MENGE MEINS MBLNR PRCTR BWART.

    SORT LT_MDATE BY MDATE DESCENDING.

    READ TABLE LT_MDATE INDEX 1.

    IF SY-SUBRC EQ 0.
      TEMP_0149-MENGE = LT_MDATE-MENGE.
      TEMP_0149-MEINS = LT_MDATE-MEINS.
      TEMP_0149-MBLNR = LT_MDATE-MBLNR.
      TEMP_0149-PRCTR = LT_MDATE-PRCTR.
      TEMP_0149-BWART = LT_MDATE-BWART.
      TEMP_0149-MDATE = LT_MDATE-MDATE.
    ENDIF.

    SELECT SINGLE MAX( BUDAT )
       INTO TEMP_0149-BUDAT
     FROM ZPPT0149
     WHERE  WERKS = P_WERKS
        AND MATNR = P_MATNR
        AND CHARG = P_CHARG
        AND LGORT = P_LGORT
       AND MDATE = TEMP_0149-MDATE.


    IF NOT ( TEMP_0149-BUDAT = '' OR TEMP_0149-BUDAT IS INITIAL ) OR
       NOT ( TEMP_0149-MBLNR = '' OR TEMP_0149-MBLNR IS INITIAL ).
      APPEND TEMP_0149.
      CLEAR  TEMP_0149.
    ENDIF.

  ENDIF.

ENDFORM.                    " SELECT_0149_MAXD
*&---------------------------------------------------------------------*
*&      Form  SEARCH_TNAME1
*&---------------------------------------------------------------------*
*       text : 플랜트 내역 가져오기
*----------------------------------------------------------------------*
*      -->P_SPWERK  text 플랜트 번호
*      -->P_NAME1   text 플랜트 내용
*----------------------------------------------------------------------*
FORM SEARCH_TNAME1  USING    P_SPWERK
                             P_NAME1.

  SELECT SINGLE NAME1
    INTO P_NAME1
    FROM T001W
   WHERE WERKS = P_SPWERK  "s_pwerk
     AND SPRAS = SY-LANGU.

ENDFORM.                    " SEARCH_TNAME1
*&---------------------------------------------------------------------*
*&      Form  SEARCH_TMAKTX
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_MATNR  text
*      -->P_MAKTX  text
*----------------------------------------------------------------------*
FORM SEARCH_TMAKTX  USING    P_MATNR
                             P_MAKTX.

  SELECT SINGLE MAKTX
    INTO P_MAKTX
    FROM MAKT
   WHERE MATNR = P_MATNR
     AND SPRAS = SY-LANGU.

ENDFORM.                    " SEARCH_TMAKTX
*&---------------------------------------------------------------------*
*&      Form  GET_ZPPT0149
*&---------------------------------------------------------------------*
*       text :  zppt0149 해당 내용 조회
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_ZPPT0149 USING P_GUBUN .

  DATA : BEGIN OF LT_NFM OCCURS 0,
           NES LIKE  /NFM/TKGW-NES,
           KGW LIKE  /NFM/TKGW-KGW,
           KGU LIKE  /NFM/TKGW-KGU,
         END OF LT_NFM.

  DATA : LV_MATNR  LIKE  MARC-MATNR.

  CASE P_GUBUN.
    WHEN 'S'.  "조회용
      CLEAR : GT_TAB, GT_TAB[].

      SELECT *
        INTO CORRESPONDING FIELDS OF TABLE GT_TAB
        FROM ZPPT0149
       WHERE WERKS IN S_PWERK
         AND MATNR IN S_MATNR
         AND MDATE = P_DATE
         AND STOCKT IN S_BAT
         AND ( BRANCHG IN S_BRAN OR
               BRANCHG EQ SPACE ).

*& 2008.04.22
*& CSR : C20080422_54797
*& 자재코드,손익센터 실제 값만 조회
      LOOP AT GT_TAB.
*20250613
        SELECT SINGLE MAT_KDAUF, MAT_KDPOS
          FROM MATDOC
         WHERE MBLNR EQ @GT_TAB-MBLNR
           AND MATNR EQ @GT_TAB-MATNR
           AND WERKS EQ @GT_TAB-WERKS
           AND CHARG EQ @GT_TAB-CHARG
          INTO (@GT_TAB-MAT_KDAUF, @GT_TAB-MAT_KDPOS).
*20250613

        IF GT_TAB-WERKS EQ '3501' AND
           GT_TAB-MEINS EQ 'SHT'.

          PERFORM CONVERSION_UNIT USING GT_TAB-MATNR
                                        GT_TAB-WERKS
                                        GT_TAB-STOCKM
                                        GT_TAB-MEINS
                                        'KG'
                                 CHANGING GT_TAB-STOCKMC.

          PERFORM CONVERSION_UNIT USING GT_TAB-MATNR
                                        GT_TAB-WERKS
                                        GT_TAB-STOPM
                                        GT_TAB-MEINS
                                        'KG'
                                 CHANGING GT_TAB-STOPMC.

          GT_TAB-MEINSC = 'KG'.
        ELSEIF GT_TAB-WERKS EQ '3501' AND
               GT_TAB-MEINS NE 'SHT'.

          GT_TAB-STOCKMC = GT_TAB-STOCKM.
          GT_TAB-STOPMC = GT_TAB-STOPM.
          GT_TAB-MEINSC = GT_TAB-MEINS.

        ENDIF.

        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
          EXPORTING
            INPUT  = GT_TAB-MATNR
          IMPORTING
            OUTPUT = GT_TAB-MATNR.

        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
          EXPORTING
            INPUT  = GT_TAB-PRCTR
          IMPORTING
            OUTPUT = GT_TAB-PRCTR.

*-{기능개선_205476_추가
        IF GT_TAB-MATNR_S IS NOT INITIAL.
          CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
            EXPORTING
              INPUT  = GT_TAB-MATNR_S
            IMPORTING
              OUTPUT = GT_TAB-MATNR_S.
        ENDIF.
*-}기능개선_205476_2017.09.06
        MODIFY GT_TAB.
      ENDLOOP.

*-{기능개선_182599 MRP관리자,CU,AL 환산계수 조회
      LOOP AT GT_TAB WHERE DISPO IS INITIAL.

        CLEAR : LV_MATNR.

*[S/4 HANA PJT]-Element or Domain 자리 수 / 자재마스터
*CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
*          EXPORTING
*            INPUT  = GT_TAB-MATNR
*          IMPORTING
*            OUTPUT = LV_MATNR.
        PERFORM CONVERSION_EXIT_MATN1_INPUT USING GT_TAB-MATNR
                                                      CHANGING LV_MATNR.
*[S/4 HANA PJT]-2023.04.10 By 오바다

        SELECT SINGLE DISPO
          INTO GT_TAB-DISPO
          FROM MARC
         WHERE WERKS = GT_TAB-WERKS
           AND MATNR = LV_MATNR.

        CLEAR : LT_NFM, LT_NFM[].

        SELECT NES KGW KGU
          INTO CORRESPONDING FIELDS OF TABLE LT_NFM
          FROM /NFM/TKGW
         WHERE WERKS = GT_TAB-WERKS
           AND MATNR = LV_MATNR
           AND NES   IN ('AL', 'CU').

        READ TABLE LT_NFM WITH KEY NES = 'CU'.  "CU 동량

        IF SY-SUBRC EQ 0.
          GT_TAB-CF_CU = LT_NFM-KGW / LT_NFM-KGU.
        ENDIF.

        READ TABLE LT_NFM WITH KEY NES = 'AL'.  "CU 동량

        IF SY-SUBRC EQ 0.
          GT_TAB-CF_AL = LT_NFM-KGW / LT_NFM-KGU.
        ENDIF.

        MODIFY GT_TAB TRANSPORTING DISPO CF_CU CF_AL
                             WHERE WERKS = GT_TAB-WERKS
                               AND MATNR = GT_TAB-MATNR.
      ENDLOOP.

      LOOP AT GT_TAB WHERE ( CF_CU > 0 OR CF_AL > 0 ).

        IF GT_TAB-CF_CU > 0 AND GT_TAB-STOPM > 0.
          GT_TAB-C_CU = GT_TAB-CF_CU * GT_TAB-STOPM.
        ENDIF.

        IF GT_TAB-CF_AL > 0 AND GT_TAB-STOPM > 0.
          GT_TAB-C_AL = GT_TAB-CF_AL * GT_TAB-STOPM.
        ENDIF.

        MODIFY GT_TAB.

      ENDLOOP.
*}-기능개선_182599

    WHEN 'U'. "결산용
      CLEAR : TEMP_0149, TEMP_0149[].

      SELECT *
        INTO CORRESPONDING FIELDS OF TABLE TEMP_0149
        FROM ZPPT0149
       WHERE WERKS IN S_PWERK
         AND MATNR IN S_MATNR
         AND MDATE = P_DATE
                  AND ( BRANCHG IN S_BRAN OR
               BRANCHG EQ SPACE ).
  ENDCASE.

ENDFORM.                    " GET_ZPPT0149
*&---------------------------------------------------------------------*
*&      Form  SELECT_matdoc_N_T0149_INBATCH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_WERKS  text
*      -->P_P_MATNR  text
*      -->P_P_LGORT  text
*      -->P_P_CHARG  text
*----------------------------------------------------------------------*
FORM SELECT_MATDOC_N_T0149_INBATCH  USING    P_WERKS
                                            P_MATNR
                                            P_LGORT
                                            P_CHARG.

  DATA : LV_WERKS     TYPE  WERKS.

  DATA : LT_MATDOC   LIKE TEMP_MATDOC OCCURS 0 WITH HEADER LINE.
  "matdoc 조회

  CLEAR : LV_WERKS.

* 싱글
  SELECT WERKS
         BUDAT    "전기일
         MENGE    "전기수량(=체류일수량)
         MEINS    "단위
         MBLNR    "자재문서번호
         ZEILE
         BWART    "이동유형
         EBELN
         EBELP
         UMWRK
  INTO CORRESPONDING FIELDS OF TABLE TEMP_MATDOC
    FROM MATDOC
   WHERE BUDAT <= P_DATE
     AND WERKS = P_WERKS
     AND MATNR = P_MATNR
     AND CHARG = P_CHARG
     AND MENGE > 0
     AND ( BWART IN ('101', '131', '501', '511', '521', '561',
*-{기능개선_194560 161제외, 459,455,457 추가
                          '459', '455', '457', '657') OR
*                     '122', '161', '657') OR
         ( BWART IN ('309','903', '301', '453') AND SHKZG = 'S') )
     %_HINTS ORACLE 'INDEX("matdoc" "matdoc~Z03")'.

  IF TEMP_MATDOC[] IS INITIAL.  "없을 경우 werks 조건 제외

    SELECT WERKS
           BUDAT    "전기일
           MENGE    "전기수량(=체류일수량)
           MEINS    "단위
           MBLNR    "자재문서번호
           ZEILE
           BWART    "이동유형
           EBELN
           EBELP
           UMWRK
    INTO CORRESPONDING FIELDS OF TABLE TEMP_MATDOC
      FROM MATDOC
     WHERE BUDAT <= P_DATE
       AND MATNR = P_MATNR
       AND CHARG = P_CHARG
       AND MENGE > 0
       AND ( BWART IN ('101', '131', '501', '511', '521', '561',
*-{기능개선_194560 161제외, 459,455,457 추가
                          '459', '455', '457', '657') OR
*                       '122', '161', '657') OR
           ( BWART IN ('309','903', '301', '453') AND SHKZG = 'S') )
           %_HINTS ORACLE 'INDEX("matdoc" "matdoc~Z03")'.
  ENDIF.

* 2023.12.08 HANA 마이그레이션 반영
  DELETE TEMP_MATDOC WHERE BWART = '561'
                                    AND BUDAT BETWEEN '20231228' AND '20240105'.

* 2024.02.08 1301->1407 이전 반영
  DELETE TEMP_MATDOC WHERE BWART = '301'
                                    AND ( BUDAT = '20240301' OR BUDAT = '20240304' )
                                    AND WERKS = '1407'
                                    AND UMWRK = '1301'.

ENDFORM.                    " SELECT_matdoc_N_T0149_INBATCH
*&---------------------------------------------------------------------*
*&      Form  SELECT_matdoc_Y_T0149_INBATCH
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TEMP2_WERKS  text
*      -->P_TEMP2_MATNR  text
*      -->P_TEMP2_LGORT  text
*      -->P_TEMP2_CHARG  text
*----------------------------------------------------------------------*
FORM SELECT_MATDOC_Y_T0149_INBATCH  USING    P_WERKS
                                            P_MATNR
                                            P_LGORT
                                            P_CHARG.
  DATA : LV_DATE  LIKE SY-DATUM,
         LV_WERKS TYPE WERKS.

  DATA : LT_MATDOC   LIKE TEMP_MATDOC OCCURS 0 WITH HEADER LINE.
  "matdoc 조회

  CLEAR : LV_DATE, LV_WERKS.
  LV_DATE = GV_MDATE.

  SELECT WERKS
          BUDAT    "전기일
          MENGE    "전기수량(=체류일수량)
          MEINS    "단위
          MBLNR    "자재문서번호
          ZEILE
          BWART    "이동유형
          EBELN
          UMWRK
   INTO CORRESPONDING FIELDS OF TABLE TEMP_MATDOC
     FROM MATDOC
    WHERE BUDAT BETWEEN GV_DATE AND P_DATE
      AND WERKS = P_WERKS
      AND MATNR = P_MATNR
      AND CHARG = P_CHARG
      AND MENGE > 0
      AND ( BWART IN ('101', '131', '501', '511', '521', '561',
*-{기능개선_194560 161제외, 459,455,457 추가
                          '459', '455', '457', '657') OR
*                      '122', '161', '657') OR
           ( BWART IN ('309','903', '301', '453') AND SHKZG = 'S') )
               %_HINTS ORACLE 'INDEX("matdoc" "matdoc~Z03")'.

  IF TEMP_MATDOC[] IS INITIAL.  "없을 경우 werks 조건 제외

    SELECT BUDAT    "전기일
           MENGE    "전기수량(=체류일수량)
           MEINS    "단위
           MBLNR    "자재문서번호
           ZEILE
           BWART    "이동유형
           EBELN
           UMWRK
      INTO CORRESPONDING FIELDS OF TABLE TEMP_MATDOC
      FROM MATDOC
    WHERE BUDAT BETWEEN GV_DATE AND P_DATE
       AND MATNR = P_MATNR
       AND CHARG = P_CHARG
       AND MENGE > 0
       AND ( BWART IN ('101', '131', '501', '511', '521', '561',
*-{기능개선_194560 161제외, 459,455,457 추가
                          '459', '455', '457', '657') OR
*                       '122', '161', '657') OR
           ( BWART IN ('309','903', '301', '453') AND SHKZG = 'S') ).

  ENDIF.

  CLEAR : TEMP_MATDOC1, TEMP_MATDOC1[].

  SELECT BUDAT    "전기일
        MENGE    "전기수량(=체류일수량)
        MEINS    "단위
        MBLNR    "자재문서번호
        PRCTR    "손익센터
        BWART    "이동유형
  INTO CORRESPONDING FIELDS OF TABLE TEMP_MATDOC1
   FROM ZPPT0149
  WHERE MDATE = LV_DATE
    AND WERKS = P_WERKS
    AND MATNR = P_MATNR
    AND CHARG = P_CHARG
    AND LGORT = P_LGORT
    AND BRANCHG <> 'Z'.

*& matdoc와 zppt0149 중복 자재문서가 아닌 경우만 append
  LOOP AT TEMP_MATDOC1.

    READ TABLE TEMP_MATDOC WITH KEY MBLNR = TEMP_MATDOC1-MBLNR
                                   MATNR = TEMP_MATDOC1-MATNR
                                   CHARG = TEMP_MATDOC1-CHARG
                                   MENGE = TEMP_MATDOC1-MENGE.

    IF SY-SUBRC NE 0.    "zppt0149에 동일한 자재문서가 없을 경우만

      MOVE-CORRESPONDING TEMP_MATDOC1 TO TEMP_MATDOC.

      APPEND TEMP_MATDOC.

    ENDIF.

  ENDLOOP.

* 2023.12.08 HANA 마이그레이션 반영
  DELETE TEMP_MATDOC WHERE BWART = '561'
                                    AND BUDAT BETWEEN '20231228' AND '20240105'.

* 2024.02.08 1301->1407 이전 반영
  DELETE TEMP_MATDOC WHERE BWART = '301'
                                    AND ( BUDAT = '20240301' OR BUDAT = '20240304' )
                                    AND WERKS = '1407'
                                    AND UMWRK = '1301'.

  SORT TEMP_MATDOC BY MBLNR ZEILE MATNR CHARG MENGE.
  DELETE ADJACENT DUPLICATES FROM TEMP_MATDOC COMPARING
         MBLNR ZEILE MATNR CHARG MENGE.



ENDFORM.                    " SELECT_matdoc_Y_T0149_INBATCH

*&---------------------------------------------------------------------*
*&      Form  SELECT_TEMP1
*&---------------------------------------------------------------------*
*text : 배치관리 하지 않는 재고 (플랜트 : '91'로 끝나는 것은 제외)
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SELECT_TEMP1 .
  DATA : LV_CNT.
  CLEAR : LV_CNT, TEMP1, TEMP1[].
* temp1 >>
  SELECT A~MATNR
         A~WERKS
         A~LGORT
         A~LABST
         A~INSME
         A~SPEME
         A~EINME
         C~MEINS
         C~DPCBT
         C~MTART
     INTO (TEMP1-MATNR,
           TEMP1-WERKS,
           TEMP1-LGORT,
           TEMP1-LABS,
           TEMP1-INSM,
           TEMP1-SPEM,
           TEMP1-EINM,
           TEMP1-MEINS,
           TEMP1-DPCBT,
           TEMP1-MTART)
    FROM MARD AS A
         INNER JOIN MARC AS B
                     ON  A~MATNR = B~MATNR
                     AND A~WERKS = B~WERKS
         INNER JOIN MARA AS C
                     ON  B~MATNR = C~MATNR
                    AND  A~MATNR = C~MATNR
                    AND  C~XCHPF = ''
    WHERE ( A~LABST > 0
       OR A~INSME > 0
       OR A~SPEME > 0
       OR A~EINME > 0 )
      AND A~MATNR IN S_MATNR
      AND A~WERKS IN S_PWERK
      AND C~MTART IN ('FERT', 'HALB', 'HAWA', 'MACF', 'MACH', 'MCFE',
      'MCHA', 'MCRO',
                       'MCHF' , 'MFER', 'MHAL', 'MRH1', 'ROH', 'ROH1',
                       'ZCSF', 'ZCSH', 'MHAW').

    SELECT COUNT( * )
     INTO LV_CNT
      FROM MBEW
      WHERE BWKEY = TEMP1-WERKS
        AND MATNR = TEMP1-MATNR
        AND BWTAR IN ('NEW', 'NOV', 'REP', 'RET').


    IF ( NOT ( TEMP1-WERKS = '' OR TEMP1-WERKS IS INITIAL )
     OR NOT ( TEMP1-LGORT = '' OR TEMP1-LGORT IS INITIAL ) )
     AND ( TEMP1-WERKS+2(2) <> '91' ).
      IF LV_CNT = 0.
        APPEND TEMP1.
        CLEAR  TEMP1.
      ENDIF.
    ENDIF.

  ENDSELECT.

* temp1 - sum 값
  IF NOT TEMP1[] IS INITIAL.
    LOOP AT TEMP1.
* 재고수량
      TEMP1-STOCKM = TEMP1-LABS + TEMP1-INSM + TEMP1-SPEM + TEMP1-EINM.
      MODIFY TEMP1.
      CLEAR  TEMP1.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " SELECT_TEMP1
*&---------------------------------------------------------------------*
*&      Form  SELECT_TEMP2
*&---------------------------------------------------------------------*
*       text : 배치/non재고데이터 ( 플랜트 : '91'로 끝나는 것은 제외 )
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SELECT_TEMP2 .
  CLEAR  : TEMP2, TEMP2[].
* temp2
  SELECT A~MATNR
         A~WERKS
         A~LGORT
         A~CHARG
         A~CLABS
         A~CINSM
         A~CSPEM
         A~CEINM
         C~MEINS
         C~DPCBT
         C~MTART
     INTO (TEMP2-MATNR,
           TEMP2-WERKS,
           TEMP2-LGORT,
           TEMP2-CHARG,
           TEMP2-LABS,
           TEMP2-INSM,
           TEMP2-SPEM,
           TEMP2-EINM,
           TEMP2-MEINS,
           TEMP2-DPCBT,
           TEMP2-MTART)
    FROM MCHB AS A
        INNER JOIN MARC AS B
                    ON  A~MATNR = B~MATNR
                    AND A~WERKS = B~WERKS
        INNER JOIN MARA AS C
                   ON  A~MATNR = C~MATNR
                  AND  B~MATNR = C~MATNR
   WHERE ( A~CLABS > 0
      OR A~CINSM > 0
      OR A~CSPEM > 0
      OR A~CEINM > 0 )
     AND A~MATNR IN S_MATNR
     AND A~WERKS IN S_PWERK
      AND C~MTART IN ('FERT', 'HALB', 'HAWA', 'MACF', 'MACH', 'MCFE',
                      'MCHA', 'MCRO', 'MCHF', 'MFER', 'MHAL', 'MRH1',
                      'ROH', 'ROH1', 'ZCSF', 'ZCSH', 'MHAW').

    IF ( NOT ( TEMP2-MATNR = '' OR TEMP2-MATNR IS INITIAL )
     OR NOT ( TEMP2-WERKS = '' OR TEMP2-WERKS IS INITIAL )
     OR NOT ( TEMP2-LGORT = '' OR TEMP2-LGORT IS INITIAL )
     OR NOT ( TEMP2-CHARG = '' OR TEMP2-CHARG IS INITIAL ) )
     AND ( TEMP2-WERKS+2(2) <> '91' ).
      APPEND TEMP2.
      CLEAR  TEMP2.
    ENDIF.
  ENDSELECT.

* temp2 - sum 값
  IF NOT TEMP2[] IS INITIAL.
    LOOP AT TEMP2.
* 재고수량
      TEMP2-STOCKM = TEMP2-LABS + TEMP2-INSM + TEMP2-SPEM + TEMP2-EINM.
      MODIFY TEMP2.
      CLEAR  TEMP2.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " SELECT_TEMP2
*&---------------------------------------------------------------------*
*&      Form  SELECT_TEMP3
*&---------------------------------------------------------------------*
*       text : 배치관리 하지 않는 재고 데이터, 배치/non재고데이터
*              ( 플랜트 : '91'로 끝나는 것은 제외 )
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SELECT_TEMP3 .
  CLEAR : TEMP3, TEMP3[].
*temp3
  SELECT A~MATNR
         A~WERKS
         A~LGORT
         A~CHARG
         A~KALAB
         A~KAINS
         A~KASPE
         A~KAEIN
         B~XCHPF
         C~MEINS
         C~DPCBT
         C~MTART
     INTO (TEMP3-MATNR,
           TEMP3-WERKS,
           TEMP3-LGORT,
           TEMP3-CHARG,
           TEMP3-LABS,
           TEMP3-INSM,
           TEMP3-SPEM,
           TEMP3-EINM,
           TEMP3-XCHPF,
           TEMP3-MEINS,
           TEMP3-DPCBT,
           TEMP3-MTART)
    FROM MSKA AS A
        INNER JOIN MARC AS B
                    ON  A~MATNR = B~MATNR
                    AND A~WERKS = B~WERKS
        INNER JOIN MARA AS C
                    ON  A~MATNR = C~MATNR
                   AND  B~MATNR = C~MATNR

   WHERE ( A~KALAB > 0
      OR A~KAINS > 0
      OR A~KASPE > 0
      OR A~KASPE > 0 )
     AND A~SOBKZ = 'E'
     AND A~MATNR IN S_MATNR
     AND A~WERKS IN S_PWERK
     AND C~MTART IN ('FERT', 'HALB', 'HAWA', 'MACF', 'MACH', 'MCFE',
     'MCHA',
                     'MCRO', 'MCHF', 'MFER', 'MHAL', 'MRH1', 'ROH',
                     'ROH1',
                       'ZCSF', 'ZCSH', 'MHAW').

    IF ( NOT ( TEMP3-MATNR = '' OR TEMP3-MATNR IS INITIAL )
     OR NOT ( TEMP3-WERKS = '' OR TEMP3-WERKS IS INITIAL )
     OR NOT ( TEMP3-LGORT = '' OR TEMP3-LGORT IS INITIAL )
     OR NOT ( TEMP3-CHARG = '' OR TEMP3-CHARG IS INITIAL ) )
     AND ( TEMP3-WERKS+2(2) <> '91' ).
      APPEND TEMP3.
      CLEAR  TEMP3.
    ENDIF.

  ENDSELECT.

* temp3 - sum 값
  IF NOT TEMP3[] IS INITIAL.
    SORT TEMP3 BY WERKS LGORT MATNR CHARG.
    LOOP AT TEMP3.
      TEMP3-STOCKM = TEMP3-LABS + TEMP3-INSM + TEMP3-SPEM + TEMP3-EINM.
      "재고수량
      MODIFY TEMP3.

      IF TEMP3-XCHPF = 'X'.
*** xchpf(배치관리)를 하는 재고일 경우 temp2의 배치재고에
****플랜트,저장위치,배치번호로 수량을 합산
        CLEAR :  TEMP3-XCHPF.

        COLLECT TEMP3 INTO TEMP2.
        CLEAR   TEMP2.
      ELSE.
*** 배치관리를 하지 않는 재고일 경우 temp1에
*플랜트,저장위치,자재코드로수량합산
        CLEAR :  TEMP3-XCHPF.

        COLLECT TEMP3 INTO TEMP1.
        CLEAR   TEMP1.
      ENDIF.
    ENDLOOP.
  ENDIF.


ENDFORM.                    " SELECT_TEMP3
*&---------------------------------------------------------------------*
*&      Form  SELECT_TMEP4
*&---------------------------------------------------------------------*
*       text : 외주 ( 플랜트 : '91'로 끝나는 것은 제외 )
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SELECT_TEMP4 .
  CLEAR : TEMP4, TEMP4[].
*temp4
  SELECT A~WERKS
         A~MATNR
         A~CHARG
         A~LIFNR
         A~LBLAB
         A~LBINS
         A~LBEIN
         C~MEINS
         B~XCHPF
         C~MTART
     INTO (TEMP4-WERKS,
           TEMP4-MATNR,
           TEMP4-CHARG,        "배치번호
           TEMP4-LGORT,        "거래처코드
           TEMP4-LABS,
           TEMP4-INSM,
           TEMP4-EINM,
           TEMP4-MEINS,
           TEMP4-XCHPF,
           TEMP4-MTART)
    FROM MSLB AS A
        INNER JOIN MARC AS B
                    ON  A~MATNR = B~MATNR
                    AND A~WERKS = B~WERKS
        INNER JOIN MARA AS C
                    ON  B~MATNR = C~MATNR
                   AND  A~MATNR = C~MATNR
   WHERE ( A~LBLAB > 0
      OR A~LBINS > 0
      OR A~LBEIN > 0 )
     AND A~SOBKZ = 'O'
     AND A~MATNR IN S_MATNR
     AND A~WERKS IN S_PWERK
      AND C~MTART IN ('FERT', 'HALB', 'HAWA', 'MACF', 'MACH', 'MCFE',
                      'MCHA', 'MCRO', 'MCHF', 'MFER', 'MHAL', 'MRH1',
                      'ROH', 'ROH1', 'ZCSF', 'ZCSH', 'MHAW').

    IF ( NOT ( TEMP4-WERKS = '' OR TEMP4-WERKS IS INITIAL )
     OR NOT ( TEMP4-LGORT = '' OR TEMP4-LGORT IS INITIAL ) )
     AND ( TEMP4-WERKS+2(2) <> '91' ).
      APPEND TEMP4.
      CLEAR  TEMP4.
    ENDIF.

  ENDSELECT.

* temp4 - sum 값
  IF NOT TEMP4[] IS INITIAL.
    LOOP AT TEMP4.
      TEMP4-STOCKM = TEMP4-LABS + TEMP4-INSM + TEMP4-EINM.  "재고수량
      MODIFY TEMP4.
      CLEAR  TEMP4.
    ENDLOOP.
  ENDIF.

ENDFORM.                    " SELECT_TMEP4
*&---------------------------------------------------------------------*
*&      Form  COUNT_ZPPT0149
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_CNT  text
*----------------------------------------------------------------------*
FORM COUNT_ZPPT0149  USING    P_CNT.

  DATA : LV_CNT0149  TYPE I.

  SELECT COUNT( * )
    INTO LV_CNT0149
    FROM ZPPT0149
   WHERE MDATE = P_DATE
     AND WERKS IN S_PWERK
     AND MATNR IN S_MATNR.


  P_CNT = LV_CNT0149.

ENDFORM.                    " COUNT_ZPPT0149
*&---------------------------------------------------------------------*
*&      Form  GET_SEQ
*&---------------------------------------------------------------------*
*       text : zppt0149 입력 시 sequence 번호 구하기
*----------------------------------------------------------------------*
*      -->P_TEMP2_WERKS  text
*      -->P_TEMP2_MATNR  text
*      -->P_TEMP2_LGORT  text
*      -->P_TEMP2_BRANCHG  text
*      -->P_TEMP2_STOCKT  text
*      -->P_P_DATE  text
*      -->P_GV_SEQ  text
*      -->P_TEMP2_CHARG  text
*----------------------------------------------------------------------*
FORM GET_SEQ  USING    P_WERKS
                       P_MATNR
                       P_LGORT
                       P_BRANCHG
                       P_STOCKT
                       P_DATE
                       P_SEQ
                       P_CHARG.

  DATA : NUM LIKE ZPPT0149-SEQUENCE,
         CNT TYPE I.

  CLEAR : CNT, NUM, P_SEQ.

  SELECT COUNT( * )
    INTO CNT
    FROM ZPPT0149
   WHERE WERKS   = P_WERKS
     AND MATNR   = P_MATNR
     AND LGORT   = P_LGORT
     AND MDATE   = P_DATE
     AND CHARG   = P_CHARG.

  IF CNT = 0.
    NUM = 0.
  ELSE.

    SELECT MAX( SEQUENCE )
    INTO NUM
    FROM ZPPT0149
   WHERE WERKS   = P_WERKS
     AND MATNR   = P_MATNR
     AND LGORT   = P_LGORT
     AND MDATE   = P_DATE
     AND CHARG   = P_CHARG.

  ENDIF.

  P_SEQ = NUM.

ENDFORM.                    " GET_SEQ
*&---------------------------------------------------------------------*
*&      Form  DEL_0149
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DEL_0149 .

  DELETE FROM ZPPT0149
        WHERE MDATE = P_DATE
          AND WERKS IN S_PWERK
          AND MATNR IN S_MATNR.

  IF SY-SUBRC <> 0.
    ROLLBACK WORK.
  ELSE.
    COMMIT WORK.
  ENDIF.

ENDFORM.                                                    " DEL_0149
*&---------------------------------------------------------------------*
*&      Form  SEL_LGOBE
*&---------------------------------------------------------------------*
*       text : 저장위치 내역
*----------------------------------------------------------------------*
*      -->P_P_WERKS  text
*      -->P_P_LGORT  text
*      -->P_LV_LGOBE  text
*----------------------------------------------------------------------*
FORM SEL_LGOBE  USING    P_WERKS
                         P_LGORT
                         P_LGOBE.

  DATA : LV_LGOBE LIKE T001L-LGOBE.

  SELECT SINGLE LGOBE
    INTO LV_LGOBE
    FROM T001L
   WHERE WERKS = P_WERKS
     AND LGORT = P_LGORT.

  P_LGOBE = LV_LGOBE.

ENDFORM.                    " SEL_LGOBE
*&---------------------------------------------------------------------*
*&      Form  SEL_NAME1
*&---------------------------------------------------------------------*
*       text : 거래처 명 조회
*----------------------------------------------------------------------*
*      -->P_P_LGORT  text
*      -->P_LV_NAME1  text
*----------------------------------------------------------------------*
FORM SEL_NAME1  USING    P_LGORT
                         P_NAME1.

  DATA : LV_NAME1 LIKE LFA1-NAME1.

  SELECT SINGLE NAME1
    INTO LV_NAME1
    FROM LFA1
   WHERE LIFNR = P_LGORT
     AND SPRAS = SY-LANGU.

  P_NAME1 = LV_NAME1.

ENDFORM.                                                    " SEL_NAME1
*&---------------------------------------------------------------------*
*&      Form  SEL_MAKTX
*&---------------------------------------------------------------------*
*       text : 자재내역 조회
*----------------------------------------------------------------------*
*      -->P_P_MATNR  text
*      -->P_P_MAKTX  text
*----------------------------------------------------------------------*
FORM SEL_MAKTX  USING    P_MATNR
                         P_MAKTX.

  SELECT SINGLE MAKTX
   INTO P_MAKTX
   FROM MAKT
  WHERE MATNR = P_MATNR   "자재번호
    AND SPRAS = SY-LANGU.

ENDFORM.                    " SEL_MAKTX
*&---------------------------------------------------------------------*
*&      Form  SELECT_CKM
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TEMP_0149_MATNR  text
*      -->P_TEMP_0149_WERKS  text
*      -->P_TEMP_0149_MDATE  text
*----------------------------------------------------------------------*
FORM SELECT_CKM  USING    P_MATNR
                          P_WERKS
                          P_CNT.

  DATA : LV_YEAR(04)  TYPE C,
         LV_MONTH(02) TYPE C,
         LV_CNT       TYPE I,
         LV_STPRSAF   LIKE ZPPT0149-STPRSAF.
  "결산 후 단가 계산시 사용

  CLEAR : LV_YEAR, LV_MONTH,  LV_CNT, LV_STPRSAF.

  LV_YEAR = P_DATE+0(4).  "날짜
  LV_MONTH = P_DATE+4(2).

** 70 은 결산 마감 된것
  SELECT COUNT( * )
    INTO LV_CNT
    FROM CKMLHD AS A
      JOIN CKMLPP    AS B
             ON A~KALNR = B~KALNR
   WHERE A~MATNR = P_MATNR
     AND A~BWKEY = P_WERKS
     AND B~BDATJ  = LV_YEAR
     AND B~POPER  = LV_MONTH
     AND B~STATUS <> '70'.

  P_CNT = LV_CNT.

ENDFORM.                    " SELECT_CKM
*&---------------------------------------------------------------------*
*&      Form  CHECK_ZPPT0000
*&---------------------------------------------------------------------*
*       text : 데이터 추출 시 권한체크(zppt0000 확인)
*----------------------------------------------------------------------*
*      -->P_AUTHORITY  text
*----------------------------------------------------------------------*
FORM CHECK_ZPPT0000  USING    P_AUTHORITY.

  DATA  : LV_CNT TYPE I.
  CLEAR : LV_CNT.

  SELECT COUNT( * )
    INTO LV_CNT
    FROM ZPPT0000
   WHERE SECTIONID = 'AUTHORITY'
     AND KEYID     = 'INVENTORY'
     AND SUBKEY    = SY-UNAME.

  IF LV_CNT = 0 OR LV_CNT IS INITIAL.
    P_AUTHORITY = 'X'.
  ENDIF.

ENDFORM.                    " CHECK_ZPPT0000
*&---------------------------------------------------------------------*
*&      Form  SELECT_matdoc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_TEMP_0149_WERKS  text
*      -->P_TEMP_0149_MATNR  text
*      -->P_TEMP_0149_LGORT  text
*      -->P_TEMP_0149_CHARG  text
*----------------------------------------------------------------------*
FORM SELECT_MATDOC  USING    P_WERKS
                            P_MATNR
                            P_LGORT
                            P_CHARG.

  SELECT  WERKS    "플랜트
          MATNR    "자재번호
          CHARG    "배치번호
          BUDAT    "전기일
          MENGE    "전기수량(=체류일수량)
          MEINS    "단위
          MBLNR    "자재문서번호
          PRCTR    "손익센터
          BWART    "이동유형
          SHKZG    "차변/대변 지시자
   INTO CORRESPONDING FIELDS OF TABLE TEMP_MATDOC
     FROM MATDOC
    WHERE BUDAT > P_DATE
      AND CPUDT > P_DATE
      AND WERKS = P_WERKS
      AND MATNR = P_MATNR
      AND CHARG = P_CHARG.

**
  SELECT  WERKS    "플랜트
          MATNR    "자재번호
          CHARG    "배치번호
          BUDAT    "전기일
          MENGE    "전기수량(=체류일수량)
          MEINS    "단위
          MBLNR    "자재문서번호
          PRCTR    "손익센터
          BWART    "이동유형
          SHKZG    "차변/대변 지시자
   APPENDING CORRESPONDING FIELDS OF TABLE TEMP_MATDOC
     FROM ZARIXMM1
    WHERE BUDAT > P_DATE
      AND CPUDT > P_DATE
      AND WERKS = P_WERKS
      AND MATNR = P_MATNR
      AND CHARG = P_CHARG
       %_HINTS ORACLE 'INDEX("ZARIXMM1" "ZARIXMM1~Z03")'.
**
  IF TEMP_MATDOC[] IS INITIAL.  "없을 경우 werks 조건 제외

    SELECT WERKS    "플랜트
           MATNR    "자재번호
           CHARG    "배치번호
           BUDAT    "전기일
           MENGE    "전기수량(=체류일수량)
           MEINS    "단위
           MBLNR    "자재문서번호
           PRCTR    "손익센터
           BWART    "이동유형
           SHKZG    "차변/대변 지시자
      INTO CORRESPONDING FIELDS OF TABLE TEMP_MATDOC
      FROM MATDOC
     WHERE BUDAT > P_DATE
       AND CPUDT > P_DATE
       AND MATNR = P_MATNR
       AND CHARG = P_CHARG.
**
    SELECT WERKS    "플랜트
           MATNR    "자재번호
           CHARG    "배치번호
           BUDAT    "전기일
           MENGE    "전기수량(=체류일수량)
           MEINS    "단위
           MBLNR    "자재문서번호
           PRCTR    "손익센터
           BWART    "이동유형
           SHKZG    "차변/대변 지시자
      APPENDING CORRESPONDING FIELDS OF TABLE TEMP_MATDOC
      FROM ZARIXMM1
     WHERE BUDAT > P_DATE
       AND CPUDT > P_DATE
       AND MATNR = P_MATNR
       AND CHARG = P_CHARG.
**
  ENDIF.

ENDFORM.                    " SELECT_matdoc
*&---------------------------------------------------------------------*
*&      Form  CHECK_DATE
*&---------------------------------------------------------------------*
*       text : 입력 생성일과 최근 생성일 비교
*----------------------------------------------------------------------*
*      -->P_CHECK  text
*      -->P_MAX_DATE  text
*----------------------------------------------------------------------*
FORM CHECK_DATE  USING    P_CHECK
                          P_MAX_DATE.

  DATA : LV_MDATE LIKE SY-DATUM,
         LV_MATNR LIKE ZPPT0149-MATNR,
         LV_WERKS LIKE ZPPT0149-WERKS.

  CLEAR : LV_MDATE, TEMP_0149, TEMP_0149[].

  SELECT SINGLE MATNR
                WERKS
                MAX( MDATE )       "생성일자
   INTO (LV_MATNR,
         LV_WERKS,
         LV_MDATE)
     FROM ZPPT0149
    WHERE WERKS IN S_PWERK
      AND MATNR IN S_MATNR
   GROUP BY BUDAT MATNR WERKS.

  IF LV_MDATE > P_DATE.
    "생성 요청 날짜가 생성된 데이터 이전일 경우
    P_CHECK = 'X'.
  ENDIF.

  P_MAX_DATE = LV_MDATE .

ENDFORM.                    " CHECK_DATE
*&---------------------------------------------------------------------*
*&      Form  CNT_ZPPT0149J
*&---------------------------------------------------------------------*
*       text : zppt0149j 테이블 확인
*----------------------------------------------------------------------*
*      -->P_CNT    text
*      -->P_WERKS  text
*      -->P_MATNR  text
*      -->P_LGORT  text
*      -->P_CHARG  text
*      -->P_GUBUN  text
*----------------------------------------------------------------------*
FORM CNT_ZPPT0149J  USING    P_CNT
                             P_WERKS
                             P_MATNR
                             P_LGORT
                             P_CHARG
                             P_GUBUN.

  DATA : LV_CNT0149J  TYPE I.
  CLEAR : LV_CNT0149J.

  IF P_GUBUN = 'S'.            "0149j에 해당 날짜의 데이터 있는지 검색

    SELECT COUNT( * )
      INTO LV_CNT0149J
      FROM ZPPT0149J
     WHERE MDATE = P_DATE
       AND WERKS IN S_PWERK.

  ELSE.                        "0149j에 기존 정보가 있는지 확인
    SELECT COUNT( * )
    INTO LV_CNT0149J
    FROM  ZPPT0149J
    WHERE MDATE = P_DATE
      AND WERKS = P_WERKS
      AND MATNR = P_MATNR
      AND LGORT = P_LGORT
      AND CHARG = P_CHARG.

  ENDIF.

  P_CNT = LV_CNT0149J.

ENDFORM.                    " CNT_ZPPT0149J
*&---------------------------------------------------------------------*
*&      Form  DEL_0149J
*&---------------------------------------------------------------------*
*       text : zppt0149j 삭제
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DEL_0149J .

  DELETE FROM ZPPT0149J
        WHERE MDATE = P_DATE
          AND WERKS IN S_PWERK
          AND MATNR IN S_MATNR.

  IF SY-SUBRC <> 0.
    ROLLBACK WORK.
  ELSE.
    COMMIT WORK.
  ENDIF.

ENDFORM.                                                    " DEL_0149J
*&---------------------------------------------------------------------*
*&      Form  GET_0149J
*&---------------------------------------------------------------------*
*       text : 0149j 테이블 값 가져오기
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_0149J.

*& 2009.12.01 마감결과 반영시 이전 데이타는 삭제
  DELETE FROM ZPPT0149J
        WHERE MDATE = P_DATE
          AND WERKS IN S_PWERK
          AND MATNR IN S_MATNR
          AND NWERKS NE 'X'.

  COMMIT WORK.

  SELECT *
   INTO CORRESPONDING FIELDS OF TABLE TEMP_0149J
   FROM ZPPT0149J
  WHERE MDATE = P_DATE
    AND WERKS IN S_PWERK
    AND MATNR IN S_MATNR.


ENDFORM.                                                    " GET_0149J
*&---------------------------------------------------------------------*
*&      Form  GET_STOCK_CLOSING
*&---------------------------------------------------------------------*
*       text : 해당 조건에 해당하는 자재문서 검색
*----------------------------------------------------------------------*
*      -->P_WERKS  text
*      -->P_MATNR  text
*      -->P_LGORT  text
*      -->P_CHARG  text
*      -->P_STOCKMAF  text
*----------------------------------------------------------------------*
FORM GET_STOCK_CLOSING.

  DATA : LV_FIRST(08)     TYPE C,
         LV_LAST(08)      TYPE C,
         LV_SYSDATE(06)   TYPE C,
         LV_YEAR(04)      TYPE C,
         LV_MONTH(02)     TYPE C,
         LV_DATE(06)      TYPE C,
         LV_SYS_FIRST(08) TYPE C.

  DATA: LT_TEMP     LIKE TEMP_MATDOC OCCURS 0 WITH HEADER LINE.

  CLEAR : LV_FIRST, LV_LAST, LV_DATE, LV_SYSDATE, LV_SYS_FIRST,
          TEMP_COLLECT, TEMP_COLLECT[], TEMP_MATDOC, TEMP_MATDOC[],
          LT_TEMP, LT_TEMP[].

  REFRESH : LT_TEMP.

  LV_YEAR  = P_DATE+0(4).
  LV_MONTH = P_DATE+4(2).
  IF LV_MONTH = '12'.
    LV_YEAR  = LV_YEAR + 1.
    LV_MONTH = '01'.
    CONCATENATE LV_YEAR LV_MONTH '01' INTO LV_SYS_FIRST.
  ELSE.

    LV_SYSDATE = P_DATE+0(6) + 1.
    CONCATENATE LV_SYSDATE '01' INTO LV_SYS_FIRST.
  ENDIF.

  LV_DATE  = P_DATE+0(6).
  CONCATENATE LV_DATE '01' INTO LV_FIRST.
*  CONCATENATE lv_date '31' INTO lv_last.
  LV_LAST = P_DATE.

**결산 부분은 zarixmm1 사용 안함.
  SELECT A~WERKS
         A~MATNR
         A~LGORT
         A~CHARG
         A~MENGE
         A~MEINS
         A~SHKZG
         A~BWART
   INTO CORRESPONDING FIELDS OF TABLE LT_TEMP
   FROM MATDOC AS A INNER JOIN MARA AS B
                      ON A~MATNR = B~MATNR
   WHERE A~BUDAT BETWEEN LV_FIRST AND LV_LAST
     AND A~CPUDT BETWEEN LV_SYS_FIRST  AND SY-DATUM
     AND A~WERKS IN S_PWERK
     AND A~MATNR IN S_MATNR
     AND A~LGORT <> SPACE
     AND B~MTART IN ('FERT', 'HALB', 'HAWA', 'MACF', 'MACH', 'MCFE',
                     'MCHA', 'MCRO', 'MCHF' , 'MFER', 'MHAL', 'MRH1',
                     'ROH', 'ROH1', 'ZCSF', 'ZCSH', 'MHAW').

  DELETE LT_TEMP WHERE BWART = '633' OR BWART = '634' OR
                       BWART = 'Z43' OR BWART = 'Z44'.


  SORT LT_TEMP DESCENDING BY WERKS MATNR LGORT CHARG.

  LOOP AT LT_TEMP.
    IF LT_TEMP-SHKZG = 'S'.
      LT_TEMP-MENGE = LT_TEMP-MENGE.
    ELSE.
      LT_TEMP-MENGE = -1 * LT_TEMP-MENGE.
    ENDIF.

    CLEAR : LT_TEMP-BWART, LT_TEMP-SHKZG.
    COLLECT LT_TEMP INTO TEMP_MATDOC.
    CLEAR : TEMP_MATDOC.
  ENDLOOP.

  DELETE TEMP_MATDOC WHERE MENGE = 0.

ENDFORM.                    " GET_STOCK_CLOSING
*&---------------------------------------------------------------------*
*&      Form  GET_STOCK_CLOSING
*&---------------------------------------------------------------------*
*       text : 해당 조건에 해당하는 자재문서 검색
*----------------------------------------------------------------------*
*      -->P_WERKS  text
*      -->P_MATNR  text
*      -->P_LGORT  text
*      -->P_CHARG  text
*      -->P_STOCKMAF  text
*----------------------------------------------------------------------*
FORM GET_STOCK_CLOSING_DEL.

  DATA : LV_FIRST(08)     TYPE C,
         LV_LAST(08)      TYPE C,
         LV_SYSDATE(06)   TYPE C,
         LV_YEAR(04)      TYPE C,
         LV_MONTH(02)     TYPE C,
         LV_DATE(06)      TYPE C,
         LV_SYS_FIRST(08) TYPE C,
         LV_TIME          TYPE MATDOC-CPUTM.

  DATA: LT_TEMP     LIKE TEMP_MATDOC OCCURS 0 WITH HEADER LINE.

  CLEAR : LV_FIRST, LV_LAST, LV_DATE, LV_SYSDATE, LV_SYS_FIRST,
          TEMP_COLLECT, TEMP_COLLECT[], TEMP_MATDOC, TEMP_MATDOC[],
          LT_TEMP, LT_TEMP[], LV_TIME.

  REFRESH : LT_TEMP.

  LV_TIME =  '150000'.

  SELECT A~WERKS
         A~MATNR
         A~LGORT
         A~CHARG
         A~MENGE
         A~MEINS
         A~SHKZG
*         a~bwart
   INTO CORRESPONDING FIELDS OF TABLE LT_TEMP
   FROM MATDOC AS A INNER JOIN MARA AS B
                      ON A~MATNR = B~MATNR
   WHERE A~BUDAT BETWEEN '20140301' AND '20140307'
     AND ( ( A~CPUDT BETWEEN '20140301' AND '20140307' ) OR
           ( A~CPUDT = '20140307' AND A~CPUTM < LV_TIME ) )
     AND A~WERKS IN S_PWERK
     AND A~MATNR IN S_MATNR
     AND A~LGORT <> SPACE
     AND A~BWART <> '633'
     AND B~MTART IN ('FERT', 'HALB', 'HAWA', 'MACF', 'MACH', 'MCFE',
                     'MCHA', 'MCRO', 'MCHF' , 'MFER', 'MHAL', 'MRH1',
                     'ROH', 'ROH1', 'ZCSF', 'ZCSH', 'MHAW').

  SELECT A~WERKS
         A~MATNR
         A~LIFNR AS LGORT
         A~CHARG
         A~MENGE
         A~MEINS
         A~SHKZG
*         a~bwart
   APPENDING CORRESPONDING FIELDS OF TABLE LT_TEMP
   FROM MATDOC AS A INNER JOIN MARA AS B
                      ON A~MATNR = B~MATNR
   WHERE A~BUDAT BETWEEN '20140301' AND '20140307'
     AND ( ( A~CPUDT BETWEEN '20140301' AND '20140307' ) OR
           ( A~CPUDT = '20140307' AND A~CPUTM < LV_TIME ) )
     AND A~WERKS IN S_PWERK
     AND A~MATNR IN S_MATNR
     AND A~LIFNR <> SPACE
     AND A~BWART <> '633'
     AND B~MTART IN ('FERT', 'HALB', 'HAWA', 'MACF', 'MACH', 'MCFE',
                     'MCHA', 'MCRO', 'MCHF' , 'MFER', 'MHAL', 'MRH1',
                     'ROH', 'ROH1', 'ZCSF', 'ZCSH', 'MHAW').

  SORT LT_TEMP DESCENDING BY WERKS MATNR LGORT CHARG.

  LOOP AT LT_TEMP.
    IF LT_TEMP-SHKZG = 'S'.
      "임시 자재문서 조회는 차변/대변 역으로
      LT_TEMP-MENGE = -1 * LT_TEMP-MENGE.
    ELSE.
      LT_TEMP-MENGE = LT_TEMP-MENGE.
    ENDIF.

    CLEAR : LT_TEMP-BWART, LT_TEMP-SHKZG.
    COLLECT LT_TEMP INTO TEMP_MATDOC.
    CLEAR : TEMP_MATDOC.
  ENDLOOP.

  DELETE TEMP_MATDOC WHERE MENGE = 0.

ENDFORM.                    " GET_STOCK_CLOSING_del

*&---------------------------------------------------------------------*
*&      Form  SELECT_STOCKM
*&---------------------------------------------------------------------*
*       text : zppt0149j 에서 해당 플랜트의 STOCKM 가져오기
*----------------------------------------------------------------------*
*      -->P_TEMP_matdoc_WERKS  text
*      -->P_TEMP_matdoc_MATNR  text
*      -->P_TEMP_matdoc_LGORT  text
*      -->P_TEMP_matdoc_CHARG  text
*      -->P_LV_STOCK  text
*----------------------------------------------------------------------*
FORM SELECT_STOCKM  USING    P_WERKS
                             P_MATNR
                             P_LGORT
                             P_CHARG
                             P_STOCK.

  SELECT SINGLE STOCKM
    INTO P_STOCK
    FROM ZPPT0149J
   WHERE MDATE = P_DATE
     AND WERKS = P_WERKS
     AND MATNR = P_MATNR
     AND LGORT = P_LGORT
     AND CHARG = P_CHARG.


ENDFORM.                    " SELECT_STOCKM
*&---------------------------------------------------------------------*
*&      Form  GET_matdoc_ZARIXMM1_CHARG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_WERKS  text
*      -->P_P_MATNR  text
*      -->P_P_LGORT  text
*      -->P_P_CHARG  text
*      -->P_LV_DATE  text
*----------------------------------------------------------------------*
FORM GET_MATDOC_ZARIXMM1_CHARG  USING    P_WERKS
                                        P_MATNR
                                        P_LGORT
                                        P_CHARG.
  DATA : LV_DATE  LIKE SY-DATUM,
         LV_SUM   LIKE MATDOC-MENGE,
         LV_WERKS LIKE MARC-WERKS.

  DATA : LT_MATDOC   LIKE TEMP_MATDOC OCCURS 0 WITH HEADER LINE.

  CLEAR : LV_DATE.
  LV_DATE = GV_MDATE.

  IF STRLEN( TEMP_ACT-LGORT ) <= 4.   "사내 일 경우

    SELECT WERKS    "플랜트
           MATNR    "자재번호
           CHARG    "배치번호
           BUDAT    "전기일
           MENGE    "전기수량(=체류일수량)
           MEINS    "단위
           MBLNR    "자재문서번호
           ZEILE
           BWART    "이동유형
           EBELN
           UMWRK
    INTO CORRESPONDING FIELDS OF TABLE TEMP_MATDOC
      FROM MATDOC
  WHERE BUDAT BETWEEN GV_DATE AND P_DATE
       AND WERKS = P_WERKS
       AND MATNR = P_MATNR
       AND CHARG = P_CHARG
       AND MENGE > 0
       AND ( BWART IN ('131', '501', '511', '521', '561',
*-{기능개선_194560 161제외, 459,455,457 추가
                      '459', '455', '457', '657') OR
           ( BWART IN ('309','903', '301', '453') AND SHKZG = 'S')
           OR
           ( BWART = '101' AND SOBKZ NE 'O') )
       AND SMBLN = SPACE
       %_HINTS ORACLE 'INDEX("matdoc" "matdoc~Z03")'.

    IF GV_DATE < GV_ADATE.    "조회 날짜보다 아카이빙 이전일 경우

      SELECT WERKS    "플랜트
             MATNR    "자재번호
             CHARG    "배치번호
             BUDAT    "전기일
             MENGE    "전기수량(=체류일수량)
             MEINS    "단위
             MBLNR    "자재문서번호
             ZEILE
             BWART    "이동유형
             EBELN
             UMWRK
       APPENDING CORRESPONDING FIELDS OF TABLE TEMP_MATDOC
        FROM ZARIXMM1
       WHERE BUDAT BETWEEN GV_DATE AND P_DATE
         AND WERKS = P_WERKS
         AND MATNR = P_MATNR
         AND CHARG = P_CHARG
         AND MENGE > 0
         AND ( BWART IN ('131', '501', '511', '521', '561',
*-{기능개선_194560 161제외, 459,455,457 추가
                      '459', '455', '457', '657') OR
            ( BWART IN ('309','903', '301', '453') AND SHKZG = 'S')
                OR
              ( BWART = '101' AND SOBKZ NE 'O') )
         AND SMBLN = SPACE
          %_HINTS ORACLE 'INDEX("ZARIXMM1" "ZARIXMM1~Z03")'.
    ENDIF.

    IF TEMP_MATDOC[] IS INITIAL.  "없을 경우 werks 조건 제외

      SELECT WERKS    "플랜트
             MATNR    "자재번호
             CHARG    "배치번호
             BUDAT    "전기일
             MENGE    "전기수량(=체류일수량)
             MEINS    "단위
             MBLNR    "자재문서번호
             ZEILE
             BWART    "이동유형
             EBELN
             UMWRK
        INTO CORRESPONDING FIELDS OF TABLE TEMP_MATDOC
        FROM MATDOC
  WHERE BUDAT BETWEEN GV_DATE AND P_DATE
         AND MATNR = P_MATNR
         AND CHARG = P_CHARG
         AND MENGE > 0
         AND ( BWART IN ('131', '501', '511', '521', '561',
*-{기능개선_194560 161제외, 459,455,457 추가
                      '459', '455', '457', '657') OR
           ( BWART IN ('309','903', '301', '453') AND SHKZG = 'S')
           OR
           ( BWART = '101' AND SOBKZ NE 'O') )
         AND SMBLN = SPACE
         %_HINTS ORACLE 'INDEX("matdoc" "matdoc~Z03")'.

      IF GV_DATE < GV_ADATE.    "조회 날짜보다 아카이빙 이전일 경우

        SELECT WERKS    "플랜트
               MATNR    "자재번호
               CHARG    "배치번호
               BUDAT    "전기일
               MENGE    "전기수량(=체류일수량)
               MEINS    "단위
               MBLNR    "자재문서번호
               ZEILE
               BWART    "이동유형
               EBELN
               UMWRK
           APPENDING CORRESPONDING FIELDS OF TABLE TEMP_MATDOC
          FROM ZARIXMM1
         WHERE BUDAT BETWEEN GV_DATE AND P_DATE
           AND MATNR = P_MATNR
           AND CHARG = P_CHARG
           AND MENGE > 0
           AND ( BWART IN ('131', '501', '511', '521', '561',
*-{기능개선_194560 161제외, 459,455,457 추가
                      '459', '455', '457', '657') OR
            ( BWART IN ('309','903', '301', '453') AND SHKZG = 'S')
             OR
             ( BWART = '101' AND SOBKZ NE 'O') )
           AND SMBLN = SPACE.
      ENDIF.
    ENDIF.

    CLEAR : TEMP_MATDOC1, TEMP_MATDOC1[].

    SELECT WERKS    "플랜트
           MATNR    "자재번호
           CHARG    "배치번호
           BUDAT    "전기일
           MENGE    "전기수량(=체류일수량)
           MEINS    "단위
           MBLNR    "자재문서번호
           PRCTR    "손익센터
           BWART    "이동유형
    INTO CORRESPONDING FIELDS OF TABLE TEMP_MATDOC1
      FROM ZPPT0149
     WHERE MDATE = LV_DATE
       AND WERKS = P_WERKS
       AND MATNR = P_MATNR
       AND CHARG = P_CHARG
       AND LGORT = P_LGORT
       AND BRANCHG <> 'Z'.

  ELSE.   "외주 일 경우

    SELECT WERKS    "플랜트
           MATNR    "자재번호
           CHARG    "배치번호
           BUDAT    "전기일
           MENGE    "전기수량(=체류일수량)
           MEINS    "단위
           MBLNR    "자재문서번호
           ZEILE
           BWART    "이동유형
    INTO CORRESPONDING FIELDS OF TABLE TEMP_MATDOC
      FROM MATDOC
    WHERE BUDAT BETWEEN GV_DATE AND P_DATE
       AND WERKS = P_WERKS
       AND MATNR = P_MATNR
       AND CHARG = P_CHARG
       AND BWART = '541'
       AND SHKZG = 'S'
       AND LIFNR = P_LGORT
       AND MENGE > 0
       AND SMBLN = SPACE
       %_HINTS ORACLE 'INDEX("matdoc" "matdoc~Z03")'.

    IF GV_DATE < GV_ADATE.    "조회 날짜보다 아카이빙 이전일 경우

      SELECT WERKS    "플랜트
             MATNR    "자재번호
             CHARG    "배치번호
             BUDAT    "전기일
             MENGE    "전기수량(=체류일수량)
             MEINS    "단위
             MBLNR    "자재문서번호
             ZEILE
             BWART    "이동유형
       APPENDING CORRESPONDING FIELDS OF TABLE TEMP_MATDOC
          FROM ZARIXMM1
       WHERE BUDAT BETWEEN GV_DATE AND P_DATE
         AND WERKS = P_WERKS
         AND MATNR = P_MATNR
         AND CHARG = P_CHARG
         AND BWART = '541'
         AND SHKZG = 'S'
         AND LIFNR = P_LGORT
         AND MENGE > 0
         AND SMBLN = SPACE
          %_HINTS ORACLE 'INDEX("ZARIXMM1" "ZARIXMM1~Z03")'.

    ENDIF.
**
*& 2008.04.30 외주 직납분 추가
    SELECT WERKS    "플랜트
           MATNR    "자재번호
           CHARG    "배치번호
           BUDAT    "전기일
           MENGE    "전기수량(=체류일수량)
           MEINS    "단위
           MBLNR    "자재문서번호
           ZEILE
           BWART    "이동유형
    APPENDING CORRESPONDING FIELDS OF TABLE TEMP_MATDOC
      FROM MATDOC
     WHERE BUDAT BETWEEN GV_DATE AND P_DATE
       AND WERKS = P_WERKS
       AND MATNR = P_MATNR
       AND CHARG = P_CHARG
       AND SHKZG = 'S'
       AND BWART = '101'
       AND SOBKZ = 'O'
       AND MENGE > 0
       AND EMLIF = P_LGORT
       AND SMBLN = SPACE
       %_HINTS ORACLE 'INDEX("matdoc" "matdoc~Z03")'.

    IF TEMP_MATDOC[] IS INITIAL.  "없을 경우 werks 조건 제외

      SELECT WERKS    "플랜트
             MATNR    "자재번호
             CHARG    "배치번호
             BUDAT    "전기일
             MENGE    "전기수량(=체류일수량)
             MEINS    "단위
             MBLNR    "자재문서번호
             ZEILE
             BWART    "이동유형
        INTO CORRESPONDING FIELDS OF TABLE TEMP_MATDOC
        FROM MATDOC
     WHERE BUDAT BETWEEN GV_DATE AND P_DATE
         AND MATNR = P_MATNR
         AND CHARG = P_CHARG
         AND SHKZG = 'S'
         AND BWART = '541'
         AND LIFNR = P_LGORT
         AND MENGE > 0
         AND SMBLN = SPACE
         %_HINTS ORACLE 'INDEX("matdoc" "matdoc~Z03")'.

      IF GV_DATE < GV_ADATE.    "조회 날짜보다 아카이빙 이전일 경우

        SELECT WERKS    "플랜트
               MATNR    "자재번호
               CHARG    "배치번호
               BUDAT    "전기일
               MENGE    "전기수량(=체류일수량)
               MEINS    "단위
               MBLNR    "자재문서번호
               ZEILE
               BWART    "이동유형
          APPENDING CORRESPONDING FIELDS OF TABLE TEMP_MATDOC
          FROM ZARIXMM1
       WHERE BUDAT BETWEEN GV_DATE AND P_DATE
           AND MATNR = P_MATNR
           AND CHARG = P_CHARG
           AND SHKZG = 'S'
           AND BWART = '541'
           AND LIFNR = P_LGORT
           AND MENGE > 0
           AND SMBLN = SPACE.
      ENDIF.

      SELECT WERKS    "플랜트
             MATNR    "자재번호
             CHARG    "배치번호
             BUDAT    "전기일
             MENGE    "전기수량(=체류일수량)
             MEINS    "단위
             MBLNR    "자재문서번호
             ZEILE
             BWART    "이동유형
        APPENDING CORRESPONDING FIELDS OF TABLE TEMP_MATDOC
        FROM MATDOC
     WHERE BUDAT BETWEEN GV_DATE AND P_DATE
         AND MATNR = P_MATNR
         AND CHARG = P_CHARG
        AND SHKZG = 'S'
         AND BWART = '101'
         AND SOBKZ = 'O'
         AND EMLIF = P_LGORT
         AND MENGE > 0
         AND SMBLN = SPACE
         %_HINTS ORACLE 'INDEX("matdoc" "matdoc~Z03")'.

    ENDIF.

    CLEAR : TEMP_MATDOC1, TEMP_MATDOC1[].

    SELECT WERKS    "플랜트
       MATNR    "자재번호
       CHARG    "배치번호
       BUDAT    "전기일
       MENGE    "전기수량(=체류일수량)
       MEINS    "단위
       MBLNR    "자재문서번호
       PRCTR    "손익센터
       BWART    "이동유형
    INTO CORRESPONDING FIELDS OF TABLE TEMP_MATDOC1
      FROM ZPPT0149
     WHERE MDATE = LV_DATE
       AND WERKS = P_WERKS
       AND MATNR = P_MATNR
       AND CHARG = P_CHARG
       AND LGORT = P_LGORT
       AND BRANCHG <> 'Z'.

  ENDIF.

* 2023.12.08 HANA 마이그레이션 반영
  DELETE TEMP_MATDOC WHERE BWART = '561'
                                    AND BUDAT BETWEEN '20231228' AND '20240105'.

* 2024.02.08 1301->1407 이전 반영
  DELETE TEMP_MATDOC WHERE BWART = '301'
                                    AND ( BUDAT = '20240301' OR BUDAT = '20240304' )
                                    AND WERKS = '1407'
                                    AND UMWRK = '1301'.

  DELETE TEMP_MATDOC WHERE BWART = '541'
                                    AND BUDAT = '20240301'
                                    AND WERKS = '1407'.

ENDFORM.          " GET_matdoc_ZARIXMM1_CHARG
*----------------------------------------------------------------------*
*&      Form  GET_matdoc_ZARIXMM1_NOCHARG
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_P_WERKS  text
*      -->P_P_MATNR  text
*      -->P_P_LGORT  text
*----------------------------------------------------------------------*
FORM GET_MATDOC_ZARIXMM1_NOCHARG  USING    P_WERKS
                                          P_MATNR
                                          P_LGORT.
  DATA : LV_DATE  LIKE SY-DATUM,
         LV_SUM   LIKE MATDOC-MENGE,
         LV_WERKS LIKE MARC-WERKS.

  DATA : LT_MATDOC   LIKE TEMP_MATDOC OCCURS 0 WITH HEADER LINE.

  CLEAR : LV_DATE.
  LV_DATE = GV_MDATE.

  IF STRLEN( TEMP_ACT-LGORT ) <= 4.   "사내 일 경우

    SELECT WERKS    "플랜트
           MATNR    "자재번호
           CHARG    "배치번호
           BUDAT    "전기일
           MENGE    "전기수량(=체류일수량)
           MEINS    "단위
           MBLNR    "자재문서번호
           ZEILE
           BWART    "이동유형
           EBELN
           UMWRK
    INTO CORRESPONDING FIELDS OF TABLE TEMP_MATDOC
      FROM MATDOC
  WHERE BUDAT BETWEEN GV_DATE AND P_DATE
       AND WERKS = P_WERKS
       AND MATNR = P_MATNR
        AND MENGE > 0
       AND ( BWART IN ('131', '501', '511', '521', '561',
*-{기능개선_194560 161제외, 459,455,457 추가
                        '459', '455', '457', '657') OR
           ( BWART IN ('309','903', '301', '453') AND SHKZG = 'S')
           OR
           ( BWART = '101' AND SOBKZ NE 'O') )
       AND SMBLN = SPACE.

    IF GV_DATE < GV_ADATE.    "조회 날짜보다 아카이빙 이전일 경우

      SELECT WERKS    "플랜트
             MATNR    "자재번호
             CHARG    "배치번호
             BUDAT    "전기일
             MENGE    "전기수량(=체류일수량)
             MEINS    "단위
             MBLNR    "자재문서번호
             ZEILE
             BWART    "이동유형
             EBELN
             UMWRK
       APPENDING CORRESPONDING FIELDS OF TABLE TEMP_MATDOC
        FROM ZARIXMM1
       WHERE BUDAT BETWEEN GV_DATE AND P_DATE
         AND WERKS = P_WERKS
         AND MATNR = P_MATNR
         AND MENGE > 0
         AND ( BWART IN ('131', '501', '511', '521', '561',
*-{기능개선_194560 161제외, 459,455,457 추가
                        '459', '455', '457', '657') OR
            ( BWART IN ('309','903', '301', '453') AND SHKZG = 'S')
                OR
              ( BWART = '101' AND SOBKZ NE 'O') )
         AND SMBLN = SPACE
          %_HINTS ORACLE 'INDEX("ZARIXMM1" "ZARIXMM1~Z03")'.
    ENDIF.

    IF TEMP_MATDOC[] IS INITIAL.  "없을 경우 werks 조건 제외

      SELECT WERKS    "플랜트
             MATNR    "자재번호
             CHARG    "배치번호
             BUDAT    "전기일
             MENGE    "전기수량(=체류일수량)
             MEINS    "단위
             MBLNR    "자재문서번호
             ZEILE
             BWART    "이동유형
             EBELN
             UMWRK
        INTO CORRESPONDING FIELDS OF TABLE TEMP_MATDOC
        FROM MATDOC
  WHERE BUDAT BETWEEN GV_DATE AND P_DATE
         AND MATNR = P_MATNR
         AND MENGE > 0
         AND ( BWART IN ('131', '501', '511', '521', '561',
*-{기능개선_194560 161제외, 459,455,457 추가
                        '459', '455', '457', '657') OR
           ( BWART IN ('309','903', '301', '453') AND SHKZG = 'S')
           OR
           ( BWART = '101' AND SOBKZ NE 'O') )
         AND SMBLN = SPACE.

      IF GV_DATE < GV_ADATE.    "조회 날짜보다 아카이빙 이전일 경우

        SELECT WERKS    "플랜트
               MATNR    "자재번호
               CHARG    "배치번호
               BUDAT    "전기일
               MENGE    "전기수량(=체류일수량)
               MEINS    "단위
               MBLNR    "자재문서번호
               ZEILE
               BWART    "이동유형
               EBELN
               UMWRK
           APPENDING CORRESPONDING FIELDS OF TABLE TEMP_MATDOC
          FROM ZARIXMM1
         WHERE BUDAT BETWEEN GV_DATE AND P_DATE
           AND MATNR = P_MATNR
           AND MENGE > 0
           AND ( BWART IN ('131', '501', '511', '521', '561',
*-{기능개선_194560 161제외, 459,455,457 추가
                        '459', '455', '457', '657') OR
            ( BWART IN ('309','903', '301', '453') AND SHKZG = 'S')
             OR
             ( BWART = '101' AND SOBKZ NE 'O') )
           AND SMBLN = SPACE.
      ENDIF.

    ENDIF.

    CLEAR : TEMP_MATDOC1, TEMP_MATDOC1[].

    SELECT WERKS    "플랜트
           MATNR    "자재번호
           CHARG    "배치번호
           BUDAT    "전기일
           MENGE    "전기수량(=체류일수량)
           MEINS    "단위
           MBLNR    "자재문서번호
           PRCTR    "손익센터
           BWART    "이동유형
    INTO CORRESPONDING FIELDS OF TABLE TEMP_MATDOC1
      FROM ZPPT0149
     WHERE MDATE = LV_DATE
       AND WERKS = P_WERKS
       AND MATNR = P_MATNR
       AND LGORT = P_LGORT
       AND BRANCHG <> 'Z'.

  ELSE.   "외주 일 경우

    SELECT WERKS    "플랜트
           MATNR    "자재번호
           CHARG    "배치번호
           BUDAT    "전기일
           MENGE    "전기수량(=체류일수량)
           MEINS    "단위
           MBLNR    "자재문서번호
           ZEILE
           BWART    "이동유형
    INTO CORRESPONDING FIELDS OF TABLE TEMP_MATDOC
      FROM MATDOC
    WHERE BUDAT BETWEEN GV_DATE AND P_DATE
       AND WERKS = P_WERKS
       AND MATNR = P_MATNR
       AND BWART = '541'
       AND SHKZG = 'S'
       AND LIFNR = P_LGORT
       AND MENGE > 0
       AND SMBLN = SPACE.

    IF GV_DATE < GV_ADATE.    "조회 날짜보다 아카이빙 이전일 경우

      SELECT WERKS    "플랜트
             MATNR    "자재번호
             CHARG    "배치번호
             BUDAT    "전기일
             MENGE    "전기수량(=체류일수량)
             MEINS    "단위
             MBLNR    "자재문서번호
             ZEILE
             BWART    "이동유형
       APPENDING CORRESPONDING FIELDS OF TABLE TEMP_MATDOC
          FROM ZARIXMM1
       WHERE BUDAT BETWEEN GV_DATE AND P_DATE
         AND WERKS = P_WERKS
         AND MATNR = P_MATNR
         AND BWART = '541'
         AND SHKZG = 'S'
         AND LIFNR = P_LGORT
         AND MENGE > 0
         AND SMBLN = SPACE
          %_HINTS ORACLE 'INDEX("ZARIXMM1" "ZARIXMM1~Z03")'.

    ENDIF.
**
*& 2008.04.30 외주 직납분 추가
    SELECT WERKS    "플랜트
           MATNR    "자재번호
           CHARG    "배치번호
           BUDAT    "전기일
           MENGE    "전기수량(=체류일수량)
           MEINS    "단위
           MBLNR    "자재문서번호
           ZEILE
           BWART    "이동유형
    APPENDING CORRESPONDING FIELDS OF TABLE TEMP_MATDOC
      FROM MATDOC
     WHERE BUDAT BETWEEN GV_DATE AND P_DATE
       AND WERKS = P_WERKS
       AND MATNR = P_MATNR
       AND SHKZG = 'S'
       AND BWART = '101'
       AND SOBKZ = 'O'
       AND MENGE > 0
       AND EMLIF = P_LGORT
       AND SMBLN = SPACE.

    IF TEMP_MATDOC[] IS INITIAL.  "없을 경우 werks 조건 제외

      SELECT WERKS    "플랜트
             MATNR    "자재번호
             CHARG    "배치번호
             BUDAT    "전기일
             MENGE    "전기수량(=체류일수량)
             MEINS    "단위
             MBLNR    "자재문서번호
             ZEILE
             BWART    "이동유형
        INTO CORRESPONDING FIELDS OF TABLE TEMP_MATDOC
        FROM MATDOC
     WHERE BUDAT BETWEEN GV_DATE AND P_DATE
         AND MATNR = P_MATNR
         AND SHKZG = 'S'
         AND BWART = '541'
         AND LIFNR = P_LGORT
         AND MENGE > 0
         AND SMBLN = SPACE.

      IF GV_DATE < GV_ADATE.    "조회 날짜보다 아카이빙 이전일 경우

        SELECT WERKS    "플랜트
               MATNR    "자재번호
               CHARG    "배치번호
               BUDAT    "전기일
               MENGE    "전기수량(=체류일수량)
               MEINS    "단위
               MBLNR    "자재문서번호
               ZEILE
               BWART    "이동유형
          APPENDING CORRESPONDING FIELDS OF TABLE TEMP_MATDOC
          FROM ZARIXMM1
       WHERE BUDAT BETWEEN GV_DATE AND P_DATE
           AND MATNR = P_MATNR
           AND SHKZG = 'S'
           AND BWART = '541'
           AND LIFNR = P_LGORT
           AND MENGE > 0
           AND SMBLN = SPACE.
      ENDIF.

      SELECT WERKS    "플랜트
             MATNR    "자재번호
             CHARG    "배치번호
             BUDAT    "전기일
             MENGE    "전기수량(=체류일수량)
             MEINS    "단위
             MBLNR    "자재문서번호
             ZEILE
             BWART    "이동유형
        APPENDING CORRESPONDING FIELDS OF TABLE TEMP_MATDOC
        FROM MATDOC
     WHERE BUDAT BETWEEN GV_DATE AND P_DATE
         AND MATNR = P_MATNR
        AND SHKZG = 'S'
         AND BWART = '101'
         AND SOBKZ = 'O'
         AND EMLIF = P_LGORT
         AND MENGE > 0
         AND SMBLN = SPACE.

    ENDIF.
  ENDIF.

  CLEAR : TEMP_MATDOC1, TEMP_MATDOC1[].

  SELECT WERKS    "플랜트
     MATNR    "자재번호
     CHARG    "배치번호
     BUDAT    "전기일
     MENGE    "전기수량(=체류일수량)
     MEINS    "단위
     MBLNR    "자재문서번호
     PRCTR    "손익센터
     BWART    "이동유형
  INTO CORRESPONDING FIELDS OF TABLE TEMP_MATDOC1
    FROM ZPPT0149
   WHERE MDATE = LV_DATE
     AND WERKS = P_WERKS
     AND MATNR = P_MATNR
     AND LGORT = P_LGORT
     AND BRANCHG <> 'Z'.

* 2023.12.08 HANA 마이그레이션 반영
  DELETE TEMP_MATDOC WHERE BWART = '561'
                                    AND BUDAT BETWEEN '20231228' AND '20240105'.

* 2024.02.08 1301->1407 이전 반영
  DELETE TEMP_MATDOC WHERE BWART = '301'
                                    AND ( BUDAT = '20240301' OR BUDAT = '20240304' )
                                    AND WERKS = '1407'
                                    AND UMWRK = '1301'.

  DELETE TEMP_MATDOC WHERE BWART = '541'
                                    AND BUDAT = '20240301'
                                    AND WERKS = '1407'.
ENDFORM.                    " GET_matdoc_ZARIXMM1_NOCHARG
