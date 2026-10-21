*----------------------------------------------------------------------*
***INCLUDE LZGTPP00F01.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form CONVERSION_INPUT_ZGTPPSIF0009
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CONVERSION_INPUT_ZGTPPSIF0009 .

  LOOP AT GT_ZGTPPSIF0009 INTO GS_ZGTPPSIF0009.

    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        INPUT  = GS_ZGTPPSIF0009-MATNR
      IMPORTING
        OUTPUT = GS_ZGTPPSIF0009-MATNR.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = GS_ZGTPPSIF0009-LIFNR
      IMPORTING
        OUTPUT = GS_ZGTPPSIF0009-LIFNR.


    MODIFY GT_ZGTPPSIF0009 FROM GS_ZGTPPSIF0009.
    CLEAR  GS_ZGTPPSIF0009.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_ALL_STOCK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_ALL_STOCK .

  RANGES : LR_WERKS FOR MARD-WERKS,
           LR_LGORT FOR MARD-LGORT.
  CLEAR: LR_WERKS, LR_WERKS[], LR_LGORT, LR_LGORT[].


  LOOP AT GT_ZGTPPSIF0009 INTO DATA(LS_ZGTPPSIF0009).

    IF LS_ZGTPPSIF0009-WERKS IS NOT INITIAL.
      CLEAR LR_WERKS.
      LR_WERKS-SIGN = 'I'.
      LR_WERKS-OPTION = 'EQ'.
      LR_WERKS-LOW = LS_ZGTPPSIF0009-WERKS.
      COLLECT LR_WERKS.
    ENDIF.
    IF LS_ZGTPPSIF0009-LGORT IS NOT INITIAL.
      CLEAR LR_LGORT.
      LR_LGORT-SIGN   = 'I'.
      LR_LGORT-OPTION = 'EQ'.
      LR_LGORT-LOW    = LS_ZGTPPSIF0009-LGORT.
      COLLECT LR_LGORT.
    ENDIF.

  ENDLOOP.


  IF GT_ZGTPPSIF0009 IS NOT INITIAL.
    "공급업체 재고
    SELECT A~MATNR A~WERKS A~CHARG A~SOBKZ A~LIFNR
          A~LBLAB AS KALAB A~LBINS AS INSME B~MEINS
     INTO CORRESPONDING FIELDS OF TABLE GT_ZGTPPSIF0010
     FROM MSLB AS A INNER JOIN MARA AS B
                       ON A~MATNR = B~MATNR
    WHERE A~WERKS IN LR_WERKS
      AND ( A~LBLAB NE 0
       OR   A~LBINS NE 0 ).

    "플랜트 재고
    SELECT B~MATNR B~WERKS B~LGORT B~LABST AS KALAB
           B~INSME B~SPEME B~RETME C~MEINS
 APPENDING CORRESPONDING FIELDS OF TABLE GT_ZGTPPSIF0010
      FROM MARC AS A INNER JOIN MARD AS B
                        ON A~MATNR = B~MATNR
                       AND A~WERKS = B~WERKS
                     INNER JOIN MARA AS C
                        ON A~MATNR = C~MATNR
     WHERE A~XCHAR = ' '
       AND B~WERKS IN LR_WERKS
       AND B~LGORT IN LR_LGORT
       AND B~LVORM = ' '
       AND ( B~LABST NE 0
        OR   B~INSME NE 0
        OR   B~SPEME NE 0 ).


    "배치 재고
    SELECT B~MATNR B~WERKS B~LGORT B~CHARG B~CLABS AS KALAB
           B~CINSM AS INSME B~CSPEM AS SPEME C~MEINS
 APPENDING CORRESPONDING FIELDS OF TABLE GT_ZGTPPSIF0010
      FROM MARC AS A INNER JOIN MCHB AS B
                        ON A~MATNR = B~MATNR
                       AND A~WERKS = B~WERKS
                     INNER JOIN MARA AS C
                        ON A~MATNR = C~MATNR
     WHERE A~XCHAR = 'X'
       AND B~LVORM = ' '
       AND A~WERKS IN LR_WERKS
       AND B~LGORT IN LR_LGORT
       AND ( B~CLABS NE 0
        OR   B~CINSM NE 0
        OR   B~CSPEM NE 0 ).


    "고객 특별 재고
    SELECT B~MATNR B~WERKS B~CHARG B~SOBKZ B~KUNNR
           B~KULAB AS KALAB B~KUINS AS INSME
           A~MEINS
 APPENDING CORRESPONDING FIELDS OF TABLE GT_ZGTPPSIF0010
      FROM MARA AS A INNER JOIN MSKU AS B
                        ON A~MATNR = B~MATNR
     WHERE B~WERKS IN LR_WERKS
       AND ( B~KULAB NE 0
        OR   B~KUINS NE 0 ).

    "판매오더 재고
    SELECT B~MATNR B~WERKS B~LGORT B~CHARG B~SOBKZ B~VBELN
           B~POSNR B~KALAB B~KAINS AS INSME B~KASPE AS SPEME
           A~MEINS
 APPENDING CORRESPONDING FIELDS OF TABLE GT_ZGTPPSIF0010
      FROM MARA AS A INNER JOIN MSKA AS B
                        ON A~MATNR = B~MATNR
     WHERE B~WERKS IN LR_WERKS
       AND B~LGORT IN LR_LGORT
       AND ( B~KALAB NE 0
        OR   B~KAINS NE 0
        OR   B~KASPE NE 0 ).

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RECEIVE_PLANT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM RECEIVE_PLANT .

  IF GT_ZGTPPSIF0009 IS NOT INITIAL.

*-LIFNR값 있으면 해당로직만 타고 EXIT.
    "공급업체번호에 값이 존재하는 경우
    IF GS_ZGTPPSIF0009-LIFNR IS NOT INITIAL.

      SELECT A~MATNR A~WERKS A~CHARG A~SOBKZ A~LIFNR
       A~LBLAB AS KALAB A~LBINS AS INSME B~MEINS
       INTO CORRESPONDING FIELDS OF TABLE GT_ZGTPPSIF0010
       FROM MSLB AS A
       INNER JOIN MARA AS B
       ON A~MATNR = B~MATNR
       FOR ALL ENTRIES IN GT_ZGTPPSIF0009
       WHERE A~WERKS  = GT_ZGTPPSIF0009-WERKS
         AND A~LIFNR =  GT_ZGTPPSIF0009-LIFNR
         AND ( A~LBLAB NE 0
           OR A~LBINS NE 0 ).
      EXIT.

    ELSE. "공급업체번호이 빈 값인 경우

      "플랜트 재고
      SELECT B~MATNR B~WERKS B~LGORT B~LABST AS KALAB
            B~INSME B~SPEME B~RETME C~MEINS
            INTO CORRESPONDING FIELDS OF TABLE GT_ZGTPPSIF0010
            FROM MARC AS A
            INNER JOIN MARD AS B
            ON   A~MATNR = B~MATNR
            AND  A~WERKS = B~WERKS
            INNER JOIN MARA AS C
            ON   A~MATNR = C~MATNR
            FOR ALL ENTRIES IN GT_ZGTPPSIF0009
            WHERE A~XCHAR = ' '
              AND B~WERKS = GT_ZGTPPSIF0009-WERKS
              AND B~LVORM = ' '
              AND ( B~LABST NE 0
                OR B~INSME NE 0
                OR B~SPEME NE 0 ).

      "배치 재고
      SELECT B~MATNR B~WERKS B~LGORT B~CHARG B~CLABS AS KALAB
             B~CINSM AS INSME B~CSPEM AS SPEME C~MEINS
             APPENDING CORRESPONDING FIELDS OF TABLE GT_ZGTPPSIF0010
             FROM MARC AS A
             INNER JOIN MCHB AS B
             ON   A~MATNR = B~MATNR
             AND  A~WERKS = B~WERKS
             INNER JOIN MARA AS C
             ON A~MATNR = C~MATNR
             FOR ALL ENTRIES IN GT_ZGTPPSIF0009
             WHERE A~XCHAR = 'X'
               AND B~LVORM = ' '
               AND A~WERKS = GT_ZGTPPSIF0009-WERKS
               AND ( B~CLABS NE 0
                  OR B~CINSM NE 0
                  OR B~CSPEM NE 0 ).

      "공급업체 재고
      SELECT A~MATNR A~WERKS A~CHARG A~SOBKZ A~LIFNR
             A~LBLAB AS KALAB A~LBINS AS INSME B~MEINS
             APPENDING CORRESPONDING FIELDS OF TABLE GT_ZGTPPSIF0010
             FROM MSLB AS A
             INNER JOIN MARA AS B
             ON A~MATNR = B~MATNR
             FOR ALL ENTRIES IN GT_ZGTPPSIF0009
             WHERE A~WERKS  = GT_ZGTPPSIF0009-WERKS
             AND ( A~LBLAB NE 0
                OR A~LBINS NE 0 ).

      "고객 특별 재고
      SELECT B~MATNR B~WERKS B~CHARG B~SOBKZ B~KUNNR
             B~KULAB AS KALAB B~KUINS AS INSME
             A~MEINS
             APPENDING CORRESPONDING FIELDS OF TABLE GT_ZGTPPSIF0010
             FROM MARA AS A
             INNER JOIN MSKU AS B
             ON A~MATNR = B~MATNR
             FOR ALL ENTRIES IN GT_ZGTPPSIF0009
             WHERE B~WERKS = GT_ZGTPPSIF0009-WERKS
             AND ( B~KULAB NE 0
               OR B~KUINS NE 0 ).

      "판매오더 재고
      SELECT B~MATNR B~WERKS B~LGORT B~CHARG B~SOBKZ B~VBELN
             B~POSNR B~KALAB B~KAINS AS INSME B~KASPE AS SPEME
             A~MEINS
             APPENDING CORRESPONDING FIELDS OF TABLE GT_ZGTPPSIF0010
             FROM MARA AS A
             INNER JOIN MSKA AS B
             ON A~MATNR = B~MATNR
             FOR ALL ENTRIES IN GT_ZGTPPSIF0009
             WHERE B~WERKS = GT_ZGTPPSIF0009-WERKS
             AND ( B~KALAB NE 0
               OR B~KAINS NE 0
               OR B~KASPE NE 0 ).
    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RECEIVE_P_L
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM RECEIVE_P_L .

  IF GT_ZGTPPSIF0009 IS NOT INITIAL.

    " 플랜트 재고
    SELECT B~MATNR B~WERKS B~LGORT B~LABST AS KALAB
          B~INSME B~SPEME B~RETME C~MEINS
          INTO CORRESPONDING FIELDS OF TABLE GT_ZGTPPSIF0010
          FROM MARC AS A
          INNER JOIN MARD AS B
          ON   A~MATNR = B~MATNR
          AND  A~WERKS = B~WERKS
          INNER JOIN MARA AS C
          ON A~MATNR = C~MATNR
          FOR ALL ENTRIES IN GT_ZGTPPSIF0009
          WHERE A~XCHAR = ' '
            AND B~WERKS = GT_ZGTPPSIF0009-WERKS
            AND B~LGORT = GT_ZGTPPSIF0009-LGORT
            AND B~LVORM = ' '
            AND ( B~LABST NE 0
              OR B~INSME NE 0
              OR B~SPEME NE 0 ).

    "배치 재고
    SELECT B~MATNR B~WERKS B~LGORT B~CHARG B~CLABS AS KALAB
           B~CINSM AS INSME B~CSPEM AS SPEME C~MEINS
           APPENDING CORRESPONDING FIELDS OF TABLE GT_ZGTPPSIF0010
      FROM MARC AS A INNER JOIN MCHB AS B
                        ON A~MATNR = B~MATNR
                       AND A~WERKS = B~WERKS
                     INNER JOIN MARA AS C
                        ON A~MATNR = C~MATNR
           FOR ALL ENTRIES IN GT_ZGTPPSIF0009
               WHERE B~MANDT = SY-MANDT
                  AND A~XCHAR = 'X'
                  AND B~WERKS = GT_ZGTPPSIF0009-WERKS
                  AND B~LGORT = GT_ZGTPPSIF0009-LGORT
                  AND B~LVORM = ' '
                  AND ( B~CLABS NE 0
                    OR B~CINSM NE 0
                    OR B~CSPEM NE 0 ).

    "판매오더 재고
    SELECT B~MATNR B~WERKS B~LGORT B~CHARG B~SOBKZ B~VBELN
           B~POSNR B~KALAB B~KAINS AS INSME B~KASPE AS SPEME
           A~MEINS
           APPENDING CORRESPONDING FIELDS OF TABLE GT_ZGTPPSIF0010
           FROM MARA AS A
           INNER JOIN MSKA AS B
           ON A~MATNR = B~MATNR
           FOR ALL ENTRIES IN GT_ZGTPPSIF0009
           WHERE B~WERKS = GT_ZGTPPSIF0009-WERKS
             AND B~LGORT = GT_ZGTPPSIF0009-LGORT
             AND ( B~KALAB NE 0
               OR B~KAINS NE 0
               OR B~KASPE NE 0 ).

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RECIEVE_P_L_M
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM RECIEVE_P_L_M .

  IF GT_ZGTPPSIF0009 IS NOT INITIAL.

    "플랜트 재고
    SELECT B~MATNR B~WERKS B~LGORT B~LABST AS KALAB
           B~INSME B~SPEME B~RETME C~MEINS
           INTO CORRESPONDING FIELDS OF TABLE GT_ZGTPPSIF0010
           FROM MARC AS A
           INNER JOIN MARD AS B
           ON   A~MATNR = B~MATNR
           AND  A~WERKS = B~WERKS
           INNER JOIN MARA AS C
           ON A~MATNR = C~MATNR
           FOR ALL ENTRIES IN GT_ZGTPPSIF0009
           WHERE A~XCHAR = ' '
             AND B~WERKS = GT_ZGTPPSIF0009-WERKS
             AND B~LGORT = GT_ZGTPPSIF0009-LGORT
             AND B~MATNR = GT_ZGTPPSIF0009-MATNR
             AND B~LVORM = ' '
             AND ( B~LABST NE 0
               OR B~INSME NE 0
               OR B~SPEME NE 0 ).

    "배치 재고
    SELECT B~MATNR B~WERKS B~LGORT B~CHARG B~CLABS AS KALAB
           B~CINSM AS INSME B~CSPEM AS SPEME C~MEINS
           APPENDING CORRESPONDING FIELDS OF TABLE GT_ZGTPPSIF0010
           FROM MARC AS A
           INNER JOIN MCHB AS B
           ON A~MATNR = B~MATNR
           AND  A~WERKS = B~WERKS
           INNER JOIN MARA AS C
           ON A~MATNR = C~MATNR
           FOR ALL ENTRIES IN GT_ZGTPPSIF0009
           WHERE A~XCHAR = 'X'
             AND B~LVORM = ' '
             AND B~WERKS = GT_ZGTPPSIF0009-WERKS
             AND B~LGORT = GT_ZGTPPSIF0009-LGORT
             AND B~MATNR = GT_ZGTPPSIF0009-MATNR
             AND ( B~CLABS NE 0
                OR B~CINSM NE 0
                OR B~CSPEM NE 0 ).

    "판매오더 재고
    SELECT B~MATNR B~WERKS B~LGORT B~CHARG B~SOBKZ B~VBELN
         B~POSNR B~KALAB B~KAINS AS INSME B~KASPE AS SPEME
         A~MEINS
         APPENDING CORRESPONDING FIELDS OF TABLE GT_ZGTPPSIF0010
         FROM MARA AS A
         INNER JOIN MSKA AS B
         ON A~MATNR = B~MATNR
         FOR ALL ENTRIES IN GT_ZGTPPSIF0009
         WHERE B~WERKS = GT_ZGTPPSIF0009-WERKS
           AND B~LGORT = GT_ZGTPPSIF0009-LGORT
           AND B~MATNR = GT_ZGTPPSIF0009-MATNR
           AND ( B~KALAB NE 0
             OR B~KAINS NE 0
             OR B~KASPE NE 0 ).

  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form RECIEVE_P_C
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM RECIEVE_P_C .

  IF GT_ZGTPPSIF0009 IS NOT INITIAL.
    "공급업체번호에 값이 존재하는 경우
    IF GS_ZGTPPSIF0009-LIFNR IS NOT INITIAL.

      SELECT A~MATNR A~WERKS A~CHARG A~SOBKZ A~LIFNR
       A~LBLAB AS KALAB A~LBINS AS INSME B~MEINS
       APPENDING CORRESPONDING FIELDS OF TABLE GT_ZGTPPSIF0010
       FROM MSLB AS A
       INNER JOIN MARA AS B
       ON A~MATNR = B~MATNR
       FOR ALL ENTRIES IN GT_ZGTPPSIF0009
       WHERE A~WERKS  = GT_ZGTPPSIF0009-WERKS
         AND A~LIFNR =  GT_ZGTPPSIF0009-LIFNR
         AND A~CHARG =  GT_ZGTPPSIF0009-CHARG
         AND ( A~LBLAB NE 0
           OR A~LBINS NE 0 ).
      EXIT.

    ELSE.  "공급업체번호(IT_ITEM-LIFNR)이 빈 값인 경우
      "배치 재고
      SELECT B~MATNR B~WERKS B~LGORT B~CHARG B~CLABS AS KALAB
             B~CINSM AS INSME B~CSPEM AS SPEME C~MEINS
       APPENDING CORRESPONDING FIELDS OF TABLE GT_ZGTPPSIF0010
       FROM MARC AS A
      INNER JOIN MCHB AS B
             ON A~MATNR = B~MATNR
             AND  A~WERKS = B~WERKS
      INNER JOIN MARA AS C
             ON A~MATNR = C~MATNR
       FOR ALL ENTRIES IN GT_ZGTPPSIF0009
                 WHERE A~XCHAR = 'X'
                    AND B~LVORM = ' '
                    AND B~WERKS = GT_ZGTPPSIF0009-WERKS
                    AND B~CHARG = GT_ZGTPPSIF0009-CHARG
                    AND ( B~CLABS NE 0
                      OR B~CINSM NE 0
                      OR B~CSPEM NE 0 ).

      "공급업체 재고
      SELECT A~MATNR A~WERKS A~CHARG A~SOBKZ A~LIFNR
             A~LBLAB AS KALAB A~LBINS AS INSME B~MEINS
       APPENDING CORRESPONDING FIELDS OF TABLE GT_ZGTPPSIF0010
           FROM MSLB AS A
           INNER JOIN MARA AS B
           ON A~MATNR = B~MATNR
       FOR ALL ENTRIES IN GT_ZGTPPSIF0009
           WHERE A~WERKS  = GT_ZGTPPSIF0009-WERKS
             AND A~CHARG  = GT_ZGTPPSIF0009-CHARG
             AND  ( A~LBLAB NE 0
                 OR A~LBINS NE 0 ).
      "고객 특별 재고
      SELECT B~MATNR B~WERKS B~CHARG B~SOBKZ B~KUNNR
            B~KULAB AS KALAB B~KUINS AS INSME
            A~MEINS
        APPENDING CORRESPONDING FIELDS OF TABLE GT_ZGTPPSIF0010
       FROM MARA AS A
     INNER JOIN MSKU AS B
     ON A~MATNR = B~MATNR
     FOR ALL ENTRIES IN GT_ZGTPPSIF0009
       WHERE B~WERKS = GT_ZGTPPSIF0009-WERKS
         AND B~CHARG = GT_ZGTPPSIF0009-CHARG
         AND ( B~KULAB NE 0
           OR B~KUINS NE 0 ).
      " 판매오더 재고
      SELECT B~MATNR B~WERKS B~LGORT B~CHARG B~SOBKZ B~VBELN
           B~POSNR B~KALAB B~KAINS AS INSME B~KASPE AS SPEME
           A~MEINS
        APPENDING CORRESPONDING FIELDS OF TABLE GT_ZGTPPSIF0010
        FROM MARA AS A
       INNER JOIN MSKA AS B
          ON A~MATNR = B~MATNR
      FOR ALL ENTRIES IN GT_ZGTPPSIF0009
       WHERE B~WERKS = GT_ZGTPPSIF0009-WERKS
          AND B~CHARG = GT_ZGTPPSIF0009-CHARG
          AND ( B~KALAB NE 0
            OR B~KAINS NE 0
            OR B~KASPE NE 0 ).
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RECIEVE_P_M
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM RECIEVE_P_M .

  IF GT_ZGTPPSIF0009 IS NOT INITIAL.
    "공급업체번호에 값이 존재하는 경우
    IF GS_ZGTPPSIF0009-LIFNR IS NOT INITIAL.

      SELECT A~MATNR A~WERKS A~CHARG A~SOBKZ A~LIFNR
      A~LBLAB AS KALAB A~LBINS AS INSME B~MEINS
      APPENDING CORRESPONDING FIELDS OF TABLE GT_ZGTPPSIF0010
      FROM MSLB AS A
      INNER JOIN MARA AS B
      ON A~MATNR = B~MATNR
      FOR ALL ENTRIES IN GT_ZGTPPSIF0009
      WHERE A~WERKS  = GT_ZGTPPSIF0009-WERKS
        AND A~LIFNR =  GT_ZGTPPSIF0009-LIFNR
        AND A~MATNR =  GT_ZGTPPSIF0009-MATNR
        AND ( A~LBLAB NE 0
          OR A~LBINS NE 0 ).
      EXIT.

    ELSE. "공급업체번호이 빈 값인 경우

      "플랜트 재고
      SELECT B~MATNR B~WERKS B~LGORT B~LABST AS KALAB
           B~INSME B~SPEME B~RETME C~MEINS
           INTO CORRESPONDING FIELDS OF TABLE GT_ZGTPPSIF0010
           FROM MARC AS A
          INNER JOIN MARD AS B
            ON A~MATNR = B~MATNR
          AND  A~WERKS = B~WERKS
          INNER JOIN MARA AS C
            ON A~MATNR = C~MATNR
         FOR ALL ENTRIES IN GT_ZGTPPSIF0009
           WHERE A~XCHAR = ' '
             AND B~WERKS = GT_ZGTPPSIF0009-WERKS
             AND B~MATNR = GT_ZGTPPSIF0009-MATNR
             AND B~LVORM = ' '
             AND ( B~LABST NE 0
               OR B~INSME NE 0
               OR B~SPEME NE 0 ).

      "배치 재고
      SELECT B~MATNR B~WERKS B~LGORT B~CHARG B~CLABS AS KALAB
             B~CINSM AS INSME B~CSPEM AS SPEME C~MEINS
       APPENDING CORRESPONDING FIELDS OF TABLE GT_ZGTPPSIF0010
       FROM MARC AS A
      INNER JOIN MCHB AS B
             ON A~MATNR = B~MATNR
             AND  A~WERKS = B~WERKS
      INNER JOIN MARA AS C
             ON A~MATNR = C~MATNR
       FOR ALL ENTRIES IN GT_ZGTPPSIF0009
                 WHERE A~XCHAR = 'X'
                    AND B~LVORM = ' '
                    AND B~WERKS = GT_ZGTPPSIF0009-WERKS
                    AND B~MATNR = GT_ZGTPPSIF0009-MATNR
                    AND ( B~CLABS NE 0
                      OR B~CINSM NE 0
                      OR B~CSPEM NE 0 ).

      "공급업체 재고
      SELECT A~MATNR A~WERKS A~CHARG A~SOBKZ A~LIFNR
             A~LBLAB AS KALAB A~LBINS AS INSME B~MEINS
       APPENDING CORRESPONDING FIELDS OF TABLE GT_ZGTPPSIF0010
           FROM MSLB AS A
           INNER JOIN MARA AS B
           ON A~MATNR = B~MATNR
       FOR ALL ENTRIES IN GT_ZGTPPSIF0009
           WHERE A~WERKS  = GT_ZGTPPSIF0009-WERKS
             AND A~MATNR  = GT_ZGTPPSIF0009-MATNR
             AND  ( A~LBLAB NE 0
                 OR A~LBINS NE 0 ).

      "고객 특별 재고
      SELECT B~MATNR B~WERKS B~CHARG B~SOBKZ B~KUNNR
            B~KULAB AS KALAB B~KUINS AS INSME A~MEINS
        APPENDING CORRESPONDING FIELDS OF TABLE GT_ZGTPPSIF0010
       FROM MARA AS A
     INNER JOIN MSKU AS B
     ON A~MATNR = B~MATNR
     FOR ALL ENTRIES IN GT_ZGTPPSIF0009
       WHERE B~WERKS = GT_ZGTPPSIF0009-WERKS
         AND B~MATNR  = GT_ZGTPPSIF0009-MATNR
         AND ( B~KULAB NE 0
           OR B~KUINS NE 0 ).

      " 판매오더 재고
      SELECT B~MATNR B~WERKS B~LGORT B~CHARG B~SOBKZ B~VBELN
           B~POSNR B~KALAB B~KAINS AS INSME B~KASPE AS SPEME
           A~MEINS
        APPENDING CORRESPONDING FIELDS OF TABLE GT_ZGTPPSIF0010
        FROM MARA AS A
       INNER JOIN MSKA AS B
          ON A~MATNR = B~MATNR
      FOR ALL ENTRIES IN GT_ZGTPPSIF0009
       WHERE B~WERKS = GT_ZGTPPSIF0009-WERKS
         AND B~MATNR = GT_ZGTPPSIF0009-MATNR
          AND ( B~KALAB NE 0
            OR B~KAINS NE 0
            OR B~KASPE NE 0 ).
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RECIEVE_P_L_M_C
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM RECIEVE_P_L_M_C .

  IF GT_ZGTPPSIF0009 IS NOT INITIAL.
    "배치 재고
    SELECT B~MATNR B~WERKS B~LGORT B~CHARG B~CLABS AS KALAB
           B~CINSM AS INSME B~CSPEM AS SPEME C~MEINS
           APPENDING CORRESPONDING FIELDS OF TABLE GT_ZGTPPSIF0010
           FROM MARC AS A
           INNER JOIN MCHB AS B
           ON   A~MATNR = B~MATNR
           AND  A~WERKS = B~WERKS
           INNER JOIN MARA AS C
           ON A~MATNR = C~MATNR
           FOR ALL ENTRIES IN GT_ZGTPPSIF0009
           WHERE A~XCHAR = 'X'
             AND B~LVORM = ' '
             AND B~WERKS = GT_ZGTPPSIF0009-WERKS
             AND B~LGORT = GT_ZGTPPSIF0009-LGORT
             AND B~MATNR = GT_ZGTPPSIF0009-MATNR
             AND B~CHARG = GT_ZGTPPSIF0009-CHARG
             AND ( B~CLABS NE 0
               OR B~CINSM NE 0
               OR B~CSPEM NE 0 ).
    "판매오더 재고
    SELECT B~MATNR B~WERKS B~LGORT B~CHARG B~SOBKZ B~VBELN
         B~POSNR B~KALAB B~KAINS AS INSME B~KASPE AS SPEME
         A~MEINS
         APPENDING CORRESPONDING FIELDS OF TABLE GT_ZGTPPSIF0010
         FROM MARA AS A
         INNER JOIN MSKA AS B
         ON A~MATNR = B~MATNR
         FOR ALL ENTRIES IN GT_ZGTPPSIF0009
     WHERE B~WERKS = GT_ZGTPPSIF0009-WERKS
       AND B~LGORT = GT_ZGTPPSIF0009-LGORT
       AND B~MATNR = GT_ZGTPPSIF0009-MATNR
       AND B~CHARG = GT_ZGTPPSIF0009-CHARG
        AND ( B~KALAB NE 0
          OR B~KAINS NE 0
          OR B~KASPE NE 0 ).

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RECIEVE_P_M_C
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM RECIEVE_P_M_C .

  IF GT_ZGTPPSIF0009 IS NOT INITIAL.
    " 공급업체번호에 값이 존재하는 경우
    IF GS_ZGTPPSIF0009-LIFNR IS NOT INITIAL.

      SELECT A~MATNR A~WERKS A~CHARG A~SOBKZ A~LIFNR
       A~LBLAB AS KALAB A~LBINS AS INSME B~MEINS
       APPENDING CORRESPONDING FIELDS OF TABLE GT_ZGTPPSIF0010
       FROM MSLB AS A
       INNER JOIN MARA AS B
       ON A~MATNR = B~MATNR
       FOR ALL ENTRIES IN GT_ZGTPPSIF0009
       WHERE A~WERKS  = GT_ZGTPPSIF0009-WERKS
         AND A~LIFNR =  GT_ZGTPPSIF0009-LIFNR
         AND A~MATNR =  GT_ZGTPPSIF0009-MATNR
         AND A~CHARG =  GT_ZGTPPSIF0009-CHARG
         AND ( A~LBLAB NE 0
           OR A~LBINS NE 0 ).
      EXIT.

    ELSE.  "공급업체번호이 빈 값인 경우
      "배치 재고
      SELECT B~MATNR B~WERKS B~LGORT B~CHARG B~CLABS AS KALAB
             B~CINSM AS INSME B~CSPEM AS SPEME C~MEINS
       APPENDING CORRESPONDING FIELDS OF TABLE GT_ZGTPPSIF0010
       FROM MARC AS A
      INNER JOIN MCHB AS B
             ON A~MATNR = B~MATNR
             AND  A~WERKS = B~WERKS
      INNER JOIN MARA AS C
             ON A~MATNR = C~MATNR
       FOR ALL ENTRIES IN GT_ZGTPPSIF0009
                 WHERE A~XCHAR = 'X'
                    AND B~LVORM = ' '
                    AND B~WERKS = GT_ZGTPPSIF0009-WERKS
                    AND B~CHARG = GT_ZGTPPSIF0009-CHARG
                    AND B~MATNR = GT_ZGTPPSIF0009-MATNR
                    AND ( B~CLABS NE 0
                      OR B~CINSM NE 0
                      OR B~CSPEM NE 0 ).
      "공급업체 재고
      SELECT A~MATNR A~WERKS A~CHARG A~SOBKZ A~LIFNR
             A~LBLAB AS KALAB A~LBINS AS INSME B~MEINS
       APPENDING CORRESPONDING FIELDS OF TABLE GT_ZGTPPSIF0010
           FROM MSLB AS A
           INNER JOIN MARA AS B
           ON A~MATNR = B~MATNR
       FOR ALL ENTRIES IN GT_ZGTPPSIF0009
           WHERE A~WERKS  = GT_ZGTPPSIF0009-WERKS
             AND A~CHARG  = GT_ZGTPPSIF0009-CHARG
             AND A~MATNR  = GT_ZGTPPSIF0009-MATNR
             AND  ( A~LBLAB NE 0
                 OR A~LBINS NE 0 ).
      "고객 특별 재고
      SELECT B~MATNR B~WERKS B~CHARG B~SOBKZ B~KUNNR
            B~KULAB AS KALAB B~KUINS AS INSME
            A~MEINS
        APPENDING CORRESPONDING FIELDS OF TABLE GT_ZGTPPSIF0010
       FROM MARA AS A
     INNER JOIN MSKU AS B
     ON A~MATNR = B~MATNR
     FOR ALL ENTRIES IN GT_ZGTPPSIF0009
       WHERE B~WERKS = GT_ZGTPPSIF0009-WERKS
         AND B~CHARG = GT_ZGTPPSIF0009-CHARG
         AND B~MATNR = GT_ZGTPPSIF0009-MATNR
         AND ( B~KULAB NE 0
           OR B~KUINS NE 0 ).
      "판매오더 재고
      SELECT B~MATNR B~WERKS B~LGORT B~CHARG B~SOBKZ B~VBELN
           B~POSNR B~KALAB B~KAINS AS INSME B~KASPE AS SPEME
           A~MEINS
        APPENDING CORRESPONDING FIELDS OF TABLE GT_ZGTPPSIF0010
        FROM MARA AS A
       INNER JOIN MSKA AS B
          ON A~MATNR = B~MATNR
      FOR ALL ENTRIES IN GT_ZGTPPSIF0009
       WHERE B~WERKS = GT_ZGTPPSIF0009-WERKS
          AND B~CHARG = GT_ZGTPPSIF0009-CHARG
          AND B~MATNR = GT_ZGTPPSIF0009-MATNR
          AND ( B~KALAB NE 0
            OR B~KAINS NE 0
            OR B~KASPE NE 0 ).
    ENDIF.

  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form RECIEVE_P_L_C
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM RECIEVE_P_L_C .

  IF GT_ZGTPPSIF0009 IS NOT INITIAL.
    "배치 재고
    SELECT B~MATNR B~WERKS B~LGORT B~CHARG B~CLABS AS KALAB
           B~CINSM AS INSME B~CSPEM AS SPEME C~MEINS
     APPENDING CORRESPONDING FIELDS OF TABLE GT_ZGTPPSIF0010
     FROM MARC AS A
    INNER JOIN MCHB AS B
           ON A~MATNR = B~MATNR
           AND  A~WERKS = B~WERKS
    INNER JOIN MARA AS C
           ON A~MATNR = C~MATNR
     FOR ALL ENTRIES IN GT_ZGTPPSIF0009
               WHERE A~XCHAR = 'X'
                  AND B~LVORM = ' '
                  AND B~WERKS = GT_ZGTPPSIF0009-WERKS
                  AND B~CHARG = GT_ZGTPPSIF0009-CHARG
                  AND B~LGORT = GT_ZGTPPSIF0009-LGORT
                  AND ( B~CLABS NE 0
                      OR B~CINSM NE 0
                    OR B~CSPEM NE 0 ).

    " 판매오더 재고
    SELECT B~MATNR B~WERKS B~LGORT B~CHARG B~SOBKZ B~VBELN
         B~POSNR B~KALAB B~KAINS AS INSME B~KASPE AS SPEME
         A~MEINS
      APPENDING CORRESPONDING FIELDS OF TABLE GT_ZGTPPSIF0010
      FROM MARA AS A
     INNER JOIN MSKA AS B
        ON A~MATNR = B~MATNR
    FOR ALL ENTRIES IN GT_ZGTPPSIF0009
     WHERE B~WERKS = GT_ZGTPPSIF0009-WERKS
        AND B~CHARG = GT_ZGTPPSIF0009-CHARG
        AND B~LGORT = GT_ZGTPPSIF0009-LGORT
        AND ( B~KALAB NE 0
          OR B~KAINS NE 0
          OR B~KASPE NE 0 ).

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_log_stock_info
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> LV_MESSAGE
*&      --> P_
*&      --> P_
*&      --> LV_EXTID
*&      --> LV_TIMESTAMP
*&      --> I_SYSTEM_ID
*&      --> I_MODE
*&---------------------------------------------------------------------*
FORM SAVE_LOG_STOCK_INFO_09  USING PV_FLAG
                          PV_MESSAGE
                          PV_TIMESTAMP
                          PV_SYSTEM_ID
                          PV_SEQNO.

  DATA : LT_ZGTPPT3190 TYPE TABLE OF ZGTPPT3190.
  DATA : LS_ZGTPPT3190 TYPE ZGTPPT3190.

  CLEAR : LT_ZGTPPT3190.


  LS_ZGTPPT3190-WERKS  = GS_ZGTPPSIF0009-WERKS.
  LS_ZGTPPT3190-LGORT  = GS_ZGTPPSIF0009-LGORT.
  IF GS_ZGTPPSIF0009-MATNR IS NOT INITIAL.
    CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
      EXPORTING
        INPUT  = GS_ZGTPPSIF0009-MATNR
      IMPORTING
        OUTPUT = LS_ZGTPPT3190-MATNR.
  ENDIF.

  IF GS_ZGTPPSIF0009-LIFNR IS NOT INITIAL.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = GS_ZGTPPSIF0009-LIFNR
      IMPORTING
        OUTPUT = LS_ZGTPPT3190-LIFNR.
  ENDIF.
*  ls_zgtppt3190-matnr  = gs_zgtppsif0009-matnr.
*  ls_zgtppt3190-lifnr  = gs_zgtppsif0009-lifnr.
  LS_ZGTPPT3190-CHARG  = GS_ZGTPPSIF0009-CHARG.
  LS_ZGTPPT3190-FLAG   = GS_ZGTPPSIF0009-FLAG.

  LS_ZGTPPT3190 =  VALUE #( BASE CORRESPONDING #( LS_ZGTPPT3190 )
                           ZIFKEY       = PV_TIMESTAMP
                           ZSYSTEM_ID   = PV_SYSTEM_ID
                           ZSERNO       = PV_SEQNO
                           ZSTAT        = PV_FLAG
                           ZMESSAGE     = PV_MESSAGE
                           ZERP_STAT    = PV_FLAG
                           ZERP_MESSAGE = PV_MESSAGE
                           IFNAM  = SY-UNAME
                           IFDAT  = SY-DATUM
                           IFTIM  = SY-UZEIT
                          )  .

  MODIFY ZGTPPT3190 FROM  LS_ZGTPPT3190.
  IF SY-SUBRC = 0.
    COMMIT WORK.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_log_stock_info_10
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> ZO_MESSAGE
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> LV_TIMESTAMP
*&      --> I_SYSTEM_ID
*&      --> P_
*&---------------------------------------------------------------------*
FORM SAVE_LOG_STOCK_INFO_10  USING PV_FLAG
                          PV_MESSAGE
                          PV_TIMESTAMP
                          PV_SYSTEM_ID
                          PV_SEQNO.

  DATA : LT_ZGTPPT3200 TYPE TABLE OF ZGTPPT3200.
  DATA : LS_ZGTPPT3200 TYPE ZGTPPT3200.
  DATA : LV_CNT(10)     TYPE N.

  CLEAR : LT_ZGTPPT3200.



  LV_CNT = '0000000001'.
  LOOP AT GT_IT_ZGTPPSIF0010 INTO GS_IT_ZGTPPSIF0010.

    MOVE-CORRESPONDING GS_IT_ZGTPPSIF0010 TO LS_ZGTPPT3200.



    LS_ZGTPPT3200 =  VALUE #( BASE CORRESPONDING #( LS_ZGTPPT3200 )
                             ZIFKEY       = PV_TIMESTAMP
                             ZSYSTEM_ID   = PV_SYSTEM_ID
                             ZSERNO       = PV_SEQNO
                             ZSEQNO       = LV_CNT
                             ZSTAT        = PV_FLAG
                             ZMESSAGE     = PV_MESSAGE
                             ZERP_STAT    = ''
                             ZERP_MESSAGE = ''
                             IFNAM  = SY-UNAME
                             IFDAT  = SY-DATUM
                             IFTIM  = SY-UZEIT
                            )  .

    MODIFY ZGTPPT3200 FROM  LS_ZGTPPT3200.
    IF SY-SUBRC = 0.
      COMMIT WORK.
    ENDIF.
    LV_CNT = LV_CNT + 1.
  ENDLOOP.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_batch_value
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_BATCH_VALUE  USING  PS_ZGTPPSIF0010 TYPE ZGTPPSIF0010.
  DATA LV_CLASS	TYPE KLAH-CLASS.
  DATA LV_CLASS_TYPE TYPE	KLAH-KLART.
  DATA LT_VAL	 TYPE TABLE OF API_VALI.
  DATA LT_CHAR TYPE TABLE OF API_CHAR.
  DATA LT_ATT  TYPE TABLE OF API_CH_ATT.

  CALL FUNCTION 'ZQC01_BATCH_VALUES_READ'
    EXPORTING
      I_VAL_MATNR    = PS_ZGTPPSIF0010-MATNR
      I_VAL_WERKS    = PS_ZGTPPSIF0010-WERKS
      I_VAL_CHARGE   = PS_ZGTPPSIF0010-CHARG
    IMPORTING
      E_CLASS        = LV_CLASS
      E_CLASS_TYPE   = LV_CLASS_TYPE
    TABLES
      T_VAL_TAB      = LT_VAL
      T_CHAR_TAB     = LT_CHAR
      T_ATT_TAB      = LT_ATT
    EXCEPTIONS
      NO_CLASS       = 1
      INTERNAL_ERROR = 2
      NO_VALUES      = 3
      NO_CHARS       = 4
      OTHERS         = 5.

  READ TABLE LT_VAL INTO DATA(LS_VAL) WITH KEY ATNAM = 'SAP_MILLCA_LENGTH'.
  IF SY-SUBRC IS INITIAL.
    PS_ZGTPPSIF0010-INDLEN  = LS_VAL-ATFLV.
    PS_ZGTPPSIF0010-INDUNIT = PS_ZGTPPSIF0010-MEINS.

    IF PS_ZGTPPSIF0010-INDLEN IS NOT INITIAL.
      PS_ZGTPPSIF0010-KALAB = PS_ZGTPPSIF0010-KALAB / PS_ZGTPPSIF0010-INDLEN.
      PS_ZGTPPSIF0010-INSME = PS_ZGTPPSIF0010-INSME / PS_ZGTPPSIF0010-INDLEN.
      PS_ZGTPPSIF0010-SPEME = PS_ZGTPPSIF0010-SPEME / PS_ZGTPPSIF0010-INDLEN.
    ELSE.
      CLEAR: PS_ZGTPPSIF0010-KALAB, PS_ZGTPPSIF0010-INSME, PS_ZGTPPSIF0010-SPEME.
    ENDIF.

    PS_ZGTPPSIF0010-MEINS = 'ST'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form convert_material_unit
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CONVERT_MATERIAL_UNIT  USING  PV_MATNR PV_MEINS PV_AUSME PV_MENGE.

  CHECK: PV_MENGE IS NOT INITIAL,
         PV_AUSME IS NOT INITIAL AND PV_AUSME NE PV_MEINS.

  CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
    EXPORTING
      I_MATNR              = PV_MATNR
      I_IN_ME              = PV_MEINS
      I_OUT_ME             = PV_AUSME
      I_MENGE              = PV_MENGE
    IMPORTING
      E_MENGE              = PV_MENGE
    EXCEPTIONS
      ERROR_IN_APPLICATION = 1
      ERROR                = 2
      OTHERS               = 3.

  PV_MEINS = PV_AUSME.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_specific_stock
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM get_specific_stock .


  RANGES : LR_WERKS FOR MARD-WERKS,
           LR_LGORT FOR MARD-LGORT,
           LR_MATNR FOR MARD-MATNR,
           LR_CHARG FOR MCHB-CHARG.
  CLEAR: LR_WERKS, LR_WERKS[], LR_LGORT, LR_LGORT[],
              LR_MATNR, LR_MATNR[], LR_CHARG, LR_CHARG[].


  LOOP AT GT_ZGTPPSIF0009 INTO DATA(LS_ZGTPPSIF0009).

    IF LS_ZGTPPSIF0009-WERKS IS NOT INITIAL.
      CLEAR LR_WERKS.
      LR_WERKS-SIGN = 'I'.
      LR_WERKS-OPTION = 'EQ'.
      LR_WERKS-LOW = LS_ZGTPPSIF0009-WERKS.
      COLLECT LR_WERKS.
    ENDIF.

"20260709 추가
  SELECT SINGLE MATNR, WERKS, LGORT, CHARG
    FROM ZPPT0001
   WHERE WERKS = @LS_ZGTPPSIF0009-WERKS
       AND  TAGNR = @LS_ZGTPPSIF0009-TAGNR
      INTO @DATA(LS_ZPPT0001).

    IF SY-SUBRC <> 0.
      DATA(LV_ERROR) = 'X'.
      EXIT.
    ENDIF.

    IF LS_ZPPT0001-MATNR IS NOT INITIAL.
      CLEAR LR_MATNR.
      LR_MATNR-SIGN   = 'I'.
      LR_MATNR-OPTION = 'EQ'.
      LR_MATNR-LOW    = LS_ZPPT0001-MATNR.
      COLLECT LR_MATNR.
    ENDIF.
*    IF LS_ZPPT0001-LGORT IS NOT INITIAL.
*      CLEAR LR_LGORT.
*      LR_LGORT-SIGN   = 'I'.
*      LR_LGORT-OPTION = 'EQ'.
*      LR_LGORT-LOW    = LS_ZPPT0001-LGORT.
*      COLLECT LR_LGORT.
*    ENDIF.
    IF LS_ZPPT0001-CHARG IS NOT INITIAL.
      CLEAR LR_CHARG.
      LR_CHARG-SIGN   = 'I'.
      LR_CHARG-OPTION = 'EQ'.
      LR_CHARG-LOW    = LS_ZPPT0001-CHARG.
      COLLECT LR_CHARG.
    ENDIF.
"20260709 추가


  ENDLOOP.

  CHECK LV_ERROR NE 'X'.

  IF GT_ZGTPPSIF0009 IS NOT INITIAL.
    "공급업체 재고
    SELECT A~MATNR A~WERKS A~CHARG A~SOBKZ A~LIFNR
          A~LBLAB AS KALAB A~LBINS AS INSME B~MEINS
     INTO CORRESPONDING FIELDS OF TABLE GT_ZGTPPSIF0010
     FROM MSLB AS A INNER JOIN MARA AS B
                       ON A~MATNR = B~MATNR
    WHERE A~WERKS IN LR_WERKS
      AND ( A~LBLAB NE 0
       OR   A~LBINS NE 0 ).

    "플랜트 재고
    SELECT B~MATNR B~WERKS B~LGORT B~LABST AS KALAB
           B~INSME B~SPEME B~RETME C~MEINS
 APPENDING CORRESPONDING FIELDS OF TABLE GT_ZGTPPSIF0010
      FROM MARC AS A INNER JOIN MARD AS B
                        ON A~MATNR = B~MATNR
                       AND A~WERKS = B~WERKS
                     INNER JOIN MARA AS C
                        ON A~MATNR = C~MATNR
     WHERE A~XCHAR = ' '
       AND B~WERKS IN LR_WERKS
       AND B~LGORT IN LR_LGORT
       AND B~MATNR IN LR_MATNR            "20260709 추가
       AND B~LVORM = ' '
       AND ( B~LABST NE 0
        OR   B~INSME NE 0
        OR   B~SPEME NE 0 ).


    "배치 재고
    SELECT B~MATNR B~WERKS B~LGORT B~CHARG B~CLABS AS KALAB
           B~CINSM AS INSME B~CSPEM AS SPEME C~MEINS
 APPENDING CORRESPONDING FIELDS OF TABLE GT_ZGTPPSIF0010
      FROM MARC AS A INNER JOIN MCHB AS B
                        ON A~MATNR = B~MATNR
                       AND A~WERKS = B~WERKS
                     INNER JOIN MARA AS C
                        ON A~MATNR = C~MATNR
     WHERE A~XCHAR = 'X'
       AND B~LVORM = ' '
       AND A~WERKS IN LR_WERKS
       AND B~LGORT IN LR_LGORT
       AND B~MATNR IN LR_MATNR            "20260709 추가
       AND B~CHARG IN LR_CHARG            "20260709 추가
       AND ( B~CLABS NE 0
        OR   B~CINSM NE 0
        OR   B~CSPEM NE 0 ).


    "고객 특별 재고
    SELECT B~MATNR B~WERKS B~CHARG B~SOBKZ B~KUNNR
           B~KULAB AS KALAB B~KUINS AS INSME
           A~MEINS
 APPENDING CORRESPONDING FIELDS OF TABLE GT_ZGTPPSIF0010
      FROM MARA AS A INNER JOIN MSKU AS B
                        ON A~MATNR = B~MATNR
     WHERE B~WERKS IN LR_WERKS
       AND B~MATNR IN LR_MATNR            "20260709 추가
       AND ( B~KULAB NE 0
        OR   B~KUINS NE 0 ).

    "판매오더 재고
    SELECT B~MATNR B~WERKS B~LGORT B~CHARG B~SOBKZ B~VBELN
           B~POSNR B~KALAB B~KAINS AS INSME B~KASPE AS SPEME
           A~MEINS
 APPENDING CORRESPONDING FIELDS OF TABLE GT_ZGTPPSIF0010
      FROM MARA AS A INNER JOIN MSKA AS B
                        ON A~MATNR = B~MATNR
     WHERE B~WERKS IN LR_WERKS
       AND B~LGORT IN LR_LGORT
       AND B~MATNR IN LR_MATNR            "20260709 추가
       AND B~CHARG IN LR_CHARG            "20260709 추가
       AND ( B~KALAB NE 0
        OR   B~KAINS NE 0
        OR   B~KASPE NE 0 ).

  ENDIF.

ENDFORM.
