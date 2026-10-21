*&---------------------------------------------------------------------*
*& Include          ZGTMMR4130F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  initial_proc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM INITIAL_PROC.
  REFRESH GT_WTAB.                          CLEAR GT_WTAB.

  PERFORM SETTING_BDC_PARAMETERS.

*  REFRESH gt_wtab.                          CLEAR gt_wtab.
*  IF p_pobox = 'X' OR    "구매오더
*     p_conf  = 'X'.
*
*    CONCATENATE '    D~STATU  = ' ' ''B'' '  INTO gt_wtab.
*    APPEND gt_wtab.                         CLEAR gt_wtab.
*
*  ENDIF.

  IF P_CANCEL = 'X'.     "취소
    CONCATENATE '    A~ELIKZ <> ' ' ''X'' '  INTO GT_WTAB.
    APPEND GT_WTAB.                         CLEAR GT_WTAB.

*    CONCATENATE 'AND D~STATU  = ' ' ''B'' '  INTO gt_wtab.
*    APPEND gt_wtab.                         CLEAR gt_wtab.

  ENDIF.

*& 공정코드 WHERE 조건 설정...
  IF S_PROCD-LOW IS INITIAL.
    GV_MATKL = '%'.
  ELSE.
    CONCATENATE '____' S_PROCD-LOW '%'  INTO GV_MATKL.
  ENDIF.
  REPLACE '*' IN GV_MATKL WITH '%'.


*& RFC 파라미터 셋팅...
  CLEAR: GV_RFCDEST, GV_RFCLOCL.
  SELECT SINGLE LOGSYS FROM CIFOPMODE CLIENT SPECIFIED
                INTO GV_RFCDEST
               WHERE MANDT = SY-MANDT.

  SELECT SINGLE LOGSYS FROM T000      CLIENT SPECIFIED
                INTO GV_RFCLOCL
               WHERE MANDT = SY-MANDT.

  IF P_VARI IS NOT INITIAL.
    ALV_VARIANT-VARIANT = P_VARI.
  ENDIF.

ENDFORM.                    " initial_proc
*&---------------------------------------------------------------------*
*&      Form  select_proc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SELECT_PROC.

  DATA : LV_MEINS LIKE EKPO-MEINS,
         LV_MENGE LIKE EKPO-MENGE.


  REFRESH GT_EBAN.
  CLEAR  :GT_EBAN.

  IF P_PRBOX = 'X'.
    SELECT A~WERKS A~DISPO A~EKGRP A~MATNR A~TXZ01
           A~BANFN A~BNFPO A~MENGE A~LFDAT A~BSMNG
           A~MEINS A~LGORT A~PSTYP A~BSART A~BSTYP
           A~FLIEF AS LIFNR
           B~MTART B~MATKL B~DPCBT B~BSTME AS MEINS_A
           B~SPART
      INTO CORRESPONDING FIELDS OF TABLE GT_EBAN
      FROM EBAN AS A INNER JOIN MARA AS B
                             ON A~MATNR = B~MATNR
     WHERE A~MATNR   IN  S_MATNR
       AND A~WERKS   EQ  P_WERKS
       AND A~LOEKZ   EQ  SPACE
       AND A~EBAKZ   EQ  SPACE
       AND A~DISPO   IN  S_DISPO
       AND A~ERDAT  IN   S_AEDAT
       AND A~LFDAT   IN  S_LFDAT
       AND A~PSTYP   IN ('0', '3')
*&       AND a~flief  IN  s_lifnr
       AND ( A~STATU  = 'N'
        OR ( A~STATU  = 'B' AND A~BSMNG = 0 ) )
       AND B~MATKL LIKE  GV_MATKL.

  ENDIF.

  IF P_POBOX = 'X' OR P_CANCEL = 'X'.
    SELECT A~WERKS A~MATNR A~TXZ01 A~BANFN A~BNFPO
           A~EBELN A~EBELP A~PSTYP
           A~LGORT A~BSTYP A~MENGE AS MENGE_A
           A~KZKFG A~CUOBJ A~CHG_SRV
           A~MEINS AS MEINS_A
           B~EKGRP B~LIFNR B~BSART B~BEDAT B~AEDAT A~AEDAT AS ERDAT
           C~EINDT AS LFDAT        C~WEMNG AS GLMNG
           F~MTART F~MATKL F~SPART F~DPCBT
           G~DISPO A~EMLIF
           APPENDING CORRESPONDING FIELDS OF TABLE GT_EBAN
      FROM EKPO AS A INNER JOIN EKKO AS B
                             ON A~EBELN = B~EBELN
                     INNER JOIN EKET AS C
                             ON A~EBELN = C~EBELN AND
                                A~EBELP = C~EBELP
                     INNER JOIN MARA AS F
                             ON A~MATNR = F~MATNR
                     INNER JOIN MARC AS G
                             ON A~MATNR = G~MATNR AND
                                A~WERKS = G~WERKS
     WHERE A~MATNR   IN  S_MATNR
       AND A~WERKS   EQ  P_WERKS
       AND A~BSTYP   EQ 'F'
       AND A~LOEKZ   EQ  SPACE
       AND A~ELIKZ   NE  'X'
       AND (GT_WTAB)
       AND A~EBELN   IN  S_EBELN
       AND A~PSTYP   IN ('0', '3')
       AND B~LIFNR   IN  S_LIFNR
       AND B~LOEKZ   EQ  SPACE
       AND B~AEDAT   IN  S_AEDAT
       AND C~EINDT   IN  S_LFDAT
       AND F~MATKL LIKE  GV_MATKL
       AND G~DISPO   IN  S_DISPO.

  ENDIF.

  IF P_CONF = 'X'.
    SELECT A~WERKS A~MATNR A~TXZ01 A~BANFN A~BNFPO
       A~EBELN A~EBELP A~PSTYP
       A~LGORT A~BSTYP A~MENGE AS MENGE_A
       A~KZKFG A~CUOBJ A~CHG_SRV
       A~MEINS AS MEINS_A
       B~EKGRP B~LIFNR B~BSART B~BEDAT B~AEDAT A~AEDAT AS ERDAT
       C~EINDT AS LFDAT
       C~EINDT C~WEMNG AS MENGE_C C~GLMNG
       F~MTART F~MATKL F~SPART F~DPCBT
       G~DISPO A~EMLIF
       APPENDING CORRESPONDING FIELDS OF TABLE GT_EBAN
  FROM EKPO AS A INNER JOIN EKKO AS B
                         ON A~EBELN = B~EBELN
                 INNER JOIN EKET AS C
                         ON A~EBELN = C~EBELN AND
                            A~EBELP = C~EBELP
                 INNER JOIN MARA AS F
                         ON A~MATNR = F~MATNR
                 INNER JOIN MARC AS G
                         ON A~MATNR = G~MATNR AND
                            A~WERKS = G~WERKS

 WHERE A~MATNR   IN  S_MATNR
   AND A~WERKS   EQ  P_WERKS
   AND A~BSTYP   EQ 'F'
   AND A~LOEKZ   EQ  SPACE
   AND A~EBELN   IN  S_EBELN
   AND A~PSTYP   IN ('0', '3')
   AND B~LIFNR   IN  S_LIFNR
   AND B~LOEKZ   EQ  SPACE
   AND B~AEDAT   IN  S_AEDAT
   AND C~EINDT   IN  S_LFDAT
   AND F~MATKL LIKE  GV_MATKL
   AND G~DISPO   IN  S_DISPO.

  ENDIF.

*& 구매요청 잔량이 있는경우, 입력용 필드 추가...
  IF P_POBOX = 'X'.
    SELECT A~WERKS A~DISPO A~EKGRP A~MATNR A~TXZ01
           A~BANFN A~BNFPO A~MENGE A~LFDAT A~BSMNG
           A~MEINS A~LGORT A~PSTYP A~BSART A~BSTYP
           A~FLIEF AS LIFNR
           B~MTART B~MATKL B~DPCBT B~BSTME AS MEINS_A
           B~SPART
           APPENDING CORRESPONDING FIELDS OF TABLE GT_EBAN_TMP
      FROM EBAN AS A INNER JOIN MARA AS B
                             ON A~MATNR = B~MATNR
     WHERE A~MATNR  IN  S_MATNR
       AND A~WERKS  EQ  P_WERKS
       AND A~LOEKZ  EQ  SPACE
       AND A~EBAKZ  EQ  SPACE
       AND A~DISPO  IN  S_DISPO
       AND A~LFDAT  IN  S_LFDAT
       AND A~PSTYP  IN ('0', '3')
       AND A~FLIEF  IN  S_LIFNR
       AND A~STATU  EQ 'B'
       AND A~EBELN  IN  S_EBELN
       AND A~MENGE   > ( SELECT SUM( MENGE )
                           FROM EKPO
                          WHERE BANFN = A~BANFN
                            AND BNFPO = A~BNFPO
                            AND LOEKZ = SPACE )
       AND B~MATKL LIKE  GV_MATKL.


*& 구매요청의 단위와 구매오더의 단위가 틀릴 경우 요청잔량을 환산하여
*조회

    LOOP AT GT_EBAN_TMP.

      CLEAR : LV_MEINS, LV_MENGE.

      SELECT MEINS SUM( MENGE )
        INTO (LV_MEINS, LV_MENGE)
        FROM EKPO
       WHERE BANFN = GT_EBAN_TMP-BANFN
         AND BNFPO = GT_EBAN_TMP-BNFPO
         AND LOEKZ = SPACE
      GROUP BY MEINS
      ORDER BY MEINS.
      ENDSELECT.

      IF GT_EBAN_TMP-MEINS IS NOT INITIAL AND
         LV_MEINS IS NOT INITIAL AND
         ( GT_EBAN_TMP-MEINS <> LV_MEINS ).
        "구매요청단위와 구매오더단위가 다를때 환산

*& 단위수량 컨버젼...

        PERFORM MD_CONVERT_MATERIAL_UNIT USING GT_EBAN_TMP-MATNR
                                               LV_MEINS
                                               GT_EBAN_TMP-MEINS
                                      CHANGING LV_MENGE.
      ENDIF.

      IF GT_EBAN_TMP-MENGE > LV_MENGE.

        MOVE-CORRESPONDING GT_EBAN_TMP TO GT_EBAN.

        APPEND GT_EBAN.

      ENDIF.

    ENDLOOP.

  ENDIF.

*&  DELETE ADJACENT DUPLICATES FROM gt_eban
*&                        COMPARING werks banfn bnfpo ebeln ebelp .
ENDFORM.                    " select_proc
*&---------------------------------------------------------------------*
*&      Form  additional_info_proc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ADDITIONAL_INFO_PROC.
  DATA: LV_MATNR  LIKE MARA-MATNR,
        LV_MENGE  LIKE EKPO-MENGE,
        LV_LENGTH TYPE P DECIMALS 3,
        LV_FACTOR TYPE I.

* 조장구성표번호, 완제품 및 완제품내역 필드 추가 / 박우진 2026.09.20.
  DATA: LT_0136 LIKE TABLE OF ZPPT0136 WITH HEADER LINE.


  IF GT_EBAN[] IS NOT INITIAL .
    CLEAR: LT_0136[].
    SELECT *
      FROM ZPPT0136
      INTO TABLE LT_0136[]
      FOR ALL ENTRIES IN GT_EBAN
      WHERE EBELN = GT_EBAN-EBELN.

    SORT LT_0136[] ASCENDING BY EBELN.
  ENDIF.


  GT_PO[] = CORRESPONDING #( GT_EBAN[] ). "추가(SJM 25.03.18)
  PERFORM GET_4110.                       "추가(SJM 25.03.18)
  SORT GT_PO BY GUBUN ASCENDING           "추가(SJM 25.04.23)
                EBELN ASCENDING
                EBELP ASCENDING
                ZGUID DESCENDING.

  LOOP AT GT_EBAN.
*& 아래 플랜트의 경우, 일반 구매오더도 같이 Dislay...
    IF GT_EBAN-WERKS = '1201' OR
*&       gt_eban-werks = '1303' OR
       GT_EBAN-WERKS = '1304' OR
       GT_EBAN-WERKS = '1305' OR
       GT_EBAN-MATKL+4(3) = 'CST' OR
       ( ( GT_EBAN-WERKS = '1202' OR
           GT_EBAN-WERKS = '1404' ) AND
         ( GT_EBAN-MATKL+4(3) = 'BWD' OR
           GT_EBAN-MATKL+4(3) = 'PLT' ) ) OR
*동해플랜트 반영
       ( GT_EBAN-WERKS = '1801' AND
         GT_EBAN-MATKL+4(3) = 'BWD' ) OR
*풍세전선 반영
       ( ( GT_EBAN-WERKS = '1901' ) AND
         ( GT_EBAN-MATKL+4(3) = 'CCB' OR
           GT_EBAN-MATKL+4(3) = 'CCS' OR
           GT_EBAN-MATKL+4(3) = 'BWD' OR
           GT_EBAN-MATKL+4(3) = 'PLT' ) ) OR

       ( ( GT_EBAN-WERKS = '2201' OR
           GT_EBAN-WERKS = '2301' ) AND
         ( GT_EBAN-MATKL+4(3) = 'CCB' OR
           GT_EBAN-MATKL+4(3) = 'CCS' OR
           GT_EBAN-MATKL+4(3) = 'BWD' OR
           GT_EBAN-MATKL+4(3) = 'PLT' ) ).    "선재
    ELSE.
      IF GT_EBAN-PSTYP = '0'.
        DELETE GT_EBAN.
        CONTINUE.
      ENDIF.
    ENDIF.

*(S)기능 추가 관련(SJM 25.03.25)
    PERFORM SET_4110_EBAN.

    IF GV_DEL = GC_X.
      DELETE GT_EBAN.
      CONTINUE.
    ENDIF.
*(E)기능 추가 관련(SJM 25.03.25)

*& 전체품명 체크...
*&    IF gt_eban-mtart = 'MCFE'.
    CLEAR  MARA.
    SELECT SINGLE ZZMAKTX80 INTO MARA-ZZMAKTX80
             FROM MARA
            WHERE MATNR = GT_EBAN-MATNR.
    IF NOT MARA-ZZMAKTX80 IS INITIAL.
      GT_EBAN-TXZ01 = MARA-ZZMAKTX80.
    ENDIF.
*&    ENDIF.

*& 구매단위가 없는경우, 기본단위를 가져온다...
    IF GT_EBAN-MEINS_A IS INITIAL.
      CLEAR  MARA.
      SELECT SINGLE MEINS INTO GT_EBAN-MEINS_A
               FROM MARA
              WHERE MATNR = GT_EBAN-MATNR.
    ENDIF.

*& 구매 요청정보...
    IF P_POBOX = 'X' OR P_CANCEL = 'X' OR P_CONF = 'X'.
      CLEAR  EBAN.
      SELECT SINGLE MENGE BSMNG MEINS
               INTO CORRESPONDING FIELDS OF GT_EBAN
               FROM EBAN
              WHERE BANFN = GT_EBAN-BANFN
                AND BNFPO = GT_EBAN-BNFPO.

    ENDIF.

*& 구매문서의 품목범주(I.C) Conversion...
    CALL FUNCTION 'ME_ITEM_CATEGORY_OUTPUT'
      EXPORTING
        PSTYP = GT_EBAN-PSTYP
      IMPORTING
        EPSTP = GT_EBAN-EPSTP.
*&        ptext = t163y-ptext.


*& 업체명...
    PERFORM GET_LIFNR_NAME1 USING GT_EBAN-LIFNR
                         CHANGING GT_EBAN-NAME1.

    IF NOT GT_EBAN-EBELN IS INITIAL.
*& 구매오더번호을 생산오더 필드에 맞게 컨버젼...
      PERFORM CONVERSION_EXIT_ALPHA_INPUT USING GT_EBAN-EBELN
                                       CHANGING GT_EBAN-AUFNR.
*& 확정여부 체크...
      CLEAR  EKES.
      SELECT SINGLE EBTYP INTO GT_EBAN-EBTYP
               FROM EKES
              WHERE EBELN = GT_EBAN-EBELN
                AND EBELP = GT_EBAN-EBELP
                AND EBTYP IN ('AB', 'LA').

*& 이전전기 여부...
      SELECT SINGLE MANDT INTO ZPPT0018-MANDT
               FROM ZPPT0018
              WHERE EBELN   =  GT_EBAN-EBELN
                AND EBELP   =  GT_EBAN-EBELP
                AND TAGNR  <> 'HEADER'
                AND MBLNR_F = 'X'.
      IF SY-SUBRC = 0.
        SELECT SINGLE MANDT INTO ZPPT0018-MANDT
                 FROM ZPPT0018
                WHERE EBELN   = GT_EBAN-EBELN
                  AND EBELP   = GT_EBAN-EBELP
                  AND TAGNR  <> 'HEADER'
                  AND MBLNR_F = SPACE.
        IF SY-SUBRC = 0.
          GT_EBAN-FLAG1 = ICON_LED_YELLOW. "'△'. "부분이전전기
        ELSE.
          GT_EBAN-FLAG1 = ICON_LED_GREEN.  "'○'. "전체이전전기

*(S)PO/Item 라인이 쪼개진 경우, 이전전기 여부 Check 추가(SJM 25.04.23)
*   라인 쪼개짐으로 자재문서가 여러건 생성가능하나 ZPPT0018에는 한 건만 저장됨
          IF LINE_EXISTS( GT_PO[ EBELN = GT_EBAN-EBELN
                                 EBELP = GT_EBAN-EBELP
                                 MBLNR = SPACE ] ).
            GT_EBAN-FLAG1 = ICON_LED_YELLOW. "'△'. "부분이전전기
          ENDIF.
*(E)PO/Item 라인이 쪼개진 경우, 이전전기 여부 Check 추가(SJM 25.04.23)
        ENDIF.
      ELSE.
        GT_EBAN-FLAG1 = ' '.   "미이전전기
      ENDIF.

*(S)승인/반려로 조회시 이전전기 완료된 건은 제외(In 구매요청/구매오더)(SJM 25.04.22)
      IF ( P_PRBOX = GC_X OR P_POBOX = GC_X ) AND P_APV = GC_X
     AND   GT_EBAN-FLAG1 = ICON_LED_GREEN.
        DELETE GT_EBAN.
        CONTINUE.
      ENDIF.
*(E)승인/반려로 조회시 이전전기 완료된 건은 제외(In 구매요청/구매오더)(SJM 25.04.22)

*& 통문증 발행 여부...
      SELECT SINGLE MANDT INTO ZPPT0018-MANDT
               FROM ZPPT0018
              WHERE EBELN   =  GT_EBAN-EBELN
                AND EBELP   =  GT_EBAN-EBELP
                AND TAGNR  <> 'HEADER'
                AND OUTPR_F = 'X'.
      IF SY-SUBRC = 0.
        SELECT SINGLE MANDT INTO ZPPT0018-MANDT
                 FROM ZPPT0018
                WHERE EBELN   =  GT_EBAN-EBELN
                  AND EBELP   =  GT_EBAN-EBELP
                  AND TAGNR  <> 'HEADER'
                  AND OUTPR_F = SPACE.
        IF SY-SUBRC = 0.
          GT_EBAN-FLAG2 = ICON_LED_YELLOW. "'△'. "부분발행
        ELSE.
          GT_EBAN-FLAG2 = ICON_LED_GREEN.  "'○'. "전체발행
        ENDIF.
      ELSE.
        GT_EBAN-FLAG2 = ' '.   "미발행
      ENDIF.

*& LOSS율...
      CLEAR  ZPPT0018.
      SELECT SINGLE LOSSR INTO GT_EBAN-LOSSR
               FROM ZPPT0018
              WHERE PSWRK  =  GT_EBAN-WERKS
                AND EBELN  =  GT_EBAN-EBELN
                AND EBELP  =  GT_EBAN-EBELP
                AND MATNR  =  GT_EBAN-MATNR
                AND TAGNR  = 'HEADER'.
      IF GT_EBAN-LOSSR IS INITIAL.
        CLEAR GT_EBAN-LOSSF.
      ELSE.
        GT_EBAN-LOSSF = 'X'.
      ENDIF.

*& 구매문서의 특성값(조장, 조장수, 포장재유형)...
      PERFORM ZMM_EKPO_SPEC_GET USING GT_EBAN-EBELN
                                      GT_EBAN-EBELP
                             CHANGING GT_EBAN-LENGTH_V
                                      GT_EBAN-FACTOR_V
                                      GT_EBAN-PACKING_CAT
                                      GT_EBAN-PACKING.

      WRITE: GT_EBAN-LENGTH_V      TO GT_EBAN-LENGTH,
             GT_EBAN-FACTOR_V      TO GT_EBAN-FACTOR.

*& 구매오더의 인증구분 조회(납품텍스트)
      IF GT_EBAN-WERKS EQ '1303'.

        PERFORM ZMM_EKPO_READ_TEXT USING GT_EBAN-EBELN
                                         GT_EBAN-EBELP
                                   CHANGING GT_EBAN-ZCERTI.


      ENDIF.
    ELSE.
*& 구매요청번호을 생산오더 필드에 맞게 컨버젼...
      PERFORM CONVERSION_EXIT_ALPHA_INPUT USING GT_EBAN-BANFN
                                       CHANGING GT_EBAN-AUFNR.

*& 작업지시 테이블에서 포장재를 가져온다...
      CLEAR  ZPPT0020.
      SELECT SINGLE VHILM INTO GT_EBAN-PACKING
               FROM ZPPT0020
              WHERE WERKS = GT_EBAN-WERKS
                AND SPGCD = GT_EBAN-DISPO+0(2)
                AND AUFNR = GT_EBAN-AUFNR.

*& 구매요청 잔량을 외주지시 수량으로 제안..
*& 구매요청과 구매오더의 단위가 틀릴때 단위를 환산하여 잔량 조회
      CLEAR  EKPO.
      SELECT MEINS SUM( MENGE )
        INTO (EKPO-MEINS, EKPO-MENGE)
        FROM EKPO
       WHERE BANFN = GT_EBAN-BANFN
         AND BNFPO = GT_EBAN-BNFPO
         AND LOEKZ = SPACE
       GROUP BY MEINS
       ORDER BY MEINS.
      ENDSELECT.

      IF GT_EBAN-MEINS IS NOT INITIAL AND
         EKPO-MEINS IS NOT INITIAL AND
         ( GT_EBAN-MEINS <> EKPO-MEINS ).

        PERFORM MD_CONVERT_MATERIAL_UNIT USING GT_EBAN-MATNR
                                               EKPO-MEINS
                                               GT_EBAN-MEINS
                                      CHANGING EKPO-MENGE.
      ENDIF.

      GT_EBAN-MENGE_B = GT_EBAN-MENGE - EKPO-MENGE.
      GT_EBAN-MENGE_A = GT_EBAN-MENGE_B.

*& 구매요청의 특성값(조장)...
      PERFORM CHARACTERISTIC_FOR_PR USING GT_EBAN-BANFN
                                          GT_EBAN-BNFPO
                                 CHANGING GT_EBAN-LENGTH_V.

      WRITE: GT_EBAN-LENGTH_V          TO GT_EBAN-LENGTH.

      IF NOT GT_EBAN-DPCBT IS INITIAL.
        IF NOT GT_EBAN-LENGTH_V IS INITIAL.
          GT_EBAN-FACTOR_V = GT_EBAN-MENGE_B / GT_EBAN-LENGTH_V.
          WRITE: GT_EBAN-FACTOR_V      TO GT_EBAN-FACTOR.
        ENDIF.
      ENDIF.

*& 단위수량 컨버젼...
      IF GT_EBAN-MEINS   IS INITIAL OR
         GT_EBAN-MEINS_A IS INITIAL.
      ELSE.
        LV_MENGE = GT_EBAN-MENGE_B.
        PERFORM MD_CONVERT_MATERIAL_UNIT USING GT_EBAN-MATNR
                                               GT_EBAN-MEINS
                                               GT_EBAN-MEINS_A
                                      CHANGING LV_MENGE.
        GT_EBAN-MENGE_A = LV_MENGE.
      ENDIF.

    ENDIF.

*& 구매문서의 품목텍스트 발췌...
    PERFORM READ_LONG_TEXT.

*& 판매오더정보 발췌...
    IF GT_EBAN-EBELN IS INITIAL.
      SELECT SINGLE VBELN VBELP
               INTO (GT_EBAN-VBELN, GT_EBAN-POSNR)
               FROM EBKN
              WHERE BANFN = GT_EBAN-BANFN
                AND BNFPO = GT_EBAN-BNFPO.
    ELSE.
      SELECT SINGLE VBELN VBELP
               INTO (GT_EBAN-VBELN, GT_EBAN-POSNR)
               FROM EKKN
              WHERE EBELN = GT_EBAN-EBELN
                AND EBELP = GT_EBAN-EBELP.
    ENDIF.

*& 납선,납지정보 발췌...
    IF GT_EBAN-VBELN IS NOT INITIAL.

      SELECT SINGLE B~NAME1 AS NAME2
               INTO CORRESPONDING FIELDS OF GT_EBAN
               FROM VBPA AS A  INNER JOIN KNA1 AS B
                                       ON A~KUNNR = B~KUNNR
              WHERE A~VBELN =  GT_EBAN-VBELN
                AND A~PARVW = 'AG'.   "납선

      SELECT SINGLE B~NAME1 AS NAME3
               INTO CORRESPONDING FIELDS OF GT_EBAN
               FROM VBPA AS A  INNER JOIN KNA1 AS B
                                       ON A~KUNNR = B~KUNNR
              WHERE A~VBELN =  GT_EBAN-VBELN
                AND A~PARVW = 'WE'.   "납지

    ENDIF.

*& 권선의 경우 직납일 경우 직납을 납선에 표시
    IF ( GT_EBAN-WERKS = '1201' OR GT_EBAN-WERKS = '1304' )
       AND ( GT_EBAN-EMLIF IS NOT INITIAL ).

      SELECT SINGLE NAME1 AS NAME2
               INTO CORRESPONDING FIELDS OF GT_EBAN
               FROM LFA1
              WHERE LIFNR = GT_EBAN-EMLIF.
    ENDIF.

*& 꼬리표 발행 여부 체크...
    IF NOT GT_EBAN-EBELN IS INITIAL.
      SELECT SINGLE MANDT INTO ZPPT0001-MANDT
               FROM ZPPT0001
              WHERE WERKS = GT_EBAN-WERKS
                AND AUFNR = GT_EBAN-AUFNR
                AND POSNR = GT_EBAN-EBELP
                AND MATNR = GT_EBAN-MATNR.
      IF SY-SUBRC = 0.
        GT_EBAN-TAG_F = ICON_LED_GREEN.
      ELSE.
        GT_EBAN-TAG_F = ''.
      ENDIF.
    ENDIF.

*& 자동차 전선의 경우, 색상정보 발췌...
    IF GT_EBAN-DISPO = 'AUF' OR
       GT_EBAN-DISPO = 'AUH'.

      IF GT_EBAN-MTART = 'FERT' OR
         GT_EBAN-MTART = 'MCFE'.
        LV_MATNR = GT_EBAN-MATNR.
      ELSE.
*& 반제품에 대한 완제품코드를 찾는다...
        PERFORM GET_WU_RECS USING GT_EBAN-MATNR "반제품
                                  GT_EBAN-WERKS
                                 '1'
                         CHANGING LV_MATNR.     "완제품
      ENDIF.

      CLEAR  MARA.
      SELECT SINGLE ZZIDEN_CODE INTO GT_EBAN-ZZIDEN_CODE
               FROM MARA
              WHERE MATNR = LV_MATNR.

    ENDIF.

*& 2010/08/13 신규 발주 자재에 대한 표시
    IF GT_EBAN-WERKS EQ '1801' OR
       GT_EBAN-WERKS EQ '1901'.     "풍세전선 추가

      PERFORM CHECK_NEW_EBAN USING GT_EBAN-NPURC.

      IF GT_EBAN-NPURC EQ 'X'.
        GT_EBAN-NPURC = '신규'.
      ELSE.
        GT_EBAN-NPURC = ' '.
      ENDIF.

    ENDIF.

*& CSR : C2007020201000001000
*& 플랜트로 회사코드 조회
    CALL FUNCTION 'Z_FI_GET_ORG_CODE'
      EXPORTING
        I_WERKS = GT_EBAN-WERKS
      IMPORTING
        E_BUKRS = GT_EBAN-BUKRS.

*& 회사코드로 구매조직 조회
    SELECT SINGLE EKORG
      INTO GT_EBAN-EKORG
      FROM T024E
     WHERE BUKRS = GT_EBAN-BUKRS.

*  조장구성표번호, 완제품 및 완제품내역 필드 추가 / 박우진 2026.09.20.
    READ TABLE LT_0136 WITH KEY EBELN = GT_EBAN-EBELN
                       BINARY SEARCH.

    IF SY-SUBRC EQ 0.
      GT_EBAN-GRPCD   = LT_0136-GRPCD.   "조장구성표번호
      GT_EBAN-MATNR_F = LT_0136-MATNR_F.  "완제품 자재번호
      GT_EBAN-MAKTX   = LT_0136-MAKTX.  "완제품 자재번호
    ENDIF.

    MODIFY GT_EBAN.

  ENDLOOP.

ENDFORM.                    " additional_info_proc
*&---------------------------------------------------------------------*
*&      Form  modify_selection_screen
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MODIFY_SELECTION_SCREEN .
  LOOP AT SCREEN.
    IF     P_PRBOX = 'X'.
      IF SCREEN-NAME = 'P_CONF' OR
         SCREEN-NAME = 'P_CANCEL'.
        SCREEN-INPUT = 0.
      ENDIF.
    ELSEIF P_POBOX = 'X'.
      IF SCREEN-NAME = 'P_CONF' OR
         SCREEN-NAME = 'P_CANCEL'.
        SCREEN-INPUT = 0.
      ENDIF.
    ELSEIF P_CANCEL = 'X'.
      IF SCREEN-NAME = 'P_PRBOX' OR
         SCREEN-NAME = 'P_POBOX' OR
         SCREEN-NAME = 'P_CONF'.
        SCREEN-INPUT = 0.
      ENDIF.
    ELSEIF P_CONF = 'X'.
      IF SCREEN-NAME = 'P_PRBOX' OR
         SCREEN-NAME = 'P_POBOX' OR
         SCREEN-NAME = 'P_CANCEL'.
        SCREEN-INPUT = 0.
      ENDIF.

*(S)기능 추가 관련(SJM 25.03.25)
      IF SCREEN-GROUP1 = GC_CNF.
        SCREEN-ACTIVE = GC_0.
      ENDIF.
*(E)기능 추가 관련(SJM 25.03.25)
    ENDIF.

    IF SCREEN-GROUP1 = 'AAA'.
      IF P_POBOX  = 'X' OR
         P_CANCEL = 'X' OR
         P_CONF   = 'X'.
      ELSE.
        SCREEN-INPUT = 0.
      ENDIF.
    ENDIF.

    MODIFY SCREEN.

  ENDLOOP.

ENDFORM.                    " modify_selection_screen
*&---------------------------------------------------------------------*
*&      Form  create_and_init_controls
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CREATE_AND_INIT_CONTROLS .
  CHECK GCL_CUSTOM_CONTAINER IS INITIAL.

*& 상속받은 Object를 연결해 주는 작업
  CREATE OBJECT GCL_CUSTOM_CONTAINER
    EXPORTING
      CONTAINER_NAME = GV_CONTAINER.
  CREATE OBJECT GCL_GRID
    EXPORTING
      I_PARENT      = GCL_CUSTOM_CONTAINER
      I_APPL_EVENTS = 'X'.

  PERFORM EXCLUDE_OF_TOOLBAR_BUTTON USING 'GT_EXCLUDE'.

*& 출력할 필드 속성을 정의
  PERFORM SET_FIELD_CATALOGS.

  PERFORM SET_CELL_ATTRIBUTE .

*& GRID 속성 지정(Display): Display시 옵션 지정
  PERFORM DISPLAY_LAYOUT_ATTRIBUTE USING GS_LAYOCAT.

*& Edit Event 및  Event Handler 등록
  PERFORM EVENT_HANDLER_REGISTER.

*& Sorting
  PERFORM BUILD_SORT_FIELD.

*& Define a drop down table.
*&  PERFORM set_drdn_table.

  GV_REPID = SY-REPID.

*& At least field REPORT of this structure has to be filled!
  ALV_VARIANT-REPORT = GV_REPID.

  GV_TITLE = '외주가공 및 부하상품 지시 리스트'.

*& ALV Grid Display
  PERFORM ALV_GRID_DISPLAY.

*  CALL METHOD gcl_grid->set_gridtitle
*    EXPORTING
*      i_gridtitle = gv_title.

  LCL_ALV_GRID=>F_ALV = '1'.

ENDFORM.                    " create_and_init_controls
*&---------------------------------------------------------------------*
*&      Form  exclude_of_toolbar_button
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0173   text
*----------------------------------------------------------------------*
FORM EXCLUDE_OF_TOOLBAR_BUTTON  USING  PV_TABNAME.
  DATA : LV_TAB_NAME             LIKE  FELD-NAME.
  FIELD-SYMBOLS : <TABLE>        TYPE  UI_FUNCTIONS.

  CONCATENATE PV_TABNAME '[]'    INTO  LV_TAB_NAME.
  ASSIGN     (LV_TAB_NAME)         TO <TABLE>.

*& 제거할 버튼 지정
  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON
   TABLES <TABLE>
*    USING : cl_gui_alv_grid=>mc_fc_excl_all. " ** 툴바 모두제거 **
    USING : CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO, " 실행취소&LOCAL&UNDO
            CL_GUI_ALV_GRID=>MC_FC_AUF,      " 소계확장 &AUF
            CL_GUI_ALV_GRID=>MC_FC_AVERAGE,  " &AVERAGE
*            cl_gui_alv_grid=>mc_fc_back_classic,
*            cl_gui_alv_grid=>mc_fc_call_abc, " &ABC
*            cl_gui_alv_grid=>mc_fc_call_chain,
*            cl_gui_alv_grid=>mc_fc_call_crbatch,
*            cl_gui_alv_grid=>mc_fc_call_crweb,
*            cl_gui_alv_grid=>mc_fc_call_lineitems,
*            cl_gui_alv_grid=>mc_fc_call_master_data,
*            cl_gui_alv_grid=>mc_fc_call_more,
*            cl_gui_alv_grid=>mc_fc_call_report,
*            cl_gui_alv_grid=>mc_fc_call_xint,
*            cl_gui_alv_grid=>mc_fc_call_xxl,
*            cl_gui_alv_grid=>mc_fc_col_invisible,
*            cl_gui_alv_grid=>mc_fc_col_optimize,
*            cl_gui_alv_grid=>mc_fc_current_variant,
*            cl_gui_alv_grid=>mc_fc_data_save,
*            cl_gui_alv_grid=>mc_fc_delete_filter,
*            cl_gui_alv_grid=>mc_fc_deselect_all,
*            cl_gui_alv_grid=>mc_fc_detail,
*            cl_gui_alv_grid=>mc_fc_expcrdata,
*            cl_gui_alv_grid=>mc_fc_expcrdesig,
*            cl_gui_alv_grid=>mc_fc_expcrtempl,
*            cl_gui_alv_grid=>mc_fc_expmdb,
*            cl_gui_alv_grid=>mc_fc_extend,
*            cl_gui_alv_grid=>mc_fc_f4,
*            cl_gui_alv_grid=>mc_fc_filter,
*            cl_gui_alv_grid=>mc_fc_find,
*            cl_gui_alv_grid=>mc_fc_fix_columns,
            CL_GUI_ALV_GRID=>MC_FC_GRAPH,
*            cl_gui_alv_grid=>mc_fc_help,
*            cl_gui_alv_grid=>mc_fc_info,
*            cl_gui_alv_grid=>mc_fc_load_variant,
*            cl_gui_alv_grid=>mc_fc_loc_copy,          " 행 카피.
*            cl_gui_alv_grid=>mc_fc_html,
            CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW,      " 열 카피.
            CL_GUI_ALV_GRID=>MC_FC_LOC_CUT,           " 가위.
            CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW,    " 행삭제.
            CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW,    " 행삽입.
            CL_GUI_ALV_GRID=>MC_FC_LOC_MOVE_ROW,
            CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW,    " 라인생성.
            CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE,         " 겹쳐쓰기.
            CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW. " 겹쳐쓰기.
*            cl_gui_alv_grid=>mc_fc_maintain_variant,
*            cl_gui_alv_grid=>mc_fc_maximum,
*            cl_gui_alv_grid=>mc_fc_minimum,
*            cl_gui_alv_grid=>mc_fc_pc_file,
*            cl_gui_alv_grid=>mc_fc_print,
*            cl_gui_alv_grid=>mc_fc_print_back,
*            cl_gui_alv_grid=>mc_fc_print_prev,
*            cl_gui_alv_grid=>mc_fc_refresh,
*            cl_gui_alv_grid=>mc_fc_reprep,
*            cl_gui_alv_grid=>mc_fc_save_variant,
*            cl_gui_alv_grid=>mc_fc_select_all.
*            cl_gui_alv_grid=>mc_fc_send,
*            cl_gui_alv_grid=>mc_fc_separator,
*            cl_gui_alv_grid=>mc_fc_sort,
*            cl_gui_alv_grid=>mc_fc_sort_asc,
*            cl_gui_alv_grid=>mc_fc_sort_dsc,
*            cl_gui_alv_grid=>mc_fc_subtot,
*            cl_gui_alv_grid=>mc_mb_sum,
*            cl_gui_alv_grid=>mc_fc_sum.
*            cl_gui_alv_grid=>mc_fc_to_office,
*            cl_gui_alv_grid=>mc_fc_to_rep_tree,
*            cl_gui_alv_grid=>mc_fc_unfix_columns,
*            cl_gui_alv_grid=>mc_fc_views,
*            cl_gui_alv_grid=>mc_fc_view_crystal,
*            cl_gui_alv_grid=>mc_fc_view_excel,
*            cl_gui_alv_grid=>mc_fc_view_grid,
*            cl_gui_alv_grid=>mc_fc_word_processor.

ENDFORM.                    " exclude_of_toolbar_button
*&---------------------------------------------------------------------*
*&      Form  set_field_catalogs
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_FIELD_CATALOGS .
  REFRESH GT_FIELDCAT.   CLEAR GT_FIELDCAT.

  PERFORM   FILL_FIELD_CATALOGS
   TABLES   GT_FIELDCAT
    USING: 'S' 'FIELDNAME'        'CHECK',
           ' ' 'COLTEXT'          '선택',
           ' ' 'JUST'             'C',
           ' ' 'CHECKBOX'         'X',
           ' ' 'EDIT'             'X',
           ' ' 'KEY'              'X',
           'E' 'OUTPUTLEN'        '1'.

*& 2010/08/13 선재 신규 발재 구분 추가
  IF P_WERKS EQ '1801' OR P_WERKS EQ '1901'.  "풍세전선 추가

    PERFORM   FILL_FIELD_CATALOGS
     TABLES   GT_FIELDCAT
      USING: 'S' 'FIELDNAME'      'NPURC',
           ' ' 'COLTEXT'          '발주구분',
           ' ' 'JUST'             'L',
           ' ' 'F4AVAILABL'       'X',
           'E' 'OUTPUTLEN'        '08'.

  ENDIF.

  PERFORM   FILL_FIELD_CATALOGS
   TABLES   GT_FIELDCAT
    USING:'S' 'FIELDNAME'        'WERKS',
          ' ' 'COLTEXT'          '플랜트',
          ' ' 'JUST'             'C',
          ' ' 'KEY'              'X',
          'E' 'OUTPUTLEN'        '04',

          'S' 'FIELDNAME'        'DISPO',
          ' ' 'COLTEXT'          'MRP관리자',
          ' ' 'JUST'             'C',
          ' ' 'KEY'              'X',
          'E' 'OUTPUTLEN'        '01',

          'S' 'FIELDNAME'        'MATNR',
          ' ' 'COLTEXT'          '자재코드',
          ' ' 'JUST'             'C',
          ' ' 'NO_ZERO'          'X',
*&           ' ' 'F4AVAILABL'       'X',
*&           ' ' 'REF_FIELD'        'MATNR',
*&           ' ' 'REF_TABLE'        'MARA',
          ' ' 'CONVEXIT'         'MATN1',
          'E' 'OUTPUTLEN'        '10',

          'S' 'FIELDNAME'        'TXZ01',
          ' ' 'COLTEXT'          '자재명',
          ' ' 'JUST'             'L',
          'E' 'OUTPUTLEN'        '80',

          'S' 'FIELDNAME'        'ZZIDEN_CODE',
          ' ' 'COLTEXT'          '절연선심식별',
          ' ' 'JUST'             'L',
          'E' 'OUTPUTLEN'        '30',

          'S' 'FIELDNAME'        'BANFN',
          ' ' 'COLTEXT'          '구매요청No.',
          ' ' 'JUST'             'C',
          ' ' 'NO_ZERO'          'X',
          'E' 'OUTPUTLEN'        '10',

          'S' 'FIELDNAME'        'BNFPO',
          ' ' 'COLTEXT'          '품목',
          ' ' 'JUST'             'C',
          ' ' 'NO_ZERO'          'X',
          'E' 'OUTPUTLEN'        '05',

          'S' 'FIELDNAME'        'MENGE',
          ' ' 'COLTEXT'          '구매요청수량',
          ' ' 'JUST'             'R',
          ' ' 'NO_ZERO'          'X',
          ' ' 'QFIELDNAME'       'MEINS',
          ' ' 'REF_FIELD'        'MENGE',
          ' ' 'REF_TABLE'        'EBAN',
          'E' 'OUTPUTLEN'        '17',

          'S' 'FIELDNAME'        'MEINS',
          ' ' 'COLTEXT'          '단위',
          ' ' 'JUST'             'C',
          'E' 'OUTPUTLEN'        '03',

          'S' 'FIELDNAME'        'LFDAT',
          ' ' 'COLTEXT'          '납품일자',
          ' ' 'JUST'             'C',
          ' ' 'F4AVAILABL'       'X',
          ' ' 'REF_FIELD'        'LFDAT',
          ' ' 'REF_TABLE'        'EBAN',
          'E' 'OUTPUTLEN'        '10',

* [S] 조장구성표, 완제품코드, 완제품내역 필드추가 / 박우진 2026.09.21 .
          'S' 'FIELDNAME'        'GRPCD',
          ' ' 'COLTEXT'          '조장구성표',
          ' ' 'JUST'             'C',
          ' ' 'NO_ZERO'          'X',
          'E' 'OUTPUTLEN'        '10',

          'S' 'FIELDNAME'        'MATNR_F',
          ' ' 'COLTEXT'          '완제품코드',
          ' ' 'JUST'             'C',
          ' ' 'NO_ZERO'          'X',
          ' ' 'CONVEXIT'         'MATN1',
          'E' 'OUTPUTLEN'        '10',

          'S' 'FIELDNAME'        'MAKTX',
          ' ' 'COLTEXT'          '완제품명',
          ' ' 'JUST'             'L',
          'E' 'OUTPUTLEN'        '80'.
* [S] 조장구성표, 완제품코드, 완제품내역 필드추가 / 박우진 2026.09.21 .


  IF P_CONF = 'X'.
    PERFORM   FILL_FIELD_CATALOGS
     TABLES   GT_FIELDCAT
      USING: 'S' 'FIELDNAME'        'EINDT',
             ' ' 'COLTEXT'          '확정일자',
             ' ' 'JUST'             'C',
             ' ' 'F4AVAILABL'       'X',
             'E' 'OUTPUTLEN'        '10',

             'S' 'FIELDNAME'        'MENGE_C',
             ' ' 'COLTEXT'          '확정수량',
             ' ' 'JUST'             'R',
             ' ' 'NO_ZERO'          'X',
             ' ' 'QFIELDNAME'       'MEINS',
             ' ' 'REF_FIELD'        'MENGE',
             ' ' 'REF_TABLE'        'EKES',
             'E' 'OUTPUTLEN'        '17'.
  ENDIF.

  PERFORM   FILL_FIELD_CATALOGS
   TABLES   GT_FIELDCAT
    USING: 'S' 'FIELDNAME'        'EPSTP',
           ' ' 'COLTEXT'          'I.C',
           ' ' 'JUST'             'C',
           ' ' 'F4AVAILABL'       'X',
           'E' 'OUTPUTLEN'        '01',

           'S' 'FIELDNAME'        'LIFNR',
           ' ' 'COLTEXT'          '업체',
           ' ' 'JUST'             'C',
*&           ' ' 'F4AVAILABL'       'X',
           ' ' 'REF_FIELD'        'LIFNR',
           ' ' 'REF_TABLE'        'LFA1',
           'E' 'OUTPUTLEN'        '10',

           'S' 'FIELDNAME'        'NAME1',
           ' ' 'COLTEXT'          '업체명',
           ' ' 'JUST'             'L',
           'E' 'OUTPUTLEN'        '35',

           'S' 'FIELDNAME'        'MENGE_A',
           ' ' 'COLTEXT'          '외주지시수량',
           ' ' 'JUST'             'R',
           ' ' 'NO_ZERO'          'X',
           ' ' 'QFIELDNAME'       'MEINS_A',
           ' ' 'REF_FIELD'        'MENGE',
           ' ' 'REF_TABLE'        'EKPO',
           'E' 'OUTPUTLEN'        '17',

           'S' 'FIELDNAME'        'MEINS_A',
           ' ' 'COLTEXT'          '단위',
           ' ' 'JUST'             'C',
           'E' 'OUTPUTLEN'        '03',

           'S' 'FIELDNAME'        'LENGTH',
           ' ' 'COLTEXT'          '개별길이',
           ' ' 'JUST'             'L',
           ' ' 'NO_ZERO'          'X',
           'E' 'OUTPUTLEN'        '30',

           'S' 'FIELDNAME'        'FACTOR',
           ' ' 'COLTEXT'          '조장수',
           ' ' 'JUST'             'L',
           ' ' 'NO_ZERO'          'X',
           'E' 'OUTPUTLEN'        '30'.

  IF P_WERKS EQ '1303'.

    PERFORM   FILL_FIELD_CATALOGS
     TABLES   GT_FIELDCAT
      USING: 'S' 'FIELDNAME'      'ZCERTI',
           ' ' 'COLTEXT'          '인증',
           ' ' 'JUST'             'L',
           ' ' 'F4AVAILABL'       'X',
           'E' 'OUTPUTLEN'        '04'.

  ENDIF.

  PERFORM   FILL_FIELD_CATALOGS
  TABLES   GT_FIELDCAT
   USING:'S' 'FIELDNAME'        'PACKING_CAT',
         ' ' 'COLTEXT'          '포장재유형',
         ' ' 'JUST'             'L',
         ' ' 'F4AVAILABL'       'X',
*&           ' ' 'DRDN_HNDL'        '1',
         'E' 'OUTPUTLEN'        '30',

         'S' 'FIELDNAME'        'PACKING',
         ' ' 'COLTEXT'          '포장재',
         ' ' 'JUST'             'L',
         ' ' 'NO_ZERO'          'X',
*&           ' ' 'F4AVAILABL'       'X',
*&           ' ' 'DRDN_HNDL'        '1',
         'E' 'OUTPUTLEN'        '30',

         'S' 'FIELDNAME'        'MENGE_B',
         ' ' 'COLTEXT'          '구매요청잔량',
         ' ' 'JUST'             'R',
         ' ' 'NO_ZERO'          'X',
         ' ' 'QFIELDNAME'       'MEINS',
         ' ' 'REF_FIELD'        'MENGE',
         ' ' 'REF_TABLE'        'EBAN',
         'E' 'OUTPUTLEN'        '17',

         'S' 'FIELDNAME'        'LOSSR',
         ' ' 'COLTEXT'          '업체Loss율',
         ' ' 'JUST'             'C',
         ' ' 'NO_ZERO'          'X',
         ' ' 'REF_FIELD'        'LOSSR',
         ' ' 'REF_TABLE'        'ZPPT0018',
         'E' 'OUTPUTLEN'        '04',

         'S' 'FIELDNAME'        'EBELN',
         ' ' 'COLTEXT'          '구매오더No.',
         ' ' 'JUST'             'C',
         'E' 'OUTPUTLEN'        '10',

         'S' 'FIELDNAME'        'EBELP',
         ' ' 'COLTEXT'          'Item',
         ' ' 'JUST'             'C',
         ' ' 'NO_ZERO'          'X',
         'E' 'OUTPUTLEN'        '05',

         'S' 'FIELDNAME'        'AEDAT',
         ' ' 'COLTEXT'          '발주일자',
         ' ' 'JUST'             'C',
         ' ' 'F4AVAILABL'       'X',
         ' ' 'REF_FIELD'        'AEDAT',
         ' ' 'REF_TABLE'        'EKKO',
         'E' 'OUTPUTLEN'        '10',

         'S' 'FIELDNAME'        'ERDAT',
         ' ' 'COLTEXT'          '변경일자',
         ' ' 'JUST'             'C',
         ' ' 'F4AVAILABL'       'X',
         ' ' 'REF_FIELD'        'AEDAT',
         ' ' 'REF_TABLE'        'EKPO',
         'E' 'OUTPUTLEN'        '10',

         'S' 'FIELDNAME'        'CHARG',
         ' ' 'COLTEXT'          '뱃치번호',
         ' ' 'JUST'             'L',
         ' ' 'NO_ZERO'          'X',
         'E' 'OUTPUTLEN'        '10'.

  IF P_CONF <> GC_X. "추가(SJM 25.03.18)
    PERFORM FILL_FIELD_CATALOGS
     TABLES GT_FIELDCAT USING :
            'S' 'FIELDNAME'     'STATS_L',
            ' ' 'COLTEXT'       '승인상태(배치 관리자재)',
            ' ' 'JUST'          'C',
            'E' 'OUTPUTLEN'     '4',

            'S' 'FIELDNAME'     'STATS_W',
            ' ' 'COLTEXT'       '승인상태(배치 미관리자재)',
            ' ' 'JUST'          'C',
            'E' 'OUTPUTLEN'     '4',

            'S' 'FIELDNAME'     'ZGUID_L',
            ' ' 'COLTEXT'       'ZGUID(배치 관리자재)',
            ' ' 'JUST'          'L',
            ' ' 'NO_OUT'        'X',
            'E' 'OUTPUTLEN'     '32',

            'S' 'FIELDNAME'     'ZGUID_W',
            ' ' 'COLTEXT'       'ZGUID(배치 미관리자재)',
            ' ' 'JUST'          'L',
            ' ' 'NO_OUT'        'X',
            'E' 'OUTPUTLEN'     '32'.
  ENDIF.

  PERFORM FILL_FIELD_CATALOGS
   TABLES GT_FIELDCAT USING :
       'S' 'FIELDNAME'        'FLAG1',
       ' ' 'COLTEXT'          '이전전기',
       ' ' 'JUST'             'C',
       ' ' 'ICON'             'X',
       'E' 'OUTPUTLEN'        '04',

       'S' 'FIELDNAME'        'FLAG2',
       ' ' 'COLTEXT'          '통문증발행',
       ' ' 'JUST'             'C',
       ' ' 'ICON'             'X',
       'E' 'OUTPUTLEN'        '04',

       'S' 'FIELDNAME'        'TAG_F',
       ' ' 'COLTEXT'          '꼬리표발행여부',
       ' ' 'JUST'             'C',
       ' ' 'ICON'             'X',
       'E' 'OUTPUTLEN'        '04',

       'S' 'FIELDNAME'        'VBELN',
       ' ' 'COLTEXT'          '영업문서',
       ' ' 'NO_ZERO'          'X',
       ' ' 'JUST'             'C',
       'E' 'OUTPUTLEN'        '10',

       'S' 'FIELDNAME'        'POSNR',
       ' ' 'COLTEXT'          '품목',
       ' ' 'JUST'             'C',
       ' ' 'NO_ZERO'          'X',
       'E' 'OUTPUTLEN'        '06',

       'S' 'FIELDNAME'        'NAME2',
       ' ' 'COLTEXT'          '납선',
       ' ' 'JUST'             'C',
       'E' 'OUTPUTLEN'        '35',

        'S' 'FIELDNAME'        'NAME3',
       ' ' 'COLTEXT'          '납지',
       ' ' 'JUST'             'C',
       'E' 'OUTPUTLEN'        '35',


       'S' 'FIELDNAME'        'GLMNG',
       ' ' 'COLTEXT'          '납품수량',
       ' ' 'JUST'             'R',
       ' ' 'NO_ZERO'          'X',
       ' ' 'QFIELDNAME'       'MEINS',
       ' ' 'REF_FIELD'        'MENGE',
       ' ' 'REF_TABLE'        'EBAN',
       'E' 'OUTPUTLEN'        '17',

       'S' 'FIELDNAME'        'LTEXT1',
       ' ' 'COLTEXT'          '구매오더정보',
       ' ' 'JUST'             'L',
       'E' 'OUTPUTLEN'        '132',

       'S' 'FIELDNAME'        'LTEXT2',
       ' ' 'COLTEXT'          '판매오더정보',
       ' ' 'JUST'             'L',
       'E' 'OUTPUTLEN'        '132'.

ENDFORM.                    " set_field_catalogs
*&---------------------------------------------------------------------*
*&      Form  set_cell_attribute
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_CELL_ATTRIBUTE .
*& 각 Cell의 특성 제어
  DATA : LT_CELLTAB  TYPE LVC_T_STYL,
         LT_COLOR    TYPE LVC_T_SCOL,
         LV_INDEX    TYPE I,
         LF_ATNEW(1).

  LOOP AT GT_EBAN.
    CLEAR: LT_CELLTAB[], LT_COLOR[].

    LV_INDEX = SY-TABIX.

    PERFORM FILL_CELLTAB CHANGING LT_CELLTAB.
    PERFORM FILL_COLOR   CHANGING LT_COLOR.

    CLEAR: GT_EBAN-CELLTAB[], GT_EBAN-F_COL[].

    INSERT LINES OF LT_CELLTAB INTO TABLE GT_EBAN-CELLTAB.
    INSERT LINES OF LT_COLOR   INTO TABLE GT_EBAN-F_COL.

    MODIFY GT_EBAN. " INDEX lv_index.
    CLEAR  GT_EBAN.

  ENDLOOP.

ENDFORM.                    " set_cell_attribute
*&---------------------------------------------------------------------*
*&      Form  fill_celltab
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LT_CELLTAB  text
*----------------------------------------------------------------------*
FORM FILL_CELLTAB  CHANGING PT_CELLTAB TYPE LVC_T_STYL.

  DATA : LS_CELLTAB TYPE LVC_S_STYL,
         LV_MODE    TYPE RAW4.
  DATA : LS_FIELDCAT   TYPE LVC_S_FCAT.

  LOOP AT GT_FIELDCAT INTO LS_FIELDCAT.
    LS_CELLTAB-FIELDNAME = LS_FIELDCAT-FIELDNAME.

    CASE LS_FIELDCAT-FIELDNAME.
*      WHEN 'CHECK'.
*        IF p_conf = 'X'.
*          ls_celltab-style  = cl_gui_alv_grid=>mc_style_disabled.
*          ls_celltab-style4 = cl_gui_alv_grid=>mc_style4_link_no.
*        ELSE.
*          ls_celltab-style  = cl_gui_alv_grid=>mc_style_enabled.
*          ls_celltab-style4 = cl_gui_alv_grid=>mc_style4_link_no.
*        ENDIF.

      WHEN 'CHECK'.
        LS_CELLTAB-STYLE  = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
        LS_CELLTAB-STYLE4 = CL_GUI_ALV_GRID=>MC_STYLE4_LINK_NO.

        INSERT LS_CELLTAB INTO TABLE PT_CELLTAB.

      WHEN 'EPSTP'. " OR 'LOSSR'.
        IF P_CANCEL        = 'X'  OR
           GT_EBAN-MENGE_B <  1   OR
           GT_EBAN-EBTYP   = 'AB' OR
           GT_EBAN-EBTYP   = 'LA' OR
         ( NOT GT_EBAN-EBELN IS INITIAL ).
          LS_CELLTAB-STYLE  = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED +
                              CL_GUI_ALV_GRID=>MC_STYLE_F4_NO.
          LS_CELLTAB-STYLE4 = CL_GUI_ALV_GRID=>MC_STYLE4_LINK_NO.
        ELSE.
          LS_CELLTAB-STYLE  = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
          LS_CELLTAB-STYLE4 = CL_GUI_ALV_GRID=>MC_STYLE4_LINK_NO.
        ENDIF.

        INSERT LS_CELLTAB INTO TABLE PT_CELLTAB.

      WHEN 'LOSSR'.
        IF P_CANCEL        = 'X'  OR
           GT_EBAN-LOSSF   = 'X'  OR
           GT_EBAN-EBTYP   = 'AB' OR
           GT_EBAN-EBTYP   = 'LA'.
          LS_CELLTAB-STYLE  = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED +
                              CL_GUI_ALV_GRID=>MC_STYLE_F4_NO.
          LS_CELLTAB-STYLE4 = CL_GUI_ALV_GRID=>MC_STYLE4_LINK_NO.
        ELSE.
          LS_CELLTAB-STYLE  = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
          LS_CELLTAB-STYLE4 = CL_GUI_ALV_GRID=>MC_STYLE4_LINK_NO.
        ENDIF.

        INSERT LS_CELLTAB INTO TABLE PT_CELLTAB.

      WHEN 'LFDAT' OR 'MENGE_A' OR 'PACKING_CAT' OR
           'PACKING' OR 'MEINS_A' OR 'ZCERTI'.
        IF P_CANCEL      = 'X'  OR
           GT_EBAN-EBTYP = 'AB' OR
           GT_EBAN-EBTYP = 'LA'.
          LS_CELLTAB-STYLE  = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED +
                              CL_GUI_ALV_GRID=>MC_STYLE_F4_NO.
          LS_CELLTAB-STYLE4 = CL_GUI_ALV_GRID=>MC_STYLE4_LINK_NO.
        ELSE.
          LS_CELLTAB-STYLE  = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
          LS_CELLTAB-STYLE4 = CL_GUI_ALV_GRID=>MC_STYLE4_LINK_NO.
        ENDIF.

        INSERT LS_CELLTAB INTO TABLE PT_CELLTAB.

      WHEN 'LENGTH'.
        IF P_CANCEL      = 'X'  OR
           GT_EBAN-EBTYP = 'AB' OR
           GT_EBAN-EBTYP = 'LA' OR
           GT_EBAN-DPCBT =  SPACE.
          LS_CELLTAB-STYLE  = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED +
                              CL_GUI_ALV_GRID=>MC_STYLE_F4_NO.
          LS_CELLTAB-STYLE4 = CL_GUI_ALV_GRID=>MC_STYLE4_LINK_NO.
        ELSE.
          LS_CELLTAB-STYLE  = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
          LS_CELLTAB-STYLE4 = CL_GUI_ALV_GRID=>MC_STYLE4_LINK_NO.
        ENDIF.

        INSERT LS_CELLTAB INTO TABLE PT_CELLTAB.

      WHEN 'FACTOR'.
        IF P_CANCEL      = 'X'  OR
           GT_EBAN-EBTYP = 'AB' OR
           GT_EBAN-EBTYP = 'LA' OR
           GT_EBAN-DPCBT = 'A'  OR
           GT_EBAN-DPCBT =  SPACE.
          LS_CELLTAB-STYLE  = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED +
                              CL_GUI_ALV_GRID=>MC_STYLE_F4_NO.
          LS_CELLTAB-STYLE4 = CL_GUI_ALV_GRID=>MC_STYLE4_LINK_NO.
        ELSE.
          LS_CELLTAB-STYLE  = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
          LS_CELLTAB-STYLE4 = CL_GUI_ALV_GRID=>MC_STYLE4_LINK_NO.
        ENDIF.

        INSERT LS_CELLTAB INTO TABLE PT_CELLTAB.

      WHEN 'LIFNR'.
        IF P_CANCEL          = 'X'  OR
           GT_EBAN-MENGE_B   <  1   OR
           GT_EBAN-EBTYP     = 'AB' OR
           GT_EBAN-EBTYP     = 'LA' OR
         ( NOT GT_EBAN-EBELN IS INITIAL ).
          LS_CELLTAB-STYLE  = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED +
                              CL_GUI_ALV_GRID=>MC_STYLE_F4_NO.
          LS_CELLTAB-STYLE4 = CL_GUI_ALV_GRID=>MC_STYLE4_LINK.
        ELSE.
          LS_CELLTAB-STYLE  = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
          LS_CELLTAB-STYLE4 = CL_GUI_ALV_GRID=>MC_STYLE4_LINK.
        ENDIF.

        INSERT LS_CELLTAB INTO TABLE PT_CELLTAB.

      WHEN 'CHARG'.
        IF P_CANCEL       = 'X'   OR
           GT_EBAN-EBTYP  = 'AB'  OR
           GT_EBAN-EBTYP  = 'LA'  OR
           GT_EBAN-SPART <> '21'.     "자동차전선
          LS_CELLTAB-STYLE  = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED +
                              CL_GUI_ALV_GRID=>MC_STYLE_F4_NO.
          LS_CELLTAB-STYLE4 = CL_GUI_ALV_GRID=>MC_STYLE4_LINK.
        ELSE.
          LS_CELLTAB-STYLE  = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
          LS_CELLTAB-STYLE4 = CL_GUI_ALV_GRID=>MC_STYLE4_LINK.
        ENDIF.
        INSERT LS_CELLTAB INTO TABLE PT_CELLTAB.

      WHEN 'MATNR' OR 'BANFN' OR 'EBELN'.
        LS_CELLTAB-STYLE  = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED +
                            CL_GUI_ALV_GRID=>MC_STYLE_F4_NO.
        LS_CELLTAB-STYLE4 = CL_GUI_ALV_GRID=>MC_STYLE4_LINK.
        INSERT LS_CELLTAB INTO TABLE PT_CELLTAB.

      WHEN  OTHERS.
        LS_CELLTAB-STYLE  = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED +
                            CL_GUI_ALV_GRID=>MC_STYLE_F4_NO.
        LS_CELLTAB-STYLE4 = CL_GUI_ALV_GRID=>MC_STYLE4_LINK_NO.
        INSERT LS_CELLTAB INTO TABLE PT_CELLTAB.

    ENDCASE.

  ENDLOOP.

ENDFORM.                    " fill_celltab
*&---------------------------------------------------------------------*
*&      Form  fill_color
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LT_COLOR  text
*----------------------------------------------------------------------*
FORM FILL_COLOR  CHANGING PT_COLOR TYPE LVC_T_SCOL.

  DATA : LS_CELLTAB TYPE LVC_S_STYL,
         LS_COLOR   TYPE LVC_S_SCOL,
         LV_MODE    TYPE RAW4.

  DATA : LS_FIELDCAT TYPE LVC_S_FCAT.

  LOOP AT GT_FIELDCAT INTO LS_FIELDCAT.
    LS_COLOR-FNAME = LS_FIELDCAT-FIELDNAME.
    CASE LS_FIELDCAT-FIELDNAME.
      WHEN 'CHECK'.
        LS_COLOR-COLOR-COL = 0.
        LS_COLOR-COLOR-INT = 1.

      WHEN 'EPSTP' OR 'LIFNR'. " OR 'LOSSR'.
        IF P_CANCEL        = 'X'  OR
           GT_EBAN-MENGE_B <  1   OR
           GT_EBAN-EBTYP   = 'AB' OR
           GT_EBAN-EBTYP   = 'LA' OR
     ( NOT GT_EBAN-EBELN   IS INITIAL ).
          LS_COLOR-COLOR-COL = 4.
          LS_COLOR-COLOR-INT = 0.
        ELSE.
          LS_COLOR-COLOR-COL = 0.
          LS_COLOR-COLOR-INT = 1.
        ENDIF.

      WHEN 'LOSSR'.
        IF P_CANCEL        = 'X'  OR
           GT_EBAN-LOSSF   = 'X'  OR
           GT_EBAN-EBTYP   = 'AB' OR
           GT_EBAN-EBTYP   = 'LA'.
          LS_COLOR-COLOR-COL = 4.
          LS_COLOR-COLOR-INT = 0.
        ELSE.
          LS_COLOR-COLOR-COL = 0.
          LS_COLOR-COLOR-INT = 1.
        ENDIF.

      WHEN 'LFDAT' OR 'MENGE_A' OR 'PACKING_CAT' OR
           'PACKING' OR 'MEINS_A' OR 'ZCERTI'.
        IF P_CANCEL      = 'X'  OR
           GT_EBAN-EBTYP = 'AB' OR
           GT_EBAN-EBTYP = 'LA'.

          LS_COLOR-COLOR-COL = 4.
          LS_COLOR-COLOR-INT = 0.
        ELSE.
          LS_COLOR-COLOR-COL = 0.
          LS_COLOR-COLOR-INT = 1.
        ENDIF.

      WHEN 'LENGTH'.
        IF P_CANCEL      = 'X'  OR
           GT_EBAN-EBTYP = 'AB' OR
           GT_EBAN-EBTYP = 'LA' OR
           GT_EBAN-DPCBT =  SPACE.       "일반뱃치

          LS_COLOR-COLOR-COL = 4.
          LS_COLOR-COLOR-INT = 0.
        ELSE.
          LS_COLOR-COLOR-COL = 0.
          LS_COLOR-COLOR-INT = 1.
        ENDIF.

      WHEN 'FACTOR'.
        IF P_CANCEL      = 'X'  OR
           GT_EBAN-EBTYP = 'AB' OR
           GT_EBAN-EBTYP = 'LA' OR
           GT_EBAN-DPCBT = 'A'  OR       "싱글뱃치
           GT_EBAN-DPCBT =  SPACE.       "일반뱃치

          LS_COLOR-COLOR-COL = 4.
          LS_COLOR-COLOR-INT = 0.
        ELSE.
          LS_COLOR-COLOR-COL = 0.
          LS_COLOR-COLOR-INT = 1.
        ENDIF.

      WHEN 'CHARG'.
        IF P_CANCEL       = 'X'  OR
           GT_EBAN-EBTYP  = 'AB' OR
           GT_EBAN-EBTYP  = 'LA' OR
           GT_EBAN-SPART <> '21'.   "자동차전선
          LS_COLOR-COLOR-COL = 4.
          LS_COLOR-COLOR-INT = 0.
        ELSE.
          LS_COLOR-COLOR-COL = 0.
          LS_COLOR-COLOR-INT = 1.
        ENDIF.

      WHEN 'WERKS' OR 'DISPO' OR 'MATNR'.
        LS_COLOR-COLOR-COL = 1.
        LS_COLOR-COLOR-INT = 1.

      WHEN 'EINDT' OR 'MENGE_C'.
        LS_COLOR-COLOR-COL = 6.
        LS_COLOR-COLOR-INT = 0.

      WHEN  OTHERS.
        LS_COLOR-COLOR-COL = 4.
        LS_COLOR-COLOR-INT = 0.

    ENDCASE.

    INSERT LS_COLOR INTO TABLE PT_COLOR.
  ENDLOOP.

ENDFORM.                    " fill_color
*&---------------------------------------------------------------------*
*&      Form  display_layout_attribute
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_LAYOCAT  text
*----------------------------------------------------------------------*
FORM DISPLAY_LAYOUT_ATTRIBUTE  USING  PS_LAYOCAT TYPE LVC_S_LAYO.

*& General display options
  PS_LAYOCAT-CWIDTH_OPT = 'X'.
*  ps_layocat-sel_mode   = 'D'.
*  ps_layocat-edit       = 'E'.
  PS_LAYOCAT-NO_ROWMARK = 'X'.           "선택버튼 비활성
  PS_LAYOCAT-STYLEFNAME = 'CELLTAB'.
  PS_LAYOCAT-CTAB_FNAME = 'F_COL'.
  PS_LAYOCAT-SMALLTITLE = 'X'.           "작은타이틀.

ENDFORM.                    " display_layout_attribute
*&---------------------------------------------------------------------*
*&      Form  event_handler_register
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM EVENT_HANDLER_REGISTER .
  DATA: LT_F4 TYPE LVC_T_F4 WITH HEADER LINE.

  CLEAR LT_F4.
  LT_F4-FIELDNAME  = 'EPSTP'.
  LT_F4-REGISTER   = 'X'.
  LT_F4-GETBEFORE  = 'X'.
  LT_F4-CHNGEAFTER = SPACE.
  INSERT TABLE LT_F4.

  CLEAR LT_F4.
  LT_F4-FIELDNAME  = 'PACKING_CAT'.
  LT_F4-REGISTER   = 'X'.
  LT_F4-GETBEFORE  = 'X'.
  LT_F4-CHNGEAFTER = SPACE.
  INSERT TABLE LT_F4.

  CLEAR LT_F4.
  LT_F4-FIELDNAME  = 'ZCERTI'.
  LT_F4-REGISTER   = 'X'.
  LT_F4-GETBEFORE  = 'X'.
  LT_F4-CHNGEAFTER = SPACE.
  INSERT TABLE LT_F4.


*& ONF4 이벤트 등록
  CALL METHOD GCL_GRID->REGISTER_F4_FOR_FIELDS
    EXPORTING
      IT_F4 = LT_F4[].

*& Edit  이벤트 등록
* IF MC_EVT_MODIFY  -> 바로 수정됨.
  CALL METHOD GCL_GRID->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

*& Event Handler 등록
  CREATE OBJECT GCL_EVENT_HANDLER.

  SET HANDLER GCL_EVENT_HANDLER->HANDLE_TOOLBAR
          FOR GCL_GRID.
  SET HANDLER GCL_EVENT_HANDLER->HANDLE_USER_COMMAND
          FOR GCL_GRID.
  SET HANDLER GCL_EVENT_HANDLER->HANDLE_DATA_CHANGED
          FOR GCL_GRID.
  SET HANDLER GCL_EVENT_HANDLER->HANDLE_DATA_CHANGED_FINISHED
          FOR GCL_GRID.
  SET HANDLER GCL_EVENT_HANDLER->HANDLE_DOUBLE_CLICK
          FOR GCL_GRID.
  SET HANDLER GCL_EVENT_HANDLER->HANDLE_AFTER_USER_COMMAND
          FOR GCL_GRID.
  SET HANDLER GCL_EVENT_HANDLER->HANDLE_BUTTON_CLICK
          FOR GCL_GRID.
  SET HANDLER GCL_EVENT_HANDLER->HANDLE_ONF4
          FOR GCL_GRID.

ENDFORM.                    " event_handler_register
*&---------------------------------------------------------------------*
*&      Form  build_sort_field
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM BUILD_SORT_FIELD .
* Sort 필드 설정
*  gs_sort-fieldname = 'WERKS'.
*  gs_sort-spos      = '1'.
*  gs_sort-up        = 'X'.
*  APPEND gs_sort   TO gt_sort.

*  gs_sort-fieldname = 'DISPO'.
*  gs_sort-spos      = '2'.
*  gs_sort-up        = 'X'.
*  APPEND gs_sort TO gt_sort.

*  gs_sort-fieldname = 'MATNR'.
*  gs_sort-spos      = '2'.
*  gs_sort-up        = 'X'.
*  APPEND gs_sort TO gt_sort.

ENDFORM.                    " build_sort_field
*&---------------------------------------------------------------------*
*&      Form  alv_grid_display
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ALV_GRID_DISPLAY .
  LCL_ALV_GRID=>F_ALV = '1'.

*& Display
  CALL METHOD GCL_GRID->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOCAT
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE
      I_SAVE               = 'A'   " 전체가능유형.
*                                       'U'   " 특정사용자전용.
*                                       'X'   " 광역 전용.
*                                       ' '   " 저장안함.
*     i_default            = 'X'   " 레이아웃 사전셋팅 허용.
*  LAYOUT   Standard   BCALV_GRID_09  참조.
*  is_variant 레이아웃선택/변경/저장/관리 enable
      IS_VARIANT           = ALV_VARIANT  " 선택 메뉴 display
    CHANGING
      IT_OUTTAB            = GT_EBAN[]
      IT_SORT              = GT_SORT
      IT_FIELDCATALOG      = GT_FIELDCAT[].
  CALL METHOD GCL_GRID->SET_ROW_RESIZE.

ENDFORM.                    " alv_grid_display
*&---------------------------------------------------------------------*
*&      Form  toolbar_pros
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_OBJECT  text
*      -->P_E_INTERACTIVE  text
*----------------------------------------------------------------------*
FORM TOOLBAR_PROS USING R_OBJECT TYPE REF TO CL_ALV_EVENT_TOOLBAR_SET
                        R_INTERACTIVE.

  DATA : LS_TOOLBAR  TYPE STB_BUTTON.

  CASE LCL_ALV_GRID=>F_ALV .
    WHEN '1'.
      MOVE   3                  TO  LS_TOOLBAR-BUTN_TYPE.
      APPEND LS_TOOLBAR         TO  R_OBJECT->MT_TOOLBAR.

      CLEAR LS_TOOLBAR.
      MOVE 'SELA'               TO  LS_TOOLBAR-FUNCTION.
      MOVE ICON_SELECT_ALL      TO  LS_TOOLBAR-ICON.
      MOVE '전체선택'           TO  LS_TOOLBAR-QUICKINFO.
*&      MOVE '전체선택'           TO  ls_toolbar-text.
      MOVE ' '                  TO  LS_TOOLBAR-DISABLED.
      APPEND LS_TOOLBAR         TO  R_OBJECT->MT_TOOLBAR.

*      MOVE   3                  TO  ls_toolbar-butn_type.
*      APPEND ls_toolbar         TO  r_object->mt_toolbar.

      CLEAR LS_TOOLBAR.
      MOVE 'DSEL'               TO  LS_TOOLBAR-FUNCTION.
      MOVE ICON_DESELECT_ALL    TO  LS_TOOLBAR-ICON.
      MOVE '전체해제'           TO  LS_TOOLBAR-QUICKINFO.
*&      MOVE '전체해제'           TO  ls_toolbar-text.
      MOVE ' '                  TO  LS_TOOLBAR-DISABLED.
      APPEND LS_TOOLBAR         TO  R_OBJECT->MT_TOOLBAR.

*      MOVE   3                  TO  ls_toolbar-butn_type.
*      APPEND ls_toolbar         TO  r_object->mt_toolbar.
*
*      CLEAR ls_toolbar.
*      MOVE 'CUOM'               TO  ls_toolbar-function.
*      MOVE icon_convert         TO  ls_toolbar-icon.
*      MOVE '단위변환'           TO  ls_toolbar-quickinfo.
*      MOVE '단위변환'           TO  ls_toolbar-text.
*      MOVE ' '                  TO  ls_toolbar-disabled.
*      APPEND ls_toolbar         TO  r_object->mt_toolbar.

    WHEN '2'.
*      MOVE   3                  TO  ls_toolbar-butn_type.
*      APPEND ls_toolbar         TO  r_object->mt_toolbar.
*
*      CLEAR ls_toolbar.
*      MOVE 'LEFT'               TO  ls_toolbar-function.
*      MOVE icon_arrow_left      TO  ls_toolbar-icon.
*      MOVE '앞화면'             TO  ls_toolbar-quickinfo.
*      MOVE '앞화면'             TO  ls_toolbar-text.
*      MOVE ' '                  TO  ls_toolbar-disabled.
*      APPEND ls_toolbar         TO  r_object->mt_toolbar.

    WHEN  OTHERS.
  ENDCASE.

ENDFORM.                    " toolbar_pros
*&---------------------------------------------------------------------*
*&      Form  user_command_pros
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_UCOMM  text
*----------------------------------------------------------------------*
FORM USER_COMMAND_PROS  USING    R_UCOMM.

  DATA: X_EXIST,
        CNT       TYPE I,
        X_CP(30),
        X_CP1(30).

  CLEAR: GT_EBAN.
  CASE R_UCOMM.
    WHEN 'SELA'.
      PERFORM MARKED_CHECK_BOX_100 USING 'X'.
      PERFORM SET_CELL_ATTRIBUTE .

    WHEN 'DSEL'.
      PERFORM MARKED_CHECK_BOX_100 USING ' '.
      PERFORM SET_CELL_ATTRIBUTE .

    WHEN 'CUOM'.
      PERFORM CONVERT_PO_UNIT.
      PERFORM SET_CELL_ATTRIBUTE .

    WHEN  OTHERS.
  ENDCASE.

ENDFORM.                    " user_command_pros
*&---------------------------------------------------------------------*
*&      Form  after_user_command
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_UCOMM  text
*----------------------------------------------------------------------*
FORM AFTER_USER_COMMAND  USING    E_UCOMM.

  CASE E_UCOMM.
    WHEN '&REFRESH'.
*      PERFORM select_proc.
*      PERFORM additional_info_proc.

    WHEN  OTHERS.
  ENDCASE.

  PERFORM REFRESH_GT_EBAN_DISPLAY.

ENDFORM.                    " after_user_command
*&---------------------------------------------------------------------*
*&      Form  data_changed
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ER_data_changed  text
*      -->P_E_ONF4  text
*----------------------------------------------------------------------*
FORM DATA_CHANGED USING RR_DATA_CHANGED
                               TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL
                        E_ONF4 TYPE CHAR1.

  DATA: LT_DELTA_CELLS   TYPE LVC_T_MODI,
        LS_DELTA_CELLS   TYPE LVC_S_MODI,
        LS_MODIFIED      TYPE CHAR01,
        LS_FRONTEND_ONLY TYPE CHAR01,
        FNAME(20).

  DATA : LS_MOD_CELLS TYPE LVC_S_MODI,
         LS_CELLS     TYPE LVC_S_MODI,
         LS_EBAN      LIKE GT_EBAN,
         L_LIFNR      LIKE LFA1-LIFNR.

  TYPES S_DATA LIKE GT_EBAN OCCURS 0 .
  FIELD-SYMBOLS : <DATA> TYPE S_DATA.

  LOOP AT RR_DATA_CHANGED->MT_GOOD_CELLS INTO LS_MOD_CELLS.

    CASE LS_MOD_CELLS-FIELDNAME.
      WHEN 'CHECK'.  "추가(SJM 25.03.18)
        READ TABLE GT_EBAN INDEX LS_MOD_CELLS-ROW_ID.
        PERFORM RESET_CHECK_LW USING LS_MOD_CELLS-VALUE.
*       PERFORM RESET_CHECK TABLES GT_EBAN
*                            USING GT_EBAN-ZGUID
*                                  LS_MOD_CELLS-VALUE.

      WHEN 'LIFNR'.  "업체
        CLEAR  LFA1.
        SELECT SINGLE NAME1 INTO GT_EBAN-NAME1
                 FROM LFA1
                WHERE LIFNR = LS_MOD_CELLS-VALUE.
        IF SY-SUBRC = 0.
          CALL METHOD RR_DATA_CHANGED->MODIFY_CELL
            EXPORTING
              I_ROW_ID    = LS_MOD_CELLS-ROW_ID
              I_FIELDNAME = 'NAME1'
              I_VALUE     = GT_EBAN-NAME1.

        ELSE.
          PERFORM DATA_INPUT_ERROR USING RR_DATA_CHANGED
                                     LS_MOD_CELLS
                                     'E'
                                     '존재하지 않는 업체코드입니다...'
                                     LS_MOD_CELLS-FIELDNAME.

        ENDIF.
      WHEN 'EPSTP'.    "I.C
        GT_EBAN-EPSTP = LS_MOD_CELLS-VALUE.
*& 구매문서의 품목범주(I.C) Conversion...
        CALL FUNCTION 'ME_ITEM_CATEGORY_INPUT'
          EXPORTING
            EPSTP = GT_EBAN-EPSTP
          IMPORTING
            PSTYP = GT_EBAN-PSTYP.

        MODIFY GT_EBAN INDEX LS_MOD_CELLS-ROW_ID
                TRANSPORTING PSTYP.

      WHEN 'MENGE_A'.  "외주지시 수량
        READ TABLE GT_EBAN INDEX LS_MOD_CELLS-ROW_ID.

        IF GT_EBAN-EBELN IS INITIAL AND
         ( GT_EBAN-MENGE_B < 1 OR
           GT_EBAN-MENGE_B < LS_MOD_CELLS-VALUE ).
          PERFORM DATA_INPUT_ERROR USING RR_DATA_CHANGED
                                         LS_MOD_CELLS
                                   'E'
                                   '구매요청 수량을 초과하였습니다...'
                                         LS_MOD_CELLS-FIELDNAME.

        ENDIF.

      WHEN  OTHERS.
    ENDCASE.
  ENDLOOP.

ENDFORM.                    " data_changed
*&---------------------------------------------------------------------*
*&      Form  data_changed_finished
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_MODIFIED  text
*      -->P_ET_GOOD_CELLS  text
*----------------------------------------------------------------------*
FORM DATA_CHANGED_FINISHED  USING    E_MODIFIED    TYPE CHAR01
                                     ET_GOOD_CELLS TYPE LVC_T_MODI.

  DATA: LS_MOD_CELLS TYPE LVC_S_MODI.
  DATA: LT_EBAN       LIKE GT_EBAN OCCURS 0 WITH HEADER LINE.

  IF E_MODIFIED = 'X'.
    CLEAR: GV_TITLE.

    PERFORM SET_CELL_ATTRIBUTE.
    GV_TITLE = '외주가공 및 부하상품 지시 리스트'.

*    CALL METHOD gcl_grid->set_gridtitle
*      EXPORTING
*        i_gridtitle = gv_title.

    L_SCROLL-ROW = 'X'.
    L_SCROLL-COL = 'X'.

    CALL METHOD GCL_GRID->REFRESH_TABLE_DISPLAY
      EXPORTING
        I_SOFT_REFRESH = 'X'
        IS_STABLE      = L_SCROLL.     "현재 그대로 입력한 refresh

    CALL METHOD GCL_GRID->SET_OPTIMIZE_ALL_COLS.

  ENDIF.

ENDFORM.                    " data_changed_finished
*&---------------------------------------------------------------------*
*&      Form  hotspot_click
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_ROW_ID  text
*      -->P_E_COLUMN_ID  text
*----------------------------------------------------------------------*
FORM HOTSPOT_CLICK  USING P_ROW_ID P_COLUMN_ID.

ENDFORM.                    " hotspot_click
*&---------------------------------------------------------------------*
*&      Form  double_click
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_ROW  text
*      -->P_E_COLUMN  text
*----------------------------------------------------------------------*
FORM DOUBLE_CLICK  USING    E_ROW
                            E_COLUMN.

  READ TABLE GT_EBAN INDEX E_ROW.
  CHECK SY-SUBRC  = 0.
  CASE E_COLUMN.
    WHEN 'MATNR'.
      PERFORM CALL_MATERIAL_MASTER USING GT_EBAN-MATNR
                                         GT_EBAN-WERKS.

    WHEN 'TXZ01'.

      SUBMIT ZPPR0061 WITH S_EBELN = GT_EBAN-EBELN
                   AND RETURN.

    WHEN 'LIFNR'.
      SET PARAMETER ID 'LIF' FIELD GT_EBAN-LIFNR.
      SET PARAMETER ID 'MAT' FIELD GT_EBAN-MATNR.
      SET PARAMETER ID 'EKO' FIELD GT_EBAN-EKORG.   "구매조직
      SET PARAMETER ID 'WRK' FIELD GT_EBAN-WERKS.
      SET PARAMETER ID 'ESO' FIELD '3'.      "외주가공

      CALL TRANSACTION 'ME13'  AND SKIP FIRST SCREEN.

    WHEN 'BANFN'.
      SET PARAMETER ID 'BBA' FIELD GT_EBAN-BSART.
      SET PARAMETER ID 'BAN' FIELD GT_EBAN-BANFN.

      CALL TRANSACTION 'ME53N' AND SKIP FIRST SCREEN.

    WHEN 'EBELN'.
      SET PARAMETER ID 'BSA' FIELD GT_EBAN-BSART.
      SET PARAMETER ID 'BES' FIELD GT_EBAN-EBELN.

      CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.

    WHEN 'LTEXT1'.

*      IF gt_eban-ltext1 IS INITIAL.
*        MESSAGE e001 WITH '조회할 구매오더 품목 텍스트가 없습니다'.
*      ELSE.
      PERFORM READ_PO_TEXT USING GT_EBAN-EBELN
                                 GT_EBAN-EBELP.

      CALL SCREEN 900 STARTING AT 10   2
                        ENDING AT 132  15.
*      ENDIF.
    WHEN  OTHERS.
  ENDCASE.

ENDFORM.                    " double_click
*&---------------------------------------------------------------------*
*&      Form  button_click
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ES_COL_ID  text
*      -->P_ES_ROW_NO  text
*----------------------------------------------------------------------*
FORM BUTTON_CLICK  USING    PS_COL_ID  TYPE  LVC_S_COL
                            PS_ROW_NO  TYPE  LVC_S_ROID.


ENDFORM.                    " button_click
*&---------------------------------------------------------------------*
*&      Form  toolbar_pros_l
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_OBJECT  text
*      -->P_E_INTERACTIVE  text
*----------------------------------------------------------------------*
FORM TOOLBAR_PROS_L USING R_OBJECT TYPE REF TO CL_ALV_EVENT_TOOLBAR_SET
                          R_INTERACTIVE.

  DATA : LS_TOOLBAR  TYPE STB_BUTTON.

  CHECK P_POBOX = 'X'.

  CASE LCL_ALV_GRID=>F_ALV .
    WHEN '1'.
      MOVE   3                  TO  LS_TOOLBAR-BUTN_TYPE.
      APPEND LS_TOOLBAR         TO  R_OBJECT->MT_TOOLBAR.

      CLEAR LS_TOOLBAR.
      MOVE 'COPY'               TO  LS_TOOLBAR-FUNCTION.
      MOVE ICON_COPY_OBJECT     TO  LS_TOOLBAR-ICON.
      MOVE '행 복사'            TO  LS_TOOLBAR-QUICKINFO.
      MOVE '행 복사'            TO  LS_TOOLBAR-TEXT.
      MOVE ' '                  TO  LS_TOOLBAR-DISABLED.
      APPEND LS_TOOLBAR         TO  R_OBJECT->MT_TOOLBAR.

*      MOVE   3                  TO  ls_toolbar-butn_type.
*      APPEND ls_toolbar         TO  r_object->mt_toolbar.

      CLEAR LS_TOOLBAR.
      MOVE 'DELR'               TO  LS_TOOLBAR-FUNCTION.
      MOVE ICON_DELETE_ROW      TO  LS_TOOLBAR-ICON.
      MOVE '행 삭제'            TO  LS_TOOLBAR-QUICKINFO.
      MOVE '행 삭제'            TO  LS_TOOLBAR-TEXT.
      MOVE ' '                  TO  LS_TOOLBAR-DISABLED.
      APPEND LS_TOOLBAR         TO  R_OBJECT->MT_TOOLBAR.

    WHEN '2'.
*      MOVE   3                  TO  ls_toolbar-butn_type.
*      APPEND ls_toolbar         TO  r_object->mt_toolbar.
*
*      CLEAR ls_toolbar.
*      MOVE 'LEFT'               TO  ls_toolbar-function.
*      MOVE icon_arrow_left      TO  ls_toolbar-icon.
*      MOVE '앞화면'             TO  ls_toolbar-quickinfo.
*      MOVE '앞화면'             TO  ls_toolbar-text.
*      MOVE ' '                  TO  ls_toolbar-disabled.
*      APPEND ls_toolbar         TO  r_object->mt_toolbar.

    WHEN  OTHERS.
  ENDCASE.

ENDFORM.                    " toolbar_pros_l
*&---------------------------------------------------------------------*
*&      Form  user_command_pros_l
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_UCOMM  text
*----------------------------------------------------------------------*
FORM USER_COMMAND_PROS_L  USING    R_UCOMM.

  DATA: X_EXIST,
        CNT       TYPE I,
        X_CP(30),
        X_CP1(30).

  CHECK P_POBOX = 'X'.

  CASE R_UCOMM.
    WHEN 'COPY'.
      PERFORM COPY_MDSB_L.

    WHEN 'DELR'.
      PERFORM DELETE_MDSB_L.

    WHEN  OTHERS.
  ENDCASE.

*& 화면 갱신...
  PERFORM SET_CELL_ATTRIBUTE_L.
  PERFORM SET_CELL_ATTRIBUTE_W2.

  L_SCROLL-ROW = 'X'.
  L_SCROLL-COL = 'X'.

  CALL METHOD GCL_GRID_L->REFRESH_TABLE_DISPLAY
    EXPORTING
      I_SOFT_REFRESH = 'X'
      IS_STABLE      = L_SCROLL.     "현재 그대로 입력한 refresh

  CALL METHOD GCL_GRID_L->SET_OPTIMIZE_ALL_COLS.

  CALL METHOD GCL_GRID_W2->REFRESH_TABLE_DISPLAY
    EXPORTING
      I_SOFT_REFRESH = 'X'
      IS_STABLE      = L_SCROLL.     "현재 그대로 입력한 refresh

  CALL METHOD GCL_GRID_W2->SET_OPTIMIZE_ALL_COLS.


ENDFORM.                    " user_command_pros_l
*&---------------------------------------------------------------------*
*&      Form  after_user_command_l
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_UCOMM  text
*----------------------------------------------------------------------*
FORM AFTER_USER_COMMAND_L  USING    E_UCOMM.


ENDFORM.                    " after_user_command_l
*&---------------------------------------------------------------------*
*&      Form  data_changed_l
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ER_data_changed  text
*      -->P_E_ONF4  text
*----------------------------------------------------------------------*
FORM DATA_CHANGED_L USING RR_DATA_CHANGED
                               TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL
                        E_ONF4 TYPE CHAR1.

  DATA: LT_DELTA_CELLS   TYPE LVC_T_MODI,
        LS_DELTA_CELLS   TYPE LVC_S_MODI,
        LS_MODIFIED      TYPE CHAR01,
        LS_FRONTEND_ONLY TYPE CHAR01,
        FNAME(20).

  DATA : LS_MOD_CELLS TYPE LVC_S_MODI,
         LS_CELLS     TYPE LVC_S_MODI,
         LS_MDSB_L    LIKE GT_MDSB_L,
         LV_TAGNR     LIKE ZPPT0011-TAGNR.

  TYPES S_DATA LIKE GT_EBAN OCCURS 0 .
  FIELD-SYMBOLS : <DATA> TYPE S_DATA.

  LOOP AT RR_DATA_CHANGED->MT_GOOD_CELLS INTO LS_MOD_CELLS.
    READ TABLE GT_MDSB_L INDEX LS_MOD_CELLS-ROW_ID.
    CASE LS_MOD_CELLS-FIELDNAME.
      WHEN 'CHECK'.  "추가(SJM 25.03.18)
        PERFORM RESET_CHECK TABLES GT_MDSB_L
                             USING GT_MDSB_L-ZGUID
                                   LS_MOD_CELLS-VALUE.

      WHEN 'CHARG'.
*--> [CHM2601-00247] 배치 수기 입력 시 부가정보 끌고오도록 함
**** 원본 BK - START
*        CLEAR  MARA.
*        SELECT SINGLE DPCBT INTO MARA-DPCBT
*                 FROM MARA
*                WHERE MATNR = GT_MDSB_L-MATNR_C.
*        IF ( NOT MARA-DPCBT         IS INITIAL ) AND
*           ( NOT LS_MOD_CELLS-VALUE IS INITIAL ) AND
*           ( GT_MDSB_L-TAGNR    IS INITIAL ).
*          PERFORM GET_TAG_NUMBER USING LS_MOD_CELLS-VALUE
*                              CHANGING GT_MDSB_L-TAGNR
*                                       GT_MDSB_L-BDMNG.
*
*          IF NOT GT_MDSB_L-TAGNR IS INITIAL.
*            CALL METHOD RR_DATA_CHANGED->MODIFY_CELL
*              EXPORTING
*                I_ROW_ID    = LS_MOD_CELLS-ROW_ID
*                I_FIELDNAME = 'TAGNR'
*                I_VALUE     = GT_MDSB_L-TAGNR.
*
*            CALL METHOD RR_DATA_CHANGED->MODIFY_CELL
*              EXPORTING
*                I_ROW_ID    = LS_MOD_CELLS-ROW_ID
*                I_FIELDNAME = 'BDMNG'
*                I_VALUE     = GT_MDSB_L-BDMNG.
*
*          ENDIF.
*        ENDIF.
**** 원본 BK - END

        IF ( NOT LS_MOD_CELLS-VALUE IS INITIAL ).
          PERFORM GET_TAG_NUMBER_2  USING LS_MOD_CELLS-VALUE
                                          GT_MDSB_L-WERKS
                                          GT_MDSB_L-MATNR_C
                                    CHANGING  GT_MDSB_L-TAGNR
                                              GT_MDSB_L-BDMNG
                                              GT_MDSB_L-LGORT.

          IF NOT GT_MDSB_L-TAGNR IS INITIAL.
            CALL METHOD RR_DATA_CHANGED->MODIFY_CELL
              EXPORTING
                I_ROW_ID    = LS_MOD_CELLS-ROW_ID
                I_FIELDNAME = 'TAGNR'
                I_VALUE     = GT_MDSB_L-TAGNR.

            CALL METHOD RR_DATA_CHANGED->MODIFY_CELL
              EXPORTING
                I_ROW_ID    = LS_MOD_CELLS-ROW_ID
                I_FIELDNAME = 'BDMNG'
                I_VALUE     = GT_MDSB_L-BDMNG.

            CALL METHOD RR_DATA_CHANGED->MODIFY_CELL
              EXPORTING
                I_ROW_ID    = LS_MOD_CELLS-ROW_ID
                I_FIELDNAME = 'LGORT'
                I_VALUE     = GT_MDSB_L-LGORT.
          ENDIF.
        ELSE.
          CALL METHOD RR_DATA_CHANGED->MODIFY_CELL
            EXPORTING
              I_ROW_ID    = LS_MOD_CELLS-ROW_ID
              I_FIELDNAME = 'TAGNR'
              I_VALUE     = SPACE.

          CALL METHOD RR_DATA_CHANGED->MODIFY_CELL
            EXPORTING
              I_ROW_ID    = LS_MOD_CELLS-ROW_ID
              I_FIELDNAME = 'BDMNG'
              I_VALUE     = SPACE.

          CALL METHOD RR_DATA_CHANGED->MODIFY_CELL
            EXPORTING
              I_ROW_ID    = LS_MOD_CELLS-ROW_ID
              I_FIELDNAME = 'LGORT'
              I_VALUE     = SPACE.
        ENDIF.

*<-- [CHM2601-00247] 배치 수기 입력 시 부가정보 끌고오도록 함
      WHEN  OTHERS.
    ENDCASE.
  ENDLOOP.

ENDFORM.                    " data_changed_l
*&---------------------------------------------------------------------*
*&      Form  data_changed_finished_l
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_MODIFIED  text
*      -->P_ET_GOOD_CELLS  text
*----------------------------------------------------------------------*
FORM DATA_CHANGED_FINISHED_L  USING   E_MODIFIED   TYPE CHAR01
                                     ET_GOOD_CELLS TYPE LVC_T_MODI.

  DATA: LS_MOD_CELLS TYPE LVC_S_MODI.
  DATA: LT_MDSB_L    LIKE GT_MDSB_L OCCURS 0 WITH HEADER LINE.

  IF E_MODIFIED = 'X'.
    CLEAR: GV_TITLE_L.

*&    PERFORM set_cell_attribute.
    GV_TITLE_L = '배치 관리 사급자재'.  "변경(SJM 25.03.31) '길이관리 사급자재'.

    CALL METHOD GCL_GRID_L->SET_GRIDTITLE
      EXPORTING
        I_GRIDTITLE = GV_TITLE_L.

    L_SCROLL-ROW = 'X'.
    L_SCROLL-COL = 'X'.

    CALL METHOD GCL_GRID_L->REFRESH_TABLE_DISPLAY
      EXPORTING
        I_SOFT_REFRESH = 'X'
        IS_STABLE      = L_SCROLL.     "현재 그대로 입력한 refresh

    CALL METHOD GCL_GRID_L->SET_OPTIMIZE_ALL_COLS.

  ENDIF.

ENDFORM.                    " data_changed_finished_l
*&---------------------------------------------------------------------*
*&      Form  hotspot_click_l
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_ROW_ID  text
*      -->P_E_COLUMN_ID  text
*----------------------------------------------------------------------*
FORM HOTSPOT_CLICK_L  USING P_ROW_ID P_COLUMN_ID.

ENDFORM.                    " hotspot_click_l
*&---------------------------------------------------------------------*
*&      Form  double_click_l
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_ROW  text
*      -->P_E_COLUMN  text
*----------------------------------------------------------------------*
FORM DOUBLE_CLICK_L  USING    E_ROW
                            E_COLUMN.

  READ TABLE GT_MDSB_L INDEX E_ROW.
  CHECK SY-SUBRC  = 0.
  CASE E_COLUMN.
    WHEN 'MATNR'.
      PERFORM CALL_MATERIAL_MASTER USING GT_MDSB_L-MATNR
                                         GT_MDSB_L-WERKS.

    WHEN 'MATNR_C'.
      PERFORM CALL_MATERIAL_MASTER USING GT_MDSB_L-MATNR_C
                                         GT_MDSB_L-WERKS.

    WHEN 'LGORT'.  "재고조회
      SET PARAMETER ID 'MAT' FIELD GT_MDSB_L-MATNR_C.
      SET PARAMETER ID 'WRK' FIELD GT_MDSB_L-WERKS.
      SET PARAMETER ID 'LAG' FIELD ''.
      CALL TRANSACTION 'MMBE'  AND SKIP FIRST SCREEN.

    WHEN 'EBELN'.
      SET PARAMETER ID 'BSA' FIELD GT_MDSB_L-BSART.
      SET PARAMETER ID 'BES' FIELD GT_MDSB_L-EBELN.

      CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.

    WHEN  OTHERS.
  ENDCASE.

ENDFORM.                    " double_click_l
*&---------------------------------------------------------------------*
*&      Form  button_click_l
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ES_COL_ID  text
*      -->P_ES_ROW_NO  text
*----------------------------------------------------------------------*
FORM BUTTON_CLICK_L USING   PS_COL_ID  TYPE  LVC_S_COL
                            PS_ROW_NO  TYPE  LVC_S_ROID.


ENDFORM.                    " button_click_l
*&---------------------------------------------------------------------*
*&      Form  onf4_proc_l
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_FIELDNAME  text
*      -->P_E_FIELDVALUE  text
*      -->P_ES_ROW_NO  text
*      -->P_ER_EVENT_DATA  text
*      -->P_ET_BAD_CELLS  text
*      -->P_E_DISPLAY  text
*----------------------------------------------------------------------*
FORM ONF4_PROC_L USING PV_FIELDNAME  TYPE LVC_FNAME
                       PV_FIELDVALUE TYPE LVC_VALUE
                       PS_ROW_NO     TYPE LVC_S_ROID
                       PR_EVENT_DATA TYPE REF TO CL_ALV_EVENT_DATA
                       PT_BAD_CELLS  TYPE LVC_T_MODI
                       PV_DISPLAY    TYPE CHAR01.

  FIELD-SYMBOLS <MODI>                  TYPE LVC_T_MODI.
  DATA: LS_MODI  TYPE LVC_S_MODI,
        LV_VALUE TYPE STRING.

  READ TABLE GT_MDSB_L INDEX PS_ROW_NO-ROW_ID.
  CHECK SY-SUBRC = 0.

  CASE PV_FIELDNAME.
    WHEN 'CHARG'.
      ASSIGN PR_EVENT_DATA->M_DATA->* TO <MODI>.
      LS_MODI-ROW_ID    = PS_ROW_NO-ROW_ID.
      LS_MODI-FIELDNAME = 'TAGNR'.
      LS_MODI-VALUE     = ''.
      APPEND LS_MODI   TO <MODI>.

      LS_MODI-ROW_ID    = PS_ROW_NO-ROW_ID.
      LS_MODI-FIELDNAME = 'BDMNG'.
      LS_MODI-VALUE     = ''.
      APPEND LS_MODI   TO <MODI>.


      PERFORM SEARCH_HELP_FOR_CHARG_L USING GT_MDSB_L-WERKS
                                            GT_MDSB_L-MATNR_C
                                   CHANGING GT_MDSB_L-CHARG
                                            GT_MDSB_L-LGORT.

      IF NOT GT_MDSB_L-CHARG IS INITIAL AND
             PV_DISPLAY      IS INITIAL.

        ASSIGN PR_EVENT_DATA->M_DATA->* TO <MODI>.
        LS_MODI-ROW_ID    = PS_ROW_NO-ROW_ID.
        LS_MODI-FIELDNAME = PV_FIELDNAME.
        LS_MODI-VALUE     = GT_MDSB_L-CHARG.
        APPEND LS_MODI   TO <MODI>.

        LS_MODI-ROW_ID    = PS_ROW_NO-ROW_ID.
        LS_MODI-FIELDNAME = 'LGORT'.
        LS_MODI-VALUE     = GT_MDSB_L-LGORT.
        APPEND LS_MODI   TO <MODI>.

        CLEAR  ZPPT0001.
        SELECT SINGLE TAGNR REMAIN
                 INTO (GT_MDSB_L-TAGNR, GT_MDSB_L-BDMNG)
                 FROM ZPPT0001
                WHERE WERKS = GT_MDSB_L-WERKS
                  AND MATNR = GT_MDSB_L-MATNR_C
                  AND CHARG = GT_MDSB_L-CHARG.
        IF SY-SUBRC = 0.
          LS_MODI-ROW_ID    = PS_ROW_NO-ROW_ID.
          LS_MODI-FIELDNAME = 'TAGNR'.
          LS_MODI-VALUE     = GT_MDSB_L-TAGNR.
          APPEND LS_MODI   TO <MODI>.

          LS_MODI-ROW_ID    = PS_ROW_NO-ROW_ID.
          LS_MODI-FIELDNAME = 'BDMNG'.
          LS_MODI-VALUE     = GT_MDSB_L-BDMNG.
          APPEND LS_MODI   TO <MODI>.

        ENDIF.
      ENDIF.

*& 2010.01.26 CSR : C20100126_00014
*& 꼬리표검색 기능 추가(구사종)
    WHEN 'TAGNR'.
      PERFORM SEARCH_HELP_FOR_TAGNR_L USING GT_MDSB_L-WERKS
                                            GT_MDSB_L-MATNR_C
                                   CHANGING GT_MDSB_L-CHARG
                                            GT_MDSB_L-LGORT
                                            GT_MDSB_L-TAGNR
                                            GT_MDSB_L-BDMNG.

      IF NOT GT_MDSB_L-CHARG IS INITIAL AND
             GT_MDSB_L-TAGNR IS NOT INITIAL AND
             PV_DISPLAY      IS INITIAL .

        ASSIGN PR_EVENT_DATA->M_DATA->* TO <MODI>.
        LS_MODI-ROW_ID    = PS_ROW_NO-ROW_ID.
        LS_MODI-FIELDNAME = 'CHARG'.
        LS_MODI-VALUE     = GT_MDSB_L-CHARG.
        APPEND LS_MODI   TO <MODI>.

        LS_MODI-ROW_ID    = PS_ROW_NO-ROW_ID.
        LS_MODI-FIELDNAME = 'LGORT'.
        LS_MODI-VALUE     = GT_MDSB_L-LGORT.
        APPEND LS_MODI   TO <MODI>.

        LS_MODI-ROW_ID    = PS_ROW_NO-ROW_ID.
        LS_MODI-FIELDNAME = 'TAGNR'.
        LS_MODI-VALUE     = GT_MDSB_L-TAGNR.
        APPEND LS_MODI   TO <MODI>.

        LS_MODI-ROW_ID    = PS_ROW_NO-ROW_ID.
        LS_MODI-FIELDNAME = 'BDMNG'.
        LS_MODI-VALUE     = GT_MDSB_L-BDMNG.
        APPEND LS_MODI   TO <MODI>.
      ENDIF.

    WHEN  OTHERS.
  ENDCASE.

  PR_EVENT_DATA->M_EVENT_HANDLED = 'X'.

ENDFORM.                                                " onf4_proc_l

*&---------------------------------------------------------------------*
*&      Form  toolbar_pros_w1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_OBJECT  text
*      -->P_E_INTERACTIVE  text
*----------------------------------------------------------------------*
FORM TOOLBAR_PROS_W1 USING R_OBJECT
                      TYPE REF TO CL_ALV_EVENT_TOOLBAR_SET
                           R_INTERACTIVE.

  DATA : LS_TOOLBAR  TYPE STB_BUTTON.

ENDFORM.                    " toolbar_pros_w1
*&---------------------------------------------------------------------*
*&      Form  user_command_pros_w1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_UCOMM  text
*----------------------------------------------------------------------*
FORM USER_COMMAND_PROS_W1  USING    R_UCOMM.

  DATA: X_EXIST,
        CNT       TYPE I,
        X_CP(30),
        X_CP1(30).

  CLEAR: GT_EBAN.


ENDFORM.                    " user_command_pros_w1
*&---------------------------------------------------------------------*
*&      Form  after_user_command_w1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_UCOMM  text
*----------------------------------------------------------------------*
FORM AFTER_USER_COMMAND_W1  USING    E_UCOMM.


ENDFORM.                    " after_user_command_w1
*&---------------------------------------------------------------------*
*&      Form  data_changed_w1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ER_data_changed  text
*      -->P_E_ONF4  text
*----------------------------------------------------------------------*
FORM DATA_CHANGED_W1 USING RR_DATA_CHANGED TYPE REF TO
                           CL_ALV_CHANGED_DATA_PROTOCOL
                           E_ONF4 TYPE CHAR1.

  DATA: LT_DELTA_CELLS   TYPE LVC_T_MODI,
        LS_DELTA_CELLS   TYPE LVC_S_MODI,
        LS_MODIFIED      TYPE CHAR01,
        LS_FRONTEND_ONLY TYPE CHAR01,
        FNAME(20).

  DATA : LS_MOD_CELLS TYPE LVC_S_MODI,
         LS_CELLS     TYPE LVC_S_MODI,
         LS_MDSB_W1   LIKE GT_MDSB_W1.

ENDFORM.                    " data_changed_w1
*&---------------------------------------------------------------------*
*&      Form  data_changed_finished_w1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_MODIFIED  text
*      -->P_ET_GOOD_CELLS  text
*----------------------------------------------------------------------*
FORM DATA_CHANGED_FINISHED_W1 USING  E_MODIFIED    TYPE CHAR01
                                     ET_GOOD_CELLS TYPE LVC_T_MODI.

  DATA: LS_MOD_CELLS TYPE LVC_S_MODI.
  DATA: LT_MDSB_W1   LIKE GT_MDSB_W1 OCCURS 0 WITH HEADER LINE.


ENDFORM.                    " data_changed_finished_w1
*&---------------------------------------------------------------------*
*&      Form  hotspot_click_w1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_ROW_ID  text
*      -->P_E_COLUMN_ID  text
*----------------------------------------------------------------------*
FORM HOTSPOT_CLICK_W1  USING P_ROW_ID P_COLUMN_ID.

ENDFORM.                    " hotspot_click_w1
*&---------------------------------------------------------------------*
*&      Form  double_click_w1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_ROW  text
*      -->P_E_COLUMN  text
*----------------------------------------------------------------------*
FORM DOUBLE_CLICK_W1  USING    E_ROW
                            E_COLUMN.

  READ TABLE GT_MDSB_W1 INDEX E_ROW.
  CHECK SY-SUBRC  = 0.
  CASE E_COLUMN.
    WHEN 'MATNR'.
      PERFORM CALL_MATERIAL_MASTER USING GT_MDSB_W1-MATNR
                                         GT_MDSB_W1-WERKS.

    WHEN 'MATNR_C'.
      PERFORM CALL_MATERIAL_MASTER USING GT_MDSB_W1-MATNR_C
                                         GT_MDSB_W1-WERKS.

    WHEN 'LGORT'.  "재고조회
      SET PARAMETER ID 'MAT' FIELD GT_MDSB_W1-MATNR_C.
      SET PARAMETER ID 'WRK' FIELD GT_MDSB_W1-WERKS.
      SET PARAMETER ID 'LAG' FIELD ''.
      CALL TRANSACTION 'MMBE'  AND SKIP FIRST SCREEN.

    WHEN 'EBELN'.
      SET PARAMETER ID 'BSA' FIELD GT_MDSB_W1-BSART.
      SET PARAMETER ID 'BES' FIELD GT_MDSB_W1-EBELN.

      CALL TRANSACTION 'ME23N' AND SKIP FIRST SCREEN.

    WHEN  OTHERS.
  ENDCASE.

ENDFORM.                    " double_click_w1
*&---------------------------------------------------------------------*
*&      Form  button_click_w1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ES_COL_ID  text
*      -->P_ES_ROW_NO  text
*----------------------------------------------------------------------*
FORM BUTTON_CLICK_W1 USING  PS_COL_ID  TYPE  LVC_S_COL
                            PS_ROW_NO  TYPE  LVC_S_ROID.


ENDFORM.                    " button_click_w1
*&---------------------------------------------------------------------*
*&      Form  toolbar_pros_w2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_OBJECT  text
*      -->P_E_INTERACTIVE  text
*----------------------------------------------------------------------*
FORM TOOLBAR_PROS_W2 USING R_OBJECT
                      TYPE REF TO CL_ALV_EVENT_TOOLBAR_SET
                           R_INTERACTIVE.

  DATA : LS_TOOLBAR  TYPE STB_BUTTON.

ENDFORM.                    " toolbar_pros_w2
*&---------------------------------------------------------------------*
*&      Form  user_command_pros_w2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_UCOMM  text
*----------------------------------------------------------------------*
FORM USER_COMMAND_PROS_W2  USING    R_UCOMM.

  DATA: X_EXIST,
        CNT       TYPE I,
        X_CP(30),
        X_CP1(30).

  CLEAR: GT_EBAN.


ENDFORM.                    " user_command_pros_w2
*&---------------------------------------------------------------------*
*&      Form  after_user_command_w2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_UCOMM  text
*----------------------------------------------------------------------*
FORM AFTER_USER_COMMAND_W2  USING    E_UCOMM.


ENDFORM.                    " after_user_command_w2
*&---------------------------------------------------------------------*
*&      Form  data_changed_w2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ER_data_changed  text
*      -->P_E_ONF4  text
*----------------------------------------------------------------------*
FORM DATA_CHANGED_W2 USING RR_DATA_CHANGED
                      TYPE REF TO CL_ALV_CHANGED_DATA_PROTOCOL
                           E_ONF4 TYPE CHAR1.

  DATA: LT_DELTA_CELLS   TYPE LVC_T_MODI,
        LS_DELTA_CELLS   TYPE LVC_S_MODI,
        LS_MODIFIED      TYPE CHAR01,
        LS_FRONTEND_ONLY TYPE CHAR01,
        FNAME(20).

  DATA: LS_MOD_CELLS TYPE LVC_S_MODI,
        LS_CELLS     TYPE LVC_S_MODI,
        LS_MDSB_W2   LIKE GT_MDSB_W2,
        LV_TAGNR     LIKE ZPPT0011-TAGNR.

  TYPES S_DATA LIKE GT_EBAN OCCURS 0 .
  FIELD-SYMBOLS : <DATA> TYPE S_DATA.

  LOOP AT RR_DATA_CHANGED->MT_GOOD_CELLS INTO LS_MOD_CELLS.
    READ TABLE GT_MDSB_W2 INDEX LS_MOD_CELLS-ROW_ID.

    CASE LS_MOD_CELLS-FIELDNAME.
      WHEN 'CHECK'.  "추가(SJM 25.03.18)
        PERFORM RESET_CHECK TABLES GT_MDSB_W2
                             USING GT_MDSB_W2-ZGUID
                                   LS_MOD_CELLS-VALUE.
      WHEN 'CHARG'.
      WHEN 'ENMNG'.
*& 출고자재 총량이 업체 불출량보다 큰경우, 신규라인 추가...
*       READ TABLE GT_MDSB_W2 INDEX LS_MOD_CELLS-ROW_ID.
        IF GT_MDSB_W2-BDMNG_A > LS_MOD_CELLS-VALUE.
          LS_MDSB_W2 = GT_MDSB_W2.
          LS_MDSB_W2-BDMNG_A = GT_MDSB_W2-BDMNG_A
                             - LS_MOD_CELLS-VALUE.
          CLEAR: LS_MDSB_W2-LOTNO, LS_MDSB_W2-CHARG,
                 LS_MDSB_W2-TAGNR, LS_MDSB_W2-LGORT.
          APPEND LS_MDSB_W2     TO GT_MDSB_W2.
        ENDIF.

      WHEN  OTHERS.
    ENDCASE.
  ENDLOOP.

ENDFORM.                    " data_changed_w2
*&---------------------------------------------------------------------*
*&      Form  data_changed_finished_w2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_MODIFIED  text
*      -->P_ET_GOOD_CELLS  text
*----------------------------------------------------------------------*
FORM DATA_CHANGED_FINISHED_W2  USING  E_MODIFIED    TYPE CHAR01
                                     ET_GOOD_CELLS TYPE LVC_T_MODI.

  DATA: LS_MOD_CELLS TYPE LVC_S_MODI.
  DATA: LT_MDSB_W2   LIKE GT_MDSB_W2 OCCURS 0 WITH HEADER LINE.

  IF E_MODIFIED = 'X'.
*&    CLEAR: gv_title_w.

    PERFORM SET_CELL_ATTRIBUTE.
*&    gv_title_l = '길이관리 사급자재'.

*&    CALL METHOD gcl_grid_w2->set_gridtitle
*&      EXPORTING
*&        i_gridtitle = gv_title_w.

    L_SCROLL-ROW = 'X'.
    L_SCROLL-COL = 'X'.

    CALL METHOD GCL_GRID_W2->REFRESH_TABLE_DISPLAY
      EXPORTING
        I_SOFT_REFRESH = 'X'
        IS_STABLE      = L_SCROLL.     "현재 그대로 입력한 refresh

    CALL METHOD GCL_GRID_W2->SET_OPTIMIZE_ALL_COLS.

  ENDIF.

ENDFORM.                    " data_changed_finished_w2
*&---------------------------------------------------------------------*
*&      Form  hotspot_click_w2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_ROW_ID  text
*      -->P_E_COLUMN_ID  text
*----------------------------------------------------------------------*
FORM HOTSPOT_CLICK_W2  USING P_ROW_ID P_COLUMN_ID.

ENDFORM.                    " hotspot_click_w2
*&---------------------------------------------------------------------*
*&      Form  double_click_w2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_ROW  text
*      -->P_E_COLUMN  text
*----------------------------------------------------------------------*
FORM DOUBLE_CLICK_W2  USING    E_ROW
                            E_COLUMN.

  READ TABLE GT_MDSB_W2 INDEX E_ROW.
  CHECK SY-SUBRC  = 0.
  CASE E_COLUMN.
    WHEN 'MATNR_C'.
      PERFORM CALL_MATERIAL_MASTER USING GT_MDSB_W2-MATNR_C
                                         GT_MDSB_W2-WERKS.

    WHEN 'LABST'.  "재고조회
      SET PARAMETER ID 'MAT' FIELD GT_MDSB_W2-MATNR_C.
      SET PARAMETER ID 'WRK' FIELD GT_MDSB_W2-WERKS.
      SET PARAMETER ID 'LAG' FIELD ''.

      CALL TRANSACTION 'MMBE'  AND SKIP FIRST SCREEN.

    WHEN 'LBLAB'.  "업체재고
      REFRESH GT_SELTAB.     CLEAR GT_SELTAB.

      MOVE: 'LIFNR'             TO GS_SELTAB_WA-SELNAME,
            'P'                 TO GS_SELTAB_WA-KIND,      "PARAMETER
             GT_MDSB_W2-LIFNR   TO GS_SELTAB_WA-LOW.
      COLLECT GS_SELTAB_WA    INTO GT_SELTAB.

      MOVE: 'MATNR'             TO GS_SELTAB_WA-SELNAME,
            'P'                 TO GS_SELTAB_WA-KIND,      "PARAMETER
             GT_MDSB_W2-MATNR_C TO GS_SELTAB_WA-LOW.
      COLLECT GS_SELTAB_WA    INTO GT_SELTAB.

      MOVE: 'WERKS'             TO GS_SELTAB_WA-SELNAME,
            'P'                 TO GS_SELTAB_WA-KIND,      "PARAMETER
             GT_MDSB_W2-WERKS   TO GS_SELTAB_WA-LOW.
      COLLECT GS_SELTAB_WA    INTO GT_SELTAB.

      SUBMIT RM07MLBB WITH SELECTION-TABLE GT_SELTAB
*&                       VIA SELECTION-SCREEN
                       AND RETURN.

    WHEN  OTHERS.
  ENDCASE.

ENDFORM.                    " double_click_w2
*&---------------------------------------------------------------------*
*&      Form  button_click_w2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_ES_COL_ID  text
*      -->P_ES_ROW_NO  text
*----------------------------------------------------------------------*
FORM BUTTON_CLICK_W2 USING  PS_COL_ID  TYPE  LVC_S_COL
                            PS_ROW_NO  TYPE  LVC_S_ROID.


ENDFORM.                    " button_click_w2
*&---------------------------------------------------------------------*
*&      Form  onf4_proc_w2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_FIELDNAME  text
*      -->P_E_FIELDVALUE  text
*      -->P_ES_ROW_NO  text
*      -->P_ER_EVENT_DATA  text
*      -->P_ET_BAD_CELLS  text
*      -->P_E_DISPLAY  text
*----------------------------------------------------------------------*
FORM ONF4_PROC_W2 USING PV_FIELDNAME  TYPE LVC_FNAME
                        PV_FIELDVALUE TYPE LVC_VALUE
                        PS_ROW_NO     TYPE LVC_S_ROID
                        PR_EVENT_DATA TYPE REF TO CL_ALV_EVENT_DATA
                        PT_BAD_CELLS  TYPE LVC_T_MODI
                        PV_DISPLAY    TYPE CHAR01.

  FIELD-SYMBOLS <MODI>                TYPE LVC_T_MODI.
  DATA: LS_MODI  TYPE LVC_S_MODI,
        LV_VALUE TYPE STRING.

  READ TABLE GT_MDSB_W2 INDEX PS_ROW_NO-ROW_ID.
  CHECK SY-SUBRC = 0.

  CASE PV_FIELDNAME.
    WHEN 'CHARG'.
      PERFORM SEARCH_HELP_FOR_CHARG_W2 USING GT_MDSB_W2-WERKS
                                             GT_MDSB_W2-MATNR_C
                                    CHANGING GT_MDSB_W2-CHARG
                                             GT_MDSB_W2-LGORT
                                             GT_MDSB_W2-ENMNG.

      IF NOT GT_MDSB_W2-CHARG IS INITIAL AND
             PV_DISPLAY       IS INITIAL.

        ASSIGN PR_EVENT_DATA->M_DATA->* TO <MODI>.
        LS_MODI-ROW_ID    = PS_ROW_NO-ROW_ID.
        LS_MODI-FIELDNAME = PV_FIELDNAME.
        LS_MODI-VALUE     = GT_MDSB_W2-CHARG.
        APPEND LS_MODI   TO <MODI>.

        LS_MODI-ROW_ID    = PS_ROW_NO-ROW_ID.
        LS_MODI-FIELDNAME = 'LGORT'.
        LS_MODI-VALUE     = GT_MDSB_W2-LGORT.
        APPEND LS_MODI   TO <MODI>.

        LS_MODI-ROW_ID    = PS_ROW_NO-ROW_ID.
        LS_MODI-FIELDNAME = 'ENMNG'.
        LS_MODI-VALUE     = GT_MDSB_W2-ENMNG.
        APPEND LS_MODI   TO <MODI>.

      ENDIF.

    WHEN 'TAGNR'.
      PERFORM SEARCH_HELP_FOR_TAGNR USING GT_MDSB_W2-WERKS
                                          GT_MDSB_W2-MATNR_C
                                 CHANGING GT_MDSB_W2-TAGNR
                                          GT_MDSB_W2-CHARG
                                          GT_MDSB_W2-LGORT
                                          GT_MDSB_W2-ENMNG.

      IF NOT GT_MDSB_W2-TAGNR IS INITIAL AND
             PV_DISPLAY       IS INITIAL.

        ASSIGN PR_EVENT_DATA->M_DATA->* TO <MODI>.

        LS_MODI-ROW_ID    = PS_ROW_NO-ROW_ID.
        LS_MODI-FIELDNAME = PV_FIELDNAME.
        LS_MODI-VALUE     = GT_MDSB_W2-TAGNR.
        APPEND LS_MODI   TO <MODI>.

        LS_MODI-ROW_ID    = PS_ROW_NO-ROW_ID.
        LS_MODI-FIELDNAME = 'CHARG'.
        LS_MODI-VALUE     = GT_MDSB_W2-CHARG.
        APPEND LS_MODI   TO <MODI>.

        LS_MODI-ROW_ID    = PS_ROW_NO-ROW_ID.
        LS_MODI-FIELDNAME = 'LGORT'.
        LS_MODI-VALUE     = GT_MDSB_W2-LGORT.
        APPEND LS_MODI   TO <MODI>.

        LS_MODI-ROW_ID    = PS_ROW_NO-ROW_ID.
        LS_MODI-FIELDNAME = 'ENMNG'.
        LS_MODI-VALUE     = GT_MDSB_W2-ENMNG.
        APPEND LS_MODI   TO <MODI>.

      ENDIF.

    WHEN  OTHERS.
  ENDCASE.

  PR_EVENT_DATA->M_EVENT_HANDLED = 'X'.

ENDFORM.                                                " onf4_proc_w2

*&---------------------------------------------------------------------*
*&      Form  add_exclude_toolbar_button
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_<TABLE>  text
*      -->P_CL_GUI_ALV_GRID=>MC_FC_LOC_UND  text
*----------------------------------------------------------------------*
FORM ADD_EXCLUDE_TOOLBAR_BUTTON  TABLES   PT_TABLE
                                 USING    PV_VALUE.

  DATA: LV_EXCLUDE TYPE UI_FUNC.

  LV_EXCLUDE = PV_VALUE.
*& 결과적으로 GT_EXCLUDE에 제거할 버튼 저장
  APPEND LV_EXCLUDE TO PT_TABLE.

ENDFORM.                    " add_exclude_toolbar_button
*&---------------------------------------------------------------------*
*&      Form  fill_field_catalogs
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0309   text
*      -->P_0310   text
*      -->P_0311   text
*----------------------------------------------------------------------*
FORM FILL_FIELD_CATALOGS  TABLES PT_FIELDCAT TYPE LVC_T_FCAT
                          USING  PV_GUB
                                 PV_FNAME
                                 PV_VALUE.

*& 'S' -> Structure에 필드 속성 값 Setting을 Start 시점
*& 'E' -> Structure의 내용을 필드 카타로그 테이블에 저장 시점

  IF PV_GUB = 'S'.
    CLEAR GS_FIELDCAT.
  ENDIF.

*& 출력될 Field 속성을 정의해서 필드 카타로그 테이블에 저장
  DATA LV_FNAME(40).
  FIELD-SYMBOLS <FS> TYPE ANY.
  CONCATENATE 'GS_FIELDCAT-' PV_FNAME INTO LV_FNAME.

  ASSIGN (LV_FNAME) TO <FS>.
  <FS> = PV_VALUE.

  IF PV_GUB = 'E'.
    APPEND GS_FIELDCAT TO PT_FIELDCAT.
  ENDIF.
ENDFORM.                    " fill_field_catalogs
*&---------------------------------------------------------------------*
*&      Form  get_lifnr_name1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_EBAN_LIFNR  text
*----------------------------------------------------------------------*
FORM GET_LIFNR_NAME1  USING    PV_LIFNR
                   CHANGING    PV_NAME1.
  CLEAR: LFA1.
  SELECT SINGLE NAME1 INTO PV_NAME1
           FROM LFA1
          WHERE LIFNR = PV_LIFNR.

ENDFORM.                    " get_lifnr_name1
*&---------------------------------------------------------------------*
*&      Form  create_purchase_order
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CREATE_PURCHASE_ORDER .
  DATA : LV_BUKRS  TYPE MSEG-BUKRS,
         LV_CHK(1).

  REFRESH: GT_EBAN_N, GT_MSG.
  CLEAR  : GT_EBAN_N, GT_MSG, GV_TABIX, LV_BUKRS, LV_CHK.

*& CSR : C2007020201000001000
*& 플랜트로 회사코드 조회
  LOOP AT GT_EBAN WHERE CHECK = 'X'.

    CALL FUNCTION 'Z_FI_GET_ORG_CODE'
      EXPORTING
        I_WERKS = GT_EBAN-WERKS
      IMPORTING
        E_BUKRS = LV_BUKRS.

    IF LV_BUKRS IS INITIAL.
      CLEAR GT_MSG.
      GT_MSG-MSGID = 'ZPP1'.
      GT_MSG-MSGTY = 'E'.
      GT_MSG-MSGNO = '004'.
      GT_MSG-MSGV1 = '회사코드 오류로 구매오더 생성 실패.'.
      GT_MSG-REFNO =  GT_EBAN-BANFN.
      GT_MSG-REFIT =  GT_EBAN-BNFPO.

      APPEND GT_MSG.    CLEAR GT_MSG.

      LV_CHK = 'X'.

      CONTINUE.

    ELSE.

      GT_EBAN-BUKRS = LV_BUKRS.

      MODIFY GT_EBAN.

    ENDIF.

  ENDLOOP.

  LOOP AT GT_EBAN WHERE CHECK = 'X'.
    GV_TABIX = SY-TABIX.

    IF NOT GT_EBAN-EBELN IS INITIAL.
      CONTINUE.
    ENDIF.

    IF GT_EBAN-MENGE_B < 1 OR
       GT_EBAN-MENGE_B < GT_EBAN-MENGE_A.
      CLEAR GT_MSG.
      GT_MSG-MSGID = 'ZPP1'.
      GT_MSG-MSGTY = 'E'.
      GT_MSG-MSGNO = '004'.
      GT_MSG-MSGV1 = '구매요청 수량을 초과하였습니다.'.
      GT_MSG-REFNO =  GT_EBAN-BANFN.
      GT_MSG-REFIT =  GT_EBAN-BNFPO.

      APPEND GT_MSG.    CLEAR GT_MSG.

      CONTINUE.
    ENDIF.
*& 구매오더 생성...
    PERFORM BAPI_PURCHASE_ORDER_CREATE.

  ENDLOOP.

*& 새로운 라인을 추가...
  IF NOT GT_EBAN_N[] IS INITIAL.
    APPEND LINES OF GT_EBAN_N TO GT_EBAN.
  ENDIF.

  IF NOT GT_MSG[] IS INITIAL.
    CALL FUNCTION 'Z_TI_POPUP_TO_ERROR_MESSAGE'
      EXPORTING
        XDOCNO_SHOW = 'X'
      TABLES
        XMSG        = GT_MSG.
  ENDIF.

ENDFORM.                    " create_purchase_order
*&---------------------------------------------------------------------*
*&      Form  create_and_init_controls_0200
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CREATE_AND_INIT_CONTROLS_0200 .
  CHECK GCL_CUSTOM_CONTAINER1 IS INITIAL.

*& 상속받은 Object를 연결해 주는 작업
  CREATE OBJECT GCL_CUSTOM_CONTAINER1
    EXPORTING
      CONTAINER_NAME = GV_CONTAINER1.

  CREATE OBJECT GCL_SPLITTER_CONTAINER
    EXPORTING
      PARENT  = GCL_CUSTOM_CONTAINER1
      ROWS    = 3
      COLUMNS = 1.

  CALL METHOD GCL_SPLITTER_CONTAINER->SET_BORDER
    EXPORTING
      BORDER = CL_GUI_CFW=>FALSE.

  CALL METHOD GCL_SPLITTER_CONTAINER->SET_ROW_MODE
    EXPORTING
      MODE = GCL_SPLITTER_CONTAINER->MODE_RELATIVE.

  CALL METHOD GCL_SPLITTER_CONTAINER->SET_COLUMN_WIDTH
    EXPORTING
      ID    = 1
      WIDTH = 25.

  GCL_CONTAINER_L  =
    GCL_SPLITTER_CONTAINER->GET_CONTAINER( ROW = 1 COLUMN = 1 ).
  GCL_CONTAINER_W1 =
    GCL_SPLITTER_CONTAINER->GET_CONTAINER( ROW = 2 COLUMN = 1 ).
  GCL_CONTAINER_W2 =
    GCL_SPLITTER_CONTAINER->GET_CONTAINER( ROW = 3 COLUMN = 1 ).

  CREATE OBJECT GCL_GRID_L
    EXPORTING
      I_PARENT = GCL_CONTAINER_L.
*&                   i_appl_events  = 'X'.

  CREATE OBJECT GCL_GRID_W1
    EXPORTING
      I_PARENT = GCL_CONTAINER_W1.
*&                   i_appl_events  = 'X'.

  CREATE OBJECT GCL_GRID_W2
    EXPORTING
      I_PARENT = GCL_CONTAINER_W2.
*&                   i_appl_events  = 'X'.

  PERFORM EXCLUDE_OF_TOOLBAR_BUTTON_L  USING 'GT_EXCLUDE_L'.
  PERFORM EXCLUDE_OF_TOOLBAR_BUTTON_W1 USING 'GT_EXCLUDE_W1'.
  PERFORM EXCLUDE_OF_TOOLBAR_BUTTON_W2 USING 'GT_EXCLUDE_W2'.

*& 출력할 필드 속성을 정의
  PERFORM SET_FIELD_CATALOGS_L.
  PERFORM SET_FIELD_CATALOGS_W1.
  PERFORM SET_FIELD_CATALOGS_W2.

  PERFORM SET_CELL_ATTRIBUTE_L.
  PERFORM SET_CELL_ATTRIBUTE_W1.
  PERFORM SET_CELL_ATTRIBUTE_W2.

*& GRID 속성 지정(Display): Display시 옵션 지정
  PERFORM DISPLAY_LAYOUT_ATTRIBUTE_L  USING GS_LAYOCAT_L.
  PERFORM DISPLAY_LAYOUT_ATTRIBUTE_W1 USING GS_LAYOCAT_W1.
  PERFORM DISPLAY_LAYOUT_ATTRIBUTE_W2 USING GS_LAYOCAT_W2.

*& Edit Event 및  Event Handler 등록
  PERFORM EVENT_HANDLER_REGISTER_L.
  PERFORM EVENT_HANDLER_REGISTER_W1.
  PERFORM EVENT_HANDLER_REGISTER_W2.

*& Sorting
  PERFORM BUILD_SORT_FIELD_L.
  PERFORM BUILD_SORT_FIELD_W1.
  PERFORM BUILD_SORT_FIELD_W2.

  GV_REPID = SY-REPID.

*& At least field REPORT of this structure has to be filled!
  ALV_VARIANT-REPORT = GV_REPID.

  GV_TITLE_L = '배치 관리 사급자재'.  "변경(SJM 25.03.31) '길이관리 사급자재'.
  GV_TITLE_W = '배치 미관리 사급자재'. "변경(SJM 25.03.31) '중량관리 사급자재'.

*& ALV Grid Display
  PERFORM ALV_GRID_DISPLAY_L.
  PERFORM ALV_GRID_DISPLAY_W1.
  PERFORM ALV_GRID_DISPLAY_W2.

  CALL METHOD GCL_GRID_L->SET_GRIDTITLE
    EXPORTING
      I_GRIDTITLE = GV_TITLE_L.

  CALL METHOD GCL_GRID_W1->SET_GRIDTITLE
    EXPORTING
      I_GRIDTITLE = GV_TITLE_W.

  LCL_ALV_GRID=>F_ALV = '1'.

ENDFORM.                    " create_and_init_controls_0200
*&---------------------------------------------------------------------*
*&      Form  exclude_of_toolbar_button_l
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_1687   text
*----------------------------------------------------------------------*
FORM EXCLUDE_OF_TOOLBAR_BUTTON_L  USING  PV_TABNAME.
  DATA : LV_TAB_NAME             LIKE  FELD-NAME.
  FIELD-SYMBOLS : <TABLE>        TYPE  UI_FUNCTIONS.

  CONCATENATE PV_TABNAME '[]'    INTO  LV_TAB_NAME.
  ASSIGN     (LV_TAB_NAME)         TO <TABLE>.

*& 제거할 버튼 지정
  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON
   TABLES <TABLE>
*    USING : cl_gui_alv_grid=>mc_fc_excl_all. " ** 툴바 모두제거 **
    USING : CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO, " 실행취소&LOCAL&UNDO
            CL_GUI_ALV_GRID=>MC_FC_AUF,      " 소계확장 &AUF
            CL_GUI_ALV_GRID=>MC_FC_AVERAGE,  " &AVERAGE
*            cl_gui_alv_grid=>mc_fc_back_classic,
*            cl_gui_alv_grid=>mc_fc_call_abc, " &ABC
*            cl_gui_alv_grid=>mc_fc_call_chain,
*            cl_gui_alv_grid=>mc_fc_call_crbatch,
*            cl_gui_alv_grid=>mc_fc_call_crweb,
*            cl_gui_alv_grid=>mc_fc_call_lineitems,
*            cl_gui_alv_grid=>mc_fc_call_master_data,
*            cl_gui_alv_grid=>mc_fc_call_more,
*            cl_gui_alv_grid=>mc_fc_call_report,
*            cl_gui_alv_grid=>mc_fc_call_xint,
*            cl_gui_alv_grid=>mc_fc_call_xxl,
*            cl_gui_alv_grid=>mc_fc_col_invisible,
*            cl_gui_alv_grid=>mc_fc_col_optimize,
*            cl_gui_alv_grid=>mc_fc_current_variant,
*            cl_gui_alv_grid=>mc_fc_data_save,
*            cl_gui_alv_grid=>mc_fc_delete_filter,
*            cl_gui_alv_grid=>mc_fc_deselect_all,
*            cl_gui_alv_grid=>mc_fc_detail,
*            cl_gui_alv_grid=>mc_fc_expcrdata,
*            cl_gui_alv_grid=>mc_fc_expcrdesig,
*            cl_gui_alv_grid=>mc_fc_expcrtempl,
*            cl_gui_alv_grid=>mc_fc_expmdb,
*            cl_gui_alv_grid=>mc_fc_extend,
*            cl_gui_alv_grid=>mc_fc_f4,
*            cl_gui_alv_grid=>mc_fc_filter,
*            cl_gui_alv_grid=>mc_fc_find,
*            cl_gui_alv_grid=>mc_fc_fix_columns,
            CL_GUI_ALV_GRID=>MC_FC_GRAPH,
*            cl_gui_alv_grid=>mc_fc_help,
*            cl_gui_alv_grid=>mc_fc_info,
*            cl_gui_alv_grid=>mc_fc_load_variant,
*            cl_gui_alv_grid=>mc_fc_loc_copy,          " 행 카피.
*            cl_gui_alv_grid=>mc_fc_html,
            CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW,      " 열 카피.
            CL_GUI_ALV_GRID=>MC_FC_LOC_CUT,           " 가위.
            CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW,    " 행삭제.
            CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW,    " 행삽입.
            CL_GUI_ALV_GRID=>MC_FC_LOC_MOVE_ROW,
            CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW,    " 라인생성.
            CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE,         " 겹쳐쓰기.
            CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW. " 겹쳐쓰기.
*            cl_gui_alv_grid=>mc_fc_maintain_variant,
*            cl_gui_alv_grid=>mc_fc_maximum,
*            cl_gui_alv_grid=>mc_fc_minimum,
*            cl_gui_alv_grid=>mc_fc_pc_file,
*            cl_gui_alv_grid=>mc_fc_print,
*            cl_gui_alv_grid=>mc_fc_print_back,
*            cl_gui_alv_grid=>mc_fc_print_prev,
*            cl_gui_alv_grid=>mc_fc_refresh,
*            cl_gui_alv_grid=>mc_fc_reprep,
*            cl_gui_alv_grid=>mc_fc_save_variant,
*            cl_gui_alv_grid=>mc_fc_select_all,
*            cl_gui_alv_grid=>mc_fc_send,
*            cl_gui_alv_grid=>mc_fc_separator,
*            cl_gui_alv_grid=>mc_fc_sort,
*            cl_gui_alv_grid=>mc_fc_sort_asc,
*            cl_gui_alv_grid=>mc_fc_sort_dsc,
*            cl_gui_alv_grid=>mc_fc_subtot,
*            cl_gui_alv_grid=>mc_mb_sum,
*            cl_gui_alv_grid=>mc_fc_sum.
*            cl_gui_alv_grid=>mc_fc_to_office,
*            cl_gui_alv_grid=>mc_fc_to_rep_tree,
*            cl_gui_alv_grid=>mc_fc_unfix_columns,
*            cl_gui_alv_grid=>mc_fc_views,
*            cl_gui_alv_grid=>mc_fc_view_crystal,
*            cl_gui_alv_grid=>mc_fc_view_excel,
*            cl_gui_alv_grid=>mc_fc_view_grid,
*            cl_gui_alv_grid=>mc_fc_word_processor.

ENDFORM.                    " exclude_of_toolbar_button_l
*&---------------------------------------------------------------------*
*&      Form  set_field_catalogs_l
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_FIELD_CATALOGS_L .
  REFRESH GT_FIELDCAT_L.   CLEAR GT_FIELDCAT_L.

  PERFORM   FILL_FIELD_CATALOGS
   TABLES   GT_FIELDCAT_L
    USING: 'S' 'FIELDNAME'        'CHECK',
           ' ' 'COLTEXT'          '선택',
           ' ' 'JUST'             'C',
           ' ' 'CHECKBOX'         'X',
           ' ' 'EDIT'             'X',
           ' ' 'KEY'              'X',
           'E' 'OUTPUTLEN'        '1',

           'S' 'FIELDNAME'        'MATNR',
           ' ' 'COLTEXT'          '입고반제품 Code',
           ' ' 'JUST'             'C',
           ' ' 'NO_ZERO'          'X',
*&           ' ' 'F4AVAILABL'       'X',
*&           ' ' 'REF_FIELD'        'MATNR',
*&           ' ' 'REF_TABLE'        'MARA',
           ' ' 'CONVEXIT'         'MATN1',
           ' ' 'KEY'              'X',
           'E' 'OUTPUTLEN'        '18',

           'S' 'FIELDNAME'        'EBELN',
           ' ' 'COLTEXT'          '구매오더No.'
                                               ,
           ' ' 'JUST'             'C',
           ' ' 'KEY'              'X',
           'E' 'OUTPUTLEN'        '10',

           'S' 'FIELDNAME'        'EBELP',
           ' ' 'COLTEXT'          'Item',
           ' ' 'JUST'             'C',
           ' ' 'NO_ZERO'          'X',
           ' ' 'KEY'              'X',
           'E' 'OUTPUTLEN'        '05',

           'S' 'FIELDNAME'        'MENGE',
           ' ' 'COLTEXT'          '구매오더수량',
           ' ' 'JUST'             'R',
           ' ' 'NO_ZERO'          'X',
           ' ' 'QFIELDNAME'       'MEINS',
           ' ' 'REF_FIELD'        'MENGE',
           ' ' 'REF_TABLE'        'EKPO',
           'E' 'OUTPUTLEN'        '17',

           'S' 'FIELDNAME'        'MATNR_C',
           ' ' 'COLTEXT'          '출고반제품 Code',
           ' ' 'JUST'             'C',
           ' ' 'NO_ZERO'          'X',
*&           ' ' 'F4AVAILABL'       'X',
*&           ' ' 'REF_FIELD'        'MATNR',
*&           ' ' 'REF_TABLE'        'MARA',
           ' ' 'CONVEXIT'         'MATN1',
           'E' 'OUTPUTLEN'        '18',

           'S' 'FIELDNAME'        'MAKTX_C',
           ' ' 'COLTEXT'          '출고반제품 품명',
           ' ' 'JUST'             'L',
           'E' 'OUTPUTLEN'        '40',

           'S' 'FIELDNAME'        'ENMNG',
           ' ' 'COLTEXT'          '출고반제품 소요량',
           ' ' 'JUST'             'R',
           ' ' 'NO_ZERO'          'X',
           ' ' 'QFIELDNAME'       'ERFME',
           ' ' 'REF_FIELD'        'ERFMG',
           ' ' 'REF_TABLE'        'RESB',
           'E' 'OUTPUTLEN'        '17',

           'S' 'FIELDNAME'        'BDMNG',
           ' ' 'COLTEXT'          '출고반제품 출고량',
           ' ' 'JUST'             'R',
           ' ' 'NO_ZERO'          'X',
           ' ' 'QFIELDNAME'       'ERFME',
           ' ' 'REF_FIELD'        'ERFMG',
           ' ' 'REF_TABLE'        'RESB',
           'E' 'OUTPUTLEN'        '17',

           'S' 'FIELDNAME'        'ERFME',
           ' ' 'COLTEXT'          '단위',
           ' ' 'JUST'             'C',
           'E' 'OUTPUTLEN'        '03',

           'S' 'FIELDNAME'        'CHARG',
           ' ' 'COLTEXT'          '뱃치번호',
           ' ' 'JUST'             'C',
           ' ' 'F4AVAILABL'       'X',
*           ' ' 'EDIT'             'X',
*&           ' ' 'REF_FIELD'        'CHARG',
*&           ' ' 'REF_TABLE'        'MCHB',
           'E' 'OUTPUTLEN'        '10',

           'S' 'FIELDNAME'        'TAGNR',
           ' ' 'COLTEXT'          '꼬리표번호',
           ' ' 'JUST'             'C',
           ' ' 'F4AVAILABL'       'X',
           'E' 'OUTPUTLEN'        '17',

           'S' 'FIELDNAME'        'LGORT',
           ' ' 'COLTEXT'          '저장위치',
           ' ' 'JUST'             'C',
           ' ' 'F4AVAILABL'       'X',
           ' ' 'REF_FIELD'        'LGORT',
           ' ' 'REF_TABLE'        'T001L',
           'E' 'OUTPUTLEN'        '04',

*(S)기능 추가 관련(SJM 25.03.18)
           'S' 'FIELDNAME'        'STATS',
           ' ' 'COLTEXT'          '승인상태',
           ' ' 'JUST'             'C',
           'E' 'OUTPUTLEN'        '4',

           'S' 'FIELDNAME'        'ZGUID',
           ' ' 'COLTEXT'          'ZGUID',
           ' ' 'JUST'             'L',
           ' ' 'NO_OUT'           'X',
           'E' 'OUTPUTLEN'        '32',
*(S)기능 추가 관련(SJM 25.03.18)

           'S' 'FIELDNAME'        'MBLNR',
           ' ' 'COLTEXT'          '자재문서',
           ' ' 'JUST'             'C',
           'E' 'OUTPUTLEN'        '10',

           'S' 'FIELDNAME'        'IV_NO',
           ' ' 'COLTEXT'          '통문번호',
           ' ' 'JUST'             'C',
           'E' 'OUTPUTLEN'        '10',

           'S' 'FIELDNAME'        'FLAG1',
           ' ' 'COLTEXT'          '이전전기',
           ' ' 'JUST'             'C',
           ' ' 'ICON'             'X',
           'E' 'OUTPUTLEN'        '04',

           'S' 'FIELDNAME'        'FLAG2',
           ' ' 'COLTEXT'          '통문증발행',
           ' ' 'JUST'             'C',
           ' ' 'ICON'             'X',
           'E' 'OUTPUTLEN'        '04'.

ENDFORM.                    " set_field_catalogs_l
*&---------------------------------------------------------------------*
*&      Form  set_cell_attribute_l
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_CELL_ATTRIBUTE_L .
*& 각 Cell의 특성 제어
  DATA : LT_CELLTAB  TYPE LVC_T_STYL,
         LT_COLOR    TYPE LVC_T_SCOL,
         LV_INDEX    TYPE I,
         LF_ATNEW(1).

  LOOP AT GT_MDSB_L.
    CLEAR: LT_CELLTAB[], LT_COLOR[].

    LV_INDEX = SY-TABIX.

    PERFORM FILL_CELLTAB_L CHANGING LT_CELLTAB.
    PERFORM FILL_COLOR_L   CHANGING LT_COLOR.

    CLEAR: GT_MDSB_L-CELLTAB[], GT_MDSB_L-F_COL[].

    INSERT LINES OF LT_CELLTAB INTO TABLE GT_MDSB_L-CELLTAB.
    INSERT LINES OF LT_COLOR   INTO TABLE GT_MDSB_L-F_COL.

    MODIFY GT_MDSB_L. " INDEX lv_index.
    CLEAR  GT_MDSB_L.

  ENDLOOP.

ENDFORM.                    " set_cell_attribute_l
*&---------------------------------------------------------------------*
*&      Form  display_layout_attribute_l
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_LAYOCAT  text
*----------------------------------------------------------------------*
FORM DISPLAY_LAYOUT_ATTRIBUTE_L  USING  PS_LAYOCAT TYPE LVC_S_LAYO.

*& General display options
  PS_LAYOCAT-CWIDTH_OPT = 'X'.
*  ps_layocat-sel_mode   = 'D'.
*  ps_layocat-edit       = 'E'.
  PS_LAYOCAT-NO_ROWMARK = 'X'.           "선택버튼 비활성
  PS_LAYOCAT-STYLEFNAME = 'CELLTAB'.
  PS_LAYOCAT-CTAB_FNAME = 'F_COL'.
  PS_LAYOCAT-SMALLTITLE = 'X'.           "작은타이틀.

ENDFORM.                    " display_layout_attribute_l
*&---------------------------------------------------------------------*
*&      Form  event_handler_register_l
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM EVENT_HANDLER_REGISTER_L .
  DATA: LT_F4 TYPE LVC_T_F4 WITH HEADER LINE.

  CLEAR LT_F4.
  LT_F4-FIELDNAME  = 'CHARG'.
  LT_F4-REGISTER   = 'X'.
  LT_F4-GETBEFORE  = 'X'.
  LT_F4-CHNGEAFTER = SPACE.
  INSERT TABLE LT_F4.

  LT_F4-FIELDNAME  = 'TAGNR'.
  LT_F4-REGISTER   = 'X'.
  LT_F4-GETBEFORE  = 'X'.
  LT_F4-CHNGEAFTER = SPACE.
  INSERT TABLE LT_F4.

*& ONF4 이벤트 등록
  CALL METHOD GCL_GRID_L->REGISTER_F4_FOR_FIELDS
    EXPORTING
      IT_F4 = LT_F4[].

*& Edit  이벤트 등록
* IF MC_EVT_MODIFY  -> 바로 수정됨.
  CALL METHOD GCL_GRID_L->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

*& Event Handler 등록
  CREATE OBJECT GCL_EVENT_HANDLER_L.

  SET HANDLER GCL_EVENT_HANDLER_L->HANDLE_TOOLBAR
          FOR GCL_GRID_L.
  SET HANDLER GCL_EVENT_HANDLER_L->HANDLE_USER_COMMAND
          FOR GCL_GRID_L.
  SET HANDLER GCL_EVENT_HANDLER_L->HANDLE_DATA_CHANGED
          FOR GCL_GRID_L.
  SET HANDLER GCL_EVENT_HANDLER_L->HANDLE_DATA_CHANGED_FINISHED
          FOR GCL_GRID_L.
  SET HANDLER GCL_EVENT_HANDLER_L->HANDLE_DOUBLE_CLICK
          FOR GCL_GRID_L.
  SET HANDLER GCL_EVENT_HANDLER_L->HANDLE_AFTER_USER_COMMAND
          FOR GCL_GRID_L.
  SET HANDLER GCL_EVENT_HANDLER_L->HANDLE_BUTTON_CLICK
          FOR GCL_GRID_L.
  SET HANDLER GCL_EVENT_HANDLER_L->HANDLE_ONF4
          FOR GCL_GRID_L.

ENDFORM.                    " event_handler_register_l
*&---------------------------------------------------------------------*
*&      Form  event_handler_register_w1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM EVENT_HANDLER_REGISTER_W1 .
*& Edit  이벤트 등록
* IF MC_EVT_MODIFY  -> 바로 수정됨.
  CALL METHOD GCL_GRID_W1->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

*& Event Handler 등록
  CREATE OBJECT GCL_EVENT_HANDLER_W1.

  SET HANDLER GCL_EVENT_HANDLER_W1->HANDLE_TOOLBAR
          FOR GCL_GRID_W1.
  SET HANDLER GCL_EVENT_HANDLER_W1->HANDLE_USER_COMMAND
          FOR GCL_GRID_W1.
  SET HANDLER GCL_EVENT_HANDLER_W1->HANDLE_DATA_CHANGED
          FOR GCL_GRID_W1.
  SET HANDLER GCL_EVENT_HANDLER_W1->HANDLE_DATA_CHANGED_FINISHED
          FOR GCL_GRID_W1.
  SET HANDLER GCL_EVENT_HANDLER_W1->HANDLE_DOUBLE_CLICK
          FOR GCL_GRID_W1.
  SET HANDLER GCL_EVENT_HANDLER_W1->HANDLE_AFTER_USER_COMMAND
          FOR GCL_GRID_W1.
  SET HANDLER GCL_EVENT_HANDLER_W1->HANDLE_BUTTON_CLICK
          FOR GCL_GRID_W1.

ENDFORM.                    " event_handler_register_w1
*&---------------------------------------------------------------------*
*&      Form  event_handler_register_w2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM EVENT_HANDLER_REGISTER_W2 .
  DATA: LT_F4 TYPE LVC_T_F4 WITH HEADER LINE.

  CLEAR LT_F4.
  LT_F4-FIELDNAME  = 'CHARG'.
  LT_F4-REGISTER   = 'X'.
  LT_F4-GETBEFORE  = 'X'.
  LT_F4-CHNGEAFTER = SPACE.
  INSERT TABLE LT_F4.

  LT_F4-FIELDNAME  = 'TAGNR'.
  LT_F4-REGISTER   = 'X'.
  LT_F4-GETBEFORE  = 'X'.
  LT_F4-CHNGEAFTER = SPACE.
  INSERT TABLE LT_F4.

*& ONF4 이벤트 등록
  CALL METHOD GCL_GRID_W2->REGISTER_F4_FOR_FIELDS
    EXPORTING
      IT_F4 = LT_F4[].

*& Edit  이벤트 등록
* IF MC_EVT_MODIFY  -> 바로 수정됨.
  CALL METHOD GCL_GRID_W2->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

*& Event Handler 등록
  CREATE OBJECT GCL_EVENT_HANDLER_W2.

  SET HANDLER GCL_EVENT_HANDLER_W2->HANDLE_TOOLBAR
          FOR GCL_GRID_W2.
  SET HANDLER GCL_EVENT_HANDLER_W2->HANDLE_USER_COMMAND
          FOR GCL_GRID_W2.
  SET HANDLER GCL_EVENT_HANDLER_W2->HANDLE_DATA_CHANGED
          FOR GCL_GRID_W2.
  SET HANDLER GCL_EVENT_HANDLER_W2->HANDLE_DATA_CHANGED_FINISHED
          FOR GCL_GRID_W2.
  SET HANDLER GCL_EVENT_HANDLER_W2->HANDLE_DOUBLE_CLICK
          FOR GCL_GRID_W2.
  SET HANDLER GCL_EVENT_HANDLER_W2->HANDLE_AFTER_USER_COMMAND
          FOR GCL_GRID_W2.
  SET HANDLER GCL_EVENT_HANDLER_W2->HANDLE_BUTTON_CLICK
          FOR GCL_GRID_W2.
  SET HANDLER GCL_EVENT_HANDLER_W2->HANDLE_ONF4
          FOR GCL_GRID_W2.

ENDFORM.                    " event_handler_register_w2

*&---------------------------------------------------------------------*
*&      Form  build_sort_field_l
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM BUILD_SORT_FIELD_L .
* Sort 필드 설정
  GS_SORT-FIELDNAME = 'MBLNR'.
  GS_SORT-SPOS      = '1'.
  GS_SORT-UP        = 'X'.
  APPEND GS_SORT   TO GT_SORT_L.

  GS_SORT-FIELDNAME = 'MATNR_C'.
  GS_SORT-SPOS      = '1'.
  GS_SORT-UP        = 'X'.
  APPEND GS_SORT   TO GT_SORT_L.

*  gs_sort-fieldname = 'DISPO'.
*  gs_sort-spos      = '2'.
*  gs_sort-up        = 'X'.
*  APPEND gs_sort TO gt_sort.

*  gs_sort-fieldname = 'MATNR'.
*  gs_sort-spos      = '2'.
*  gs_sort-up        = 'X'.
*  APPEND gs_sort TO gt_sort.



ENDFORM.                    " build_sort_field_l
*&---------------------------------------------------------------------*
*&      Form  build_sort_field_w1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM BUILD_SORT_FIELD_W1 .

ENDFORM.                    " build_sort_field_w1
*&---------------------------------------------------------------------*
*&      Form  build_sort_field_w2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM BUILD_SORT_FIELD_W2 .

ENDFORM.                    " build_sort_field_w2

*&---------------------------------------------------------------------*
*&      Form  alv_grid_display_l
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ALV_GRID_DISPLAY_L .
*&  lcl_alv_grid=>f_alv = '1'.

*& Display
  CALL METHOD GCL_GRID_L->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOCAT_L
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_L
      I_SAVE               = 'A'   " 전체가능유형.
*                                       'U'   " 특정사용자전용.
*                                       'X'   " 광역 전용.
*                                       ' '   " 저장안함.
      I_DEFAULT            = 'X'   " 레이아웃 사전셋팅 허용.
*  LAYOUT   Standard   BCALV_GRID_09  참조.
*  is_variant 레이아웃선택/변경/저장/관리 enable
      IS_VARIANT           = ALV_VARIANT  " 선택 메뉴 display
    CHANGING
      IT_OUTTAB            = GT_MDSB_L[]
      IT_SORT              = GT_SORT_L
      IT_FIELDCATALOG      = GT_FIELDCAT_L[].
  CALL METHOD GCL_GRID_L->SET_ROW_RESIZE.

ENDFORM.                    " alv_grid_display_l
*&---------------------------------------------------------------------*
*&      Form  fill_celltab_l
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LT_CELLTAB  text
*----------------------------------------------------------------------*
FORM FILL_CELLTAB_L  CHANGING PT_CELLTAB TYPE LVC_T_STYL.

  DATA : LS_CELLTAB TYPE LVC_S_STYL,
         LV_MODE    TYPE RAW4.
  DATA : LS_FIELDCAT     TYPE LVC_S_FCAT.

  LOOP AT GT_FIELDCAT_L  INTO LS_FIELDCAT.
    LS_CELLTAB-FIELDNAME = LS_FIELDCAT-FIELDNAME.

    CASE LS_FIELDCAT-FIELDNAME.
      WHEN 'CHECK'.
        LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
        LS_CELLTAB-STYLE4 = CL_GUI_ALV_GRID=>MC_STYLE4_LINK_NO.
        INSERT LS_CELLTAB INTO TABLE PT_CELLTAB.

      WHEN 'CHARG' OR 'LGORT' OR 'BDMNG' OR 'TAGNR'.
        IF P_CANCEL = 'X' OR GT_MDSB_L-MBLNR_F = 'X'
        OR ( GT_MDSB_L-STATS = ICON_MAIL     "추가(SJM 25.03.18)
          OR GT_MDSB_L-STATS = ICON_ALLOW ). "추가(SJM 25.03.18)
          LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED +
                             CL_GUI_ALV_GRID=>MC_STYLE_F4_NO.
          INSERT LS_CELLTAB INTO TABLE PT_CELLTAB.
        ELSE.
          LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED +
                             CL_GUI_ALV_GRID=>MC_STYLE_F4.
          INSERT LS_CELLTAB INTO TABLE PT_CELLTAB.
        ENDIF.

      WHEN 'MATNR' OR 'MATNR_C' OR 'EBELN'.
        LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED +
                           CL_GUI_ALV_GRID=>MC_STYLE_F4_NO.
        LS_CELLTAB-STYLE4 = CL_GUI_ALV_GRID=>MC_STYLE4_LINK.
        INSERT LS_CELLTAB INTO TABLE PT_CELLTAB.

      WHEN  OTHERS.
        LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED +
                           CL_GUI_ALV_GRID=>MC_STYLE_F4_NO.
        LS_CELLTAB-STYLE4 = CL_GUI_ALV_GRID=>MC_STYLE4_LINK_NO.
        INSERT LS_CELLTAB INTO TABLE PT_CELLTAB.

    ENDCASE.

  ENDLOOP.

ENDFORM.                    " fill_celltab_l
*&---------------------------------------------------------------------*
*&      Form  fill_color_l
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LT_COLOR  text
*----------------------------------------------------------------------*
FORM FILL_COLOR_L   CHANGING PT_COLOR TYPE LVC_T_SCOL.

  DATA : LS_CELLTAB TYPE LVC_S_STYL,
         LS_COLOR   TYPE LVC_S_SCOL,
         LV_MODE    TYPE RAW4.

  DATA : LS_FIELDCAT    TYPE LVC_S_FCAT.

  LOOP AT GT_FIELDCAT_L INTO LS_FIELDCAT.
    LS_COLOR-FNAME = LS_FIELDCAT-FIELDNAME.
    CASE LS_FIELDCAT-FIELDNAME.
      WHEN 'CHECK'.
        LS_COLOR-COLOR-COL = 0.
        LS_COLOR-COLOR-INT = 1.

      WHEN 'CHARG' OR 'LGORT' OR 'BDMNG'.    "입력필드
        IF P_CANCEL = 'X' OR GT_MDSB_L-MBLNR_F = 'X'
        OR ( GT_MDSB_L-STATS = ICON_MAIL     "추가(SJM 25.03.18)
          OR GT_MDSB_L-STATS = ICON_ALLOW ). "추가(SJM 25.03.18)
          LS_COLOR-COLOR-COL = 4.
          LS_COLOR-COLOR-INT = 0.
        ELSE.
          LS_COLOR-COLOR-COL = 0.
          LS_COLOR-COLOR-INT = 1.
        ENDIF.

      WHEN 'MATNR' OR 'EBELN' OR 'EBELP'.    "KEY 필드
        LS_COLOR-COLOR-COL = 1.
        LS_COLOR-COLOR-INT = 1.

      WHEN  OTHERS.
        LS_COLOR-COLOR-COL = 4.
        LS_COLOR-COLOR-INT = 0.

    ENDCASE.

    INSERT LS_COLOR INTO TABLE PT_COLOR.
  ENDLOOP.

ENDFORM.                    " fill_color_l
*&---------------------------------------------------------------------*
*&      Form  exclude_of_toolbar_button_w1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_2012   text
*----------------------------------------------------------------------*
FORM EXCLUDE_OF_TOOLBAR_BUTTON_W1  USING  PV_TABNAME.
  DATA : LV_TAB_NAME             LIKE  FELD-NAME.
  FIELD-SYMBOLS : <TABLE>        TYPE  UI_FUNCTIONS.

  CONCATENATE PV_TABNAME '[]'    INTO  LV_TAB_NAME.
  ASSIGN     (LV_TAB_NAME)         TO <TABLE>.

*& 제거할 버튼 지정
  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON
   TABLES <TABLE>
*    USING : cl_gui_alv_grid=>mc_fc_excl_all. " ** 툴바 모두제거 **
    USING : CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO, " 실행취소&LOCAL&UNDO
            CL_GUI_ALV_GRID=>MC_FC_AUF,      " 소계확장 &AUF
            CL_GUI_ALV_GRID=>MC_FC_AVERAGE,  " &AVERAGE
*            cl_gui_alv_grid=>mc_fc_back_classic,
*            cl_gui_alv_grid=>mc_fc_call_abc, " &ABC
*            cl_gui_alv_grid=>mc_fc_call_chain,
*            cl_gui_alv_grid=>mc_fc_call_crbatch,
*            cl_gui_alv_grid=>mc_fc_call_crweb,
*            cl_gui_alv_grid=>mc_fc_call_lineitems,
*            cl_gui_alv_grid=>mc_fc_call_master_data,
*            cl_gui_alv_grid=>mc_fc_call_more,
*            cl_gui_alv_grid=>mc_fc_call_report,
*            cl_gui_alv_grid=>mc_fc_call_xint,
*            cl_gui_alv_grid=>mc_fc_call_xxl,
*            cl_gui_alv_grid=>mc_fc_col_invisible,
*            cl_gui_alv_grid=>mc_fc_col_optimize,
*            cl_gui_alv_grid=>mc_fc_current_variant,
*            cl_gui_alv_grid=>mc_fc_data_save,
*            cl_gui_alv_grid=>mc_fc_delete_filter,
*            cl_gui_alv_grid=>mc_fc_deselect_all,
*            cl_gui_alv_grid=>mc_fc_detail,
*            cl_gui_alv_grid=>mc_fc_expcrdata,
*            cl_gui_alv_grid=>mc_fc_expcrdesig,
*            cl_gui_alv_grid=>mc_fc_expcrtempl,
*            cl_gui_alv_grid=>mc_fc_expmdb,
*            cl_gui_alv_grid=>mc_fc_extend,
*            cl_gui_alv_grid=>mc_fc_f4,
*            cl_gui_alv_grid=>mc_fc_filter,
*            cl_gui_alv_grid=>mc_fc_find,
*            cl_gui_alv_grid=>mc_fc_fix_columns,
            CL_GUI_ALV_GRID=>MC_FC_GRAPH,
*            cl_gui_alv_grid=>mc_fc_help,
*            cl_gui_alv_grid=>mc_fc_info,
*            cl_gui_alv_grid=>mc_fc_load_variant,
*            cl_gui_alv_grid=>mc_fc_loc_copy,          " 행 카피.
*            cl_gui_alv_grid=>mc_fc_html,
            CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW,      " 열 카피.
            CL_GUI_ALV_GRID=>MC_FC_LOC_CUT,           " 가위.
            CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW,    " 행삭제.
            CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW,    " 행삽입.
            CL_GUI_ALV_GRID=>MC_FC_LOC_MOVE_ROW,
            CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW,    " 라인생성.
            CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE,         " 겹쳐쓰기.
            CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW. " 겹쳐쓰기.
*            cl_gui_alv_grid=>mc_fc_maintain_variant,
*            cl_gui_alv_grid=>mc_fc_maximum,
*            cl_gui_alv_grid=>mc_fc_minimum,
*            cl_gui_alv_grid=>mc_fc_pc_file,
*            cl_gui_alv_grid=>mc_fc_print,
*            cl_gui_alv_grid=>mc_fc_print_back,
*            cl_gui_alv_grid=>mc_fc_print_prev,
*            cl_gui_alv_grid=>mc_fc_refresh,
*            cl_gui_alv_grid=>mc_fc_reprep,
*            cl_gui_alv_grid=>mc_fc_save_variant,
*            cl_gui_alv_grid=>mc_fc_select_all,
*            cl_gui_alv_grid=>mc_fc_send,
*            cl_gui_alv_grid=>mc_fc_separator,
*            cl_gui_alv_grid=>mc_fc_sort,
*            cl_gui_alv_grid=>mc_fc_sort_asc,
*            cl_gui_alv_grid=>mc_fc_sort_dsc,
*            cl_gui_alv_grid=>mc_fc_subtot,
*            cl_gui_alv_grid=>mc_mb_sum,
*            cl_gui_alv_grid=>mc_fc_sum.
*            cl_gui_alv_grid=>mc_fc_to_office,
*            cl_gui_alv_grid=>mc_fc_to_rep_tree,
*            cl_gui_alv_grid=>mc_fc_unfix_columns,
*            cl_gui_alv_grid=>mc_fc_views,
*            cl_gui_alv_grid=>mc_fc_view_crystal,
*            cl_gui_alv_grid=>mc_fc_view_excel,
*            cl_gui_alv_grid=>mc_fc_view_grid,
*            cl_gui_alv_grid=>mc_fc_word_processor.

ENDFORM.                    " exclude_of_toolbar_button_w1
*&---------------------------------------------------------------------*
*&      Form  exclude_of_toolbar_button_w2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_2016   text
*----------------------------------------------------------------------*
FORM EXCLUDE_OF_TOOLBAR_BUTTON_W2  USING  PV_TABNAME.
  DATA : LV_TAB_NAME             LIKE  FELD-NAME.
  FIELD-SYMBOLS : <TABLE>        TYPE  UI_FUNCTIONS.

  CONCATENATE PV_TABNAME '[]'    INTO  LV_TAB_NAME.
  ASSIGN     (LV_TAB_NAME)         TO <TABLE>.

*& 제거할 버튼 지정
  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON
   TABLES <TABLE>
    USING : CL_GUI_ALV_GRID=>MC_FC_EXCL_ALL. " ** 툴바 모두제거 **
*    USING : cl_gui_alv_grid=>mc_fc_loc_undo, " 실행취소&LOCAL&UNDO
*            cl_gui_alv_grid=>mc_fc_auf,      " 소계확장 &AUF
*            cl_gui_alv_grid=>mc_fc_average,  " &AVERAGE
*            cl_gui_alv_grid=>mc_fc_back_classic,
*            cl_gui_alv_grid=>mc_fc_call_abc, " &ABC
*            cl_gui_alv_grid=>mc_fc_call_chain,
*            cl_gui_alv_grid=>mc_fc_call_crbatch,
*            cl_gui_alv_grid=>mc_fc_call_crweb,
*            cl_gui_alv_grid=>mc_fc_call_lineitems,
*            cl_gui_alv_grid=>mc_fc_call_master_data,
*            cl_gui_alv_grid=>mc_fc_call_more,
*            cl_gui_alv_grid=>mc_fc_call_report,
*            cl_gui_alv_grid=>mc_fc_call_xint,
*            cl_gui_alv_grid=>mc_fc_call_xxl,
*            cl_gui_alv_grid=>mc_fc_col_invisible,
*            cl_gui_alv_grid=>mc_fc_col_optimize,
*            cl_gui_alv_grid=>mc_fc_current_variant,
*            cl_gui_alv_grid=>mc_fc_data_save,
*            cl_gui_alv_grid=>mc_fc_delete_filter,
*            cl_gui_alv_grid=>mc_fc_deselect_all,
*            cl_gui_alv_grid=>mc_fc_detail,
*            cl_gui_alv_grid=>mc_fc_expcrdata,
*            cl_gui_alv_grid=>mc_fc_expcrdesig,
*            cl_gui_alv_grid=>mc_fc_expcrtempl,
*            cl_gui_alv_grid=>mc_fc_expmdb,
*            cl_gui_alv_grid=>mc_fc_extend,
*            cl_gui_alv_grid=>mc_fc_f4,
*            cl_gui_alv_grid=>mc_fc_filter,
*            cl_gui_alv_grid=>mc_fc_find,
*            cl_gui_alv_grid=>mc_fc_fix_columns,
*            cl_gui_alv_grid=>mc_fc_graph,
*            cl_gui_alv_grid=>mc_fc_help,
*            cl_gui_alv_grid=>mc_fc_info,
*            cl_gui_alv_grid=>mc_fc_load_variant,
*            cl_gui_alv_grid=>mc_fc_loc_copy,          " 행 카피.
*            cl_gui_alv_grid=>mc_fc_html,
*            cl_gui_alv_grid=>mc_fc_loc_copy_row,      " 열 카피.
*            cl_gui_alv_grid=>mc_fc_loc_cut,           " 가위.
*            cl_gui_alv_grid=>mc_fc_loc_delete_row,    " 행삭제.
*            cl_gui_alv_grid=>mc_fc_loc_insert_row,    " 행삽입.
*            cl_gui_alv_grid=>mc_fc_loc_move_row,
*            cl_gui_alv_grid=>mc_fc_loc_append_row,    " 라인생성.
*            cl_gui_alv_grid=>mc_fc_loc_paste,         " 겹쳐쓰기.
*            cl_gui_alv_grid=>mc_fc_loc_paste_new_row. " 겹쳐쓰기.
*            cl_gui_alv_grid=>mc_fc_maintain_variant,
*            cl_gui_alv_grid=>mc_fc_maximum,
*            cl_gui_alv_grid=>mc_fc_minimum,
*            cl_gui_alv_grid=>mc_fc_pc_file,
*            cl_gui_alv_grid=>mc_fc_print,
*            cl_gui_alv_grid=>mc_fc_print_back,
*            cl_gui_alv_grid=>mc_fc_print_prev,
*            cl_gui_alv_grid=>mc_fc_refresh,
*            cl_gui_alv_grid=>mc_fc_reprep,
*            cl_gui_alv_grid=>mc_fc_save_variant,
*            cl_gui_alv_grid=>mc_fc_select_all,
*            cl_gui_alv_grid=>mc_fc_send,
*            cl_gui_alv_grid=>mc_fc_separator,
*            cl_gui_alv_grid=>mc_fc_sort,
*            cl_gui_alv_grid=>mc_fc_sort_asc,
*            cl_gui_alv_grid=>mc_fc_sort_dsc,
*            cl_gui_alv_grid=>mc_fc_subtot,
*            cl_gui_alv_grid=>mc_mb_sum,
*            cl_gui_alv_grid=>mc_fc_sum.
*            cl_gui_alv_grid=>mc_fc_to_office,
*            cl_gui_alv_grid=>mc_fc_to_rep_tree,
*            cl_gui_alv_grid=>mc_fc_unfix_columns,
*            cl_gui_alv_grid=>mc_fc_views,
*            cl_gui_alv_grid=>mc_fc_view_crystal,
*            cl_gui_alv_grid=>mc_fc_view_excel,
*            cl_gui_alv_grid=>mc_fc_view_grid,
*            cl_gui_alv_grid=>mc_fc_word_processor.

ENDFORM.                    " exclude_of_toolbar_button_w2
*&---------------------------------------------------------------------*
*&      Form  set_field_catalogs_w1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_FIELD_CATALOGS_W1 .
  REFRESH GT_FIELDCAT_W1.   CLEAR GT_FIELDCAT_W1.

  PERFORM   FILL_FIELD_CATALOGS
   TABLES   GT_FIELDCAT_W1
*&    USING: 'S' 'FIELDNAME'        'CHECK',
*&           ' ' 'COLTEXT'          '선택',
*&           ' ' 'JUST'             'C',
*&           ' ' 'CHECKBOX'         'X',
*&           ' ' 'EDIT'             'X',
*&           ' ' 'KEY'              'X',
*&           'E' 'OUTPUTLEN'        '1',

    USING: 'S' 'FIELDNAME'        'MATNR',
           ' ' 'COLTEXT'          '입고반제품 Code',
           ' ' 'JUST'             'C',
           ' ' 'NO_ZERO'          'X',
*&           ' ' 'F4AVAILABL'       'X',
*&           ' ' 'REF_FIELD'        'MATNR',
*&           ' ' 'REF_TABLE'        'MARA',
           ' ' 'CONVEXIT'         'MATN1',
           ' ' 'KEY'              'X',
           'E' 'OUTPUTLEN'        '18',

           'S' 'FIELDNAME'        'EBELN',
           ' ' 'COLTEXT'          '구매오더No.'
                                               ,
           ' ' 'JUST'             'C',
           ' ' 'KEY'              'X',
           'E' 'OUTPUTLEN'        '10',

           'S' 'FIELDNAME'        'EBELP',
           ' ' 'COLTEXT'          'Item',
           ' ' 'JUST'             'C',
           ' ' 'NO_ZERO'          'X',
           ' ' 'KEY'              'X',
           'E' 'OUTPUTLEN'        '05',

           'S' 'FIELDNAME'        'MENGE',
           ' ' 'COLTEXT'          '구매오더수량',
           ' ' 'JUST'             'R',
           ' ' 'NO_ZERO'          'X',
           ' ' 'QFIELDNAME'       'MEINS',
           ' ' 'REF_FIELD'        'MENGE',
           ' ' 'REF_TABLE'        'EKPO',
           'E' 'OUTPUTLEN'        '17',

           'S' 'FIELDNAME'        'MATNR_C',
           ' ' 'COLTEXT'          '출고반제품 Code',
           ' ' 'JUST'             'C',
           ' ' 'NO_ZERO'          'X',
*&           ' ' 'F4AVAILABL'       'X',
*&           ' ' 'REF_FIELD'        'MATNR',
*&           ' ' 'REF_TABLE'        'MARA',
           ' ' 'CONVEXIT'         'MATN1',
           'E' 'OUTPUTLEN'        '18',

           'S' 'FIELDNAME'        'MAKTX_C',
           ' ' 'COLTEXT'          '출고반제품 품명',
           ' ' 'JUST'             'L',
           'E' 'OUTPUTLEN'        '40',

           'S' 'FIELDNAME'        'BDMNG_A',
           ' ' 'COLTEXT'          '출고자재 소요량',
           ' ' 'JUST'             'R',
           ' ' 'NO_ZERO'          'X',
           ' ' 'QFIELDNAME'       'MEINS',
           ' ' 'REF_FIELD'        'ERFMG',
           ' ' 'REF_TABLE'        'RESB',
           'E' 'OUTPUTLEN'        '17',

           'S' 'FIELDNAME'        'MEINS',
           ' ' 'COLTEXT'          '단위',
           ' ' 'JUST'             'C',
           ' ' 'REF_FIELD'        'MEINS',
           ' ' 'REF_TABLE'        'MARA',
           'E' 'OUTPUTLEN'        '03'.

ENDFORM.                    " set_field_catalogs_w1
*&---------------------------------------------------------------------*
*&      Form  set_field_catalogs_w2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_FIELD_CATALOGS_W2 .
  REFRESH GT_FIELDCAT_W2.   CLEAR GT_FIELDCAT_W2.

  PERFORM   FILL_FIELD_CATALOGS
   TABLES   GT_FIELDCAT_W2
    USING: 'S' 'FIELDNAME'        'CHECK',
           ' ' 'COLTEXT'          '선택',
           ' ' 'JUST'             'C',
           ' ' 'CHECKBOX'         'X',
           ' ' 'EDIT'             'X',
           ' ' 'KEY'              'X',
           'E' 'OUTPUTLEN'        '1',

           'S' 'FIELDNAME'        'MATNR_C',
           ' ' 'COLTEXT'          '출고자재 Code',
           ' ' 'JUST'             'C',
           ' ' 'NO_ZERO'          'X',
*&           ' ' 'F4AVAILABL'       'X',
*&           ' ' 'REF_FIELD'        'MATNR',
*&           ' ' 'REF_TABLE'        'MARA',
           ' ' 'CONVEXIT'         'MATN1',
           ' ' 'KEY'              'X',
           'E' 'OUTPUTLEN'        '10',

           'S' 'FIELDNAME'        'LABST',
           ' ' 'COLTEXT'          '현재고(PLANT)',
           ' ' 'JUST'             'R',
           ' ' 'NO_ZERO'          'X',
           ' ' 'QFIELDNAME'       'MEINS',
           ' ' 'REF_FIELD'        'LABST',
           ' ' 'REF_TABLE'        'MARD',
           'E' 'OUTPUTLEN'        '17',

           'S' 'FIELDNAME'        'LBLAB',
           ' ' 'COLTEXT'          'SC업체 현재고',
           ' ' 'JUST'             'R',
           ' ' 'NO_ZERO'          'X',
           ' ' 'QFIELDNAME'       'MEINS',
           ' ' 'REF_FIELD'        'LBLAB',
           ' ' 'REF_TABLE'        'MSLB',
           'E' 'OUTPUTLEN'        '17',

           'S' 'FIELDNAME'        'MEINS',
           ' ' 'COLTEXT'          '단위',
           ' ' 'JUST'             'C',
           'E' 'OUTPUTLEN'        '03',

           'S' 'FIELDNAME'        'BDMNG_A',
           ' ' 'COLTEXT'          '출고자재 총량',
           ' ' 'JUST'             'R',
           ' ' 'NO_ZERO'          'X',
           ' ' 'QFIELDNAME'       'AUSME',
           ' ' 'REF_FIELD'        'ERFMG',
           ' ' 'REF_TABLE'        'RESB',
           'E' 'OUTPUTLEN'        '17',

           'S' 'FIELDNAME'        'ENMNG',
           ' ' 'COLTEXT'          '업체 불출량',
           ' ' 'JUST'             'R',
           ' ' 'NO_ZERO'          'X',
           ' ' 'QFIELDNAME'       'AUSME',
           ' ' 'REF_FIELD'        'ENMNG',
           ' ' 'REF_TABLE'        'RESB',
           'E' 'OUTPUTLEN'        '17',

           'S' 'FIELDNAME'        'RVMNG',
           ' ' 'COLTEXT'          '예약수량',
           ' ' 'JUST'             'R',
           ' ' 'NO_ZERO'          'X',
           ' ' 'QFIELDNAME'       'AUSME',
           ' ' 'REF_FIELD'        'ENMNG',
           ' ' 'REF_TABLE'        'RESB',
           'E' 'OUTPUTLEN'        '17',

           'S' 'FIELDNAME'        'AUSME',
           ' ' 'COLTEXT'          '단위',
           ' ' 'JUST'             'C',
           ' ' 'REF_FIELD'        'AUSME',
           ' ' 'REF_TABLE'        'MARC',
           'E' 'OUTPUTLEN'        '03',

           'S' 'FIELDNAME'        'LOTNO',
           ' ' 'COLTEXT'          'Lot No.',
           ' ' 'JUST'             'C',
           ' ' 'NO_OUT'           'X',  "추가(SJM 25.03.31)
           'E' 'OUTPUTLEN'        '20',

           'S' 'FIELDNAME'        'CHARG',
           ' ' 'COLTEXT'          '뱃치번호',
           ' ' 'JUST'             'C',
           ' ' 'NO_OUT'           'X',  "추가(SJM 25.03.31)
           ' ' 'F4AVAILABL'       'X',
           'E' 'OUTPUTLEN'        '10',

           'S' 'FIELDNAME'        'TAGNR',
           ' ' 'COLTEXT'          '꼬리표번호',
           ' ' 'JUST'             'C',
*          ' ' 'NO_OUT'           'X',  "추가(SJM 25.03.31)->삭제(SJM 25.05.12)
           ' ' 'F4AVAILABL'       'X',
           'E' 'OUTPUTLEN'        '17',

           'S' 'FIELDNAME'        'LGORT',
           ' ' 'COLTEXT'          '저장위치',
           ' ' 'JUST'             'C',
           ' ' 'F4AVAILABL'       'X',
           ' ' 'REF_FIELD'        'LGORT',
           ' ' 'REF_TABLE'        'T001L',
           'E' 'OUTPUTLEN'        '04',

*(S)기능 추가 관련(SJM 25.03.18)
           'S' 'FIELDNAME'        'STATS',
           ' ' 'COLTEXT'          '승인상태',
           ' ' 'JUST'             'C',
           'E' 'OUTPUTLEN'        '4',

           'S' 'FIELDNAME'        'ZGUID',
           ' ' 'COLTEXT'          'ZGUID',
           ' ' 'JUST'             'L',
           ' ' 'NO_OUT'           'X',
           'E' 'OUTPUTLEN'        '32',
*(S)기능 추가 관련(SJM 25.03.18)

           'S' 'FIELDNAME'        'MBLNR',
           ' ' 'COLTEXT'          '자재문서',
           ' ' 'JUST'             'C',
           'E' 'OUTPUTLEN'        '10',

           'S' 'FIELDNAME'        'IV_NO',
           ' ' 'COLTEXT'          '통문번호',
           ' ' 'JUST'             'C',
           'E' 'OUTPUTLEN'        '10',

*           'S' 'FIELDNAME'        'IV_PRINT_YN',
*           ' ' 'COLTEXT'          '통문증발행',
*           ' ' 'JUST'             'C',
*           'E' 'OUTPUTLEN'        '10',
*
*           'S' 'FIELDNAME'        'MBLNR_F',
*           ' ' 'COLTEXT'          '이전전기',
*           ' ' 'JUST'             'C',
*           'E' 'OUTPUTLEN'        '08'.

           'S' 'FIELDNAME'        'FLAG1',
           ' ' 'COLTEXT'          '이전전기',
           ' ' 'JUST'             'C',
           ' ' 'ICON'             'X',
           'E' 'OUTPUTLEN'        '04',

           'S' 'FIELDNAME'        'FLAG2',
           ' ' 'COLTEXT'          '통문증발행',
           ' ' 'JUST'             'C',
           ' ' 'ICON'             'X',
           'E' 'OUTPUTLEN'        '04'.

ENDFORM.                    " set_field_catalogs_w2
*&---------------------------------------------------------------------*
*&      Form  set_cell_attribute_w1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_CELL_ATTRIBUTE_W1 .
*& 각 Cell의 특성 제어
  DATA : LT_CELLTAB  TYPE LVC_T_STYL,
         LT_COLOR    TYPE LVC_T_SCOL,
         LV_INDEX    TYPE I,
         LF_ATNEW(1).

  LOOP AT GT_MDSB_W1.
    CLEAR: LT_CELLTAB[], LT_COLOR[].

    LV_INDEX = SY-TABIX.

    PERFORM FILL_CELLTAB_W1 CHANGING LT_CELLTAB.
    PERFORM FILL_COLOR_W1   CHANGING LT_COLOR.

    CLEAR: GT_MDSB_W1-CELLTAB[], GT_MDSB_W1-F_COL[].

    INSERT LINES OF LT_CELLTAB INTO TABLE GT_MDSB_W1-CELLTAB.
    INSERT LINES OF LT_COLOR   INTO TABLE GT_MDSB_W1-F_COL.

    MODIFY GT_MDSB_W1. " INDEX lv_index.
    CLEAR  GT_MDSB_W1.

  ENDLOOP.

ENDFORM.                    " set_cell_attribute_w1
*&---------------------------------------------------------------------*
*&      Form  set_cell_attribute_w2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_CELL_ATTRIBUTE_W2 .
*& 각 Cell의 특성 제어
  DATA : LT_CELLTAB  TYPE LVC_T_STYL,
         LT_COLOR    TYPE LVC_T_SCOL,
         LV_INDEX    TYPE I,
         LF_ATNEW(1).

  LOOP AT GT_MDSB_W2.
    CLEAR: LT_CELLTAB[], LT_COLOR[].

    LV_INDEX = SY-TABIX.

    PERFORM FILL_CELLTAB_W2 CHANGING LT_CELLTAB.
    PERFORM FILL_COLOR_W2   CHANGING LT_COLOR.

    CLEAR: GT_MDSB_W2-CELLTAB[], GT_MDSB_W2-F_COL[].

    INSERT LINES OF LT_CELLTAB INTO TABLE GT_MDSB_W2-CELLTAB.
    INSERT LINES OF LT_COLOR   INTO TABLE GT_MDSB_W2-F_COL.

    MODIFY GT_MDSB_W2. " INDEX lv_index.
    CLEAR  GT_MDSB_W2.

  ENDLOOP.

ENDFORM.                    " set_cell_attribute_w2
*&---------------------------------------------------------------------*
*&      Form  fill_celltab_w1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LT_CELLTAB  text
*----------------------------------------------------------------------*
FORM FILL_CELLTAB_W1  CHANGING PT_CELLTAB TYPE LVC_T_STYL.

  DATA : LS_CELLTAB TYPE LVC_S_STYL,
         LV_MODE    TYPE RAW4.
  DATA : LS_FIELDCAT     TYPE LVC_S_FCAT.

  LOOP AT GT_FIELDCAT_W1  INTO LS_FIELDCAT.
    LS_CELLTAB-FIELDNAME = LS_FIELDCAT-FIELDNAME.
    CASE  LS_CELLTAB-FIELDNAME.
      WHEN 'MATNR' OR 'MATNR_C' OR 'EBELN'.
        LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED +
                           CL_GUI_ALV_GRID=>MC_STYLE_F4_NO.
        LS_CELLTAB-STYLE4 = CL_GUI_ALV_GRID=>MC_STYLE4_LINK.
        INSERT LS_CELLTAB INTO TABLE PT_CELLTAB.

      WHEN  OTHERS.
        LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED +
                           CL_GUI_ALV_GRID=>MC_STYLE_F4_NO.
        LS_CELLTAB-STYLE4 = CL_GUI_ALV_GRID=>MC_STYLE4_LINK_NO.
        INSERT LS_CELLTAB INTO TABLE PT_CELLTAB.

    ENDCASE.


  ENDLOOP.

ENDFORM.                    " fill_celltab_w1
*&---------------------------------------------------------------------*
*&      Form  fill_color_w1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LT_COLOR  text
*----------------------------------------------------------------------*
FORM FILL_COLOR_W1   CHANGING PT_COLOR TYPE LVC_T_SCOL.

  DATA : LS_CELLTAB TYPE LVC_S_STYL,
         LS_COLOR   TYPE LVC_S_SCOL,
         LV_MODE    TYPE RAW4.

  DATA : LS_FIELDCAT     TYPE LVC_S_FCAT.

  LOOP AT GT_FIELDCAT_W1 INTO LS_FIELDCAT.
    LS_COLOR-FNAME = LS_FIELDCAT-FIELDNAME.
    CASE LS_FIELDCAT-FIELDNAME.
      WHEN 'MATNR' OR 'EBELN' OR 'EBELP'.
        LS_COLOR-COLOR-COL = 1.
        LS_COLOR-COLOR-INT = 1.

      WHEN  OTHERS.
        LS_COLOR-COLOR-COL = 4.
        LS_COLOR-COLOR-INT = 0.

    ENDCASE.

    INSERT LS_COLOR INTO TABLE PT_COLOR.
  ENDLOOP.

ENDFORM.                    " fill_color_w1
*&---------------------------------------------------------------------*
*&      Form  fill_celltab_w2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LT_CELLTAB  text
*----------------------------------------------------------------------*
FORM FILL_CELLTAB_W2  CHANGING PT_CELLTAB TYPE LVC_T_STYL.

  DATA : LS_CELLTAB TYPE LVC_S_STYL,
         LV_MODE    TYPE RAW4.
  DATA : LS_FIELDCAT      TYPE LVC_S_FCAT.

  LOOP AT GT_FIELDCAT_W2  INTO LS_FIELDCAT.
    LS_CELLTAB-FIELDNAME = LS_FIELDCAT-FIELDNAME.

    CASE LS_FIELDCAT-FIELDNAME.
      WHEN 'CHECK'.
        LS_CELLTAB-STYLE = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
        INSERT LS_CELLTAB INTO TABLE PT_CELLTAB.

      WHEN 'ENMNG' OR 'LOTNO'.
        IF P_CANCEL = 'X' OR GT_MDSB_W2-MBLNR_F = 'X'
        OR ( GT_MDSB_W2-STATS = ICON_MAIL     "추가(SJM 25.03.18)
          OR GT_MDSB_W2-STATS = ICON_ALLOW ). "추가(SJM 25.03.18)
          LS_CELLTAB-STYLE  = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED +
                              CL_GUI_ALV_GRID=>MC_STYLE_F4_NO.
          LS_CELLTAB-STYLE4 = CL_GUI_ALV_GRID=>MC_STYLE4_LINK_NO.
          INSERT LS_CELLTAB INTO TABLE PT_CELLTAB.
        ELSE.
          LS_CELLTAB-STYLE  = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED.
          LS_CELLTAB-STYLE4 = CL_GUI_ALV_GRID=>MC_STYLE4_LINK_NO.
          INSERT LS_CELLTAB INTO TABLE PT_CELLTAB.
        ENDIF.

      WHEN 'LGORT' OR 'CHARG' OR 'TAGNR'.
        IF P_CANCEL = 'X' OR GT_MDSB_W2-MBLNR_F = 'X'
        OR ( GT_MDSB_W2-STATS = ICON_MAIL     "추가(SJM 25.03.18)
          OR GT_MDSB_W2-STATS = ICON_ALLOW ). "추가(SJM 25.03.18)
          LS_CELLTAB-STYLE  = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED +
                              CL_GUI_ALV_GRID=>MC_STYLE_F4_NO.
          LS_CELLTAB-STYLE4 = CL_GUI_ALV_GRID=>MC_STYLE4_LINK_NO.
          INSERT LS_CELLTAB INTO TABLE PT_CELLTAB.
        ELSE.
          LS_CELLTAB-STYLE  = CL_GUI_ALV_GRID=>MC_STYLE_ENABLED +
                              CL_GUI_ALV_GRID=>MC_STYLE_F4.
          LS_CELLTAB-STYLE4 = CL_GUI_ALV_GRID=>MC_STYLE4_LINK_NO.
          INSERT LS_CELLTAB INTO TABLE PT_CELLTAB.
        ENDIF.

      WHEN 'MATNR_C' OR 'LBLAB' OR 'LABST'.
        LS_CELLTAB-STYLE  = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED +
                            CL_GUI_ALV_GRID=>MC_STYLE_F4_NO.
        LS_CELLTAB-STYLE4 = CL_GUI_ALV_GRID=>MC_STYLE4_LINK.
        INSERT LS_CELLTAB INTO TABLE PT_CELLTAB.

      WHEN  OTHERS.
        LS_CELLTAB-STYLE  = CL_GUI_ALV_GRID=>MC_STYLE_DISABLED +
                            CL_GUI_ALV_GRID=>MC_STYLE_F4_NO.
        LS_CELLTAB-STYLE4 = CL_GUI_ALV_GRID=>MC_STYLE4_LINK_NO.
        INSERT LS_CELLTAB INTO TABLE PT_CELLTAB.

    ENDCASE.

  ENDLOOP.

ENDFORM.                    " fill_celltab_w2
*&---------------------------------------------------------------------*
*&      Form  fill_color_w2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LT_COLOR  text
*----------------------------------------------------------------------*
FORM FILL_COLOR_W2   CHANGING PT_COLOR TYPE LVC_T_SCOL.

  DATA : LS_CELLTAB TYPE LVC_S_STYL,
         LS_COLOR   TYPE LVC_S_SCOL,
         LV_MODE    TYPE RAW4.

  DATA : LS_FIELDCAT     TYPE LVC_S_FCAT.

  LOOP AT GT_FIELDCAT_W2 INTO LS_FIELDCAT.
    LS_COLOR-FNAME = LS_FIELDCAT-FIELDNAME.
    CASE LS_FIELDCAT-FIELDNAME.
      WHEN 'CHECK'.                                      "입력필드
        LS_COLOR-COLOR-COL = 0.
        LS_COLOR-COLOR-INT = 1.

      WHEN 'ENMNG' OR 'LOTNO' OR 'LGORT' OR 'CHARG' OR 'TAGNR'.
        IF P_CANCEL = 'X' OR GT_MDSB_W2-MBLNR_F = 'X'
        OR ( GT_MDSB_W2-STATS = ICON_MAIL     "추가(SJM 25.03.18)
          OR GT_MDSB_W2-STATS = ICON_ALLOW ). "추가(SJM 25.03.18)
          LS_COLOR-COLOR-COL = 4.
          LS_COLOR-COLOR-INT = 0.
        ELSE.
          LS_COLOR-COLOR-COL = 0.
          LS_COLOR-COLOR-INT = 1.
        ENDIF.

      WHEN 'MATNR_C'.                                    "KEY 필드
        LS_COLOR-COLOR-COL = 1.
        LS_COLOR-COLOR-INT = 1.

      WHEN  OTHERS.
        LS_COLOR-COLOR-COL = 4.
        LS_COLOR-COLOR-INT = 0.

    ENDCASE.

    INSERT LS_COLOR INTO TABLE PT_COLOR.
  ENDLOOP.

ENDFORM.                    " fill_color_w2
*&---------------------------------------------------------------------*
*&      Form  display_layout_attribute_w1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_LAYOCAT  text
*----------------------------------------------------------------------*
FORM DISPLAY_LAYOUT_ATTRIBUTE_W1  USING  PS_LAYOCAT TYPE LVC_S_LAYO.

*& General display options
  PS_LAYOCAT-CWIDTH_OPT = 'X'.
  PS_LAYOCAT-SEL_MODE   = 'D'.
*  ps_layocat-edit       = 'E'.
  PS_LAYOCAT-NO_ROWMARK = 'X'.           "선택버튼 비활성
  PS_LAYOCAT-STYLEFNAME = 'CELLTAB'.
  PS_LAYOCAT-CTAB_FNAME = 'F_COL'.
  PS_LAYOCAT-SMALLTITLE = 'X'.           "작은타이틀.

ENDFORM.                    " display_layout_attribute_w1
*&---------------------------------------------------------------------*
*&      Form  display_layout_attribute_w2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GS_LAYOCAT  text
*----------------------------------------------------------------------*
FORM DISPLAY_LAYOUT_ATTRIBUTE_W2  USING  PS_LAYOCAT TYPE LVC_S_LAYO.

*& General display options
  PS_LAYOCAT-CWIDTH_OPT = 'X'.
*  ps_layocat-sel_mode   = 'D'.
*  ps_layocat-edit       = 'E'.
  PS_LAYOCAT-NO_ROWMARK = 'X'.           "선택버튼 비활성
  PS_LAYOCAT-STYLEFNAME = 'CELLTAB'.
  PS_LAYOCAT-CTAB_FNAME = 'F_COL'.
  PS_LAYOCAT-SMALLTITLE = 'X'.           "작은타이틀.

ENDFORM.                    " display_layout_attribute_w2
*&---------------------------------------------------------------------*
*&      Form  alv_grid_display_w1
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ALV_GRID_DISPLAY_W1 .
  LCL_ALV_GRID=>F_ALV = '1'.

*& Display
  CALL METHOD GCL_GRID_W1->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOCAT_W1
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_W1
      I_SAVE               = 'A'   " 전체가능유형.
*                                       'U'   " 특정사용자전용.
*                                       'X'   " 광역 전용.
*                                       ' '   " 저장안함.
*     i_default            = 'X'   " 레이아웃 사전셋팅 허용.
*  LAYOUT   Standard   BCALV_GRID_09  참조.
*  is_variant 레이아웃선택/변경/저장/관리 enable
      IS_VARIANT           = ALV_VARIANT  " 선택 메뉴 display
    CHANGING
      IT_OUTTAB            = GT_MDSB_W1[]
      IT_SORT              = GT_SORT_W1
      IT_FIELDCATALOG      = GT_FIELDCAT_W1[].
  CALL METHOD GCL_GRID_W1->SET_ROW_RESIZE.

ENDFORM.                    " alv_grid_display_w1
*&---------------------------------------------------------------------*
*&      Form  alv_grid_display_w2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ALV_GRID_DISPLAY_W2 .
  LCL_ALV_GRID=>F_ALV = '1'.

*& Display
  CALL METHOD GCL_GRID_W2->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOCAT_W2
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_W2
      I_SAVE               = 'A'   " 전체가능유형.
*                                       'U'   " 특정사용자전용.
*                                       'X'   " 광역 전용.
*                                       ' '   " 저장안함.
*     i_default            = 'X'   " 레이아웃 사전셋팅 허용.
*  LAYOUT   Standard   BCALV_GRID_09  참조.
*  is_variant 레이아웃선택/변경/저장/관리 enable
      IS_VARIANT           = ALV_VARIANT  " 선택 메뉴 display
    CHANGING
      IT_OUTTAB            = GT_MDSB_W2[]
      IT_SORT              = GT_SORT_W2
      IT_FIELDCATALOG      = GT_FIELDCAT_W2[].
  CALL METHOD GCL_GRID_W2->SET_ROW_RESIZE.

ENDFORM.                    " alv_grid_display_w2

*&---------------------------------------------------------------------*
*&      Form  call_screen_0200
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CALL_SCREEN_0200 .
  DATA: LV_IV_NO LIKE ZLET0005-IV_NO,
        LV_MBLNR LIKE MKPF-MBLNR,
        LV_NOMNG LIKE RESB-NOMNG,
        LV_ENMNG LIKE RESB-ENMNG.

  REFRESH: GT_MDSB_L,  GT_MDSB_L3, GT_MDSB_W1,
           GT_MDSB_W2, GT_MDSB_W3, GT_LIFNR.
  CLEAR  : GT_MDSB_L,  GT_MDSB_L3, GT_MDSB_W1,
           GT_MDSB_W2, GT_MDSB_W3, GT_LIFNR.

*& 외주오더, 동일 업체만 가능...
  CLEAR GF_PSTYP.
  LOOP AT GT_EBAN WHERE CHECK = 'X'.
    IF GT_EBAN-PSTYP = '0'.
      GF_PSTYP = 'X'.
      EXIT.
    ENDIF.

    GT_LIFNR-LIFNR = GT_EBAN-LIFNR.
    COLLECT GT_LIFNR.  CLEAR GT_LIFNR.
  ENDLOOP.
  IF NOT GF_PSTYP IS INITIAL.
    MESSAGE S001 WITH '일반오더가 포함되어 있습니다.!!!'.
    EXIT.
  ENDIF.

  DESCRIBE TABLE GT_LIFNR LINES GV_DBCNT.
  IF GV_DBCNT > 1.
    MESSAGE S001 WITH '동일 업체가 아닙니다.!!!'.
    EXIT.
  ELSEIF GV_DBCNT < 1.
    MESSAGE S001 WITH '선택한 데이타가 없습니다.!!!'.
    EXIT.
  ENDIF.

  PERFORM SET_POX. "추가(SJM 25.05.13)

  CLEAR GV_SPART.
  LOOP AT GT_EBAN WHERE CHECK = 'X'.
    GV_SPART = GT_EBAN-SPART.

*& 사급자재 정보 발췌...
    CHECK NOT GT_EBAN-EBELN IS INITIAL.
    PERFORM SELECT_MDSB_PROC USING ''.   "구매오더 생성이 아닌경우

  ENDLOOP.

*& 길이관리...
  LOOP AT GT_MDSB_L3.
    "배치관리 자재(MARA-XCHPF='X')만 GT_MDSB_L에 담는다(SJM 25.03.27)
    " GT_MDSB_L 에 GT_MDSB_W2 데이터가 중복으로 남지 않도록..
    CHECK GT_MDSB_L3-XCHPF = GC_X.

    PERFORM RESET_L_LIST.     "추가(SJM 25.04.23)
    CHECK GV_RES IS INITIAL.  "추가(SJM 25.04.23)

    CLEAR : GT_MDSB_L.
    MOVE-CORRESPONDING GT_MDSB_L3 TO GT_MDSB_L.
    APPEND GT_MDSB_L.
  ENDLOOP.

  PERFORM ADD_POL. "추가(SJM 25.05.13)

  DATA(LT_W1) = GT_MDSB_W1[]. "추가(SJM 25.04.02)
  SORT LT_W1 BY MATNR_C.      "추가(SJM 25.04.02)

*& 중량관리...
  LOOP AT GT_MDSB_W3.
    PERFORM RESET_W3_QTY TABLES LT_W1. "추가(SJM 25.04.02)
    MOVE-CORRESPONDING GT_MDSB_W3 TO GT_MDSB_W2.


*& 이전전기 및 통문증 발행 여부...
    IF GT_MDSB_W3-MBLNR_F = 'X'.
      GT_MDSB_W2-FLAG1 = ICON_LED_GREEN.
    ELSE.
      CLEAR GT_MDSB_W2-FLAG1.
    ENDIF.

    IF GT_MDSB_W3-IV_PRINT_YN = 'X'.
      GT_MDSB_W2-FLAG2 = ICON_LED_GREEN.
    ELSE.
      CLEAR GT_MDSB_W2-FLAG2.
    ENDIF.

*& 단위 컨버젼...
    IF NOT GT_MDSB_W2-AUSME IS INITIAL.

      PERFORM MD_CONVERT_MATERIAL_UNIT USING GT_MDSB_W2-MATNR_C
                                             GT_MDSB_W2-MEINS
                                             GT_MDSB_W2-AUSME
                                    CHANGING GT_MDSB_W2-BDMNG_A.
    ENDIF.

*& 현재고(PLANT)...
    SELECT SUM( LABST ) INTO GT_MDSB_W2-LABST
                        FROM MARD
                       WHERE MATNR  =  GT_MDSB_W3-MATNR_C
                         AND WERKS  =  GT_MDSB_W3-WERKS.

*& SC업체 현재고...
    SELECT SUM( LBLAB ) INTO GT_MDSB_W2-LBLAB
                        FROM MSLB
                       WHERE MATNR  =  GT_MDSB_W3-MATNR_C
                         AND WERKS  =  GT_MDSB_W3-WERKS
                         AND SOBKZ  = 'O'
                         AND LIFNR  =  GT_MDSB_W3-LIFNR.
*& 업체불출량...
    IF NOT GT_MDSB_W3-MBLNR IS INITIAL.
      "(S)기존 로직 오류 수정(SJM 25.04.02)
      PERFORM SET_ENMNG.
*     CLEAR  ZPPT0018.
*     SELECT SINGLE ENMNG INTO GT_MDSB_W2-ENMNG
*              FROM ZPPT0018
*             WHERE MBLNR = GT_MDSB_W3-MBLNR
*               AND MJAHR = GT_MDSB_W3-MJAHR.
      "(E)기존 로직 오류 수정(SJM 25.04.02)
    ENDIF.

*& 예약수량 계산...
    CLEAR: LV_NOMNG, LV_ENMNG.
*&    IF NOT gt_mdsb_w1[] IS INITIAL.
    SELECT NOMNG ENMNG EBELN EBELP
      INTO (MDSB-NOMNG, MDSB-ENMNG, MDSB-EBELN, MDSB-EBELP)
      FROM MDSB
     WHERE MATNR = GT_MDSB_W3-MATNR_C
       AND WERKS = GT_MDSB_W3-WERKS
       AND XLOEK = SPACE
       AND POSTP = 'L'
       AND KZEAR <> 'X'.

*& 삭제, 납품완료 대상 구매오더 제외...
      CLEAR  EKPO.
      SELECT SINGLE LOEKZ ELIKZ
               INTO (EKPO-LOEKZ, EKPO-ELIKZ)
               FROM EKPO
              WHERE EBELN = MDSB-EBELN
                AND EBELP = MDSB-EBELP.
      IF EKPO-LOEKZ <> SPACE OR
         EKPO-ELIKZ <> SPACE.
        CLEAR: MDSB-NOMNG, MDSB-ENMNG.
      ENDIF.

      LV_NOMNG = LV_NOMNG + MDSB-NOMNG. "요청수량
      LV_ENMNG = LV_ENMNG + MDSB-ENMNG. "출고수량

    ENDSELECT.
*&    ENDIF.

    GT_MDSB_W2-RVMNG = LV_NOMNG - LV_ENMNG.


    APPEND  GT_MDSB_W2.        CLEAR GT_MDSB_W2.
  ENDLOOP.

*& 길이관리...
  SORT GT_MDSB_L BY IV_NO MBLNR.
  LV_IV_NO = 'ZZZZZZZZZZ'.
  LV_MBLNR = 'ZZZZZZZZZZ'.
  LOOP AT GT_MDSB_L.
    IF GT_MDSB_L-IV_NO IS INITIAL.
      IF GT_MDSB_L-MBLNR IS INITIAL.

      ELSE.
        IF GT_MDSB_L-MBLNR <> LV_MBLNR.
          LV_MBLNR = GT_MDSB_L-MBLNR.
        ELSE.
          GT_MDSB_L-CHECK = '-'.
        ENDIF.
      ENDIF.
    ELSE.
      IF GT_MDSB_L-IV_NO <> LV_IV_NO.
        LV_IV_NO = GT_MDSB_L-IV_NO.
      ELSE.
        GT_MDSB_L-CHECK = '-'.
      ENDIF.
    ENDIF.

**(S)기능 추가 관련(SJM 25.03.18) -> 위치 변경(SJM 25.04.23)
**   IF GT_MDSB_L-MBLNR IS INITIAL.
*    PERFORM SET_4114 USING GT_MDSB_L-EBELN
*                           GT_MDSB_L-EBELP
*                           GT_MDSB_L-MATNR_C 'L'
*                  CHANGING GT_MDSB_L.
**   ENDIF.
**(E)기능 추가 관련(SJM 25.03.18)

    MODIFY GT_MDSB_L.

  ENDLOOP.

  SORT GT_PO BY GUBUN EBELN EBELP MATNR TAGNR. "추가(SJM 25.05.12)

*& 중량관리...
* SORT GT_MDSB_W2 BY IV_NO MBLNR. "위치 변경(SJM 25.05.13)
* LV_IV_NO = 'ZZZZZZZZZZ'.
* LV_MBLNR = 'ZZZZZZZZZZ'.
  LOOP AT GT_MDSB_W2.
*   IF GT_MDSB_W2-IV_NO IS INITIAL.
*   ENDIF.

*(S)기능 추가 관련(SJM 25.03.18)
*   CHECK GT_MDSB_W2-MBLNR IS INITIAL.
    READ TABLE GT_MDSB_W1 WITH KEY WERKS   = GT_MDSB_W2-WERKS
                                   MATNR_C = GT_MDSB_W2-MATNR_C.

    CHECK SY-SUBRC = 0.

    PERFORM SET_4114 USING GT_MDSB_W1-EBELN
                           GT_MDSB_W1-EBELP
                           GT_MDSB_W1-MATNR_C
                           GT_MDSB_W2-TAGNR   'W'
                  CHANGING GT_MDSB_W2.
*(E)기능 추가 관련(SJM 25.03.18)

    MODIFY GT_MDSB_W2.
  ENDLOOP.
  SORT GT_MDSB_W2 BY IV_NO MBLNR. "위치 변경(SJM 25.05.13)

  IF GT_MDSB_L[]  IS INITIAL AND
     GT_MDSB_W2[] IS INITIAL.
    MESSAGE S004 WITH '해당 구성부품 자료가 없습니다.!!!'.
  ELSE.
    CALL SCREEN 0200.
  ENDIF.
ENDFORM.                    " call_screen_0200
*&---------------------------------------------------------------------*
*&      Form  select_mdsb_proc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SELECT_MDSB_PROC USING PV_FLAG.

  DATA : LV_XCHPF LIKE  MARA-XCHPF,
         LV_CHECK TYPE  CHAR1.

  "배치 기준 변경[MARA-XCHPF -> MARC-XCHPF](SJM 25.05.12)
  SELECT SINGLE XCHPF INTO LV_XCHPF
    FROM MDSB AS A INNER JOIN MARC AS B
                           ON A~MATNR = B~MATNR
                          AND B~WERKS = P_WERKS
*   FROM MDSB AS A INNER JOIN MARA AS B
*                          ON A~MATNR = B~MATNR
     WHERE A~EBELN = GT_EBAN-EBELN
       AND A~EBELP = GT_EBAN-EBELP
       AND B~XCHPF = 'X'.            "뱃치관리

*(S)기능 추가 관련(SJM 25.03.27) 길이/중량을 나누는 기준은 MARA-XCHPF 로만!
* IF LV_XCHPF ='X' AND NOT ( GT_EBAN-MATKL CP 'HXX-BWD++' OR
*                            GT_EBAN-MATKL EQ 'HXX-DSCR'  OR
*                            GT_EBAN-MATKL CP 'HBC-SCR++' OR
*                            GT_EBAN-MEINS_A EQ 'KG' OR
*                            GT_EBAN-MEINS_A EQ 'G' ).
  IF LV_XCHPF ='X'.
*(E)기능 추가 관련(SJM 25.03.27)

    SELECT A~WERKS A~MATNR AS MATNR_C A~ERFMG A~BDMNG
           A~BDMNG AS ENMNG
           A~POSNR A~SERNR A~ERFME
           B~MEINS B~MATKL C~XCHPF "기준 변경(SJM 25.06.05) B~XCHPF
           C~AUSME
           D~EBELN D~EBELP D~MENGE
           E~MAKTX AS MAKTX_C
      INTO CORRESPONDING FIELDS OF TABLE GT_MDSB_L3A
      FROM MDSB AS A INNER JOIN MARA AS B
                             ON A~MATNR = B~MATNR
                     INNER JOIN MARC AS C
                             ON A~MATNR = C~MATNR AND
                                A~WERKS = C~WERKS
                     INNER JOIN EKPO AS D
                             ON A~EBELN = D~EBELN AND
                                A~EBELP = D~EBELP
                     INNER JOIN MAKT AS E
                             ON A~MATNR = E~MATNR
     WHERE A~EBELN = GT_EBAN-EBELN
       AND A~EBELP = GT_EBAN-EBELP
       AND E~SPRAS = SY-LANGU
     ORDER BY A~BDMNG.
*소요수량 enmng,출고수량 bdmng
    SELECT F~ENMNG AS BDMNG F~BDMNG AS ENMNG F~CHARG F~TAGNR
           F~LOTNO F~LGORT F~EBELN F~EBELP
           F~MBLNR F~MJAHR F~MBLNR_F F~POSNR F~MATNR AS MATNR_C
     INTO CORRESPONDING FIELDS OF TABLE GT_MDSB_L3T
     FROM ZPPT0018 AS F INNER JOIN MARA AS B
                                ON F~MATNR = B~MATNR
                        INNER JOIN MARC AS C
                                ON F~MATNR = C~MATNR AND
                                   F~PSWRK = C~WERKS
                        INNER JOIN EKPO AS D
                                ON F~EBELN = D~EBELN AND
                                   F~EBELP = D~EBELP
                        INNER JOIN MAKT AS E
                                ON F~MATNR = E~MATNR
    WHERE F~PSWRK = P_WERKS
      AND F~EBELN = GT_EBAN-EBELN
      AND F~EBELP = GT_EBAN-EBELP
      AND F~MBLNR_F = 'X'
      AND E~SPRAS = SY-LANGU.

    LOOP AT GT_MDSB_L3A.
*& 출고수량(enmng) <-> 소요수량(bdmng)
      CLEAR LV_CHECK.
      CLEAR : GT_MDSB_L3. "기존 로직 오류 수정(SJM 25.04.02)

*                                posnr   = gt_mdsb_l3a-posnr   AND
*                                bdmng   = gt_mdsb_l3a-bdmng   AND
      LOOP AT GT_MDSB_L3T WHERE MATNR_C = GT_MDSB_L3A-MATNR_C AND
                                EBELN   = GT_MDSB_L3A-EBELN   AND
                                EBELP   = GT_MDSB_L3A-EBELP   AND
                                CHECK   <> 'X'.

*(S)기능 추가 관련(SJM 25.03.27)
        IF GT_MDSB_L3A-XCHPF = GC_X
       AND GT_MDSB_L3A-POSNR <> GT_MDSB_L3T-POSNR.
          CONTINUE.
        ENDIF.
*(E)기능 추가 관련(SJM 25.03.27)

        GT_MDSB_L3-WERKS   = GT_MDSB_L3A-WERKS.
        GT_MDSB_L3-MATNR_C = GT_MDSB_L3A-MATNR_C.
        GT_MDSB_L3-ERFMG   = GT_MDSB_L3A-ERFMG.
        GT_MDSB_L3-POSNR   = GT_MDSB_L3A-POSNR.
        GT_MDSB_L3-SERNR   = GT_MDSB_L3A-SERNR.
        GT_MDSB_L3-ERFME   = GT_MDSB_L3A-ERFME.
        GT_MDSB_L3-MEINS   = GT_MDSB_L3A-MEINS.
        GT_MDSB_L3-MATKL   = GT_MDSB_L3A-MATKL.
        GT_MDSB_L3-XCHPF   = GT_MDSB_L3A-XCHPF.
        GT_MDSB_L3-AUSME   = GT_MDSB_L3A-AUSME.
        GT_MDSB_L3-EBELN   = GT_MDSB_L3A-EBELN.
        GT_MDSB_L3-EBELP   = GT_MDSB_L3A-EBELP.
        GT_MDSB_L3-MENGE   = GT_MDSB_L3A-MENGE.
        GT_MDSB_L3-MAKTX_C = GT_MDSB_L3A-MAKTX_C.
        GT_MDSB_L3-ENMNG   = GT_MDSB_L3T-BDMNG.
        GT_MDSB_L3-BDMNG   = GT_MDSB_L3T-ENMNG.
        GT_MDSB_L3-CHARG   = GT_MDSB_L3T-CHARG.
        GT_MDSB_L3-TAGNR   = GT_MDSB_L3T-TAGNR.
        GT_MDSB_L3-LOTNO   = GT_MDSB_L3T-LOTNO.
        GT_MDSB_L3-LGORT   = GT_MDSB_L3T-LGORT.
        GT_MDSB_L3-MBLNR   = GT_MDSB_L3T-MBLNR.
        GT_MDSB_L3-MJAHR   = GT_MDSB_L3T-MJAHR.
        GT_MDSB_L3-MBLNR_F = GT_MDSB_L3T-MBLNR_F.
        GT_MDSB_L3-MATNR_C = GT_MDSB_L3T-MATNR_C.

        GT_MDSB_L3T-CHECK ='X'.
        LV_CHECK = 'X'.
        MODIFY GT_MDSB_L3T.
        APPEND GT_MDSB_L3. CLEAR GT_MDSB_L3.
        CLEAR GT_MDSB_L3T.

      ENDLOOP.

      IF LV_CHECK <> 'X'.
        GT_MDSB_L3-WERKS   = GT_MDSB_L3A-WERKS.
        GT_MDSB_L3-MATNR_C = GT_MDSB_L3A-MATNR_C.
        GT_MDSB_L3-ERFMG   = GT_MDSB_L3A-ERFMG.
        GT_MDSB_L3-BDMNG   = GT_MDSB_L3A-BDMNG.
        GT_MDSB_L3-ENMNG   = GT_MDSB_L3A-BDMNG.
        GT_MDSB_L3-POSNR   = GT_MDSB_L3A-POSNR.
        GT_MDSB_L3-SERNR   = GT_MDSB_L3A-SERNR.
        GT_MDSB_L3-ERFME   = GT_MDSB_L3A-ERFME.
        GT_MDSB_L3-MEINS   = GT_MDSB_L3A-MEINS.
        GT_MDSB_L3-MATKL   = GT_MDSB_L3A-MATKL.
        GT_MDSB_L3-XCHPF   = GT_MDSB_L3A-XCHPF.
        GT_MDSB_L3-AUSME   = GT_MDSB_L3A-AUSME.
        GT_MDSB_L3-EBELN   = GT_MDSB_L3A-EBELN.
        GT_MDSB_L3-EBELP   = GT_MDSB_L3A-EBELP.
        GT_MDSB_L3-MENGE   = GT_MDSB_L3A-MENGE.
        GT_MDSB_L3-MAKTX_C = GT_MDSB_L3A-MAKTX_C.

        APPEND GT_MDSB_L3. CLEAR GT_MDSB_L3.

      ENDIF.

      CLEAR GT_MDSB_L3T.
    ENDLOOP.


*    IF gt_eban-flag1 = ' '.  "이전전기 미실시
*
*      SELECT a~werks a~matnr AS matnr_c a~erfmg a~bdmng
*             a~bdmng AS enmng
*           a~posnr a~sernr a~erfme
*           b~meins b~matkl b~xchpf
*           c~ausme
*           d~ebeln d~ebelp d~menge
*           e~maktx AS maktx_c
*      INTO CORRESPONDING FIELDS OF TABLE gt_mdsb_l3
*      FROM mdsb AS a INNER JOIN mara AS b
*                             ON a~matnr = b~matnr
*                     INNER JOIN marc AS c
*                             ON a~matnr = c~matnr AND
*                                a~werks = c~werks
*                     INNER JOIN ekpo AS d
*                             ON a~ebeln = d~ebeln AND
*                                a~ebelp = d~ebelp
*                     INNER JOIN makt AS e
*                             ON a~matnr = e~matnr
*     WHERE a~ebeln = gt_eban-ebeln
*       AND a~ebelp = gt_eban-ebelp
*       AND e~spras = sy-langu.
*
*    ELSE.
*      SELECT f~pswrk AS werks f~matnr AS matnr_c f~enmng AS erfmg
*             f~bdmng f~posnr f~sernr f~meins AS erfme
*           b~meins b~matkl b~xchpf
*           c~ausme
*           d~ebeln d~ebelp d~menge
*           e~maktx AS maktx_c
*           f~enmng f~charg f~tagnr f~lotno f~lgort
*           f~mblnr f~mjahr f~mblnr_f
*      INTO CORRESPONDING FIELDS OF TABLE gt_mdsb_l3
*      FROM zppt0018 AS f INNER JOIN mara AS b
*                                 ON f~matnr = b~matnr
*                         INNER JOIN marc AS c
*                                 ON f~matnr = c~matnr AND
*                                    f~pswrk = c~werks
*                         INNER JOIN ekpo AS d
*                                 ON f~ebeln = d~ebeln AND
*                                    f~ebelp = d~ebelp
*                         INNER JOIN makt AS e
*                                 ON f~matnr = e~matnr
*     WHERE f~pswrk = p_werks
*       AND f~ebeln = gt_eban-ebeln
*       AND f~ebelp = gt_eban-ebelp
*       AND f~mblnr_f = 'X'
*       AND e~spras = sy-langu.
*
*    ENDIF.

  ELSE.
    SELECT A~WERKS A~MATNR AS MATNR_C A~ERFMG A~BDMNG
           A~POSNR A~SERNR A~ERFME
           B~MEINS B~MATKL C~XCHPF "기준 변경(SJM 25.06.05) B~XCHPF
           C~AUSME
           D~EBELN D~EBELP D~MENGE
           E~MAKTX AS MAKTX_C
           F~BDMNG AS ENMNG F~CHARG F~TAGNR F~LOTNO F~LGORT
           F~MBLNR F~MJAHR F~MBLNR_F
 APPENDING CORRESPONDING FIELDS OF TABLE GT_MDSB_L3 "변경(25.03.26)
*     INTO CORRESPONDING FIELDS OF TABLE GT_MDSB_L3
      FROM MDSB AS A INNER JOIN MARA AS B
                             ON A~MATNR = B~MATNR
                     INNER JOIN MARC AS C
                             ON A~MATNR = C~MATNR AND
                                A~WERKS = C~WERKS
                     INNER JOIN EKPO AS D
                             ON A~EBELN = D~EBELN AND
                                A~EBELP = D~EBELP
                     INNER JOIN MAKT AS E
                             ON A~MATNR = E~MATNR
                LEFT OUTER JOIN ZPPT0018 AS F
                             ON A~WERKS   = F~PSWRK AND
                                A~EBELN   = F~EBELN AND
                                A~EBELP   = F~EBELP AND
                                A~MATNR   = F~MATNR AND
                                F~MBLNR_F = 'X'

     WHERE A~EBELN = GT_EBAN-EBELN
       AND A~EBELP = GT_EBAN-EBELP
       AND E~SPRAS = SY-LANGU.

  ENDIF.

  LOOP AT GT_MDSB_L3 WHERE EBELN = GT_EBAN-EBELN
                       AND EBELP = GT_EBAN-EBELP.

    MOVE: GT_EBAN-MATNR    TO GT_MDSB_L3-MATNR,
          GT_EBAN-LIFNR    TO GT_MDSB_L3-LIFNR,
          GT_EBAN-BSART    TO GT_MDSB_L3-BSART,
          GT_EBAN-BSTYP    TO GT_MDSB_L3-BSTYP.

*& 출고단위 체크...
    IF GT_MDSB_L3-AUSME IS INITIAL.
      GT_MDSB_L3-AUSME = GT_MDSB_L3-MEINS.
    ENDIF.

    IF NOT GT_MDSB_L3-MBLNR IS INITIAL.
*       gt_mdsb_l3-bdmng = gt_mdsb_l3-enmng. "소요수량과 출고수량이 바뀜

*& 자재문서 정보...
      CLEAR  MKPF.
      SELECT SINGLE BUDAT CPUDT
               INTO CORRESPONDING FIELDS OF GT_MDSB_L3
               FROM MKPF
              WHERE MBLNR = GT_MDSB_L3-MBLNR
                AND MJAHR = GT_MDSB_L3-MJAHR.

*& 통문 정보...
      SELECT SINGLE B~IV_PRINT_YN B~OUT_YN B~IV_NO B~IV_DATE
               INTO CORRESPONDING FIELDS OF GT_MDSB_L3
               FROM ZLET0006 AS A  INNER JOIN ZLET0005 AS B
                                      ON A~IV_NO = B~IV_NO
              WHERE A~MBLNR        = GT_MDSB_L3-MBLNR
                AND A~MJAHR        = GT_MDSB_L3-MJAHR
                AND A~MATNR        = GT_MDSB_L3-MATNR_C
                AND B~IV_CANCEL_YN = SPACE.
      IF SY-SUBRC <> 0.
        CLEAR: GT_MDSB_L3-IV_PRINT_YN, GT_MDSB_L3-OUT_YN.
*& 통문증 미발행 때문에 CBO테이블을 한번더 체크...
        SELECT SINGLE OUTPR_F INTO GT_MDSB_L3-IV_PRINT_YN
                 FROM *ZPPT0018
                WHERE MBLNR = GT_MDSB_L3-MBLNR
                  AND MJAHR = GT_MDSB_L3-MJAHR.
      ENDIF.
    ENDIF.

*& 이전전기 및 통문증 발행 여부...
    IF GT_MDSB_L3-MBLNR_F = 'X'.
      GT_MDSB_L3-FLAG1 = ICON_LED_GREEN.
    ELSE.
      CLEAR GT_MDSB_L3-FLAG1.
    ENDIF.

    IF GT_MDSB_L3-IV_PRINT_YN = 'X'.
      GT_MDSB_L3-FLAG2 = ICON_LED_GREEN.
    ELSE.
      CLEAR GT_MDSB_L3-FLAG2.
    ENDIF.

    MOVE-CORRESPONDING GT_MDSB_L3 TO: GT_MDSB_W1,
                                      GT_MDSB_W3.

    IF PV_FLAG = 'PO'.  "구매오더 생성시
      GT_MDSB_W1-ERFMG_A = GT_MDSB_W1-ERFMG + ( GT_MDSB_W1-ERFMG *
                         ( GT_EBAN-LOSSR / 100 ) ).
      GT_MDSB_W3-ERFMG_A = GT_MDSB_W1-ERFMG + ( GT_MDSB_W1-ERFMG *
                         ( GT_EBAN-LOSSR / 100 ) ).

      GT_MDSB_W1-BDMNG_A = GT_MDSB_W1-BDMNG + ( GT_MDSB_W1-BDMNG *
                         ( GT_EBAN-LOSSR / 100 ) ).
      GT_MDSB_W3-BDMNG_A = GT_MDSB_W1-BDMNG + ( GT_MDSB_W1-BDMNG *
                         ( GT_EBAN-LOSSR / 100 ) ).
    ELSE.
      GT_MDSB_W1-ERFMG_A = GT_MDSB_W1-ERFMG.
      GT_MDSB_W3-ERFMG_A = GT_MDSB_W1-ERFMG.

      GT_MDSB_W1-BDMNG_A = GT_MDSB_W1-BDMNG.
      GT_MDSB_W3-BDMNG_A = GT_MDSB_W1-BDMNG.
    ENDIF.

*& 단위 컨버젼...
*    PERFORM md_convert_material_unit USING gt_mdsb_w2-matnr_c
*                                           gt_mdsb_w2-meins
*                                           gt_mdsb_w2-ausme
*                                  CHANGING gt_mdsb_w2-erfmg.


*& 뱃치관리를 하는 자재중
*& 1) 선재(8SQ이하)의 경우 중량관리 사급자재로 표시
*& 2) 권선 SCR의 경우 중량관리 사급자재로 표시
    CASE GT_MDSB_L3-XCHPF.
      WHEN 'X'. "길이관리
*(S)기능 추가 관련(SJM 25.03.27) 길이/중량을 나누는 기준은 MARA-XCHPF 로만!
        MODIFY GT_MDSB_L3.
*       IF GT_MDSB_L3-MATKL CP 'HXX-BWD++' OR  "중량관리로 이동
*          GT_MDSB_L3-MATKL EQ 'HXX-DSCR'  OR
*          GT_MDSB_L3-MATKL CP 'HBC-SCR++' OR
*          GT_MDSB_L3-MEINS EQ 'KG'        OR
*          GT_MDSB_L3-MEINS EQ 'G'.
*
*         APPEND  GT_MDSB_W1.   CLEAR GT_MDSB_W1.
*         COLLECT GT_MDSB_W3.   CLEAR GT_MDSB_W3.
*         MODIFY  GT_MDSB_L3.   CLEAR GT_MDSB_L3.
*       ELSE.
*         MODIFY  GT_MDSB_L3.   CLEAR GT_MDSB_L3.
*       ENDIF.
*(E)기능 추가 관련(SJM 25.03.27)

      WHEN ' '. "중량관리
*(S)배치 미관리 자재 꼬리표 쪼개짐 Case 추가(SJM 25.05.12)
        PERFORM SET_WX_LIST.
*       APPEND GT_MDSB_W1.  CLEAR : GT_MDSB_W1.
*       COLLECT GT_MDSB_W3. CLEAR : GT_MDSB_W3.
*(E)배치 미관리 자재 꼬리표 쪼개짐 Case 추가(SJM 25.05.12)

      WHEN  OTHERS.
        CLEAR : GT_MDSB_L3, GT_MDSB_W1, GT_MDSB_W2, GT_MDSB_W3.

    ENDCASE.

  ENDLOOP.

*& 중량관리 사급자재의 경우, 중복 구매오더 삭제...
  SORT GT_MDSB_W1 BY EBELN EBELP MATNR_C.
  DELETE ADJACENT DUPLICATES FROM GT_MDSB_W1
                        COMPARING EBELN EBELP MATNR_C.

*(S)배치 미관리 자재 꼬리표 쪼개짐 Case 추가(SJM 25.05.12)
  SORT GT_MDSB_W3 BY WERKS LGORT MATNR_C TAGNR.
  DELETE ADJACENT DUPLICATES FROM GT_MDSB_W3
                        COMPARING WERKS LGORT MATNR_C TAGNR.
*(E)배치 미관리 자재 꼬리표 쪼개짐 Case 추가(SJM 25.05.12)

ENDFORM.                    " select_mdsb_proc
*&---------------------------------------------------------------------*
*&      Form  exit_program
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM EXIT_PROGRAM .
  CASE SY-DYNNR.
    WHEN '0100'.
      CALL METHOD GCL_CUSTOM_CONTAINER->FREE.
      CALL METHOD CL_GUI_CFW=>FLUSH.
      CLEAR: GCL_CUSTOM_CONTAINER.

    WHEN '0200'.
      CALL METHOD GCL_CUSTOM_CONTAINER1->FREE.
      CALL METHOD CL_GUI_CFW=>FLUSH.
      CLEAR: GCL_CUSTOM_CONTAINER1.

    WHEN  OTHERS.
  ENDCASE.
ENDFORM.                    " exit_program
*&---------------------------------------------------------------------*
*&      Form  data_input_error
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_RR_DATA_CHANGED  text
*      -->P_LS_MOD_CELLS  text
*      -->P_1804   text
*      -->P_1805   text
*      -->P_LS_MOD_CELLS_FIELDNAME  text
*----------------------------------------------------------------------*
FORM DATA_INPUT_ERROR USING RR_DATA_CHANGED TYPE REF TO
                                         CL_ALV_CHANGED_DATA_PROTOCOL
                            PS_MOD_CELLS    TYPE LVC_S_MODI
                            PV_MSGTY
                            PV_MSGV1
                            PV_FIELDNAME.
* Error Message Display
  CALL METHOD RR_DATA_CHANGED->ADD_PROTOCOL_ENTRY
    EXPORTING
      I_MSGID     = '0K'
      I_MSGNO     = '000'
      I_MSGTY     = PV_MSGTY
      I_MSGV1     = PV_MSGV1
      I_MSGV2     = ''
      I_MSGV3     = ''
      I_FIELDNAME = PV_FIELDNAME
      I_ROW_ID    = PS_MOD_CELLS-ROW_ID.

ENDFORM.                    " data_input_error
*&---------------------------------------------------------------------*
*&      Form  get_tag_number
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LS_MOD_CELLS_VALUE  text
*      <--P_LV_TAGNR  text
*----------------------------------------------------------------------*
FORM GET_TAG_NUMBER  USING    PV_VALUE
                     CHANGING PV_TAGNR
                              PV_BDMNG.
  CLEAR  ZPPT0001.
  SELECT SINGLE TAGNR REMAIN
           INTO (PV_TAGNR,  PV_BDMNG)
           FROM ZPPT0001
          WHERE CHARG = PV_VALUE.
ENDFORM.                    " get_tag_number
*&---------------------------------------------------------------------*
*&      Form  onf4_proc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_FIELDNAME  text
*      -->P_E_FIELDVALUE  text
*      -->P_ES_ROW_NO  text
*      -->P_ER_EVENT_DATA  text
*      -->P_ET_BAD_CELLS  text
*      -->P_E_DISPLAY  text
*----------------------------------------------------------------------*
FORM ONF4_PROC USING PV_FIELDNAME  TYPE LVC_FNAME
                     PV_FIELDVALUE TYPE LVC_VALUE
                     PS_ROW_NO     TYPE LVC_S_ROID
                     PR_EVENT_DATA TYPE REF TO CL_ALV_EVENT_DATA
                     PT_BAD_CELLS  TYPE LVC_T_MODI
                     PV_DISPLAY    TYPE CHAR01.

  FIELD-SYMBOLS <MODI>             TYPE LVC_T_MODI.
  DATA: LS_MODI  TYPE LVC_S_MODI,
        LV_VALUE TYPE STRING,
        LV_MODE.

  IF PV_DISPLAY = 'X'.
    LV_MODE = 'D'.
  ENDIF.

  READ TABLE GT_EBAN INDEX PS_ROW_NO-ROW_ID.
  CHECK SY-SUBRC = 0.

  CASE PV_FIELDNAME.
    WHEN 'EPSTP'.
      CALL FUNCTION 'HELP_VALUES_EPSTP'
        EXPORTING
          PROGRAM   = SY-CPROG
          DYNNR     = SY-DYNNR
          FIELDNAME = 'GT_EBAN-EPSTP'
          BSART     = GT_EBAN-BSART
          BSTYP     = GT_EBAN-BSTYP
          MODE      = LV_MODE
        IMPORTING
          EPSTP     = GT_EBAN-EPSTP
        EXCEPTIONS
          OTHERS    = 1.

      IF SY-SUBRC = 0 AND PV_DISPLAY IS INITIAL.
        ASSIGN PR_EVENT_DATA->M_DATA->* TO <MODI>.
        LS_MODI-ROW_ID    = PS_ROW_NO-ROW_ID.
        LS_MODI-FIELDNAME = PV_FIELDNAME.
        LS_MODI-VALUE     = GT_EBAN-EPSTP.
        APPEND LS_MODI   TO <MODI>.
      ENDIF.

    WHEN 'PACKING_CAT'.
      CALL FUNCTION 'Z_ED_CHARACTER_VALUE_F4'
        EXPORTING
          I_TYPE      = 'C'
          DYNPPROG    = SY-REPID
          DYNPNR      = SY-DYNNR
          DYNPROFIELD = SPACE
          CHARACTNAME = 'SAP_MILLCA_PACKAGING_CAT' "포장재유형
        IMPORTING
*&          e_value     = p_value
          E_TEXT      = GT_EBAN-PACKING_CAT.


      IF SY-SUBRC = 0 AND PV_DISPLAY IS INITIAL.
        ASSIGN PR_EVENT_DATA->M_DATA->* TO <MODI>.
        LS_MODI-ROW_ID    = PS_ROW_NO-ROW_ID.
        LS_MODI-FIELDNAME = PV_FIELDNAME.
        LS_MODI-VALUE     = GT_EBAN-PACKING_CAT.
        APPEND LS_MODI   TO <MODI>.
      ENDIF.

    WHEN 'ZCERTI'.
      PERFORM SEARCH_HELP_FOR_ZCERTI CHANGING GT_EBAN-ZCERTI.

      IF NOT GT_EBAN IS INITIAL AND
             PV_DISPLAY    IS INITIAL.

        ASSIGN PR_EVENT_DATA->M_DATA->* TO <MODI>.
        LS_MODI-ROW_ID    = PS_ROW_NO-ROW_ID.
        LS_MODI-FIELDNAME = PV_FIELDNAME.
        LS_MODI-VALUE     = GT_EBAN-ZCERTI.
        APPEND LS_MODI   TO <MODI>.
      ENDIF.

    WHEN  OTHERS.
  ENDCASE.

  PR_EVENT_DATA->M_EVENT_HANDLED = 'X'.

ENDFORM.                                                    " onf4_proc
*&---------------------------------------------------------------------*
*&      Form  setting_bdc_parameters
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SETTING_BDC_PARAMETERS .
  CLEAR: GS_BDCPARAMS.

  GS_BDCPARAMS-DISMODE  = 'N'.   " 처리모드
  GS_BDCPARAMS-UPDMODE  = 'S'.   " 갱신세션
  GS_BDCPARAMS-CATTMODE = 'A'.   " CATT모드
  GS_BDCPARAMS-DEFSIZE  = ' '.   " 기본화면
  GS_BDCPARAMS-RACOMMIT = 'X'.   " COMMIT 이후 지속
  GS_BDCPARAMS-NOBINPT  = ' '.   " BI 세션

ENDFORM.                    " setting_bdc_parameters
*&---------------------------------------------------------------------*
*&      Form  bapi_purchase_order_create
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM BAPI_PURCHASE_ORDER_CREATE .
  DATA: LV_EKGRP LIKE EBAN-EKGRP,        "구매그룹
        LV_EKORG.

  REFRESH: GT_BAPI_TEXTHEADER,
           GT_BAPI_PARTNER,
           GT_BAPI_ITEM,
           GT_BAPI_ITEMX,
           GT_BAPI_SCHEDULE,
           GT_BAPI_SCHEDULEX,
           GT_BAPI_ACCOUNT,
           GT_BAPI_ACCOUNTX,
           GT_BAPI_EXPIMPITEM,
           GT_BAPI_EXPIMPITEMX,
           GT_BAPI_TEXTITEM,
           GT_BAPI_COND,
           GT_BAPI_CONDX,
           GT_BAPI_EXTENSIONIN,
           GT_BAPI_EXTENSIONOUT,
           GT_RET2.

  CLEAR:   GT_BAPI_TEXTHEADER,
           GT_BAPI_PARTNER,
           GT_BAPI_ITEM,
           GT_BAPI_ITEMX,
           GT_BAPI_SCHEDULE,
           GT_BAPI_SCHEDULEX,
           GT_BAPI_ACCOUNT,
           GT_BAPI_ACCOUNTX,
           GT_BAPI_EXPIMPITEM,
           GT_BAPI_EXPIMPITEMX,
           GT_BAPI_TEXTITEM,
           GT_BAPI_COND,
           GT_BAPI_CONDX,
           GT_BAPI_EXTENSIONIN,
           GT_BAPI_EXTENSIONOUT,
           GT_RET2.

  CLEAR:   GS_BAPI_HEADER,
           GS_BAPI_HEADERX,
           GS_BAPI_VENDOR,
           GS_BAPI_EXPIMPHEADER,
           GS_BAPI_EXPIMPHEADERX,
           LV_EKORG.

*& 구매그룹을 Info Record에서 가져온다...
  CLEAR  LV_EKGRP.
  SELECT SINGLE B~EKGRP INTO LV_EKGRP
           FROM EINA AS A INNER JOIN EINE AS B
                                  ON A~INFNR = B~INFNR
          WHERE A~LIFNR = GT_EBAN-LIFNR
            AND A~MATNR = GT_EBAN-MATNR.


*& P/O Header 구성...
*  GS_BAPI_HEADER-COMP_CODE        = '1000'.           "회사코드
  GS_BAPI_HEADER-COMP_CODE        =  GT_EBAN-BUKRS.    "회사코드

  GS_BAPI_HEADER-DOC_TYPE         = 'NB'.             "구매문서유형
  GS_BAPI_HEADER-CREAT_DATE       =  SY-DATUM.        "레코드생성일
  GS_BAPI_HEADER-CREATED_BY       =  SY-UNAME.  "오브젝트 생성인 이름
  GS_BAPI_HEADER-ITEM_INTVL       = '00010'.          "품목번호간격
  GS_BAPI_HEADER-LANGU            =  SY-LANGU.        "언어 키
*  GS_BAPI_HEADER-PURCH_ORG        = '1100'.           "구매조직
  GS_BAPI_HEADER-PURCH_ORG        =  GT_EBAN-EKORG.         "구매조직

  GS_BAPI_HEADER-PUR_GROUP        =  LV_EKGRP.        "구매그룹
  GS_BAPI_HEADER-DOC_DATE         =  SY-DATUM.        "구매증빙일
  GS_BAPI_HEADER-VENDOR           =  GT_EBAN-LIFNR.   "공급업체

*& P/O Header(변경툴바) 구성...
  GS_BAPI_HEADERX-COMP_CODE       = 'X'.              "회사코드
  GS_BAPI_HEADERX-DOC_TYPE        = 'X'.              "구매문서유형
  GS_BAPI_HEADERX-CREAT_DATE      = 'X'.              "레코드생성일
  GS_BAPI_HEADERX-CREATED_BY      = 'X'.     "오브젝트 생성인 이름
  GS_BAPI_HEADERX-ITEM_INTVL      = 'X'.              "품목번호간격
  GS_BAPI_HEADERX-LANGU           = 'X'.              "언어 키
  GS_BAPI_HEADERX-PURCH_ORG       = 'X'.              "구매조직
  GS_BAPI_HEADERX-PUR_GROUP       = 'X'.              "구매그룹
  GS_BAPI_HEADERX-DOC_DATE        = 'X'.              "구매증빙일
  GS_BAPI_HEADERX-VENDOR          = 'X'.              "공급업체

*& P/O Item 구성...
  GT_BAPI_ITEM-PO_ITEM            =  '00010'.         "구매문서 품목번호
  GT_BAPI_ITEM-ITEM_CAT           =  GT_EBAN-EPSTP.   "구매문서 품목범주
  GT_BAPI_ITEM-MATERIAL           =  GT_EBAN-MATNR.   "자재번호
  GT_BAPI_ITEM-PLANT              =  GT_EBAN-WERKS.   "입고플랜트
*  gt_bapi_item-stge_loc           =  gt_eban-lgort.   "저장위치
  GT_BAPI_ITEM-QUANTITY           =  GT_EBAN-MENGE_A. "구매오더수량
  GT_BAPI_ITEM-PO_UNIT            =  GT_EBAN-MEINS_A. "단위
*  gt_bapi_item-tax_code           = 'VA'.             "세금코드
  GT_BAPI_ITEM-PREQ_NO            =  GT_EBAN-BANFN.   "구매요청번호
  GT_BAPI_ITEM-PREQ_ITEM          =  GT_EBAN-BNFPO.   "품목번호
*  gt_bapi_item-po_price           = '2'.              "지시자(단가)
*  gt_bapi_item-net_price          = '1'.              "단가


  APPEND GT_BAPI_ITEM.         CLEAR GT_BAPI_ITEM.
*& P/O Item(변경툴바) 구성...
  GT_BAPI_ITEMX-PO_ITEM           = '00010'.         "구매문서 품목번호
  GT_BAPI_ITEMX-PO_ITEMX          = 'X'.             "구매문서 품목번호
  GT_BAPI_ITEMX-ITEM_CAT          = 'X'.             "구매문서 품목범주
  GT_BAPI_ITEMX-MATERIAL          = 'X'.             "포장자재
  GT_BAPI_ITEMX-PLANT             = 'X'.             "입고플랜트
*  gt_bapi_itemx-stge_loc          = 'X'.             "저장위치
  GT_BAPI_ITEMX-QUANTITY          = 'X'.             "구매오더수량
  GT_BAPI_ITEMX-PO_UNIT           = 'X'.             "단위
*  gt_bapi_itemx-tax_code          = 'X'.             "세금코드
  GT_BAPI_ITEMX-PREQ_NO           = 'X'.             "구매요청번호
  GT_BAPI_ITEMX-PREQ_ITEM         = 'X'.             "품목번호
*  gt_bapi_itemx-po_price          = 'X'.             "지시자(단가)
*  gt_bapi_itemx-net_price         = 'X'.             "단가


  APPEND GT_BAPI_ITEMX.        CLEAR  GT_BAPI_ITEMX.

*& P/O 납품일정라인 구성...
  GT_BAPI_SCHEDULE-PO_ITEM        = '00010'.         "구매문서 품목번호
  GT_BAPI_SCHEDULE-DELIVERY_DATE  =  GT_EBAN-LFDAT.  "납기일

  APPEND GT_BAPI_SCHEDULE.    CLEAR  GT_BAPI_SCHEDULE.
*& P/O 납품일정라인(변경툴바) 구성...
  GT_BAPI_SCHEDULEX-PO_ITEM       = '00010'.         "구매문서 품목번호
  GT_BAPI_SCHEDULEX-PO_ITEMX      = 'X'.             "구매문서 품목번호
  GT_BAPI_SCHEDULEX-DELIVERY_DATE = 'X'.             "납기일
  APPEND GT_BAPI_SCHEDULEX.   CLEAR  GT_BAPI_SCHEDULEX.

*& 구매오더를 생성한다...
  CALL FUNCTION 'BAPI_PO_CREATE1'
    EXPORTING
      POHEADER         = GS_BAPI_HEADER
      POHEADERX        = GS_BAPI_HEADERX
*&            poaddrvendor             = gs_bapi_vendor
      TESTRUN          = GV_TESTRUN
*&            MEMORY_UNCOMPLETE        =
*&            MEMORY_COMPLETE          =
*&            poexpimpheader           = gs_bapi_expimpheader
*&            poexpimpheaderx          = gs_bapi_expimpheaderx
*&            VERSIONS                 =
*&            NO_MESSAGING             =
*&            NO_MESSAGE_REQ           =
*&            NO_AUTHORITY             =
*&            NO_PRICE_FROM_PO         =
    IMPORTING
      EXPPURCHASEORDER = GT_EBAN-EBELN
*&            EXPHEADER                =
*&            EXPPOEXPIMPHEADER        =
    TABLES
      RETURN           = GT_RET2
      POITEM           = GT_BAPI_ITEM
      POITEMX          = GT_BAPI_ITEMX
      POSCHEDULE       = GT_BAPI_SCHEDULE
      POSCHEDULEX      = GT_BAPI_SCHEDULEX.
*&            poaccount                = gt_bapi_account
*&            poaccountx               = gt_bapi_accountx.
*&            pocond                   = gt_bapi_cond
*&            pocondx                  = gt_bapi_condx
*&            extensionout             = gt_bapi_extensionout.
*&            poexpimpitem             = gt_bapi_expimpitem
*&            poexpimpitemx            = gt_bapi_expimpitemx
*&            potextheader             = gt_bapi_textheader
*&            potextitem               = gt_bapi_textitem
*&            popartner                = gt_bapi_partner.

  READ TABLE GT_RET2 WITH KEY TYPE = 'E'.
  IF SY-SUBRC <> 0.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.

*& 사급자재 정보 발췌...
    REFRESH: GT_MDSB_L, GT_MDSB_W1, GT_MDSB_W2, GT_MDSB_W3.
    CLEAR  : GT_MDSB_L, GT_MDSB_W1, GT_MDSB_W2, GT_MDSB_W3.

    GT_EBAN-EBELP = '00010'.
*&    PERFORM select_mdsb_proc USING 'PO'. "구매오더 생성일 경우

*& 구매오더 변경 BDC ...
    GS_BDCPARAMS-NOBINPT  = 'X'.   " BI 세션
*& 구매문서의 특성값(조장, 조장수) 체크...
    CLEAR: GV_LENGTH, GV_FACTOR, GV_PACKING_CAT, GV_PACKING.
    PERFORM ZMM_EKPO_SPEC_GET USING GT_EBAN-EBELN
                                    GT_EBAN-EBELP
                           CHANGING GV_LENGTH
                                    GV_FACTOR
                                    GV_PACKING_CAT
                                    GV_PACKING.

    PERFORM ME22N_GENERATE_BDC_DATA.
    PERFORM ME22N_CALL_TRANSACTION.

*& CBO 테이블에 저장...
    PERFORM INSERT_INTO_ZPPT0018_HD.
*&    PERFORM insert_into_zppt0018_dt USING 'L'.
*&    PERFORM insert_into_zppt0018_dt USING 'W'.

*& 생성된 구매오더번호를 인터널 테이블에 반영...
    CLEAR: GT_EBAN-CHECK, GT_EBAN-MENGE_B.
    MODIFY GT_EBAN INDEX GV_TABIX
            TRANSPORTING EBELN EBELP MENGE_B CHECK.

*& 새로운 라인 추가를 위한 데이타 발췌...
    PERFORM INSET_LINE_PROC.

* CSR : C2006061201000000279
* 2006.07.03 구매오더 생성시 오더수량이 요청수량의 90%이상이면
* 구매요청 마감지시자 체크(이상갑K)

    IF GT_EBAN-BANFN IS NOT INITIAL.
      PERFORM PR_END_CHECK USING GT_EBAN-MATNR
                                 GT_EBAN-BANFN          "구매요청 번호
                                 GT_EBAN-BNFPO          "구매요청 품목
                                 ' '.
      "생성(' '),삭제('X')
    ENDIF.

    CLEAR GT_MSG.
    MOVE: GT_RET2-LOG_NO      TO GT_MSG-LOGNO,
          GT_RET2-LOG_MSG_NO  TO GT_MSG-MSGSQ,
          GT_RET2-ID          TO GT_MSG-MSGID,
          GT_RET2-TYPE        TO GT_MSG-MSGTY,
          GT_RET2-NUMBER      TO GT_MSG-MSGNO,
          GT_RET2-MESSAGE_V1  TO GT_MSG-MSGV1,
          GT_RET2-MESSAGE_V2  TO GT_MSG-MSGV2,
          GT_RET2-MESSAGE_V3  TO GT_MSG-MSGV3,
          GT_RET2-MESSAGE_V4  TO GT_MSG-MSGV4,
          GT_RET2-MESSAGE     TO GT_MSG-MSGTX,
          GT_EBAN-BANFN       TO GT_MSG-REFNO,
          GT_EBAN-BNFPO       TO GT_MSG-REFIT.

    APPEND GT_MSG.         CLEAR GT_MSG.

  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    CLEAR GT_MSG.
    LOOP AT GT_RET2.
      MOVE: GT_RET2-LOG_NO      TO GT_MSG-LOGNO,
            GT_RET2-LOG_MSG_NO  TO GT_MSG-MSGSQ,
            GT_RET2-ID          TO GT_MSG-MSGID,
            GT_RET2-TYPE        TO GT_MSG-MSGTY,
            GT_RET2-NUMBER      TO GT_MSG-MSGNO,
            GT_RET2-MESSAGE_V1  TO GT_MSG-MSGV1,
            GT_RET2-MESSAGE_V2  TO GT_MSG-MSGV2,
            GT_RET2-MESSAGE_V3  TO GT_MSG-MSGV3,
            GT_RET2-MESSAGE_V4  TO GT_MSG-MSGV4,
            GT_RET2-MESSAGE     TO GT_MSG-MSGTX,
            GT_EBAN-BANFN       TO GT_MSG-REFNO,
            GT_EBAN-BNFPO       TO GT_MSG-REFIT.

      APPEND GT_MSG.         CLEAR GT_MSG.
    ENDLOOP.

  ENDIF.

ENDFORM.                    " bapi_purchase_order_create
*&---------------------------------------------------------------------*
*&      Form  refresh_gt_eban_display
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM REFRESH_GT_EBAN_DISPLAY .
  CLEAR: GV_TITLE.

  PERFORM SET_CELL_ATTRIBUTE.
*&    gv_title = '외주가공 및 부하상품 지시 리스트'.

*&    CALL METHOD gcl_grid->set_gridtitle
*&      EXPORTING
*&        i_gridtitle = gv_title.

  L_SCROLL-ROW = 'X'.
  L_SCROLL-COL = 'X'.

  CALL METHOD GCL_GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
      I_SOFT_REFRESH = 'X'
      IS_STABLE      = L_SCROLL.     "현재 그대로 입력한 refresh

  CALL METHOD GCL_GRID->SET_OPTIMIZE_ALL_COLS.

ENDFORM.                    " refresh_gt_eban_display
*&---------------------------------------------------------------------*
*&      Form  refresh_gt_mdsb_l_display
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM REFRESH_GT_MDSB_L_DISPLAY .
  CLEAR: GV_TITLE_L.

  PERFORM SET_CELL_ATTRIBUTE_L.
*&    gv_title = '외주가공 및 부하상품 지시 리스트'.

*&    CALL METHOD gcl_grid->set_gridtitle
*&      EXPORTING
*&        i_gridtitle = gv_title.

  L_SCROLL-ROW = 'X'.
  L_SCROLL-COL = 'X'.

  CALL METHOD GCL_GRID_L->REFRESH_TABLE_DISPLAY
    EXPORTING
      I_SOFT_REFRESH = 'X'
      IS_STABLE      = L_SCROLL.     "현재 그대로 입력한 refresh

  CALL METHOD GCL_GRID_L->SET_OPTIMIZE_ALL_COLS.

ENDFORM.                    " refresh_gt_mdsb_l_display
*&---------------------------------------------------------------------*
*&      Form  refresh_gt_mdsb_w1_display
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM REFRESH_GT_MDSB_W1_DISPLAY .
  CLEAR: GV_TITLE_W.

  PERFORM SET_CELL_ATTRIBUTE_W1.
*&    gv_title = '외주가공 및 부하상품 지시 리스트'.

*&    CALL METHOD gcl_grid->set_gridtitle
*&      EXPORTING
*&        i_gridtitle = gv_title.

  L_SCROLL-ROW = 'X'.
  L_SCROLL-COL = 'X'.

  CALL METHOD GCL_GRID_W1->REFRESH_TABLE_DISPLAY
    EXPORTING
      I_SOFT_REFRESH = 'X'
      IS_STABLE      = L_SCROLL.     "현재 그대로 입력한 refresh

  CALL METHOD GCL_GRID_W1->SET_OPTIMIZE_ALL_COLS.

ENDFORM.                    " refresh_gt_mdsb_w1_display
*&---------------------------------------------------------------------*
*&      Form  refresh_gt_mdsb_w2_display
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM REFRESH_GT_MDSB_W2_DISPLAY .
  CLEAR: GV_TITLE_W.

  PERFORM SET_CELL_ATTRIBUTE_W2.
*&    gv_title = '외주가공 및 부하상품 지시 리스트'.

*&    CALL METHOD gcl_grid->set_gridtitle
*&      EXPORTING
*&        i_gridtitle = gv_title.

  L_SCROLL-ROW = 'X'.
  L_SCROLL-COL = 'X'.

  CALL METHOD GCL_GRID_W2->REFRESH_TABLE_DISPLAY
    EXPORTING
      I_SOFT_REFRESH = 'X'
      IS_STABLE      = L_SCROLL.     "현재 그대로 입력한 refresh

  CALL METHOD GCL_GRID_W2->SET_OPTIMIZE_ALL_COLS.

ENDFORM.                    " refresh_gt_mdsb_w2_display

*&---------------------------------------------------------------------*
*&      Form  me22n_generate_bdc_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ME22N_GENERATE_BDC_DATA .
  DATA: LV_ERFMG_T(17).

  REFRESH: GT_BDCDATA, GT_MSGCOLL.
  CLEAR  : GT_BDCDATA, GT_MSGCOLL.

  PERFORM DYNPRO USING:
    'X'  'SAPLMEGUI'               '0014',
    ' '  'BDC_OKCODE'              '=MECHOB'.

  PERFORM DYNPRO USING:
    'X'  'SAPLMEGUI'               '0002',
    ' '  'BDC_OKCODE'              '=MEOK',
    ' '  'BDC_CURSOR'              'MEPO_SELECT-EBELN',
    ' '  'MEPO_SELECT-EBELN'        GT_EBAN-EBELN,    "구매오더번호
    ' '  'MEPO_SELECT-BSTYP_F'     'X'.               "구매오더선택

  PERFORM DYNPRO USING:
    'X'  'SAPLMEGUI'               '0014',
    ' '  'BDC_OKCODE'              '=/SAPMP/CE_MUEBS',
    ' '  'BDC_CURSOR'              '/SAPMP/MUEBS',
    ' '  '/SAPMP/MUEBS'            ' '.               "특성조회

  PERFORM DYNPRO USING:
    'X'  'SAPLMEGUI'               '0014',
    ' '  'BDC_OKCODE'              '=/SAPMP/CE_MUEBS',
    ' '  'BDC_CURSOR'              '/SAPMP/MUEBS',
    ' '  '/SAPMP/SCOPE'            'ALL',             "조회범위
    ' '  '/SAPMP/MUEBS'            'MM_001'.          "특성조회

*&  IF gv_length IS INITIAL.
  IF GT_EBAN-KZKFG IS INITIAL.
    PERFORM DYNPRO USING:
      'X'  'SAPLMEGUI'             '0014',
      ' '  'BDC_OKCODE'            '=/SAPMP/CE_CONF',
      ' '  'BDC_CURSOR'            'MEPO1211-/SAPMP/CE_ICON(01)'.
  ENDIF.

  PERFORM DYNPRO USING:
    'X'  'SAPLMEGUI'               '0014',
    ' '  'BDC_OKCODE'              '/00'.

  IF GT_EBAN-WERKS = '1201' OR
     GT_EBAN-WERKS = '1304'.
  ELSE.
    PERFORM DYNPRO USING:
      ' '  'MEPO1211-/SAPMP/ATWRT01(01)'  GT_EBAN-FACTOR,
      ' '  'MEPO1211-/SAPMP/ATWRT02(01)'  GT_EBAN-LENGTH.
  ENDIF.

  PERFORM DYNPRO USING:
    ' '  'MEPO1211-/SAPMP/ATWRT03(01)'  GT_EBAN-PACKING_CAT,
    ' '  'MEPO1211-/SAPMP/ATWRT04(01)'  GT_EBAN-PACKING.

*  PERFORM dynpro USING:
*    'X'  'SAPLMEGUI'               '0014',
*    ' '  'BDC_OKCODE'              '/00',
*    ' '  'MEPO1211-/SAPMP/ATWRT01(01)'  gt_eban-factor,
*    ' '  'MEPO1211-/SAPMP/ATWRT02(01)'  gt_eban-length,
*    ' '  'MEPO1211-/SAPMP/ATWRT03(01)'  gt_eban-packing_cat,
*    ' '  'MEPO1211-/SAPMP/ATWRT04(01)'  gt_eban-packing.

*& 구성부품 Loss율 적용(중량관리)...
  IF NOT GT_MDSB_W1[] IS INITIAL.
    LOOP AT GT_MDSB_W1.
      WRITE: GT_MDSB_W1-ERFMG_A  TO LV_ERFMG_T.

      PERFORM DYNPRO USING:                               "자재데이타
        'X'  'SAPLMEGUI'           '0014',
        ' '  'BDC_OKCODE'          '=TABIDT3'.

      PERFORM DYNPRO USING:                               "구성부품
        'X'  'SAPLMEGUI'           '0014',
        ' '  'BDC_OKCODE'          '=MEPO1319BOM'.

      PERFORM DYNPRO USING:                               "찾기
        'X'  'SAPLM61Q'            '0115',
        ' '  'BDC_OKCODE'          '=SUCH',
        ' '  'BDC_CURSOR'          'MDPM-MATNR(01)'.

      PERFORM DYNPRO USING:                               "찾기
        'X'  'SAPLM61Q'            '0300',
        ' '  'BDC_OKCODE'          '=SUCH',
        ' '  'SUCHL-MATNR'          GT_MDSB_W1-MATNR_C. "사급자재

      PERFORM DYNPRO USING:                               "
        'X'  'SAPLM61Q'            '0115',
        ' '  'BDC_OKCODE'          '/00',
        ' '  'MDPM-ERFMG(01)'       LV_ERFMG_T.

      PERFORM DYNPRO USING:                               "
        'X'  'SAPLM61Q'            '0115',
        ' '  'BDC_OKCODE'          '=BACK'.
    ENDLOOP.
  ENDIF.

  PERFORM DYNPRO USING:                               "구성부품
    'X'  'SAPLMEGUI'               '0014',
    ' '  'BDC_OKCODE'              '=MESAVE'.

ENDFORM.                    " me22n_generate_bdc_data
*&---------------------------------------------------------------------*
*&      Form  dynpro
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_6161   text
*      -->P_6162   text
*      -->P_6163   text
*----------------------------------------------------------------------*
FORM DYNPRO USING DYNBEGIN NAME VALUE.
  CLEAR GT_BDCDATA.
  IF DYNBEGIN = 'X'.
    MOVE: NAME  TO GT_BDCDATA-PROGRAM,
          VALUE TO GT_BDCDATA-DYNPRO,
          'X'   TO GT_BDCDATA-DYNBEGIN.
    APPEND GT_BDCDATA.
  ELSE.
    MOVE: NAME  TO GT_BDCDATA-FNAM,
          VALUE TO GT_BDCDATA-FVAL.
    APPEND GT_BDCDATA.
  ENDIF.
ENDFORM.                    " dynpro
*&---------------------------------------------------------------------*
*&      Form  me22n_call_transaction
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ME22N_CALL_TRANSACTION .
  CALL TRANSACTION 'ME22N'          "Transaction Call.
             USING GT_BDCDATA
           OPTIONS FROM GS_BDCPARAMS
          MESSAGES INTO GT_MSGCOLL.

  READ TABLE GT_MSGCOLL WITH KEY MSGTYP = 'E'.
  IF SY-SUBRC = 0.
    CLEAR GT_MSG.
    MOVE: GT_MSGCOLL-MSGID    TO GT_MSG-MSGID,
          GT_MSGCOLL-MSGTYP   TO GT_MSG-MSGTY,
          GT_MSGCOLL-MSGNR    TO GT_MSG-MSGNO,
          GT_MSGCOLL-MSGV1    TO GT_MSG-MSGV1,
          GT_MSGCOLL-MSGV2    TO GT_MSG-MSGV2,
          GT_MSGCOLL-MSGV3    TO GT_MSG-MSGV3,
          GT_MSGCOLL-MSGV4    TO GT_MSG-MSGV4,
          GT_EBAN-BANFN       TO GT_MSG-REFNO,
          GT_EBAN-BNFPO       TO GT_MSG-REFIT.

    APPEND GT_MSG.         CLEAR GT_MSG.

  ENDIF.
ENDFORM.                    " me22n_call_transaction
*&---------------------------------------------------------------------*
*&      Form  insert_into_zppt0018_dt
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM INSERT_INTO_ZPPT0018_DT USING PV_GUBUN.

  DATA : LV_POSNR   TYPE ZPPT0018-POSNR.
  CLEAR  LV_POSNR.

  CASE PV_GUBUN.
    WHEN 'L'.   "길이관리 사급자재
      LOOP AT GT_MDSB_L.

*        SELECT SINGLE mandt INTO zppt0018-mandt
*                 FROM zppt0018
*                WHERE pswrk = gt_mdsb_l-werks
*                  AND ebeln = gt_mdsb_l-ebeln
*                  AND ebelp = gt_mdsb_l-ebelp
*                  AND matnr = gt_mdsb_l-matnr_c
*                  AND tagnr = gt_mdsb_l-tagnr
*                  AND posnr = gt_mdsb_l-posnr.
*        IF sy-subrc = 0.
*          IF gt_mdsb_l-check = 'X'.
*            UPDATE zppt0018 SET: enmng   =  gt_mdsb_l-bdmng  "출고수량
*                                 bdmng   =  gt_mdsb_l-enmng  "소요수량
*                                 lgort   =  gt_mdsb_l-lgort
*                                 mblnr   =  gt_mdsb_l-mblnr
*                                 mjahr   =  gt_mdsb_l-mjahr
*                                 mblnr_f = 'X'
*                                 charg   =  gt_mdsb_l-charg
*                                 scqty   =  gt_mdsb_l-lblab
*                          WHERE  pswrk   =  gt_mdsb_l-werks
*                            AND  ebeln   =  gt_mdsb_l-ebeln
*                            AND  ebelp   =  gt_mdsb_l-ebelp
*                            AND  matnr   =  gt_mdsb_l-matnr_c
*                            AND  tagnr   =  gt_mdsb_l-tagnr
*                            AND  posnr   =  gt_mdsb_l-posnr.
*          ENDIF.
*        ELSE.
        IF GT_MDSB_L-CHECK = 'X'.
          MOVE-CORRESPONDING GT_MDSB_L  TO  ZPPT0018.
          MOVE: GT_MDSB_L-WERKS         TO  ZPPT0018-PSWRK,
                GT_MDSB_L-MATNR_C       TO  ZPPT0018-MATNR,
                GT_EBAN-LOSSR           TO  ZPPT0018-LOSSR,
                GT_MDSB_L-LBLAB         TO  ZPPT0018-SCQTY,
                GT_MDSB_L-POSNR         TO  ZPPT0018-POSNR,
               'X'                      TO  ZPPT0018-MBLNR_F,
               'L'                      TO  ZPPT0018-GUBUN,
                SY-DATUM                TO  ZPPT0018-ERDAT,
                SY-UZEIT                TO  ZPPT0018-ERTIM,
                SY-UNAME                TO  ZPPT0018-ERNAM.

          INSERT ZPPT0018. COMMIT WORK AND WAIT.
        ENDIF.
*        ENDIF.

      ENDLOOP.

    WHEN 'W'.   "중량관리 사급자재
      LOOP AT GT_MDSB_W1.
        LOOP AT GT_MDSB_W2 WHERE WERKS   = GT_MDSB_W1-WERKS
                             AND MATNR_C = GT_MDSB_W1-MATNR_C.

*& 중량관리 자재여도 이전전기 자재문서로 취소하기위해 insert
*          SELECT SINGLE mandt INTO zppt0018-mandt
*                   FROM zppt0018
*                  WHERE pswrk = gt_mdsb_w1-werks
*                    AND ebeln = gt_mdsb_w1-ebeln
*                    AND ebelp = gt_mdsb_w1-ebelp
*                    AND matnr = gt_mdsb_w1-matnr_c
*                    AND tagnr = gt_mdsb_w2-tagnr.

          SELECT MAX( POSNR ) INTO LV_POSNR
                   FROM ZPPT0018
                  WHERE PSWRK = GT_MDSB_W1-WERKS
                    AND EBELN = GT_MDSB_W1-EBELN
                    AND EBELP = GT_MDSB_W1-EBELP
                    AND MATNR = GT_MDSB_W1-MATNR_C
                    AND TAGNR = GT_MDSB_W2-TAGNR.

          LV_POSNR = LV_POSNR + 1.

          IF GT_MDSB_W2-CHECK = 'X'.
            MOVE-CORRESPONDING GT_MDSB_W1 TO  ZPPT0018.
            MOVE: GT_MDSB_W1-WERKS        TO  ZPPT0018-PSWRK,
                  GT_MDSB_W1-MATNR_C      TO  ZPPT0018-MATNR,
                  GT_EBAN-LOSSR           TO  ZPPT0018-LOSSR,
                  GT_MDSB_W1-BDMNG_A      TO  ZPPT0018-BDMNG,
                  GT_MDSB_W2-ENMNG        TO  ZPPT0018-ENMNG,
                  GT_MDSB_W2-LBLAB        TO  ZPPT0018-SCQTY,
                  GT_MDSB_W2-AUSME        TO  ZPPT0018-MEINS,
                  GT_MDSB_W2-MBLNR        TO  ZPPT0018-MBLNR,
                  GT_MDSB_W2-ZEILE        TO  ZPPT0018-ZEILE,
                  GT_MDSB_W2-MJAHR        TO  ZPPT0018-MJAHR,
                  GT_MDSB_W2-LGORT        TO  ZPPT0018-LGORT,
                  LV_POSNR                TO  ZPPT0018-POSNR,
                  GT_MDSB_W2-TAGNR        TO  ZPPT0018-TAGNR,
                  GT_MDSB_W2-CHARG        TO  ZPPT0018-CHARG,
                 'X'                      TO  ZPPT0018-MBLNR_F,
                 'W'                      TO  ZPPT0018-GUBUN,
                  SY-DATUM                TO  ZPPT0018-ERDAT,
                  SY-UZEIT                TO  ZPPT0018-ERTIM,
                  SY-UNAME                TO  ZPPT0018-ERNAM.

            INSERT ZPPT0018. COMMIT WORK AND WAIT.
          ENDIF.

        ENDLOOP.
      ENDLOOP.
    WHEN  OTHERS.
  ENDCASE.
ENDFORM.                    " insert_into_zppt0018_dt
*&---------------------------------------------------------------------*
*&      Form  sc_stock_tranfer
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SC_STOCK_TRANFER.
  REFRESH GT_MSG.          CLEAR GT_MSG.

  CLEAR : GT_WIF[]. "추가(SJM 25.06.11)

*& 조장구성표 정보의 저장을 위한 sorting
  DATA: BEGIN OF LT_EBELN OCCURS 0,
          EBELN TYPE EKKO-EBELN,
        END OF LT_EBELN.

*& 길이관리...
  READ TABLE GT_MDSB_L WITH KEY CHECK   = 'X'
                                MBLNR_F = 'X'.
  IF SY-SUBRC = 0.
    MESSAGE W004 WITH '출고반제품코드"'
                       GT_MDSB_L-MATNR_C
                      '은(는) 이미 재고이전이 되었습니다.!!!'.
  ELSE.
    PERFORM SC_TRANSFER_BAPI_L.
  ENDIF.

*  CLEAR : gv_tabix.
*  LOOP AT gt_mdsb_l WHERE check = 'X'.
*    gv_tabix = sy-tabix.
*    IF gt_mdsb_l-mblnr_f = 'X'.
*      MESSAGE w004 WITH '출고반제품코드"'
*                         gt_mdsb_l-matnr_c
*                        '은(는) 이미 재고이전이 되었습니다.!!!'.
*    ELSE.
**& 재고 이전전기...
*      PERFORM sc_transfer_bapi_l.
*    ENDIF.
*  ENDLOOP.

*& 중량관리...
  READ TABLE GT_MDSB_W2 WITH KEY CHECK   = 'X'
                                 MBLNR_F = 'X'.
  IF SY-SUBRC = 0.
    MESSAGE W004 WITH '출고반제품코드"'
                       GT_MDSB_W2-MATNR_C
                      '은(는) 이미 재고이전이 되었습니다.!!!'.
  ELSE.
    PERFORM SC_TRANSFER_BAPI_W2.
  ENDIF.

*  CLEAR : gv_tabix.
*  LOOP AT gt_mdsb_w2 WHERE check = 'X'.
*    gv_tabix = sy-tabix.
*    IF gt_mdsb_w2-mblnr_f = 'X'.
*      MESSAGE w004 WITH '출고반제품코드"'
*                         gt_mdsb_w2-matnr_c
*                        '은(는) 이미 재고이전이 되었습니다.!!!'.
*    ELSE.
*      PERFORM sc_transfer_bapi_w2.
*    ENDIF.
*  ENDLOOP.

  PERFORM SEND_WMS. "추가(SJM 25.06.11)

  CHECK NOT GT_MSG[] IS INITIAL.
  CALL FUNCTION 'Z_TI_POPUP_TO_ERROR_MESSAGE'
    EXPORTING
      XDOCNO_SHOW = 'X'
    TABLES
      XMSG        = GT_MSG.

*& 구매오더의 전달 및 조장구성표 저장 실행
*& 사급자재 이전전기시에 구매오더에 대한 조장구성표 번호를
*& ZPPT0136 테이블에 보관하도록 보완
*& 2005.08.02 D.J.CHA
  CLEAR LT_EBELN.
  REFRESH LT_EBELN.

  LOOP AT GT_MDSB_L.    " 길이관리 사급자재
    LT_EBELN-EBELN = GT_MDSB_L-EBELN.
    COLLECT LT_EBELN. CLEAR LT_EBELN.
  ENDLOOP.

  LOOP AT GT_MDSB_W1.   " 중량관리 사급자재
    LT_EBELN-EBELN = GT_MDSB_W1-EBELN.
    COLLECT LT_EBELN. CLEAR LT_EBELN.
  ENDLOOP.

  LOOP AT LT_EBELN.
    SUBMIT ZPPR0060 WITH S_EBELN = LT_EBELN-EBELN
                     AND RETURN.
  ENDLOOP.

ENDFORM.                    " sc_stock_tranfer
*&---------------------------------------------------------------------*
*&      Form  delete_purchase_order
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DELETE_PURCHASE_ORDER.
  CLEAR : GV_TABIX.
  REFRESH GT_MSG. CLEAR GT_MSG.
  LOOP AT GT_EBAN WHERE CHECK = 'X'.
    GV_TABIX = SY-TABIX.
    IF GT_EBAN-FLAG1 <> SPACE.
      CLEAR GT_MSG.
      GT_MSG-MSGID = 'ZPP1'.
      GT_MSG-MSGTY = 'E'.
      GT_MSG-MSGNO = '004'.
      GT_MSG-MSGV1 = '먼저 이전전기를 취소 하십시요..'.
      GT_MSG-REFNO =  GT_EBAN-EBELN.
      GT_MSG-REFIT =  GT_EBAN-EBELP.

      APPEND GT_MSG.    CLEAR GT_MSG.

      GT_EBAN-CHECK = ''.
      MODIFY GT_EBAN.
      CONTINUE.
    ENDIF.

*(S)상신중/승인완료 상태이면, 구매오더 삭제 불가처리(SJM 25.04.28)
    IF GT_EBAN-ZGUID_L IS NOT INITIAL
    OR GT_EBAN-ZGUID_W IS NOT INITIAL.
      "먼저 상신/확정취소를 실행하세요.
      PERFORM SET_POP_MSG USING 'ZGTMM01' 'E' '137' ' ' GT_EBAN-EBELN GT_EBAN-EBELP.

      GT_EBAN-CHECK = SPACE.
      MODIFY GT_EBAN TRANSPORTING CHECK.
      CONTINUE.
    ENDIF.
*(E)상신중/승인완료 상태이면, 구매오더 삭제 불가처리(SJM 25.04.28)

*& 구매오더 삭제...
    PERFORM BAPI_PURCHASE_ORDER_DELETE.

  ENDLOOP.

  IF NOT GT_MSG[] IS INITIAL.
    CALL FUNCTION 'Z_TI_POPUP_TO_ERROR_MESSAGE'
      EXPORTING
        XDOCNO_SHOW = 'X'
      TABLES
        XMSG        = GT_MSG.
  ENDIF.

ENDFORM.                    " delete_purchase_order
*&---------------------------------------------------------------------*
*&      Form  sc_transfer_bapi_l
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SC_TRANSFER_BAPI_L .
  DATA: LV_MBLNR LIKE MKPF-MBLNR,
        LV_MJAHR LIKE MKPF-MJAHR,
        LV_INDEX LIKE MSEG-ZEILE.

  REFRESH: GT_BAPI_GM_ITEM,
           GT_BAPI_GM_SERIALNUMBER,
           GT_BAPI_GM_MATDOCITEM,
           GT_RET2.

  CLEAR  : GS_BAPI_GM_HEADER,
           GS_BAPI_GM_CODE,
           GS_BAPI_GM_HEADRET,
           GT_BAPI_GM_ITEM,
           GT_BAPI_GM_SERIALNUMBER,
           GT_BAPI_GM_MATDOCITEM,
           GT_RET2,
           LV_INDEX.

*& Material Document Header Data...
  GS_BAPI_GM_HEADER-PSTNG_DATE  =  SY-DATUM.          "전기일.
  GS_BAPI_GM_HEADER-DOC_DATE    =  SY-DATUM.          "증빙일.
  GS_BAPI_GM_HEADER-PR_UNAME    =  SY-UNAME.
  GS_BAPI_GM_HEADER-HEADER_TXT  =  'ZGTMMR4130'.
  "외주가공지시 프로그램명"

*& Assign Code to Transaction for Goods Movement
  GS_BAPI_GM_CODE-GM_CODE       =  GC_TCD_MB1B.       "T-Code

*& Material Document Items Data...
  LOOP AT GT_MDSB_L WHERE CHECK   = 'X'
                      AND MBLNR_F = ' '.

    GT_BAPI_GM_ITEM-MATERIAL    =  GT_MDSB_L-MATNR_C. "사급자재
    GT_BAPI_GM_ITEM-PLANT       =  GT_MDSB_L-WERKS.   "플랜트
    GT_BAPI_GM_ITEM-STGE_LOC    =  GT_MDSB_L-LGORT.   "저장위치
    GT_BAPI_GM_ITEM-BATCH       =  GT_MDSB_L-CHARG.   "뱃치
    GT_BAPI_GM_ITEM-VENDOR      =  GT_MDSB_L-LIFNR.   "공급업체
    GT_BAPI_GM_ITEM-MOVE_TYPE   =  GC_MVT_541.        "이동유형
*&  gt_bapi_gm_item-STCK_TYPE   = ' '.                "재고유형
    GT_BAPI_GM_ITEM-SPEC_STOCK  = ' '.              "특별재고지시자
    GT_BAPI_GM_ITEM-ENTRY_QNT   =  GT_MDSB_L-BDMNG.   "단위수량*
*    gt_bapi_gm_item-entry_qnt   =  gt_mdsb_l-enmng.   "단위수량
*&  gt_bapi_gm_item-entry_uom   = gt_mdsb-matnr_c.  "입력단위
    GT_BAPI_GM_ITEM-PO_NUMBER   =  GT_MDSB_L-EBELN.   "P/O 번호
    GT_BAPI_GM_ITEM-PO_ITEM     =  GT_MDSB_L-EBELP.   "품목번호
*&  gt_bapi_gm_item-ITEM_TEXT  = ''.                "항목텍스트
    GT_BAPI_GM_ITEM-MVT_IND     = ' '.                "이동지시자
*&  gt_bapi_gm_item-MOVE_REAS  = ''.                "이동사유

    APPEND GT_BAPI_GM_ITEM.    CLEAR GT_BAPI_GM_ITEM.

    LV_INDEX = LV_INDEX + 1.

    GT_MDSB_L-ZEILE = LV_INDEX.
    MODIFY GT_MDSB_L.

  ENDLOOP.

*& 자재 이동을 수행...
  CHECK NOT GT_BAPI_GM_ITEM[] IS INITIAL.
  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
    EXPORTING
      GOODSMVT_HEADER       = GS_BAPI_GM_HEADER
      GOODSMVT_CODE         = GS_BAPI_GM_CODE
      TESTRUN               = GV_TESTRUN
    IMPORTING
      GOODSMVT_HEADRET      = GS_BAPI_GM_HEADRET
      MATERIALDOCUMENT      = LV_MBLNR
      MATDOCUMENTYEAR       = LV_MJAHR
    TABLES
      GOODSMVT_ITEM         = GT_BAPI_GM_ITEM
      GOODSMVT_SERIALNUMBER = GT_BAPI_GM_SERIALNUMBER
      RETURN                = GT_RET2.

  READ TABLE GT_RET2 WITH KEY TYPE = 'E'.
  IF SY-SUBRC <> 0.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.

*& 생성된 자재문서를 인터널 테이블에 반영...
    LOOP AT GT_MDSB_L WHERE CHECK   = 'X'
                        AND MBLNR_F = ' '.

      GT_MDSB_L-MBLNR   = LV_MBLNR.
      GT_MDSB_L-MJAHR   = LV_MJAHR.
      GT_MDSB_L-CPUDT   =  SY-DATUM.
      GT_MDSB_L-MBLNR_F = 'X'.
      GT_MDSB_L-FLAG1   =  ICON_LED_GREEN.

      MODIFY GT_MDSB_L.

*& CBO 테이블에 저장...
      PERFORM UPDATE_ZPPT0001 USING GT_MDSB_L-WERKS
                                    GT_MDSB_L-TAGNR
                                    GT_MDSB_L-MBLNR
                                   '0'
                                   'Y'.

*(S)기능 추가 관련(SJM 25.03.18)
      PERFORM UPDATE_ZGTMMT4110 USING GT_MDSB_L-ZGUID
                                      GT_MDSB_L-MBLNR
                                      GT_MDSB_L-MJAHR.
*(E)기능 추가 관련(SJM 25.03.18)

*(S)WMS I/F 기능 추가(SJM 25.06.11)
      PERFORM SET_WIF USING GT_MDSB_L-LGORT
                            GT_MDSB_L-MBLNR
                            GT_MDSB_L-MJAHR.
*(E)WMS I/F 기능 추가(SJM 25.06.11)
    ENDLOOP.

    PERFORM INSERT_INTO_ZPPT0018_DT USING 'L'.


*&    MODIFY gt_mdsb_l INDEX gv_tabix
*&              TRANSPORTING mblnr mjahr cpudt mblnr_f flag1.

*& 구매오더에 뱃치번호를 넣어준다...
*&    gs_bdcparams-nobinpt  = 'X'.   " BI 세션
*&    PERFORM modify_purchase_order_bdc_l.

*& CBO 테이블에 저장...
*&    PERFORM insert_into_zppt0018_dt USING 'L'.
*&    PERFORM update_zppt0018_l.
*&    PERFORM update_zppt0001 USING gt_mdsb_l-werks
*&                                  gt_mdsb_l-tagnr
*&                                  gt_mdsb_l-mblnr
*&                                 '0'
*&                                 'Y'.

    MOVE: 'ZPP1'                TO GT_MSG-MSGID,
          'S'                   TO GT_MSG-MSGTY,
          '004'                 TO GT_MSG-MSGNO,
          '문서번호'            TO GT_MSG-MSGV1,
           LV_MBLNR             TO GT_MSG-MSGV2,
          '이(가) 생성 되었습니다.'
                                TO GT_MSG-MSGV3.

    CONCATENATE '문서번호'
                 LV_MBLNR
                '이(가) 생성 되었습니다.'
                              INTO GT_MSG-MSGTX.

    APPEND GT_MSG.         CLEAR GT_MSG.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    CLEAR GT_MSG.
    LOOP AT GT_RET2.
      MOVE: GT_RET2-LOG_NO      TO GT_MSG-LOGNO,
            GT_RET2-LOG_MSG_NO  TO GT_MSG-MSGSQ,
            GT_RET2-ID          TO GT_MSG-MSGID,
            GT_RET2-TYPE        TO GT_MSG-MSGTY,
            GT_RET2-NUMBER      TO GT_MSG-MSGNO,
            GT_RET2-MESSAGE_V1  TO GT_MSG-MSGV1,
            GT_RET2-MESSAGE_V2  TO GT_MSG-MSGV2,
            GT_RET2-MESSAGE_V3  TO GT_MSG-MSGV3,
            GT_RET2-MESSAGE_V4  TO GT_MSG-MSGV4,
            GT_RET2-MESSAGE     TO GT_MSG-MSGTX.

      APPEND GT_MSG.         CLEAR GT_MSG.
    ENDLOOP.

  ENDIF.

ENDFORM.                    " sc_transfer_bapi_l
*&---------------------------------------------------------------------*
*&      Form  sc_transfer_bapi_w2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SC_TRANSFER_BAPI_W2.
  DATA: BEGIN OF LT_MATNR OCCURS 0,
          MATNR LIKE MSEG-MATNR,
          CHARG LIKE MSEG-CHARG,
        END   OF LT_MATNR.

  DATA: LV_MJAHR LIKE MSEG-MJAHR,
        LV_MBLNR LIKE MSEG-MBLNR,
        LV_INDEX LIKE MSEG-ZEILE.

  REFRESH: GT_BAPI_GM_ITEM,
           GT_BAPI_GM_SERIALNUMBER,
           GT_BAPI_GM_MATDOCITEM,
           GT_RET2.

  CLEAR  : GS_BAPI_GM_HEADER,
           GS_BAPI_GM_CODE,
           GS_BAPI_GM_HEADRET,
           GT_BAPI_GM_ITEM,
           GT_BAPI_GM_SERIALNUMBER,
           GT_BAPI_GM_MATDOCITEM,
           GT_RET2,
           LV_INDEX.

*& Material Document Header Data...
  GS_BAPI_GM_HEADER-PSTNG_DATE  =  SY-DATUM.          "전기일.
  GS_BAPI_GM_HEADER-DOC_DATE    =  SY-DATUM.          "증빙일.
  GS_BAPI_GM_HEADER-PR_UNAME    =  SY-UNAME.
  GS_BAPI_GM_HEADER-HEADER_TXT  =  'ZGTMMR4130'.
  "외주가공지시 프로그램명"

*& Assign Code to Transaction for Goods Movement
  GS_BAPI_GM_CODE-GM_CODE       =  GC_TCD_MB1B.        "T-Code

*& Material Document Items Data...
  LOOP AT GT_MDSB_W2 WHERE CHECK   = 'X'
                       AND MBLNR_F = ' '.

    GT_BAPI_GM_ITEM-MATERIAL      =  GT_MDSB_W2-MATNR_C. "사급자재
    GT_BAPI_GM_ITEM-PLANT         =  GT_MDSB_W2-WERKS.   "플랜트
    GT_BAPI_GM_ITEM-STGE_LOC      =  GT_MDSB_W2-LGORT.   "저장위치
    GT_BAPI_GM_ITEM-BATCH         =  GT_MDSB_W2-CHARG.   "뱃치
    GT_BAPI_GM_ITEM-VENDOR        =  GT_MDSB_W2-LIFNR.   "공급업체
    GT_BAPI_GM_ITEM-MOVE_TYPE     =  GC_MVT_541.         "이동유형
    GT_BAPI_GM_ITEM-SPEC_STOCK    = ' '.                 "특별재고지시자
    GT_BAPI_GM_ITEM-ENTRY_QNT     =  GT_MDSB_W2-ENMNG.   "단위수량
    GT_BAPI_GM_ITEM-ITEM_TEXT     =  GT_MDSB_W2-LOTNO.   "항목텍스트
    GT_BAPI_GM_ITEM-MVT_IND       = ' '.                 "이동지시자

    APPEND GT_BAPI_GM_ITEM.    CLEAR GT_BAPI_GM_ITEM.

    LV_INDEX = LV_INDEX + 1.

    GT_MDSB_W2-ZEILE = LV_INDEX.
    MODIFY GT_MDSB_W2.

  ENDLOOP.

*& 자재 이동을 수행...
  CHECK NOT GT_BAPI_GM_ITEM[] IS INITIAL.
  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
    EXPORTING
      GOODSMVT_HEADER       = GS_BAPI_GM_HEADER
      GOODSMVT_CODE         = GS_BAPI_GM_CODE
      TESTRUN               = GV_TESTRUN
    IMPORTING
      GOODSMVT_HEADRET      = GS_BAPI_GM_HEADRET
      MATERIALDOCUMENT      = LV_MBLNR
      MATDOCUMENTYEAR       = LV_MJAHR
    TABLES
      GOODSMVT_ITEM         = GT_BAPI_GM_ITEM
      GOODSMVT_SERIALNUMBER = GT_BAPI_GM_SERIALNUMBER
      RETURN                = GT_RET2.

  READ TABLE GT_RET2 WITH KEY TYPE = 'E'.
  IF SY-SUBRC <> 0.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.

*& 생성된 자재문서를 인터널 테이블에 반영...
    REFRESH LT_MATNR.  CLEAR LT_MATNR.
    LOOP AT GT_MDSB_W2 WHERE CHECK   = 'X'
                         AND MBLNR_F = ' '.

      GT_MDSB_W2-MBLNR   =  LV_MBLNR.
      GT_MDSB_W2-MJAHR   =  LV_MJAHR.
      GT_MDSB_W2-BUDAT   =  SY-DATUM.
      GT_MDSB_W2-CPUDT   =  SY-DATUM.
      GT_MDSB_W2-MBLNR_F = 'X'.
      GT_MDSB_W2-FLAG1   =  ICON_LED_GREEN.
      PERFORM RESET_STK_W2 USING 'Y'. "추가(SJM 25.03.18)
      MODIFY GT_MDSB_W2.

      PERFORM UPDATE_ZPPT0001 USING GT_MDSB_W2-WERKS
                                    GT_MDSB_W2-TAGNR
                                    LV_MBLNR
                                   '0'
                                   'Y'.

*(S)기능 추가 관련(SJM 25.03.18)
      PERFORM UPDATE_ZGTMMT4110 USING GT_MDSB_W2-ZGUID
                                      GT_MDSB_W2-MBLNR
                                      GT_MDSB_W2-MJAHR.
*(E)기능 추가 관련(SJM 25.03.18)

*(S)WMS I/F 기능 추가(SJM 25.06.11)
      PERFORM SET_WIF USING GT_MDSB_W2-LGORT
                            GT_MDSB_W2-MBLNR
                            GT_MDSB_W2-MJAHR.
*(E)WMS I/F 기능 추가(SJM 25.06.11)

*& 구매오더에 뱃치번호를 넣어주기 위함...
*& 동일자재에는 동일 뱃치를 쓰기로함...
*&      lt_matnr-matnr = gt_mdsb_w2-matnr_c.
*&      lt_matnr-charg = gt_mdsb_w2-charg.
*&      COLLECT lt_matnr.  CLEAR lt_matnr.

    ENDLOOP.

*& 구매오더에 뱃치번호를 넣어준다...
*&    gs_bdcparams-nobinpt  = 'X'.   " BI 세션

*&    LOOP AT lt_matnr.
*&      PERFORM modify_purchase_order_bdc_w2 USING lt_matnr-matnr
*&                                                 lt_matnr-charg.
*&    ENDLOOP.



*    gt_mdsb_w2-cpudt   =  sy-datum.
*    gt_mdsb_w2-mblnr_f = 'X'.
*    gt_mdsb_w2-flag1   = icon_led_green.
*    MODIFY gt_mdsb_w2 INDEX gv_tabix
*               TRANSPORTING mblnr mjahr cpudt mblnr_f flag1.

*& CBO 테이블에 저장...
    PERFORM INSERT_INTO_ZPPT0018_DT USING 'W'.
*&    PERFORM update_zppt0018_w2.
*&    PERFORM update_zppt0001 USING gt_mdsb_w2-werks
*&                                  gt_mdsb_w2-tagnr
*&                                  lv_mblnr
*&                                 '0'
*&                                 'Y'.

    MOVE: 'ZPP1'                TO GT_MSG-MSGID,
          'S'                   TO GT_MSG-MSGTY,
          '004'                 TO GT_MSG-MSGNO,
          '문서번호'            TO GT_MSG-MSGV1,
           LV_MBLNR             TO GT_MSG-MSGV2,
          '이(가) 생성 되었습니다.'
                                TO GT_MSG-MSGV3.

    CONCATENATE '문서번호'
                 LV_MBLNR
                '이(가) 생성 되었습니다.'
                              INTO GT_MSG-MSGTX.

    APPEND GT_MSG.         CLEAR GT_MSG.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    CLEAR GT_MSG.
    LOOP AT GT_RET2.
      MOVE: GT_RET2-LOG_NO      TO GT_MSG-LOGNO,
            GT_RET2-LOG_MSG_NO  TO GT_MSG-MSGSQ,
            GT_RET2-ID          TO GT_MSG-MSGID,
            GT_RET2-TYPE        TO GT_MSG-MSGTY,
            GT_RET2-NUMBER      TO GT_MSG-MSGNO,
            GT_RET2-MESSAGE_V1  TO GT_MSG-MSGV1,
            GT_RET2-MESSAGE_V2  TO GT_MSG-MSGV2,
            GT_RET2-MESSAGE_V3  TO GT_MSG-MSGV3,
            GT_RET2-MESSAGE_V4  TO GT_MSG-MSGV4,
            GT_RET2-MESSAGE     TO GT_MSG-MSGTX.

      APPEND GT_MSG.         CLEAR GT_MSG.
    ENDLOOP.

  ENDIF.
ENDFORM.                    " sc_transfer_bapi_w2
*&---------------------------------------------------------------------*
*&      Form  update_zppt0018_l
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM UPDATE_ZPPT0018_L .
  SELECT SINGLE MANDT INTO ZPPT0018-MANDT
           FROM ZPPT0018
          WHERE PSWRK  =  GT_MDSB_L-WERKS
            AND EBELN  =  GT_MDSB_L-EBELN
            AND EBELP  =  GT_MDSB_L-EBELP
            AND MATNR  =  GT_MDSB_L-MATNR_C
            AND TAGNR <> 'HEADER'.
  IF SY-SUBRC = 0.
*& 길이관리 사급자재...
    UPDATE ZPPT0018 SET: ENMNG   =  GT_MDSB_L-BDMNG
                         LGORT   =  GT_MDSB_L-LGORT
                         MBLNR   =  GT_MDSB_L-MBLNR
                         MBLNR_F = 'X'
                         MJAHR   =  GT_MDSB_L-MJAHR
                         TAGNR   =  GT_MDSB_L-TAGNR
                         CHARG   =  GT_MDSB_L-CHARG
                         SCQTY   =  GT_MDSB_L-LBLAB
                  WHERE  PSWRK   =  GT_MDSB_L-WERKS
                    AND  EBELN   =  GT_MDSB_L-EBELN
                    AND  EBELP   =  GT_MDSB_L-EBELP
                    AND  MATNR   =  GT_MDSB_L-MATNR_C
                    AND  TAGNR  <> 'HEADER'.

  ELSE.
    MOVE-CORRESPONDING GT_MDSB_L TO ZPPT0018.
    MOVE: GT_MDSB_L-WERKS        TO ZPPT0018-PSWRK,
          GT_MDSB_L-MATNR_C      TO ZPPT0018-MATNR,
          GT_EBAN-LOSSR          TO ZPPT0018-LOSSR,
         'L'                     TO ZPPT0018-GUBUN,
          GT_MDSB_L-BDMNG        TO ZPPT0018-BDMNG,
          GT_MDSB_L-LGORT        TO ZPPT0018-LGORT,
          GT_MDSB_L-MBLNR        TO ZPPT0018-MBLNR,
         'X'                     TO ZPPT0018-MBLNR_F,
          GT_MDSB_L-MJAHR        TO ZPPT0018-MJAHR,
          GT_MDSB_L-TAGNR        TO ZPPT0018-TAGNR,
          GT_MDSB_L-CHARG        TO ZPPT0018-CHARG,
          GT_MDSB_L-LBLAB        TO ZPPT0018-SCQTY,
          SY-DATUM               TO ZPPT0018-ERDAT,
          SY-UZEIT               TO ZPPT0018-ERTIM,
          SY-UNAME               TO ZPPT0018-ERNAM.

    INSERT ZPPT0018. COMMIT WORK AND WAIT.
  ENDIF.
ENDFORM.                    " update_zppt0018_l
*&---------------------------------------------------------------------*
*&      Form  update_zppt0018_w2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM UPDATE_ZPPT0018_W2 .
*& 중량관리 사급자재...
  LOOP AT GT_MDSB_W1 WHERE  MATNR_C =  GT_MDSB_W2-MATNR_C.
    SELECT SINGLE MANDT INTO ZPPT0018-MANDT
             FROM ZPPT0018
            WHERE PSWRK  =  GT_MDSB_W1-WERKS
              AND EBELN  =  GT_MDSB_W1-EBELN
              AND EBELP  =  GT_MDSB_W1-EBELP
              AND MATNR  =  GT_MDSB_W1-MATNR_C
              AND TAGNR <> 'HEADER'.
    IF SY-SUBRC = 0.
      UPDATE ZPPT0018    SET: ENMNG   =  GT_MDSB_W2-ENMNG
                              MEINS   =  GT_MDSB_W2-AUSME
                              MBLNR   =  GT_MDSB_W2-MBLNR
                              MBLNR_F = 'X'
                              MJAHR   =  GT_MDSB_W2-MJAHR
                              LGORT   =  GT_MDSB_W2-LGORT
                              LOTNO   =  GT_MDSB_W2-LOTNO
                              SCQTY   =  GT_MDSB_W2-LBLAB
                       WHERE  PSWRK   =  GT_MDSB_W1-WERKS
                         AND  EBELN   =  GT_MDSB_W1-EBELN
                         AND  EBELP   =  GT_MDSB_W1-EBELP
                         AND  MATNR   =  GT_MDSB_W1-MATNR_C
                         AND  TAGNR  <> 'HEADER'.
    ELSE.
      MOVE-CORRESPONDING GT_MDSB_W1  TO  ZPPT0018.
      MOVE: GT_MDSB_W1-WERKS         TO  ZPPT0018-PSWRK,
            GT_MDSB_W1-MATNR_C       TO  ZPPT0018-MATNR,
            GT_EBAN-LOSSR            TO  ZPPT0018-LOSSR,
            GT_MDSB_W1-BDMNG_A       TO  ZPPT0018-BDMNG,
           'W'                       TO  ZPPT0018-GUBUN,

            GT_MDSB_W2-BDMNG         TO  ZPPT0018-BDMNG,
            GT_MDSB_W2-LGORT         TO  ZPPT0018-LGORT,
            GT_MDSB_W2-MBLNR         TO  ZPPT0018-MBLNR,
           'X'                       TO  ZPPT0018-MBLNR_F,
            GT_MDSB_W2-MJAHR         TO  ZPPT0018-MJAHR,
            GT_MDSB_W2-TAGNR         TO  ZPPT0018-TAGNR,
            GT_MDSB_W2-CHARG         TO  ZPPT0018-CHARG,
            GT_MDSB_W2-LBLAB         TO  ZPPT0018-SCQTY,

            SY-DATUM                 TO  ZPPT0018-ERDAT,
            SY-UZEIT                 TO  ZPPT0018-ERTIM,
            SY-UNAME                 TO  ZPPT0018-ERNAM.

      INSERT ZPPT0018. COMMIT WORK AND WAIT.

    ENDIF.
  ENDLOOP.
ENDFORM.                    " update_zppt0018_w2
*&---------------------------------------------------------------------*
*&      Form  submit_zmmr0041
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SUBMIT_ZMMR0041 .
  REFRESH: GT_SELTAB, GT_LIFNR.
  CLEAR  : GT_SELTAB, GT_LIFNR, GV_DBCNT, GV_ERROR.

*& 동일 업체만 가능...
  CLEAR GF_PSTYP.
  LOOP AT GT_EBAN WHERE CHECK = 'X'.

*& C2006012601000001057로 외주가공 및 반제품구매도 발주서 출력
*가능(2006.02.03)
*    IF gt_eban-pstyp = '0'.
*      gf_pstyp = 'X'.
*      EXIT.
*    ENDIF.

    GT_LIFNR-LIFNR = GT_EBAN-LIFNR.
    COLLECT GT_LIFNR.  CLEAR GT_LIFNR.
  ENDLOOP.

*  IF NOT gf_pstyp IS INITIAL.
*    MESSAGE s001 WITH '일반오더가 포함되어 있습니다.!!!'.
*    EXIT.
*  ENDIF.

  DESCRIBE TABLE GT_LIFNR LINES GV_DBCNT.
  IF GV_DBCNT > 1.
    MESSAGE S001 WITH '동일 업체가 아닙니다.!!!'.
    EXIT.
  ELSEIF GV_DBCNT < 1.
    MESSAGE S001 WITH '선택한 데이타가 없습니다.!!!'.
    EXIT.
  ENDIF.

  LOOP AT GT_EBAN WHERE CHECK = 'X'.
    IF GT_EBAN-EBELN IS INITIAL.
      GV_ERROR = 'X'.
      MESSAGE S004 WITH '먼저 구매오더를 생성 하십시오.!!!'.
      EXIT.
    ENDIF.

    CLEAR  GS_SELTAB_WA.       "회사코드
    MOVE: 'P_BUKRS'          TO GS_SELTAB_WA-SELNAME,
          'P'                TO GS_SELTAB_WA-KIND,      " PARAMETER
           GT_EBAN-BUKRS     TO GS_SELTAB_WA-LOW.
    COLLECT GS_SELTAB_WA   INTO GT_SELTAB.

    CLEAR  GS_SELTAB_WA.       "공급업체
    MOVE: 'P_LIFNR'          TO GS_SELTAB_WA-SELNAME,
          'P'                TO GS_SELTAB_WA-KIND,      " PARAMETER
           GT_EBAN-LIFNR     TO GS_SELTAB_WA-LOW.
    COLLECT GS_SELTAB_WA   INTO GT_SELTAB.

    CLEAR  GS_SELTAB_WA.       "플랜트
    MOVE: 'S_WERKS'          TO GS_SELTAB_WA-SELNAME,
          'P'                TO GS_SELTAB_WA-KIND,      " PARAMETER
           GT_EBAN-WERKS     TO GS_SELTAB_WA-LOW.
    COLLECT GS_SELTAB_WA   INTO GT_SELTAB.

    CLEAR GS_SELTAB_WA.        "구매오더
    MOVE: 'S_EBELN'          TO GS_SELTAB_WA-SELNAME,
          'P'                TO GS_SELTAB_WA-KIND,      " PARAMETER
           GT_EBAN-EBELN     TO GS_SELTAB_WA-LOW.
    COLLECT GS_SELTAB_WA   INTO GT_SELTAB.

    CLEAR GS_SELTAB_WA.        "구매증빙일
    MOVE: 'S_BEDAT'          TO GS_SELTAB_WA-SELNAME,
          'P'                TO GS_SELTAB_WA-KIND,      " PARAMETER
           GT_EBAN-BEDAT     TO GS_SELTAB_WA-LOW.
    COLLECT GS_SELTAB_WA   INTO GT_SELTAB.

  ENDLOOP.
  CHECK GV_ERROR IS INITIAL.
*& 발주서 발행 프로그램 호출...
  SUBMIT ZMMR0041 WITH SELECTION-TABLE GT_SELTAB
*&                       VIA SELECTION-SCREEN
                   AND RETURN.

ENDFORM.                    " submit_zmmr0041
*&---------------------------------------------------------------------*
*&      Form  submit_zler0015
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SUBMIT_ZLER0015.
  DATA: LV_BZAREA       LIKE ZLET0034-BZAREA.

  REFRESH: GT_SELTAB, GT_LIFNR.
  CLEAR  : GT_SELTAB, GT_LIFNR, GV_DBCNT, GV_TABIX, GV_ERROR.

  CLEAR : GV_ERR. "추가(SJM 25.05.14)

*& 동일 업체만 가능...
  LOOP AT GT_EBAN WHERE CHECK = 'X'.
    GT_LIFNR-LIFNR = GT_EBAN-LIFNR.
    COLLECT GT_LIFNR.  CLEAR GT_LIFNR.
  ENDLOOP.

  DESCRIBE TABLE GT_LIFNR LINES GV_DBCNT.
  IF GV_DBCNT > 1.
    MESSAGE S001 WITH '동일 업체가 아닙니다.!!!'.
    EXIT.
  ELSEIF GV_DBCNT < 1.
    MESSAGE S001 WITH '선택한 데이타가 없습니다.!!!'.
    EXIT.
  ENDIF.

*& 사업장코드를 가져온다....
  CLEAR: ZLET0034, LV_BZAREA.
  SELECT SINGLE BZAREA INTO LV_BZAREA
           FROM ZLET0034
          WHERE WERKS = P_WERKS.

*& 길이관리...
  LOOP AT GT_MDSB_L WHERE CHECK = 'X'.
    IF GT_MDSB_L-MBLNR IS INITIAL.
      MESSAGE S004 WITH '먼저 구성부품 이전전기를 수행 하십시오.!!!'.
      GV_ERR = GC_X. "추가(SJM 25.05.14)
      CONTINUE.
    ENDIF.

    IF GT_MDSB_L-IV_PRINT_YN = 'X'.
      MESSAGE W004 WITH GT_MDSB_L-MBLNR
                '은(는) 이미 통문증이 발행되었습니다.!!!'.
      GV_ERR = GC_X. "추가(SJM 25.05.14)
      CONTINUE.
    ENDIF.

    MOVE: 'R1'               TO GS_SELTAB_WA-SELNAME,
          'P'                TO GS_SELTAB_WA-KIND,      "PARAMETER
          ' '                TO GS_SELTAB_WA-LOW.       "PP일반
    COLLECT GS_SELTAB_WA   INTO GT_SELTAB.

    MOVE: 'R2'               TO GS_SELTAB_WA-SELNAME,
          'P'                TO GS_SELTAB_WA-KIND,      "PARAMETER
          ' '                TO GS_SELTAB_WA-LOW.       "PP일반
    COLLECT GS_SELTAB_WA   INTO GT_SELTAB.

    MOVE: 'R3'               TO GS_SELTAB_WA-SELNAME,
          'P'                TO GS_SELTAB_WA-KIND,      "PARAMETER
          'X'                TO GS_SELTAB_WA-LOW.       "PP일반
    COLLECT GS_SELTAB_WA   INTO GT_SELTAB.
*-{자체개선_51713_추가
    MOVE: 'P_BUKRS'          TO GS_SELTAB_WA-SELNAME,
          'P'                TO GS_SELTAB_WA-KIND,      "PARAMETER
          G_BUKRS            TO GS_SELTAB_WA-LOW.       "PP일반
    COLLECT GS_SELTAB_WA   INTO GT_SELTAB.
*-}자체개선_51713_2014.11.05
    MOVE: 'P_BZAREA'         TO GS_SELTAB_WA-SELNAME,
          'P'                TO GS_SELTAB_WA-KIND,      "PARAMETER
           LV_BZAREA         TO GS_SELTAB_WA-LOW.       "사업장
    COLLECT GS_SELTAB_WA   INTO GT_SELTAB.

    SET PARAMETER ID 'ZIVTYPE' FIELD 'B01'.             "무상사급
*    MOVE: 'P_GUBUN1'         TO GS_SELTAB_WA-SELNAME,
*          'P'                TO GS_SELTAB_WA-KIND,      "PARAMETER
*          '2'                TO GS_SELTAB_WA-LOW.       "통문구분
*    COLLECT GS_SELTAB_WA   INTO GT_SELTAB.

    CLEAR GS_SELTAB_WA.
    MOVE: 'I_CPUDT'          TO GS_SELTAB_WA-SELNAME,
          'P'                TO GS_SELTAB_WA-KIND,      "PARAMETER
           GT_MDSB_L-CPUDT   TO GS_SELTAB_WA-LOW.       "자재문서발행일
    COLLECT GS_SELTAB_WA   INTO GT_SELTAB.

    CLEAR GS_SELTAB_WA.
    MOVE: 'I_WERKS'          TO GS_SELTAB_WA-SELNAME,
          'P'                TO GS_SELTAB_WA-KIND,      "PARAMETER
           GT_MDSB_L-WERKS   TO GS_SELTAB_WA-LOW.       "사업단위
    COLLECT GS_SELTAB_WA   INTO GT_SELTAB.

    CLEAR GS_SELTAB_WA.
    MOVE: 'I_MBLNR'          TO GS_SELTAB_WA-SELNAME,
          'P'                TO GS_SELTAB_WA-KIND,      "PARAMETER
           GT_MDSB_L-MBLNR   TO GS_SELTAB_WA-LOW.       "자재문서
    COLLECT GS_SELTAB_WA   INTO GT_SELTAB.

    CLEAR GS_SELTAB_WA.
    MOVE: 'I_LIFNR'          TO GS_SELTAB_WA-SELNAME,
          'P'                TO GS_SELTAB_WA-KIND,      "PARAMETER
           GT_MDSB_L-LIFNR   TO GS_SELTAB_WA-LOW.       "거래처
    COLLECT GS_SELTAB_WA   INTO GT_SELTAB.
  ENDLOOP.

  CHECK GV_ERR IS INITIAL. "추가(SJM 25.05.14)

*& 중량관리...
  LOOP AT GT_MDSB_W2 WHERE CHECK = 'X'.
    IF GT_MDSB_W2-MBLNR IS INITIAL.
      MESSAGE S004 WITH '먼저 구성부품 이전전기를 수행 하십시오.!!!'.
      GV_ERR = GC_X. "추가(SJM 25.05.14)
      CONTINUE.
    ENDIF.

    IF GT_MDSB_W2-IV_PRINT_YN = 'X'.
      MESSAGE W004 WITH GT_MDSB_W2-MBLNR
                '은(는) 이미 통문증이 발행되었습니다.!!!'.
      GV_ERR = GC_X. "추가(SJM 25.05.14)
      CONTINUE.
    ENDIF.

    MOVE: 'R1'               TO GS_SELTAB_WA-SELNAME,
          'P'                TO GS_SELTAB_WA-KIND,      "PARAMETER
          ' '                TO GS_SELTAB_WA-LOW.       "PP일반
    COLLECT GS_SELTAB_WA   INTO GT_SELTAB.

    MOVE: 'R2'               TO GS_SELTAB_WA-SELNAME,
          'P'                TO GS_SELTAB_WA-KIND,      "PARAMETER
          ' '                TO GS_SELTAB_WA-LOW.       "PP일반
    COLLECT GS_SELTAB_WA   INTO GT_SELTAB.

    MOVE: 'R3'               TO GS_SELTAB_WA-SELNAME,
          'P'                TO GS_SELTAB_WA-KIND,      "PARAMETER
          'X'                TO GS_SELTAB_WA-LOW.       "PP일반
    COLLECT GS_SELTAB_WA   INTO GT_SELTAB.
*-{자체개선_51713_추가
    MOVE: 'P_BUKRS'          TO GS_SELTAB_WA-SELNAME,
          'P'                TO GS_SELTAB_WA-KIND,      "PARAMETER
          G_BUKRS            TO GS_SELTAB_WA-LOW.       "PP일반
    COLLECT GS_SELTAB_WA   INTO GT_SELTAB.
*-}자체개선_51713_2014.11.05
    MOVE: 'P_BZAREA'         TO GS_SELTAB_WA-SELNAME,
          'P'                TO GS_SELTAB_WA-KIND,      "PARAMETER
           LV_BZAREA         TO GS_SELTAB_WA-LOW.       "사업장
    COLLECT GS_SELTAB_WA   INTO GT_SELTAB.

    SET PARAMETER ID 'ZIVTYPE' FIELD 'B01'.             "무상사급
*    MOVE: 'P_GUBUN1'         TO GS_SELTAB_WA-SELNAME,
*          'P'                TO GS_SELTAB_WA-KIND,      "PARAMETER
*          '2'                TO GS_SELTAB_WA-LOW.       "통문구분
*    COLLECT GS_SELTAB_WA   INTO GT_SELTAB.

    CLEAR GS_SELTAB_WA.
    MOVE: 'I_CPUDT'          TO GS_SELTAB_WA-SELNAME,
          'P'                TO GS_SELTAB_WA-KIND,      "PARAMETER
           GT_MDSB_W2-CPUDT  TO GS_SELTAB_WA-LOW.       "자재문서발행일
    COLLECT GS_SELTAB_WA   INTO GT_SELTAB.

    CLEAR GS_SELTAB_WA.
    MOVE: 'I_WERKS'          TO GS_SELTAB_WA-SELNAME,
          'P'                TO GS_SELTAB_WA-KIND,      "PARAMETER
           GT_MDSB_W2-WERKS  TO GS_SELTAB_WA-LOW.       "사업단위
    COLLECT GS_SELTAB_WA   INTO GT_SELTAB.

    CLEAR GS_SELTAB_WA.
    MOVE: 'I_MBLNR'          TO GS_SELTAB_WA-SELNAME,
          'P'                TO GS_SELTAB_WA-KIND,      "PARAMETER
           GT_MDSB_W2-MBLNR  TO GS_SELTAB_WA-LOW.       "자재문서
    COLLECT GS_SELTAB_WA   INTO GT_SELTAB.

    CLEAR GS_SELTAB_WA.
    MOVE: 'I_LIFNR'          TO GS_SELTAB_WA-SELNAME,
          'P'                TO GS_SELTAB_WA-KIND,      "PARAMETER
           GT_MDSB_W2-LIFNR  TO GS_SELTAB_WA-LOW.       "거래처
    COLLECT GS_SELTAB_WA   INTO GT_SELTAB.
  ENDLOOP.

  CHECK GV_ERR IS INITIAL. "추가(SJM 25.05.14)

  CHECK NOT GT_SELTAB[] IS INITIAL.
*& 통문증 발행 프로그램 호출...
  SUBMIT ZLER0015 WITH SELECTION-TABLE GT_SELTAB
*&                       VIA SELECTION-SCREEN
                   AND RETURN.

*& 통문증 발행여부 체크...
  LOOP AT GT_MDSB_L WHERE CHECK = 'X'.
    PERFORM CHECK_IV_PRINT_YN_D USING GT_MDSB_L-MBLNR
                                      GT_MDSB_L-MJAHR
                             CHANGING GT_MDSB_L-IV_PRINT_YN
                                      GT_MDSB_L-IV_NO
                                      GT_MDSB_L-IV_DATE.

    IF GT_MDSB_L-IV_PRINT_YN = 'X'.
      GT_MDSB_L-FLAG2 = ICON_LED_GREEN.
    ELSE.
      GT_MDSB_L-FLAG2 = ''.
    ENDIF.

*& CBO 테이블에 반영...
    UPDATE ZPPT0018 SET: OUTPR_F =  GT_MDSB_L-IV_PRINT_YN
                  WHERE  MBLNR   =  GT_MDSB_L-MBLNR
                    AND  MJAHR   =  GT_MDSB_L-MJAHR.

*    UPDATE zppt0018 SET: outpr_f =  gt_mdsb_l-iv_print_yn
*                  WHERE  pswrk   =  gt_mdsb_l-werks
*                    AND  ebeln   =  gt_mdsb_l-ebeln
*                    AND  ebelp   =  gt_mdsb_l-ebelp
*                    AND  matnr   =  gt_mdsb_l-matnr_c
*                    AND  tagnr  <> 'HEADER'.

*(S)기존 로직 오류 개선(SJM 25.05.14)
    MODIFY GT_MDSB_L TRANSPORTING IV_PRINT_YN IV_NO IV_DATE FLAG2
                            WHERE MBLNR = GT_MDSB_L-MBLNR
                              AND MJAHR = GT_MDSB_L-MJAHR.
*   MODIFY GT_MDSB_L.
*(E)기존 로직 오류 개선(SJM 25.05.14)
  ENDLOOP.

*& 인터널 테이블 갱신...
  LOOP AT GT_MDSB_L.
*(S)기존 로직 오류 개선(SJM 25.05.14)
    CLEAR : GT_MDSB_L-IV_PRINT_YN.
    IF GT_MDSB_L-MBLNR IS NOT INITIAL.
*(E)기존 로직 오류 개선(SJM 25.05.14)
      CLEAR  ZPPT0018.
      SELECT SINGLE OUTPR_F INTO GT_MDSB_L-IV_PRINT_YN
               FROM ZPPT0018
              WHERE MBLNR = GT_MDSB_L-MBLNR
                AND MJAHR = GT_MDSB_L-MJAHR.
    ENDIF.

    IF GT_MDSB_L-IV_PRINT_YN = 'X'.
      GT_MDSB_L-FLAG2 = ICON_LED_GREEN.
    ELSE.
      GT_MDSB_L-FLAG2 = ''.
    ENDIF.

    MODIFY GT_MDSB_L.
  ENDLOOP.


  LOOP AT GT_MDSB_W2 WHERE CHECK = 'X'.
    PERFORM CHECK_IV_PRINT_YN_D USING GT_MDSB_W2-MBLNR
                                      GT_MDSB_W2-MJAHR
                             CHANGING GT_MDSB_W2-IV_PRINT_YN
                                      GT_MDSB_W2-IV_NO
                                      GT_MDSB_W2-IV_DATE.

    IF GT_MDSB_W2-IV_PRINT_YN = 'X'.
      GT_MDSB_W2-FLAG2 = ICON_LED_GREEN.
    ELSE.
      GT_MDSB_W2-FLAG2 = ''.
    ENDIF.

*& CBO 테이블에 반영...
    UPDATE ZPPT0018 SET: OUTPR_F =  GT_MDSB_W2-IV_PRINT_YN
                  WHERE  MBLNR   =  GT_MDSB_W2-MBLNR
                    AND  MJAHR   =  GT_MDSB_W2-MJAHR.

*& CBO 테이블에 반영...
*    LOOP AT gt_mdsb_w1 WHERE  matnr_c =  gt_mdsb_w2-matnr_c.
*      UPDATE zppt0018    SET: outpr_f =  gt_mdsb_w2-iv_print_yn
*                       WHERE  pswrk   =  gt_mdsb_w1-werks
*                         AND  ebeln   =  gt_mdsb_w1-ebeln
*                         AND  ebelp   =  gt_mdsb_w1-ebelp
*                         AND  matnr   =  gt_mdsb_w1-matnr_c
*                         AND  tagnr  <> 'HEADER'.
*    ENDLOOP.

    MODIFY GT_MDSB_W2.
  ENDLOOP.

*& 인터널 테이블 갱신...
  LOOP AT GT_MDSB_W2.
*(S)기존 로직 오류 개선(SJM 25.05.14)
    CLEAR : GT_MDSB_W2-IV_PRINT_YN.
    IF GT_MDSB_W2-MBLNR IS NOT INITIAL.
*(E)기존 로직 오류 개선(SJM 25.05.14)
      CLEAR  ZPPT0018.
      SELECT SINGLE OUTPR_F INTO GT_MDSB_W2-IV_PRINT_YN
               FROM ZPPT0018
              WHERE MBLNR = GT_MDSB_W2-MBLNR
                AND MJAHR = GT_MDSB_W2-MJAHR.
    ENDIF.

    IF GT_MDSB_W2-IV_PRINT_YN = 'X'.
      GT_MDSB_W2-FLAG2 = ICON_LED_GREEN.
    ELSE.
      GT_MDSB_W2-FLAG2 = ''.
    ENDIF.

    MODIFY GT_MDSB_W2.
  ENDLOOP.

ENDFORM.                    " submit_zler0015
*&---------------------------------------------------------------------*
*&      Form  submit_zler0016
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SUBMIT_ZLER0016.
  DATA: LV_BZAREA       LIKE ZLET0034-BZAREA.

  REFRESH: GT_SELTAB, GT_LIFNR.
  CLEAR  : GT_SELTAB, GT_LIFNR,
           GV_DBCNT, GV_TABIX, GV_ERROR.

  CLEAR : GV_ERR. "추가(SJM 25.05.14)

*& 동일 업체만 가능...
  LOOP AT GT_EBAN WHERE CHECK = 'X'.
    GT_LIFNR-LIFNR = GT_EBAN-LIFNR.
    COLLECT GT_LIFNR.  CLEAR GT_LIFNR.
  ENDLOOP.

  DESCRIBE TABLE GT_LIFNR LINES GV_DBCNT.
  IF GV_DBCNT > 1.
    MESSAGE S001 WITH '동일 업체가 아닙니다.!!!'.
    EXIT.
  ELSEIF GV_DBCNT < 1.
    MESSAGE S001 WITH '선택한 데이타가 없습니다.!!!'.
    EXIT.
  ENDIF.

*& 사업장코드를 가져온다....
  CLEAR: ZLET0034, LV_BZAREA.
  SELECT SINGLE BZAREA INTO LV_BZAREA
           FROM ZLET0034
          WHERE WERKS = P_WERKS.

*& 길이관리...
  LOOP AT GT_MDSB_L WHERE CHECK = 'X'.
    IF GT_MDSB_L-OUT_YN = 'X'.
      MESSAGE W004 WITH GT_MDSB_L-MBLNR
                '이(가) 통문이 완료되어 취소할 수 없습니다.!!!'.
      GV_ERR = GC_X. "추가(SJM 25.05.14)
      CONTINUE.
    ENDIF.

    IF GT_MDSB_L-IV_PRINT_YN <> 'X'.
      MESSAGE W004 WITH GT_MDSB_L-MBLNR
                '은(는) 통문증 미발행 상태입니다.!!!'.
      GV_ERR = GC_X. "추가(SJM 25.05.14)
      CONTINUE.
    ENDIF.

    MOVE: 'R1'               TO GS_SELTAB_WA-SELNAME,
          'P'                TO GS_SELTAB_WA-KIND,      "PARAMETER
          ' '                TO GS_SELTAB_WA-LOW.       "PP일반
    COLLECT GS_SELTAB_WA   INTO GT_SELTAB.

    MOVE: 'R2'               TO GS_SELTAB_WA-SELNAME,
          'P'                TO GS_SELTAB_WA-KIND,      "PARAMETER
          ' '                TO GS_SELTAB_WA-LOW.       "PP일반
    COLLECT GS_SELTAB_WA   INTO GT_SELTAB.

    MOVE: 'R3'               TO GS_SELTAB_WA-SELNAME,
          'P'                TO GS_SELTAB_WA-KIND,      "PARAMETER
          'X'                TO GS_SELTAB_WA-LOW.       "PP일반
    COLLECT GS_SELTAB_WA   INTO GT_SELTAB.
*-{자체개선_51713_추가
    MOVE: 'P_BUKRS'          TO GS_SELTAB_WA-SELNAME,
          'P'                TO GS_SELTAB_WA-KIND,      "PARAMETER
          G_BUKRS            TO GS_SELTAB_WA-LOW.       "PP일반
    COLLECT GS_SELTAB_WA   INTO GT_SELTAB.
*-}자체개선_51713_2014.11.05
    MOVE: 'P_BZAREA'         TO GS_SELTAB_WA-SELNAME,
          'P'                TO GS_SELTAB_WA-KIND,      "PARAMETER
           LV_BZAREA         TO GS_SELTAB_WA-LOW.       "사업장
    COLLECT GS_SELTAB_WA   INTO GT_SELTAB.

    MOVE: 'P_GUBUN1'         TO GS_SELTAB_WA-SELNAME,
          'P'                TO GS_SELTAB_WA-KIND,      "PARAMETER
          '2'                TO GS_SELTAB_WA-LOW.       "통문구분
    COLLECT GS_SELTAB_WA   INTO GT_SELTAB.

    CLEAR GS_SELTAB_WA.
    MOVE: 'I_DATE'           TO GS_SELTAB_WA-SELNAME,
          'P'                TO GS_SELTAB_WA-KIND,      "PARAMETER
           GT_MDSB_L-IV_DATE TO GS_SELTAB_WA-LOW.       "통문증발행일
    COLLECT GS_SELTAB_WA   INTO GT_SELTAB.

    CLEAR GS_SELTAB_WA.
    MOVE: 'I_WERKS'          TO GS_SELTAB_WA-SELNAME,
          'P'                TO GS_SELTAB_WA-KIND,      "PARAMETER
           GT_MDSB_L-WERKS   TO GS_SELTAB_WA-LOW.       "사업단위
    COLLECT GS_SELTAB_WA   INTO GT_SELTAB.

    CLEAR GS_SELTAB_WA.
    MOVE: 'I_IVNO'           TO GS_SELTAB_WA-SELNAME,
          'P'                TO GS_SELTAB_WA-KIND,      "PARAMETER
           GT_MDSB_L-IV_NO   TO GS_SELTAB_WA-LOW.       "통문증번호
    COLLECT GS_SELTAB_WA   INTO GT_SELTAB.

    CLEAR GS_SELTAB_WA.
    MOVE: 'I_LIFNR'          TO GS_SELTAB_WA-SELNAME,
          'P'                TO GS_SELTAB_WA-KIND,      "PARAMETER
           GT_MDSB_L-LIFNR   TO GS_SELTAB_WA-LOW.       "거래처
    COLLECT GS_SELTAB_WA   INTO GT_SELTAB.

  ENDLOOP.

  CHECK GV_ERR IS INITIAL. "추가(SJM 25.05.14)

*& 중량관리...
  LOOP AT GT_MDSB_W2 WHERE CHECK = 'X'.
    IF GT_MDSB_W2-OUT_YN = 'X'.
      MESSAGE W004 WITH GT_MDSB_L-MBLNR
                '이(가) 통문이 완료되어 취소할 수 없습니다.!!!'.
      GV_ERR = GC_X. "추가(SJM 25.05.14)
      CONTINUE.
    ENDIF.

    IF GT_MDSB_W2-IV_PRINT_YN <> 'X'.
      MESSAGE W004 WITH GT_MDSB_W2-MBLNR
                '은(는) 통문증 미발행 상태입니다.!!!'.
      GV_ERR = GC_X. "추가(SJM 25.05.14)
      CONTINUE.
    ENDIF.

    MOVE: 'R1'               TO GS_SELTAB_WA-SELNAME,
          'P'                TO GS_SELTAB_WA-KIND,      "PARAMETER
          ' '                TO GS_SELTAB_WA-LOW.       "PP일반
    COLLECT GS_SELTAB_WA   INTO GT_SELTAB.

    MOVE: 'R2'               TO GS_SELTAB_WA-SELNAME,
          'P'                TO GS_SELTAB_WA-KIND,      "PARAMETER
          ' '                TO GS_SELTAB_WA-LOW.       "PP일반
    COLLECT GS_SELTAB_WA   INTO GT_SELTAB.

    MOVE: 'R3'               TO GS_SELTAB_WA-SELNAME,
          'P'                TO GS_SELTAB_WA-KIND,      "PARAMETER
          'X'                TO GS_SELTAB_WA-LOW.       "PP일반
    COLLECT GS_SELTAB_WA   INTO GT_SELTAB.
*-{자체개선_51713_추가
    MOVE: 'P_BUKRS'          TO GS_SELTAB_WA-SELNAME,
          'P'                TO GS_SELTAB_WA-KIND,      "PARAMETER
          G_BUKRS            TO GS_SELTAB_WA-LOW.       "PP일반
    COLLECT GS_SELTAB_WA   INTO GT_SELTAB.
*-}자체개선_51713.2014.11.05
    MOVE: 'P_BZAREA'         TO GS_SELTAB_WA-SELNAME,
          'P'                TO GS_SELTAB_WA-KIND,      "PARAMETER
           LV_BZAREA         TO GS_SELTAB_WA-LOW.       "사업장
    COLLECT GS_SELTAB_WA   INTO GT_SELTAB.

    MOVE: 'P_GUBUN1'         TO GS_SELTAB_WA-SELNAME,
          'P'                TO GS_SELTAB_WA-KIND,      "PARAMETER
          '2'                TO GS_SELTAB_WA-LOW.       "통문구분
    COLLECT GS_SELTAB_WA   INTO GT_SELTAB.

    CLEAR GS_SELTAB_WA.
    MOVE: 'I_DATE'           TO GS_SELTAB_WA-SELNAME,
          'P'                TO GS_SELTAB_WA-KIND,      "PARAMETER
           GT_MDSB_W2-IV_DATE   TO GS_SELTAB_WA-LOW.    "통문증발행일
    COLLECT GS_SELTAB_WA   INTO GT_SELTAB.

    CLEAR GS_SELTAB_WA.
    MOVE: 'I_WERKS'          TO GS_SELTAB_WA-SELNAME,
          'P'                TO GS_SELTAB_WA-KIND,      "PARAMETER
           GT_MDSB_W2-WERKS  TO GS_SELTAB_WA-LOW.       "사업단위
    COLLECT GS_SELTAB_WA   INTO GT_SELTAB.

    CLEAR GS_SELTAB_WA.
    MOVE: 'I_IVNO'           TO GS_SELTAB_WA-SELNAME,
          'P'                TO GS_SELTAB_WA-KIND,      "PARAMETER
           GT_MDSB_W2-IV_NO  TO GS_SELTAB_WA-LOW.       "통문증번호
    COLLECT GS_SELTAB_WA   INTO GT_SELTAB.

    CLEAR GS_SELTAB_WA.
    MOVE: 'I_LIFNR'          TO GS_SELTAB_WA-SELNAME,
          'P'                TO GS_SELTAB_WA-KIND,      "PARAMETER
           GT_MDSB_W2-LIFNR  TO GS_SELTAB_WA-LOW.       "거래처
    COLLECT GS_SELTAB_WA   INTO GT_SELTAB.

  ENDLOOP.

  CHECK GV_ERR IS INITIAL. "추가(SJM 25.05.14)

  CHECK NOT GT_SELTAB[] IS INITIAL.
*& 통문증 발행 프로그램 호출...
  SUBMIT ZLER0016 WITH SELECTION-TABLE GT_SELTAB
*&                       VIA SELECTION-SCREEN
                   AND RETURN.

*& 통문증 발행여부 체크...
  LOOP AT GT_MDSB_L WHERE MBLNR <> ''.
    PERFORM CHECK_IV_PRINT_YN_D USING GT_MDSB_L-MBLNR
                                      GT_MDSB_L-MJAHR
                             CHANGING GT_MDSB_L-IV_PRINT_YN
                                      GT_MDSB_L-IV_NO
                                      GT_MDSB_L-IV_DATE.

    IF GT_MDSB_L-IV_PRINT_YN = 'X'.
      GT_MDSB_L-FLAG2 = ICON_LED_GREEN.
    ELSE.
      GT_MDSB_L-FLAG2 = ''.
    ENDIF.

*& CBO 테이블에 반영...
    UPDATE ZPPT0018 SET: OUTPR_F =  GT_MDSB_L-IV_PRINT_YN
                  WHERE  MBLNR   =  GT_MDSB_L-MBLNR
                    AND  MJAHR   =  GT_MDSB_L-MJAHR.

*& 인터널 테이블에 반영...
    MODIFY GT_MDSB_L.
  ENDLOOP.

*& 인터널 테이블 갱신...
  LOOP AT GT_MDSB_L.
*(S)기존 로직 오류 개선(SJM 25.05.14)
    CLEAR : GT_MDSB_L-IV_PRINT_YN.
    IF GT_MDSB_L-MBLNR IS NOT INITIAL.
*(E)기존 로직 오류 개선(SJM 25.05.14)
      CLEAR  ZPPT0018.
      SELECT SINGLE OUTPR_F INTO GT_MDSB_L-IV_PRINT_YN
               FROM ZPPT0018
              WHERE MBLNR = GT_MDSB_L-MBLNR
                AND MJAHR = GT_MDSB_L-MJAHR.
    ENDIF.

    IF GT_MDSB_L-IV_PRINT_YN = 'X'.
      GT_MDSB_L-FLAG2 = ICON_LED_GREEN.
    ELSE.
      GT_MDSB_L-FLAG2 = ''.
    ENDIF.

    MODIFY GT_MDSB_L.
  ENDLOOP.


  LOOP AT GT_MDSB_W2 WHERE MBLNR <> ' '.
    PERFORM CHECK_IV_PRINT_YN_D USING GT_MDSB_W2-MBLNR
                                      GT_MDSB_W2-MJAHR
                             CHANGING GT_MDSB_W2-IV_PRINT_YN
                                      GT_MDSB_W2-IV_NO
                                      GT_MDSB_W2-IV_DATE.

    IF GT_MDSB_W2-IV_PRINT_YN = 'X'.
      GT_MDSB_W2-FLAG2 = ICON_LED_GREEN.
    ELSE.
      GT_MDSB_W2-FLAG2 = ''.
    ENDIF.

*& CBO 테이블에 반영...
    UPDATE ZPPT0018    SET: OUTPR_F =  GT_MDSB_W2-IV_PRINT_YN
                     WHERE  MBLNR   =  GT_MDSB_W2-MBLNR
                       AND  MJAHR   =  GT_MDSB_W2-MJAHR.

*& 인터널 테이블에 반영...
    MODIFY GT_MDSB_W2.
  ENDLOOP.

*& 인터널 테이블 갱신...
  LOOP AT GT_MDSB_W2.
*(S)기존 로직 오류 개선(SJM 25.05.14)
    CLEAR : GT_MDSB_W2-IV_PRINT_YN.
    IF GT_MDSB_W2-MBLNR IS NOT INITIAL.
*(E)기존 로직 오류 개선(SJM 25.05.14)
      CLEAR  ZPPT0018.
      SELECT SINGLE OUTPR_F INTO GT_MDSB_W2-IV_PRINT_YN
               FROM ZPPT0018
              WHERE MBLNR = GT_MDSB_W2-MBLNR
                AND MJAHR = GT_MDSB_W2-MJAHR.
    ENDIF.

    IF GT_MDSB_W2-IV_PRINT_YN = 'X'.
      GT_MDSB_W2-FLAG2 = ICON_LED_GREEN.
    ELSE.
      GT_MDSB_W2-FLAG2 = ''.
    ENDIF.

    MODIFY GT_MDSB_W2.
  ENDLOOP.

ENDFORM.                    " submit_zler0016
*&---------------------------------------------------------------------*
*&      Form  check_iv_print_yn_h
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_IV_PRINT_YN_H USING PV_EBELN
                               PV_EBELP
                      CHANGING PV_FLAG2.

  SELECT SINGLE A~MANDT        INTO ZPPT0018-MANDT
           FROM ZPPT0018 AS A INNER JOIN ZLET0006 AS B
                                 ON A~MBLNR = B~MBLNR AND
                                    A~MJAHR = B~MJAHR
                              INNER JOIN ZLET0005 AS C
                                 ON B~IV_NO = C~IV_NO
          WHERE A~EBELN        =  PV_EBELN
            AND A~EBELP        =  PV_EBELP
            AND A~TAGNR       <> 'HEADER'
            AND C~IV_CANCEL_YN =  SPACE.
  IF SY-SUBRC = 0.
    SELECT SINGLE C~IV_CANCEL_YN INTO ZLET0005-IV_CANCEL_YN
             FROM ZPPT0018 AS A INNER JOIN ZLET0006 AS B
                                   ON A~MBLNR = B~MBLNR AND
                                      A~MJAHR = B~MJAHR
                                INNER JOIN ZLET0005 AS C
                                   ON B~IV_NO = C~IV_NO
            WHERE A~EBELN        =  PV_EBELN
              AND A~EBELP        =  PV_EBELP
              AND A~TAGNR       <> 'HEADER'
              AND C~IV_PRINT_YN  =  SPACE.
    IF SY-SUBRC <> 0.
      PV_FLAG2 = 'X'.
    ELSE.
      PV_FLAG2 = ' '.
    ENDIF.
  ENDIF.

ENDFORM.                    " check_iv_print_yn_h

*&---------------------------------------------------------------------*
*&      Form  check_iv_print_yn_d
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHECK_IV_PRINT_YN_D USING PV_MBLNR
                               PV_MJAHR
                      CHANGING PV_IV_PRINT_YN
                               PV_IV_NO
                               PV_IV_DATE.

  CLEAR: PV_IV_PRINT_YN, PV_IV_NO, PV_IV_DATE.
  SELECT SINGLE B~IV_PRINT_YN B~IV_NO B~IV_DATE
    INTO (PV_IV_PRINT_YN, PV_IV_NO, PV_IV_DATE)
    FROM ZLET0006 AS A  INNER JOIN ZLET0005 AS B
                                ON A~IV_NO = B~IV_NO
   WHERE A~MBLNR        = PV_MBLNR
     AND A~MJAHR        = PV_MJAHR
     AND B~IV_CANCEL_YN = SPACE.

ENDFORM.                    " check_iv_print_yn_d
*&---------------------------------------------------------------------*
*&      Form  bapi_purchase_order_delete
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM BAPI_PURCHASE_ORDER_DELETE .
  DATA   : LT_BAPI_ITEMS     LIKE BAPIEKPO OCCURS 0 WITH HEADER LINE,
           LT_BAPI_SCHEDULES LIKE BAPIEKET OCCURS 0 WITH HEADER LINE.

  REFRESH: GT_BAPI_TEXTHEADER,
           GT_BAPI_PARTNER,
           GT_BAPI_ITEM,
           GT_BAPI_ITEMX,
           GT_BAPI_SCHEDULE,
           GT_BAPI_SCHEDULEX,
           GT_BAPI_EXPIMPITEM,
           GT_BAPI_EXPIMPITEMX,
           GT_BAPI_TEXTITEM,
           GT_BAPI_COND,
           GT_BAPI_CONDX,
           GT_RET1,
           GT_RET2,
           LT_BAPI_ITEMS.

  CLEAR:   GT_BAPI_TEXTHEADER,
           GT_BAPI_PARTNER,
           GT_BAPI_ITEM,
           GT_BAPI_ITEMX,
           GT_BAPI_SCHEDULE,
           GT_BAPI_SCHEDULEX,
           GT_BAPI_EXPIMPITEM,
           GT_BAPI_EXPIMPITEMX,
           GT_BAPI_TEXTITEM,
           GT_BAPI_COND,
           GT_BAPI_CONDX,
           GT_RET1,
           GT_RET2,
           LT_BAPI_ITEMS.

  CLEAR:   GS_BAPI_HEADER,
           GS_BAPI_HEADERX,
           GS_BAPI_VENDOR,
           GS_BAPI_EXPIMPHEADER,
           GS_BAPI_EXPIMPHEADERX.

*& P/O Header 구성...
*  gs_bapi_header-delete_ind       = 'C'.   "구매문서상 삭제지시자
*& P/O Header(변경툴바) 구성...
*  gs_bapi_headerx-delete_ind      = 'X'.   "구매문서상 삭제지시자

*& P/O Item 구성...
  GT_BAPI_ITEM-PO_ITEM            = '10'.             "구매문서 품목번호
  GT_BAPI_ITEM-DELETE_IND         = 'L'.   "구매문서상 삭제지시자
  APPEND GT_BAPI_ITEM.         CLEAR GT_BAPI_ITEM.
*& P/O Item(변경툴바) 구성...
  GT_BAPI_ITEMX-PO_ITEM           =  '10'.            "구매문서 품목번호
  GT_BAPI_ITEMX-PO_ITEMX          =  'X'.             "구매문서 품목번호
  GT_BAPI_ITEMX-DELETE_IND        =  'X'.  "구매문서상 삭제지시자
  APPEND GT_BAPI_ITEMX.        CLEAR  GT_BAPI_ITEMX.

*& 구매오더를 삭제한다...
  CALL FUNCTION 'BAPI_PO_CHANGE'
    EXPORTING
      PURCHASEORDER = GT_EBAN-EBELN
      POHEADER      = GS_BAPI_HEADER
      POHEADERX     = GS_BAPI_HEADERX
*&            poaddrvendor             = gs_bapi_vendor
      TESTRUN       = GV_TESTRUN
*&            MEMORY_UNCOMPLETE        =
*&            MEMORY_COMPLETE          =
*&            poexpimpheader           = gs_bapi_expimpheader
*&            poexpimpheaderx          = gs_bapi_expimpheaderx
*&            VERSIONS                 =
*&            NO_MESSAGING             =
*&            NO_MESSAGE_REQ           =
*&            NO_AUTHORITY             =
*&            NO_PRICE_FROM_PO         =
*&       IMPORTING
*&            EXPHEADER                =
*&            EXPPOEXPIMPHEADER        =
    TABLES
      RETURN        = GT_RET2
      POITEM        = GT_BAPI_ITEM
      POITEMX       = GT_BAPI_ITEMX.
*&            poschedule               = gt_bapi_schedule
*&            poschedulex              = gt_bapi_schedulex.
*&            pocond                   = gt_bapi_cond
*&            pocondx                  = gt_bapi_condx
*&            poexpimpitem             = gt_bapi_expimpitem
*&            poexpimpitemx            = gt_bapi_expimpitemx
*&            potextheader             = gt_bapi_textheader
*&            potextitem               = gt_bapi_textitem
*&            popartner                = gt_bapi_partner.

  READ TABLE GT_RET2 WITH KEY TYPE = 'E'.
  IF SY-SUBRC <> 0.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.

* CSR : C2006061201000000279
* 2006.07.03 구매오더 삭제시 구매요청 마감지시자 체크(이상갑K)

    IF GT_EBAN-BANFN IS NOT INITIAL.
      PERFORM PR_END_CHECK USING GT_EBAN-MATNR
                                 GT_EBAN-BANFN          "구매요청 번호
                                 GT_EBAN-BNFPO          "구매요청 품목
                                 'X'.
      "생성(' '),삭제('X')
    ENDIF.

*& CBO 테이블에 저장...
    PERFORM UPDATE_ZPPT0018_PROC.

*& 삭제된 구매오더를 인터널 테이블에 반영...
    CLEAR: GT_EBAN-EBELN, GT_EBAN-EBELP.
    MODIFY GT_EBAN INDEX GV_TABIX
            TRANSPORTING EBELN EBELP.

    CLEAR GT_MSG.
    MOVE: GT_RET2-LOG_NO      TO GT_MSG-LOGNO,
          GT_RET2-LOG_MSG_NO  TO GT_MSG-MSGSQ,
          GT_RET2-ID          TO GT_MSG-MSGID,
          GT_RET2-TYPE        TO GT_MSG-MSGTY,
          GT_RET2-NUMBER      TO GT_MSG-MSGNO,
          GT_RET2-MESSAGE_V1  TO GT_MSG-MSGV1,
          GT_RET2-MESSAGE_V2  TO GT_MSG-MSGV2,
          GT_RET2-MESSAGE_V3  TO GT_MSG-MSGV3,
          GT_RET2-MESSAGE_V4  TO GT_MSG-MSGV4,
          GT_RET2-MESSAGE     TO GT_MSG-MSGTX,
          GT_EBAN-EBELN       TO GT_MSG-REFNO,
          GT_EBAN-EBELP       TO GT_MSG-REFIT.

    APPEND GT_MSG.         CLEAR GT_MSG.

  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    CLEAR GT_MSG.
    LOOP AT GT_RET2.
      MOVE: GT_RET2-LOG_NO      TO GT_MSG-LOGNO,
            GT_RET2-LOG_MSG_NO  TO GT_MSG-MSGSQ,
            GT_RET2-ID          TO GT_MSG-MSGID,
            GT_RET2-TYPE        TO GT_MSG-MSGTY,
            GT_RET2-NUMBER      TO GT_MSG-MSGNO,
            GT_RET2-MESSAGE_V1  TO GT_MSG-MSGV1,
            GT_RET2-MESSAGE_V2  TO GT_MSG-MSGV2,
            GT_RET2-MESSAGE_V3  TO GT_MSG-MSGV3,
            GT_RET2-MESSAGE_V4  TO GT_MSG-MSGV4,
            GT_RET2-MESSAGE     TO GT_MSG-MSGTX,
            GT_EBAN-EBELN       TO GT_MSG-REFNO,
            GT_EBAN-EBELP       TO GT_MSG-REFIT.

      APPEND GT_MSG.         CLEAR GT_MSG.
    ENDLOOP.

  ENDIF.
ENDFORM.                    " bapi_purchase_order_delete
*&---------------------------------------------------------------------*
*&      Form  update_zppt0018_proc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM UPDATE_ZPPT0018_PROC .
  UPDATE ZPPT0018 SET: LOEKZ  = 'X'
                WHERE  PSWRK  =  GT_EBAN-WERKS
                  AND  EBELN  =  GT_EBAN-EBELN
                  AND  EBELP  =  GT_EBAN-EBELP.
*&                  AND  matnr  =  gt_eban-matnr
*&                  AND  tagnr  = 'HEADER'.
ENDFORM.                    " update_zppt0018_proc
*&---------------------------------------------------------------------*
*&      Form  popup_to_confirm_step
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_0078   text
*      -->P_0079   text
*      -->P_0080   text
*      -->P_0081   text
*----------------------------------------------------------------------*
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

ENDFORM.                    " popup_to_confirm_step
*&---------------------------------------------------------------------*
*&      Form  zmm_ekpo_spec_get
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ZMM_EKPO_SPEC_GET USING PV_EBELN
                             PV_EBELP
                    CHANGING PV_LENGTH
                             PV_FACTOR
                             PV_PACKING_CAT
                             PV_PACKING.

  DATA: LS_RETURN TYPE BAPIRET2_T.
  DATA: LT_CHAR   LIKE E1CUVAL OCCURS 0 WITH HEADER LINE.
  DATA: LV_VALUE_0(16) TYPE P DECIMALS 0,
        LV_VALUE_3(16) TYPE P DECIMALS 3.

  CLEAR: PV_LENGTH, PV_FACTOR.
*& 특성값 가져오기........................
  CALL FUNCTION 'ZMM_EKPO_SPEC_GET'
    EXPORTING
      EBELN                        = PV_EBELN
      EBELP                        = PV_EBELP
    IMPORTING
      ET_RETURN                    = LS_RETURN
    TABLES
      T_E1CUVAL                    = LT_CHAR
    EXCEPTIONS
      INSTANCE_NOT_FOUND           = 1
      INTERNAL_ERROR               = 2
      INSTANCE_IS_A_CLASSIFICATION = 3
      OTHERS                       = 4.

  CHECK SY-SUBRC = 0.
  LOOP AT LT_CHAR.
    CASE LT_CHAR-CHARC.
      WHEN 'SAP_MILLCA_LENGTH'.          "조장(기본단위)
        PERFORM CHAR_FLTP_CONVERSION USING LT_CHAR-VALUE
                                  CHANGING PV_LENGTH. "lv_value_3.
*&        WRITE lv_value_3                TO pv_length.

      WHEN 'SAP_MILLCA_FACTOR'.          "조장수
        PERFORM CHAR_FLTP_CONVERSION USING LT_CHAR-VALUE
                                  CHANGING PV_FACTOR. "lv_value_0.
*&        WRITE lv_value_0                TO pv_factor.

      WHEN 'SAP_MILLCA_PACKAGING_CAT'.   "포장재유형
        PV_PACKING_CAT = LT_CHAR-VALUE_TXT.

      WHEN 'SAP_MILLCA_PACKAGING'.       "포장재
        PV_PACKING = LT_CHAR-VALUE.

      WHEN  OTHERS.
    ENDCASE.
  ENDLOOP.
ENDFORM.                    " zmm_ekpo_spec_get
*&---------------------------------------------------------------------*
*&      Form  char_fltp_conversion
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LT_E1CUVAL_VALUE  text
*      <--P_LV_VALUE_3  text
*----------------------------------------------------------------------*
FORM CHAR_FLTP_CONVERSION  USING    PV_VALUE_S
                           CHANGING PV_VALUE_P.

  DATA: LV_FLTP     LIKE RSCVP-VALU1,
        LV_PACK(16) TYPE P DECIMALS 3.

  CALL FUNCTION 'CHAR_FLTP_CONVERSION'
    EXPORTING
      STRING          = PV_VALUE_S
    IMPORTING
      FLSTR           = LV_FLTP
*&      ivalu           = x_ival
    EXCEPTIONS
      STRING_NOT_FLTP = 1.

  PV_VALUE_P = LV_FLTP.

ENDFORM.                    " char_fltp_conversion
*&---------------------------------------------------------------------*
*&      Form  update_zppt0018_l_cancel
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM UPDATE_ZPPT0018_L_CANCEL .
*& 길이관리 사급자재...
  DELETE FROM ZPPT0018 WHERE MBLNR   =  GT_MDSB_L-MBLNR
                         AND MJAHR   =  GT_MDSB_L-MJAHR.
*  UPDATE zppt0018 SET: enmng   =  ''
*                       lgort   =  ''
*                       mblnr   =  ''
*                       mblnr_f =  ''
*                       mjahr   =  ''
*                       charg   =  ''
*                       scqty   =  ''
*                WHERE  mblnr   =  gt_mdsb_l-mblnr
*                  AND  mjahr   =  gt_mdsb_l-mjahr.

*                WHERE  pswrk   =  gt_mdsb_l-werks
*                  AND  ebeln   =  gt_mdsb_l-ebeln
*                  AND  ebelp   =  gt_mdsb_l-ebelp
*                  AND  matnr   =  gt_mdsb_l-matnr_c
*                  AND  tagnr   =  gt_mdsb_l-tagnr.

ENDFORM.                    " update_zppt0018_l_cancel
*&---------------------------------------------------------------------*
*&      Form  update_zppt0018_w2_cancel
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM UPDATE_ZPPT0018_W2_CANCEL USING PV_MBLNR
                                     PV_MJAHR.
*& 중량관리 사급자재...
  UPDATE ZPPT0018   SET: ENMNG   =  ''
                         MEINS   =  ''
                         MBLNR   =  ''
                         MBLNR_F =  ''
                         MJAHR   =  ''
                         LOTNO   =  ''
                         SCQTY   =  ''
                  WHERE  MBLNR   =  PV_MBLNR
                    AND  MJAHR   =  PV_MJAHR.


*  LOOP AT gt_mdsb_w1 WHERE  matnr_c =  gt_mdsb_w2-matnr_c.
*    UPDATE zppt0018    SET: enmng   =  ''
*                            meins   =  ''
*                            mblnr   =  ''
*                            mblnr_f =  ''
*                            mjahr   =  ''
*                            lotno   =  ''
*                            scqty   =  ''
*                     WHERE  pswrk   =  gt_mdsb_w1-werks
*                       AND  ebeln   =  gt_mdsb_w1-ebeln
*                       AND  ebelp   =  gt_mdsb_w1-ebelp
*                       AND  matnr   =  gt_mdsb_w1-matnr_c.
*  ENDLOOP.
ENDFORM.                    " update_zppt0018_w2_cancel
*&---------------------------------------------------------------------*
*&      Form  call_material_master
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CALL_MATERIAL_MASTER USING PV_MATNR
                                PV_WERKS.

  DATA : BEGIN OF LT_OBJECTX OCCURS 10.
           INCLUDE STRUCTURE IOPICK.
  DATA : END   OF LT_OBJECTX.

  REFRESH: LT_OBJECTX.   CLEAR LT_OBJECTX.
  MOVE 'PLAF-MATNR'         TO LT_OBJECTX-NAME.
  MOVE  PV_MATNR            TO LT_OBJECTX-VALUE.
  APPEND LT_OBJECTX.

  MOVE 'PLAF-PLWRK'         TO LT_OBJECTX-NAME.
  MOVE  PV_WERKS            TO LT_OBJECTX-VALUE.
  APPEND LT_OBJECTX.

  MOVE '%D'                 TO LT_OBJECTX-NAME.
  MOVE 'D'                  TO LT_OBJECTX-VALUE.
  APPEND LT_OBJECTX.

  CALL FUNCTION 'MASTER_DATA'
    EXPORTING
      PROGRAM          = 'SAPLM61O'
      DATENFELD        = 'PLAF-MATNR'
    TABLES
      IOBJECT          = LT_OBJECTX
    EXCEPTIONS
      OBJECT_NOT_FOUND = 1
      FIELD_IS_INITIAL = 2
      OTHERS           = 3.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE SY-MSGTY
                      NUMBER SY-MSGNO
                        WITH SY-MSGV1
                             SY-MSGV2
                             SY-MSGV3
                             SY-MSGV4.
  ENDIF.

ENDFORM.                    " call_material_master
*&---------------------------------------------------------------------*
*&      Form  inset_line_proc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM INSET_LINE_PROC .
  DATA : LV_MEINS      LIKE EKPO-MEINS,
         LV_MENGE      LIKE EKPO-MENGE,
         LV_EKPO_MENGE LIKE EKPO-MENGE.

  SELECT SINGLE A~WERKS A~DISPO A~EKGRP A~MATNR A~TXZ01
                A~BANFN A~BNFPO A~MENGE A~LFDAT A~BSMNG
                A~MEINS A~LGORT A~PSTYP A~BSART A~BSTYP
                A~FLIEF AS LIFNR
                B~MTART B~MATKL B~DPCBT B~BSTME AS MEINS_A
                B~SPART
    INTO CORRESPONDING FIELDS OF GT_EBAN_N
    FROM EBAN AS A INNER JOIN MARA AS B
                           ON A~MATNR = B~MATNR
   WHERE A~BANFN  =  GT_EBAN-BANFN
     AND A~BNFPO  =  GT_EBAN-BNFPO
     AND A~PSTYP  IN ('0', '3')
     AND A~STATU  = 'B'
     AND A~FLIEF  IN  S_LIFNR
     AND A~MENGE   > ( SELECT SUM( MENGE )
                         FROM EKPO
                        WHERE BANFN = A~BANFN
                          AND BNFPO = A~BNFPO
                          AND LOEKZ = SPACE )
     AND B~MATKL LIKE  GV_MATKL.

  CHECK SY-SUBRC = 0.

  CLEAR : LV_MEINS, LV_MENGE, LV_EKPO_MENGE.

  SELECT MEINS SUM( MENGE )
    INTO (LV_MEINS, LV_MENGE)
    FROM EKPO
   WHERE BANFN = GT_EBAN_N-BANFN
     AND BNFPO = GT_EBAN_N-BNFPO
     AND LOEKZ = SPACE
  GROUP BY MEINS
  ORDER BY MEINS.
  ENDSELECT.

  IF GT_EBAN_N-MEINS IS NOT INITIAL AND
     LV_MEINS IS NOT INITIAL AND
     ( GT_EBAN_N-MEINS <> LV_MEINS ).
    "구매요청단위와 구매오더단위가 다를때 환산

*& 단위수량 컨버젼...

    PERFORM MD_CONVERT_MATERIAL_UNIT USING GT_EBAN_N-MATNR
                                           LV_MEINS
                                           GT_EBAN_N-MEINS
                                  CHANGING LV_MENGE.
    IF GT_EBAN_N-MENGE =< LV_MENGE.

      CLEAR : GT_EBAN_N.



    ENDIF.

  ENDIF.

  IF GT_EBAN_N IS NOT INITIAL.

*& 구매문서의 품목범주(I.C) Conversion...
    CALL FUNCTION 'ME_ITEM_CATEGORY_OUTPUT'
      EXPORTING
        PSTYP = GT_EBAN_N-PSTYP
      IMPORTING
        EPSTP = GT_EBAN_N-EPSTP.
*&        ptext = t163y-ptext.

    PERFORM GET_LIFNR_NAME1 USING GT_EBAN_N-LIFNR
                         CHANGING GT_EBAN_N-NAME1.

*& 구매요청 잔량...
    CLEAR  EKPO.
    SELECT MEINS SUM( MENGE )
          INTO (EKPO-MEINS, EKPO-MENGE)
          FROM EKPO
         WHERE BANFN = GT_EBAN-BANFN
           AND BNFPO = GT_EBAN-BNFPO
           AND LOEKZ = SPACE
         GROUP BY MEINS
         ORDER BY MEINS.
    ENDSELECT.


    IF GT_EBAN-MEINS IS NOT INITIAL AND
    "구매요청과 구매오더의 단위가 틀릴 경우
       EKPO-MEINS IS NOT INITIAL AND
       ( GT_EBAN-MEINS <> EKPO-MEINS ).

      LV_EKPO_MENGE = EKPO-MENGE.

      PERFORM MD_CONVERT_MATERIAL_UNIT USING GT_EBAN_N-MATNR
                                             EKPO-MEINS
                                             GT_EBAN_N-MEINS
                                      CHANGING LV_EKPO_MENGE.

      GT_EBAN_N-MENGE_B = GT_EBAN_N-MENGE - LV_EKPO_MENGE.


      PERFORM MD_CONVERT_MATERIAL_UNIT USING GT_EBAN_N-MATNR
                                             GT_EBAN_N-MEINS
                                             EKPO-MEINS
                                    CHANGING GT_EBAN_N-MENGE.

      GT_EBAN_N-MENGE_A = GT_EBAN_N-MENGE - EKPO-MENGE.

    ELSE.

      GT_EBAN_N-MENGE_B = GT_EBAN_N-MENGE - EKPO-MENGE.
      GT_EBAN_N-MENGE_A = GT_EBAN_N-MENGE_B.
    ENDIF.



*& 구매요청의 특성값(조장)...
    PERFORM CHARACTERISTIC_FOR_PR USING GT_EBAN_N-BANFN
                                        GT_EBAN_N-BNFPO
                               CHANGING GT_EBAN_N-LENGTH_V.

    WRITE: GT_EBAN_N-LENGTH_V        TO GT_EBAN_N-LENGTH.

    IF NOT GT_EBAN_N-DPCBT IS INITIAL.
      IF NOT GT_EBAN_N-LENGTH_V IS INITIAL.
        GT_EBAN_N-FACTOR_V = GT_EBAN_N-MENGE_B /
                             GT_EBAN_N-LENGTH_V.
        WRITE: GT_EBAN_N-FACTOR_V    TO GT_EBAN_N-FACTOR.
      ENDIF.
    ENDIF.

*& Single Unit Batch인 경우, 구매요청 잔량을 외주지시,
*& 개별길이로 제안, 조장수는 1을 제안...
*  IF gt_eban_n-dpcbt EQ 'C'.
*    gt_eban_n-menge_a = gt_eban_n-menge_b.
*    gt_eban_n-factor  = 1.
*    WRITE gt_eban_n-menge_b    TO gt_eban_n-length.
*  ENDIF.

*& 전체품명 체크...
    IF GT_EBAN-MTART = 'MCFE'.
      CLEAR  MARA.
      SELECT SINGLE ZZMAKTX80 INTO MARA-ZZMAKTX80
               FROM MARA
              WHERE MATNR = GT_EBAN-MATNR.
      IF NOT MARA-ZZMAKTX80 IS INITIAL.
        GT_EBAN-TXZ01 = MARA-ZZMAKTX80.
      ENDIF.
    ENDIF.

    APPEND GT_EBAN_N.         CLEAR GT_EBAN_N.

  ENDIF.

ENDFORM.                    " inset_line_proc
*&---------------------------------------------------------------------*
*&      Form  modify_purchase_order_bdc_l
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MODIFY_PURCHASE_ORDER_BDC_L .
  REFRESH: GT_BDCDATA, GT_MSGCOLL.
  CLEAR  : GT_BDCDATA, GT_MSGCOLL.

  PERFORM DYNPRO USING:
    'X'  'SAPLMEGUI'               '0014',
    ' '  'BDC_OKCODE'              '=MECHOB'.

  PERFORM DYNPRO USING:
    'X'  'SAPLMEGUI'               '0002',
    ' '  'BDC_OKCODE'              '=MEOK',
    ' '  'BDC_CURSOR'              'MEPO_SELECT-EBELN',
    ' '  'MEPO_SELECT-EBELN'        GT_MDSB_L-EBELN,  "구매오더번호
    ' '  'MEPO_SELECT-BSTYP_F'     'X'.               "구매오더선택

  PERFORM DYNPRO USING:                               "자재데이타
    'X'  'SAPLMEGUI'              '0014',
    ' '  'BDC_OKCODE'             '=TABIDT3'.

  PERFORM DYNPRO USING:                               "구성부품
    'X'  'SAPLMEGUI'              '0014',
    ' '  'BDC_OKCODE'             '=MEPO1319BOM'.

  PERFORM DYNPRO USING:                               "찾기
    'X'  'SAPLM61Q'               '0115',
    ' '  'BDC_OKCODE'             '=SUCH',
    ' '  'BDC_CURSOR'             'MDPM-MATNR(01)'.

  PERFORM DYNPRO USING:                               "찾기
    'X'  'SAPLM61Q'              '0300',
    ' '  'BDC_OKCODE'            '=SUCH',
*&    ' '  'SUCHL-MATNR'            gt_mdsb_l-matnr_c. "사급자재
    ' '  'SUCHL-POSNR'            GT_MDSB_L-POSNR.    "품목번호

  PERFORM DYNPRO USING:                               "
    'X'  'SAPLM61Q'              '0115',
    ' '  'BDC_OKCODE'            '/00',
    ' '  'MDPM-CHARG(01)'         GT_MDSB_L-CHARG.

  PERFORM DYNPRO USING:                               "
    'X'  'SAPLM61Q'              '0115',
    ' '  'BDC_OKCODE'            '=BACK'.

  PERFORM DYNPRO USING:                               "구성부품
    'X'  'SAPLMEGUI'             '0014',
    ' '  'BDC_OKCODE'            '=MESAVE'.

  CALL TRANSACTION 'ME22N'          "Transaction Call.
             USING GT_BDCDATA
           OPTIONS FROM GS_BDCPARAMS
          MESSAGES INTO GT_MSGCOLL.

  READ TABLE GT_MSGCOLL WITH KEY MSGTYP = 'E'.
  IF SY-SUBRC = 0.
    GT_MSGCOLL-MSGTYP = 'W'.
    MESSAGE ID GT_MSGCOLL-MSGID TYPE GT_MSGCOLL-MSGTYP
                              NUMBER GT_MSGCOLL-MSGNR
                                WITH GT_MSGCOLL-MSGV1
                                     GT_MSGCOLL-MSGV2
                                     GT_MSGCOLL-MSGV3
                                     GT_MSGCOLL-MSGV4.
  ENDIF.

ENDFORM.                    " modify_purchase_order_bdc_l
*&---------------------------------------------------------------------*
*&      Form  md_convert_material_unit
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_MDSB_W3_MATNR_C  text
*      -->P_GT_MDSB_W3_MEINS  text
*      -->P_GT_MDSB_W3_AUSME  text
*      <--P_GT_MDSB_W2_ENMNG  text
*----------------------------------------------------------------------*
FORM MD_CONVERT_MATERIAL_UNIT  USING    PV_MATNR
                                        PV_IN_MEINS
                                        PV_OUT_MEINS
                               CHANGING PV_MENGE.

  CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
    EXPORTING
      I_MATNR              = PV_MATNR
      I_IN_ME              = PV_IN_MEINS
      I_OUT_ME             = PV_OUT_MEINS
      I_MENGE              = PV_MENGE
    IMPORTING
      E_MENGE              = PV_MENGE
    EXCEPTIONS
      ERROR_IN_APPLICATION = 1
      ERROR                = 2.
  IF SY-SUBRC <> 0.
    MESSAGE E001 WITH '단위 컨버젼 에러.!!!'.
  ENDIF.
ENDFORM.                    " md_convert_material_unit
*&---------------------------------------------------------------------*
*&      Form  refresh_gt_eban
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM REFRESH_GT_EBAN .
  LOOP AT GT_EBAN WHERE CHECK = 'X'.
    IF NOT GT_EBAN-EBELN IS INITIAL.
*& 이전전기 여부...
      SELECT SINGLE MANDT INTO ZPPT0018-MANDT
               FROM ZPPT0018
              WHERE EBELN = GT_EBAN-EBELN
                AND EBELP = GT_EBAN-EBELP
                AND ( MBLNR_F = 'X' OR MBLNR   = SPACE ).
      IF SY-SUBRC <> 0.
        GT_EBAN-FLAG1 = 'X'.
      ELSE.
        GT_EBAN-FLAG1 = ' '.
      ENDIF.

*& LOSS율...
      CLEAR  ZPPT0018.
      SELECT SINGLE LOSSR INTO GT_EBAN-LOSSR
               FROM ZPPT0018
              WHERE PSWRK  =  GT_EBAN-WERKS
                AND EBELN  =  GT_EBAN-EBELN
                AND EBELP  =  GT_EBAN-EBELP
                AND TAGNR <> 'HEADER'
                AND LOSSR <>  SPACE.

    ENDIF.
*& 통문증 발행 여부...
    IF NOT GT_EBAN-EBELN IS INITIAL.
      PERFORM CHECK_IV_PRINT_YN_H USING GT_EBAN-EBELN
                                        GT_EBAN-EBELP
                               CHANGING GT_EBAN-FLAG2.
    ENDIF.

*& 구매문서의 특성값(조장, 조장수)...
    PERFORM ZMM_EKPO_SPEC_GET USING GT_EBAN-EBELN
                                    GT_EBAN-EBELP
                           CHANGING GT_EBAN-LENGTH_V
                                    GT_EBAN-FACTOR_V
                                    GT_EBAN-PACKING_CAT
                                    GT_EBAN-PACKING.

    WRITE: GT_EBAN-LENGTH_V       TO GT_EBAN-LENGTH,
           GT_EBAN-FACTOR_V       TO GT_EBAN-FACTOR.

*&    gt_eban-length      = gv_length.
*&    gt_eban-factor      = gv_factor.
*&    gt_eban-packing_cat = gv_packing_cat.

    MODIFY GT_EBAN.
  ENDLOOP.
ENDFORM.                    " refresh_gt_eban
*&---------------------------------------------------------------------*
*&      Form  display_length_ord_detail
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DISPLAY_LENGTH_ORD_DETAIL .
  DATA: BEGIN OF LS_ZPDS0007,
          ORDNO(12),
          ITEM_NUMBER(6),
        END   OF LS_ZPDS0007.

  READ TABLE GT_MDSB_L WITH KEY CHECK = 'X'.
  CHECK SY-SUBRC = 0.
  CLEAR LS_ZPDS0007.
  LS_ZPDS0007-ORDNO = GT_MDSB_L-EBELN.

*& RFC Destination 을 가져온다...
  CALL FUNCTION 'Z_PD_DISPLAY_LENGTH_ORD_DETAIL'
    DESTINATION GV_RFCDEST
    EXPORTING
      LOGICAL_SYSTEM          = GV_RFCLOCL
      SPEC_ORDER              = LS_ZPDS0007
    EXCEPTIONS
      INVALID_ORDER_SELECTION = 1
      INVALID_ORDER           = 2
      ROUTING_READ_ERROR      = 3
      OTHERS                  = 4.

  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE 'I' NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    " display_length_ord_detail
*&---------------------------------------------------------------------*
*&      Form  mm_doc_cancel_bapi
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MM_DOC_CANCEL_BAPI.
  DATA: BEGIN OF LT_MBLNR OCCURS 0,
          MBLNR LIKE MSEG-MBLNR,
          MJAHR LIKE MSEG-MJAHR,
          BUDAT LIKE MKPF-BUDAT,
        END   OF LT_MBLNR.

  DATA : LV_TNM TYPE TABNAME. "추가(SJM 25.05.14)

  REFRESH GT_MSG. CLEAR GT_MSG.
  CLEAR : GT_WIF[]. "추가(SJM 25.06.11)

*& 길이관리...
  CLEAR : GV_TABIX.
  LOOP AT GT_MDSB_L WHERE CHECK = 'X'.
    GV_TABIX = SY-TABIX.

    PERFORM MM_DOC_CANCEL_BAPI_L USING GT_MDSB_L-MBLNR.

  ENDLOOP.
*& 인터널 테이블 갱신...
  LOOP AT GT_MDSB_L WHERE MBLNR <> ''.
*(S)체크 테이블 동적 변경(SJM 25.05.14)
    LV_TNM = COND #( WHEN GT_MDSB_L-STATS <> SPACE THEN GC_ZGTMMT4114
                                                   ELSE GC_ZPPT0018 ).
*(E)체크 테이블 동적 변경(SJM 25.05.14)

    CLEAR  ZPPT0018.
    SELECT SINGLE MBLNR_F INTO ZPPT0018-MBLNR_F
             FROM (LV_TNM) "변경(SJM 25.05.14) ZPPT0018
            WHERE MBLNR = GT_MDSB_L-MBLNR
              AND MJAHR = GT_MDSB_L-MJAHR.

    IF ZPPT0018-MBLNR_F IS INITIAL.
      GT_MDSB_L-MBLNR   = ' '.
      GT_MDSB_L-MJAHR   = ' '.
      GT_MDSB_L-MBLNR_F = ' '.
      GT_MDSB_L-FLAG1   = ' '.
      GT_MDSB_L-CHECK   = GC_X.               "추가(SJM 25.04.25)
      PERFORM CLEAR_MDOC USING GT_MDSB_L 'L'. "추가(SJM 25.03.18)

      MODIFY GT_MDSB_L.
    ENDIF.
  ENDLOOP.


*& 중량관리...
  REFRESH LT_MBLNR.    CLEAR LT_MBLNR.
  LOOP AT GT_MDSB_W2 WHERE CHECK = 'X'.
    LT_MBLNR-MBLNR = GT_MDSB_W2-MBLNR.
    LT_MBLNR-MJAHR = GT_MDSB_W2-MJAHR.
    LT_MBLNR-BUDAT = GT_MDSB_W2-BUDAT.

    COLLECT LT_MBLNR.  CLEAR LT_MBLNR.
  ENDLOOP.

  LOOP AT LT_MBLNR.
    PERFORM MM_DOC_CANCEL_BAPI_W2 USING LT_MBLNR-MBLNR
                                        LT_MBLNR-MJAHR
                                        LT_MBLNR-BUDAT.

  ENDLOOP.

*  CLEAR : gv_tabix.
*  LOOP AT gt_mdsb_w2 WHERE check = 'X'.
*    gv_tabix = sy-tabix.
*
*    PERFORM mm_doc_cancel_bapi_w2.
*
*  ENDLOOP.

  PERFORM SEND_WMS. "추가(SJM 25.06.11)

  CHECK NOT GT_MSG[] IS INITIAL.
  CALL FUNCTION 'Z_TI_POPUP_TO_ERROR_MESSAGE'
    EXPORTING
      XDOCNO_SHOW = 'X'
    TABLES
      XMSG        = GT_MSG.

ENDFORM.                    " mm_doc_cancel_bapi
*&---------------------------------------------------------------------*
*&      Form  mm_doc_cancel_bapi_l
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MM_DOC_CANCEL_BAPI_L USING PV_MBLNR.
  CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
    EXPORTING
      MATERIALDOCUMENT    = GT_MDSB_L-MBLNR
      MATDOCUMENTYEAR     = GT_MDSB_L-MJAHR
      GOODSMVT_PSTNG_DATE = GT_MDSB_L-BUDAT  "sy-datum
    IMPORTING
      GOODSMVT_HEADRET    = GS_BAPI_GM_HEADRET
    TABLES
      RETURN              = GT_RET2.

  READ TABLE GT_RET2 WITH KEY TYPE = 'E'.
  IF SY-SUBRC <> 0.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.

*& CBO 테이블에 저장...
    PERFORM UPDATE_ZPPT0018_L_CANCEL.

    PERFORM UPDATE_ZGTMMT411X USING GT_MDSB_L-MBLNR
                                    GT_MDSB_L-MJAHR 'L'. "추가(SJM 25.03.18)

    LOOP AT GT_MDSB_L WHERE MBLNR = PV_MBLNR.
*(S)WMS I/F 기능 추가(SJM 25.06.11)
      PERFORM SET_WIF USING GT_MDSB_L-LGORT
                            GS_BAPI_GM_HEADRET-MAT_DOC
                            GS_BAPI_GM_HEADRET-DOC_YEAR.
*(E)WMS I/F 기능 추가(SJM 25.06.11)

      PERFORM UPDATE_ZPPT0001 USING GT_MDSB_L-WERKS
                                    GT_MDSB_L-TAGNR
                                    GT_MDSB_L-MBLNR
                                    GT_MDSB_L-BDMNG
                                    'N'.
    ENDLOOP.

    PERFORM UPDATE_ZPPT0001 USING GT_MDSB_L-WERKS
                                  GT_MDSB_L-TAGNR
                                  GT_MDSB_L-MBLNR
                                  GT_MDSB_L-BDMNG
                                 'N'.

*& 인터널 테이블에 이전전기 취소 Flag 설정...
    GT_MDSB_L-MBLNR_F = ' '.
    GT_MDSB_L-FLAG1   = ' '.
    MODIFY GT_MDSB_L INDEX GV_TABIX
              TRANSPORTING MBLNR_F FLAG1.

*& Message Display...
*&    MESSAGE s004 WITH '문서번호 "'
*&                       gt_mdsb_l-mblnr
*&                      '"이(가) 취소 되었습니다.!!!'.

    MOVE: 'ZPP1'                TO GT_MSG-MSGID,
          'S'                   TO GT_MSG-MSGTY,
          '004'                 TO GT_MSG-MSGNO,
          '문서번호'            TO GT_MSG-MSGV1,
           GT_MDSB_L-MBLNR      TO GT_MSG-MSGV2,
          '이(가) 취소 되었습니다.'
                                TO GT_MSG-MSGV3.

    CONCATENATE '문서번호'
                 GT_MDSB_L-MBLNR
                '이(가) 취소 되었습니다.'
                              INTO GT_MSG-MSGTX.

    APPEND GT_MSG.           CLEAR GT_MSG.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    LOOP AT GT_RET2.
      MOVE: GT_RET2-LOG_NO      TO GT_MSG-LOGNO,
            GT_RET2-LOG_MSG_NO  TO GT_MSG-MSGSQ,
            GT_RET2-ID          TO GT_MSG-MSGID,
            GT_RET2-TYPE        TO GT_MSG-MSGTY,
            GT_RET2-NUMBER      TO GT_MSG-MSGNO,
            GT_RET2-MESSAGE_V1  TO GT_MSG-MSGV1,
            GT_RET2-MESSAGE_V2  TO GT_MSG-MSGV2,
            GT_RET2-MESSAGE_V3  TO GT_MSG-MSGV3,
            GT_RET2-MESSAGE_V4  TO GT_MSG-MSGV4,
            GT_RET2-MESSAGE     TO GT_MSG-MSGTX.

      APPEND GT_MSG.         CLEAR GT_MSG.
    ENDLOOP.

  ENDIF.

ENDFORM.                    " mm_doc_cancel_bapi_l
*&---------------------------------------------------------------------*
*&      Form  mm_doc_cancel_bapi_w2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MM_DOC_CANCEL_BAPI_W2 USING PV_MBLNR
                                 PV_MJAHR
                                 PV_BUDAT.

  CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
    EXPORTING
      MATERIALDOCUMENT    = PV_MBLNR
      MATDOCUMENTYEAR     = PV_MJAHR
      GOODSMVT_PSTNG_DATE = PV_BUDAT  "sy-datum
    IMPORTING
      GOODSMVT_HEADRET    = GS_BAPI_GM_HEADRET
    TABLES
      RETURN              = GT_RET2.

  READ TABLE GT_RET2 WITH KEY TYPE = 'E'.
  IF SY-SUBRC <> 0.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.

*& CBO 테이블에 저장...
    PERFORM UPDATE_ZPPT0018_W2_CANCEL USING PV_MBLNR
                                            PV_MJAHR.

    PERFORM UPDATE_ZGTMMT411X USING PV_MBLNR
                                    PV_MJAHR 'W'. "추가(SJM 25.03.18)

    LOOP AT GT_MDSB_W2 WHERE MBLNR = PV_MBLNR.
      PERFORM UPDATE_ZPPT0001 USING GT_MDSB_W2-WERKS
                                    GT_MDSB_W2-TAGNR
                                    GT_MDSB_W2-MBLNR
                                    GT_MDSB_W2-ENMNG
                                   'N'.

      GT_MDSB_W2-MBLNR   = SPACE. "추가(SJM 25.03.18)
      GT_MDSB_W2-MJAHR   = SPACE. "추가(SJM 25.03.18)
      GT_MDSB_W2-MBLNR_F = ' '.
      GT_MDSB_W2-FLAG1   = ' '.
      PERFORM RESET_STK_W2 USING 'N'.            "추가(SJM 25.03.18)
      PERFORM CLEAR_MDOC   USING GT_MDSB_W2 'W'. "추가(SJM 25.03.18)
      MODIFY GT_MDSB_W2.

*(S)WMS I/F 기능 추가(SJM 25.06.11)
      PERFORM SET_WIF USING GT_MDSB_W2-LGORT
                            GS_BAPI_GM_HEADRET-MAT_DOC
                            GS_BAPI_GM_HEADRET-DOC_YEAR.
*(E)WMS I/F 기능 추가(SJM 25.06.11)
    ENDLOOP.

*& 이전전기 취소 Flag 설정...
*    gt_mdsb_w2-mblnr_f = ' '.
*    gt_mdsb_w2-flag1   = ' '.
*    MODIFY gt_mdsb_w2 INDEX gv_tabix
*               TRANSPORTING mblnr_f flag1.

*& Message Display...
*&    MESSAGE s004 WITH '문서번호 "'
*&                       pv_mblnr
*&                      '"이(가) 취소 되었습니다.!!!'.


    MOVE: 'ZPP1'                TO GT_MSG-MSGID,
          'S'                   TO GT_MSG-MSGTY,
          '004'                 TO GT_MSG-MSGNO,
          '문서번호'              TO GT_MSG-MSGV1,
          PV_MBLNR              TO GT_MSG-MSGV2, "변경(SJM 25.03.27)
*         GT_MDSB_L-MBLNR       TO GT_MSG-MSGV2,
          '이(가) 취소 되었습니다.'
                                TO GT_MSG-MSGV3.

    CONCATENATE '문서번호'
                 PV_MBLNR       "변경(SJM 25.03.27) GT_MDSB_L-MBLNR
                '이(가) 취소 되었습니다.'
                              INTO GT_MSG-MSGTX.

    APPEND GT_MSG.           CLEAR GT_MSG.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

*&    REFRESH gt_msg.          CLEAR gt_msg.
    LOOP AT GT_RET2.
      MOVE: GT_RET2-LOG_NO      TO GT_MSG-LOGNO,
            GT_RET2-LOG_MSG_NO  TO GT_MSG-MSGSQ,
            GT_RET2-ID          TO GT_MSG-MSGID,
            GT_RET2-TYPE        TO GT_MSG-MSGTY,
            GT_RET2-NUMBER      TO GT_MSG-MSGNO,
            GT_RET2-MESSAGE_V1  TO GT_MSG-MSGV1,
            GT_RET2-MESSAGE_V2  TO GT_MSG-MSGV2,
            GT_RET2-MESSAGE_V3  TO GT_MSG-MSGV3,
            GT_RET2-MESSAGE_V4  TO GT_MSG-MSGV4,
            GT_RET2-MESSAGE     TO GT_MSG-MSGTX.

      APPEND GT_MSG.         CLEAR GT_MSG.
    ENDLOOP.

*    CALL FUNCTION 'Z_TI_POPUP_TO_ERROR_MESSAGE'
*      EXPORTING
*        xdocno_show = 'X'
*      TABLES
*        xmsg        = gt_msg.

  ENDIF.

ENDFORM.                    " mm_doc_cancel_bapi_w2
*&---------------------------------------------------------------------*
*&      Form  submit_zler0015_z
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SUBMIT_ZLER0015_Z .
  REFRESH: GT_SELTAB, GT_LIFNR.
  CLEAR  : GT_SELTAB, GT_LIFNR, GV_DBCNT, GV_TABIX, GV_ERROR.

*& 동일 업체만 가능...
  LOOP AT GT_EBAN WHERE CHECK = 'X'.
    GT_LIFNR-LIFNR = GT_EBAN-LIFNR.
    COLLECT GT_LIFNR.  CLEAR GT_LIFNR.
  ENDLOOP.

  DESCRIBE TABLE GT_LIFNR LINES GV_DBCNT.
  IF GV_DBCNT > 1.
    MESSAGE S001 WITH '동일 업체가 아닙니다.!!!'.
    EXIT.
  ELSEIF GV_DBCNT < 1.
    MESSAGE S001 WITH '선택한 데이타가 없습니다.!!!'.
    EXIT.
  ENDIF.

*& 길이관리...
  LOOP AT GT_MDSB_L WHERE CHECK = 'X'.
    IF GT_MDSB_L-MBLNR IS INITIAL.
      MESSAGE S004 WITH '먼저 구성부품 이전전기를 수행 하십시오.!!!'.
      CONTINUE.
    ENDIF.

    IF GT_MDSB_L-IV_PRINT_YN = 'X'.
      MESSAGE W004 WITH GT_MDSB_L-MBLNR
                '은(는) 이미 통문증이 발행되었습니다.!!!'.
      CONTINUE.
    ENDIF.

    GT_MDSB_L-IV_PRINT_YN = 'X'.
*& CBO 테이블에 반영...
    UPDATE ZPPT0018 SET: OUTPR_F =  GT_MDSB_L-IV_PRINT_YN
                  WHERE  MBLNR   =  GT_MDSB_L-MBLNR
                    AND  MJAHR   =  GT_MDSB_L-MJAHR.

*    UPDATE zppt0018 SET: outpr_f =  gt_mdsb_l-iv_print_yn
*                  WHERE  pswrk   =  gt_mdsb_l-werks
*                    AND  ebeln   =  gt_mdsb_l-ebeln
*                    AND  ebelp   =  gt_mdsb_l-ebelp
*                    AND  matnr   =  gt_mdsb_l-matnr_c
*                    AND  tagnr  <> 'HEADER'.

    IF GT_MDSB_L-IV_PRINT_YN = 'X'.
      GT_MDSB_L-FLAG2 = ICON_LED_GREEN.
    ELSE.
      GT_MDSB_L-FLAG2 = ''.
    ENDIF.

    MODIFY GT_MDSB_L.

  ENDLOOP.

*& 중량관리...
  LOOP AT GT_MDSB_W2 WHERE CHECK = 'X'.
    IF GT_MDSB_W2-MBLNR IS INITIAL.
      MESSAGE S004 WITH '먼저 구성부품 이전전기를 수행 하십시오.!!!'.
      CONTINUE.
    ENDIF.

    IF GT_MDSB_W2-IV_PRINT_YN = 'X'.
      MESSAGE W004 WITH GT_MDSB_L-MBLNR
                '은(는) 이미 통문증이 발행되었습니다.!!!'.
      CONTINUE.
    ENDIF.

    GT_MDSB_W2-IV_PRINT_YN = 'X'.
*& CBO 테이블에 반영...
    UPDATE ZPPT0018    SET: OUTPR_F =  GT_MDSB_W2-IV_PRINT_YN
                     WHERE  MBLNR   =  GT_MDSB_W2-MBLNR
                       AND  MJAHR   =  GT_MDSB_W2-MJAHR.

*    LOOP AT gt_mdsb_w1 WHERE  matnr_c =  gt_mdsb_w2-matnr_c.
*      UPDATE zppt0018    SET: outpr_f =  gt_mdsb_w2-iv_print_yn
*                       WHERE  pswrk   =  gt_mdsb_w1-werks
*                         AND  ebeln   =  gt_mdsb_w1-ebeln
*                         AND  ebelp   =  gt_mdsb_w1-ebelp
*                         AND  matnr   =  gt_mdsb_w1-matnr_c
*                         AND  tagnr  <> 'HEADER'.
*    ENDLOOP.

    IF GT_MDSB_W2-IV_PRINT_YN = 'X'.
      GT_MDSB_W2-FLAG2 = ICON_LED_GREEN.
    ELSE.
      GT_MDSB_W2-FLAG2 = ''.
    ENDIF.

    MODIFY GT_MDSB_W2.

  ENDLOOP.


ENDFORM.                    " submit_zler0015_z
*&---------------------------------------------------------------------*
*&      Form  submit_zler0016_z
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SUBMIT_ZLER0016_Z .
  REFRESH: GT_SELTAB, GT_LIFNR.
  CLEAR  : GT_SELTAB, GT_LIFNR, GV_DBCNT, GV_TABIX, GV_ERROR.

*& 동일 업체만 가능...
  LOOP AT GT_EBAN WHERE CHECK = 'X'.
    GT_LIFNR-LIFNR = GT_EBAN-LIFNR.
    COLLECT GT_LIFNR.  CLEAR GT_LIFNR.
  ENDLOOP.

  DESCRIBE TABLE GT_LIFNR LINES GV_DBCNT.
  IF GV_DBCNT > 1.
    MESSAGE S001 WITH '동일 업체가 아닙니다.!!!'.
    EXIT.
  ELSEIF GV_DBCNT < 1.
    MESSAGE S001 WITH '선택한 데이타가 없습니다.!!!'.
    EXIT.
  ENDIF.

*& 길이관리...
  LOOP AT GT_MDSB_L WHERE CHECK = 'X'.
    IF GT_MDSB_L-OUT_YN = 'X'.
      MESSAGE W004 WITH GT_MDSB_L-MBLNR
                '이(가) 통문이 완료되어 취소할 수 없습니다.!!!'.
      CONTINUE.
    ENDIF.

    IF GT_MDSB_L-IV_PRINT_YN <> 'X'.
      MESSAGE W004 WITH GT_MDSB_L-MBLNR
                '은(는) 통문증 미발행 상태입니다.!!!'.
      CONTINUE.
    ENDIF.

    GT_MDSB_L-IV_PRINT_YN = ''.
*& CBO 테이블에 반영...
    UPDATE ZPPT0018 SET: OUTPR_F =  GT_MDSB_L-IV_PRINT_YN
                  WHERE  MBLNR   =  GT_MDSB_L-MBLNR
                    AND  MJAHR   =  GT_MDSB_L-MJAHR.

*    UPDATE zppt0018 SET: outpr_f =  gt_mdsb_l-iv_print_yn
*                  WHERE  pswrk   =  gt_mdsb_l-werks
*                    AND  ebeln   =  gt_mdsb_l-ebeln
*                    AND  ebelp   =  gt_mdsb_l-ebelp
*                    AND  matnr   =  gt_mdsb_l-matnr_c
*                    AND  tagnr  <> 'HEADER'.

    IF GT_MDSB_L-IV_PRINT_YN = 'X'.
      GT_MDSB_L-FLAG2 = ICON_LED_GREEN.
    ELSE.
      GT_MDSB_L-FLAG2 = ''.
    ENDIF.

*& 인터널 테이블에 반영...
    MODIFY GT_MDSB_L.

  ENDLOOP.

*& 중량관리...
  LOOP AT GT_MDSB_W2 WHERE CHECK = 'X'.
    IF GT_MDSB_W2-OUT_YN = 'X'.
      MESSAGE W004 WITH GT_MDSB_L-MBLNR
                '이(가) 통문이 완료되어 취소할 수 없습니다.!!!'.
      CONTINUE.
    ENDIF.

    IF GT_MDSB_W2-IV_PRINT_YN <> 'X'.
      MESSAGE W004 WITH GT_MDSB_L-MBLNR
                '은(는) 통문증 미발행 상태입니다.!!!'.
      CONTINUE.
    ENDIF.

    GT_MDSB_W2-IV_PRINT_YN = ''.
*& CBO 테이블에 반영...
    UPDATE ZPPT0018    SET: OUTPR_F =  GT_MDSB_W2-IV_PRINT_YN
                     WHERE  MBLNR   =  GT_MDSB_W2-MBLNR
                       AND  MJAHR   =  GT_MDSB_W2-MJAHR.

*    LOOP AT gt_mdsb_w1 WHERE  matnr_c =  gt_mdsb_w2-matnr_c.
*      UPDATE zppt0018    SET: outpr_f =  gt_mdsb_w2-iv_print_yn
*                       WHERE  pswrk   =  gt_mdsb_w1-werks
*                         AND  ebeln   =  gt_mdsb_w1-ebeln
*                         AND  ebelp   =  gt_mdsb_w1-ebelp
*                         AND  matnr   =  gt_mdsb_w1-matnr_c
*                         AND  tagnr  <> 'HEADER'.
*    ENDLOOP.

    IF GT_MDSB_W2-IV_PRINT_YN = 'X'.
      GT_MDSB_W2-FLAG2 = ICON_LED_GREEN.
    ELSE.
      GT_MDSB_W2-FLAG2 = ''.
    ENDIF.

*& 인터널 테이블에 반영...
    MODIFY GT_MDSB_W2.

  ENDLOOP.
ENDFORM.                    " submit_zler0016_z
*&---------------------------------------------------------------------*
*&      Form  marked_check_box_100
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_2638   text
*----------------------------------------------------------------------*
FORM MARKED_CHECK_BOX_100  USING  PV_CHECK.
  GT_EBAN-CHECK = PV_CHECK.
  MODIFY GT_EBAN TRANSPORTING CHECK WHERE CHECK <> PV_CHECK.

ENDFORM.                    " marked_check_box_100
*&---------------------------------------------------------------------*
*&      Form  marked_check_box_200
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_2638   text
*----------------------------------------------------------------------*
FORM MARKED_CHECK_BOX_200  USING  PV_CHECK.
  GT_MDSB_L-CHECK = PV_CHECK.
  MODIFY GT_MDSB_L TRANSPORTING CHECK WHERE MATNR <> ' '.

  GT_MDSB_W2-CHECK = PV_CHECK.
  MODIFY GT_MDSB_W2 TRANSPORTING CHECK WHERE MATNR_C <> ' '.

*& 테이블 리프레쉬...
  PERFORM SET_CELL_ATTRIBUTE.
  L_SCROLL-ROW = 'X'.
  L_SCROLL-COL = 'X'.

*& 길이관리...
  CALL METHOD GCL_GRID_L->REFRESH_TABLE_DISPLAY
    EXPORTING
      I_SOFT_REFRESH = 'X'
      IS_STABLE      = L_SCROLL.     "현재 그대로 입력한 refresh

  CALL METHOD GCL_GRID_L->SET_OPTIMIZE_ALL_COLS.

*& 중량관리...
  CALL METHOD GCL_GRID_W2->REFRESH_TABLE_DISPLAY
    EXPORTING
      I_SOFT_REFRESH = 'X'
      IS_STABLE      = L_SCROLL.     "현재 그대로 입력한 refresh

  CALL METHOD GCL_GRID_W2->SET_OPTIMIZE_ALL_COLS.

ENDFORM.                    " marked_check_box_200
*&---------------------------------------------------------------------*
*&      Form  search_help_for_tagnr
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SEARCH_HELP_FOR_TAGNR  USING    PV_WERKS
                                     PV_MATNR_C
                            CHANGING PV_TAGNR
                                     PV_CHARG
                                     PV_LGORT
                                     PV_REMAIN.

  DATA: LV_TABIX LIKE SY-TABIX,
        LV_INDEX LIKE SY-INDEX.

  DATA: BEGIN OF LT_TAGNR OCCURS 0,
          REMAIN(17) TYPE C,
          CHARG      LIKE ZPPT0001-CHARG,
          LGORT      LIKE ZPPT0001-LGORT,
          TAGNR      LIKE ZPPT0001-TAGNR,
        END   OF LT_TAGNR.

  REFRESH: GT_DYNPUPDATE,  GT_DYNPREAD, GT_FIELD.
  CLEAR  : GT_DYNPUPDATE,  GT_DYNPREAD, GT_FIELD.
  CLEAR  : GS_SELECTFIELD, GS_SELECT_VALUE.

*& 작업실적(ZPPT0001) 테이블로부터 꼬리표번호를 가져온다.
  REFRESH LT_TAGNR.  CLEAR LT_TAGNR.
  SELECT * FROM ZPPT0001
          WHERE WERKS  =  PV_WERKS
*&            AND charg  =  pv_charg
            AND MATNR  =  PV_MATNR_C
            AND REMAIN >  0
            AND GIFLG  = 'N'.

    MOVE: ZPPT0001-TAGNR  TO LT_TAGNR-TAGNR,
          ZPPT0001-REMAIN TO LT_TAGNR-REMAIN,
          ZPPT0001-CHARG  TO LT_TAGNR-CHARG,
          ZPPT0001-LGORT  TO LT_TAGNR-LGORT.

    APPEND LT_TAGNR.   CLEAR LT_TAGNR.
  ENDSELECT.

*(S)꼬리표 대상 제외 로직 추가(SJM 25.05.14)
  RANGES : LR_TAGNR FOR ZGTMMT4114-TAGNR.

  IF LT_TAGNR[] IS NOT INITIAL.
    SELECT DISTINCT TAGNR  AS LOW,
                    @GC_I  AS SIGN,
                    @GC_EQ AS OPTION
      FROM ZGTMMT4114
      INTO CORRESPONDING FIELDS OF TABLE @LR_TAGNR
     WHERE PSWRK = @PV_WERKS
       AND MATNR = @PV_MATNR_C.
*      AND MBLNR = @SPACE.

    IF LR_TAGNR[] IS NOT INITIAL.
      DELETE LT_TAGNR WHERE TAGNR IN LR_TAGNR.
    ENDIF.
  ENDIF.
*(E)꼬리표 대상 제외 로직 추가(SJM 25.05.14)

  SORT LT_TAGNR BY TAGNR.

*& 아래 부분이 F4를 눌렀을 때, Hit List를 보여준다.
  GT_FIELD-TABNAME     = 'ZMMSI21'.
  GT_FIELD-FIELDNAME   = 'MENGE'.
  GT_FIELD-SELECTFLAG  = ' '.
  APPEND GT_FIELD. CLEAR GT_FIELD.

  GT_FIELD-TABNAME     = 'ZPPT0001'.
  GT_FIELD-FIELDNAME   = 'CHARG'.
  GT_FIELD-SELECTFLAG  = ' '.
  APPEND GT_FIELD. CLEAR GT_FIELD.

  GT_FIELD-TABNAME     = 'ZPPT0001'.
  GT_FIELD-FIELDNAME   = 'LGORT'.
  GT_FIELD-SELECTFLAG  = ' '.
  APPEND GT_FIELD. CLEAR GT_FIELD.

  GT_FIELD-TABNAME     = 'ZPPT0001'.
  GT_FIELD-FIELDNAME   = 'TAGNR'.
  GT_FIELD-SELECTFLAG  = 'X'.
  APPEND GT_FIELD. CLEAR GT_FIELD.

  CALL FUNCTION 'HELP_VALUES_GET_NO_DD_NAME'
    EXPORTING
      TITEL                        = '꼬리표 선택'
      SELECTFIELD                  = GS_SELECTFIELD
    IMPORTING
      IND                          = LV_TABIX
      SELECT_VALUE                 = GS_SELECT_VALUE
    TABLES
      FIELDS                       = GT_FIELD
      FULL_TABLE                   = LT_TAGNR
    EXCEPTIONS
      FULL_TABLE_EMPTY             = 1
      NO_TABLESTRUCTURE_GIVEN      = 2
      NO_TABLEFIELDS_IN_DICTIONARY = 3
      MORE_THEN_ONE_SELECTFIELD    = 4
      NO_SELECTFIELD               = 5
      OTHERS                       = 6.

  CHECK NOT LV_TABIX IS INITIAL.
  READ TABLE LT_TAGNR INDEX LV_TABIX.
  PV_TAGNR  = LT_TAGNR-TAGNR.
  PV_CHARG  = LT_TAGNR-CHARG.
  PV_LGORT  = LT_TAGNR-LGORT.
  PV_REMAIN = LT_TAGNR-REMAIN.

ENDFORM.                    " search_help_for_tagnr
*&---------------------------------------------------------------------*
*&      Form  update_zppt0001
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_MDSB_L_WERKS  text
*      -->P_GT_MDSB_L_TAGNR  text
*----------------------------------------------------------------------*
FORM UPDATE_ZPPT0001  USING     PV_WERKS
                                PV_TAGNR
                                PV_MBLNR
                                PV_MENGE
                                PV_GIFLG.

  UPDATE ZPPT0001 SET: GIFLG  = PV_GIFLG
                       MBLNR  = PV_MBLNR
                       REMAIN = PV_MENGE
                WHERE  WERKS  = PV_WERKS
                  AND  TAGNR  = PV_TAGNR.

ENDFORM.                    " update_zppt0001
*&---------------------------------------------------------------------*
*&      Form  search_help_for_charg_l
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_MDSB_L_WERKS  text
*      -->P_GT_MDSB_L_MATNR_C  text
*      <--P_GT_MDSB_L_CHARG  text
*      <--P_GT_MDSB_L_LGORT  text
*----------------------------------------------------------------------*
FORM SEARCH_HELP_FOR_CHARG_L  USING    PV_WERKS
                                       PV_MATNR_C
                              CHANGING PV_CHARG
                                       PV_LGORT.

  DATA: LV_TABIX LIKE SY-TABIX,
        LV_INDEX LIKE SY-INDEX.

  DATA: BEGIN OF LT_CHARG OCCURS 0,
          LGORT LIKE MCHB-LGORT,
          MBEST LIKE RMCP2-MBEST,
          CHARG LIKE MCHB-CHARG,
        END   OF LT_CHARG.

  REFRESH: GT_DYNPUPDATE,  GT_DYNPREAD, GT_FIELD.
  CLEAR  : GT_DYNPUPDATE,  GT_DYNPREAD, GT_FIELD.
  CLEAR  : GS_SELECTFIELD, GS_SELECT_VALUE.

*& 뱃치재고(MCHB) 테이블로 부터 뱃치번호를 가져온다.
  REFRESH LT_CHARG.              CLEAR LT_CHARG.
  SELECT LGORT CLABS CHARG
    INTO (MCHB-LGORT, MCHB-CLABS, MCHB-CHARG)
           FROM MCHB
          WHERE MATNR = PV_MATNR_C
            AND WERKS = PV_WERKS
            AND CLABS > 0.
    MOVE: MCHB-LGORT    TO LT_CHARG-LGORT,
          MCHB-CLABS    TO LT_CHARG-MBEST,
          MCHB-CHARG    TO LT_CHARG-CHARG.
    APPEND LT_CHARG. CLEAR LT_CHARG.
  ENDSELECT.

  SORT LT_CHARG BY CHARG.

*& 아래 부분이 F4를 눌렀을 때, Hit List를 보여준다.
  GT_FIELD-TABNAME     = 'MCHB'.
  GT_FIELD-FIELDNAME   = 'LGORT'.
  GT_FIELD-SELECTFLAG  = ' '.
  APPEND GT_FIELD. CLEAR GT_FIELD.

  GT_FIELD-TABNAME     = 'RMCP2'.
  GT_FIELD-FIELDNAME   = 'MBEST'.
  GT_FIELD-SELECTFLAG  = ' '.
  APPEND GT_FIELD. CLEAR GT_FIELD.

  GT_FIELD-TABNAME     = 'MCHB'.
  GT_FIELD-FIELDNAME   = 'CHARG'.
  GT_FIELD-SELECTFLAG  = 'X'.
  APPEND GT_FIELD. CLEAR GT_FIELD.

  CALL FUNCTION 'HELP_VALUES_GET_NO_DD_NAME'
    EXPORTING
      TITEL                        = '뱃치 선택'
      SELECTFIELD                  = GS_SELECTFIELD
    IMPORTING
      IND                          = LV_TABIX
      SELECT_VALUE                 = GS_SELECT_VALUE
    TABLES
      FIELDS                       = GT_FIELD
      FULL_TABLE                   = LT_CHARG
    EXCEPTIONS
      FULL_TABLE_EMPTY             = 1
      NO_TABLESTRUCTURE_GIVEN      = 2
      NO_TABLEFIELDS_IN_DICTIONARY = 3
      MORE_THEN_ONE_SELECTFIELD    = 4
      NO_SELECTFIELD               = 5
      OTHERS                       = 6.

  CHECK NOT LV_TABIX IS INITIAL.
  READ TABLE LT_CHARG INDEX LV_TABIX.
  PV_CHARG = LT_CHARG-CHARG.
  PV_LGORT = LT_CHARG-LGORT.

ENDFORM.                    " search_help_for_charg_l
*&---------------------------------------------------------------------*
*&      Form  search_help_for_charg_w2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_MDSB_W2_WERKS  text
*      -->P_GT_MDSB_W2_MATNR_C  text
*      <--P_GT_MDSB_W2_CHARG  text
*      <--P_GT_MDSB_W2_LGORT  text
*      <--P_GT_MDSB_W2_ENMNG  text
*----------------------------------------------------------------------*
FORM SEARCH_HELP_FOR_CHARG_W2  USING PV_WERKS
                                     PV_MATNR
                            CHANGING PV_CHARG
                                     PV_LGORT
                                     PV_MBEST.

  DATA: LV_TABIX LIKE SY-TABIX,
        LV_INDEX LIKE SY-INDEX.

  DATA: BEGIN OF LT_CHARG OCCURS 0,
          LGORT LIKE MCHB-LGORT,
          MBEST LIKE RMCP2-MBEST,
          CHARG LIKE MCHB-CHARG,
        END   OF LT_CHARG.

  REFRESH: GT_DYNPUPDATE,  GT_DYNPREAD, GT_FIELD.
  CLEAR  : GT_DYNPUPDATE,  GT_DYNPREAD, GT_FIELD.
  CLEAR  : GS_SELECTFIELD, GS_SELECT_VALUE.

*& 뱃치재고(MCHB) 테이블로 부터 뱃치번호를 가져온다.
  REFRESH LT_CHARG.              CLEAR LT_CHARG.
  SELECT LGORT CLABS CHARG
    INTO (MCHB-LGORT, MCHB-CLABS, MCHB-CHARG)
           FROM MCHB
          WHERE MATNR = PV_MATNR
            AND WERKS = PV_WERKS
            AND CLABS > 0.
    MOVE: MCHB-LGORT    TO LT_CHARG-LGORT,
          MCHB-CLABS    TO LT_CHARG-MBEST,
          MCHB-CHARG    TO LT_CHARG-CHARG.

    APPEND LT_CHARG. CLEAR LT_CHARG.
  ENDSELECT.

  SORT LT_CHARG BY CHARG.

*& 아래 부분이 F4를 눌렀을 때, Hit List를 보여준다.
  GT_FIELD-TABNAME     = 'MCHB'.
  GT_FIELD-FIELDNAME   = 'LGORT'.
  GT_FIELD-SELECTFLAG  = ' '.
  APPEND GT_FIELD. CLEAR GT_FIELD.

  GT_FIELD-TABNAME     = 'RMCP2'.
  GT_FIELD-FIELDNAME   = 'MBEST'.
  GT_FIELD-SELECTFLAG  = ' '.
  APPEND GT_FIELD. CLEAR GT_FIELD.

  GT_FIELD-TABNAME     = 'MCHB'.
  GT_FIELD-FIELDNAME   = 'CHARG'.
  GT_FIELD-SELECTFLAG  = 'X'.
  APPEND GT_FIELD. CLEAR GT_FIELD.

  CALL FUNCTION 'HELP_VALUES_GET_NO_DD_NAME'
    EXPORTING
      TITEL                        = '뱃치 선택'
      SELECTFIELD                  = GS_SELECTFIELD
    IMPORTING
      IND                          = LV_TABIX
      SELECT_VALUE                 = GS_SELECT_VALUE
    TABLES
      FIELDS                       = GT_FIELD
      FULL_TABLE                   = LT_CHARG
    EXCEPTIONS
      FULL_TABLE_EMPTY             = 1
      NO_TABLESTRUCTURE_GIVEN      = 2
      NO_TABLEFIELDS_IN_DICTIONARY = 3
      MORE_THEN_ONE_SELECTFIELD    = 4
      NO_SELECTFIELD               = 5
      OTHERS                       = 6.

  CHECK NOT LV_TABIX IS INITIAL.
  READ TABLE LT_CHARG INDEX LV_TABIX.
  PV_CHARG = LT_CHARG-CHARG.
  PV_LGORT = LT_CHARG-LGORT.
  PV_MBEST = LT_CHARG-MBEST.

ENDFORM.                    " search_help_for_charg_w2
*&---------------------------------------------------------------------*
*&      Form  modify_purchase_order_bdc_w2
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM MODIFY_PURCHASE_ORDER_BDC_W2 USING PV_MATNR
                                        PV_CHARG.
  REFRESH: GT_BDCDATA, GT_MSGCOLL.
  CLEAR  : GT_BDCDATA, GT_MSGCOLL.

  LOOP AT GT_MDSB_W1 WHERE MATNR_C = PV_MATNR.

    PERFORM DYNPRO USING:
      'X'  'SAPLMEGUI'               '0014',
      ' '  'BDC_OKCODE'              '=MECHOB'.

    PERFORM DYNPRO USING:
      'X'  'SAPLMEGUI'               '0002',
      ' '  'BDC_OKCODE'              '=MEOK',
      ' '  'BDC_CURSOR'              'MEPO_SELECT-EBELN',
      ' '  'MEPO_SELECT-EBELN'        GT_MDSB_W1-EBELN,  "구매오더번호
      ' '  'MEPO_SELECT-BSTYP_F'     'X'.               "구매오더선택

    PERFORM DYNPRO USING:                               "자재데이타
      'X'  'SAPLMEGUI'              '0014',
      ' '  'BDC_OKCODE'             '=TABIDT3'.

    PERFORM DYNPRO USING:                               "구성부품
      'X'  'SAPLMEGUI'              '0014',
      ' '  'BDC_OKCODE'             '=MEPO1319BOM'.

    PERFORM DYNPRO USING:                               "찾기
      'X'  'SAPLM61Q'               '0115',
      ' '  'BDC_OKCODE'             '=SUCH',
      ' '  'BDC_CURSOR'             'MDPM-MATNR(01)'.

    PERFORM DYNPRO USING:                               "찾기
      'X'  'SAPLM61Q'              '0300',
      ' '  'BDC_OKCODE'            '=SUCH',
      ' '  'SUCHL-MATNR'            PV_MATNR.           "사급자재

    PERFORM DYNPRO USING:                               "
      'X'  'SAPLM61Q'              '0115',
      ' '  'BDC_OKCODE'            '/00',
      ' '  'MDPM-CHARG(01)'         PV_CHARG.

    PERFORM DYNPRO USING:                               "
      'X'  'SAPLM61Q'              '0115',
      ' '  'BDC_OKCODE'            '=BACK'.

    PERFORM DYNPRO USING:                               "구성부품
      'X'  'SAPLMEGUI'             '0014',
      ' '  'BDC_OKCODE'            '=MESAVE'.

    CALL TRANSACTION 'ME22N'          "Transaction Call.
               USING GT_BDCDATA
        OPTIONS FROM GS_BDCPARAMS
       MESSAGES INTO GT_MSGCOLL.

    READ TABLE GT_MSGCOLL WITH KEY MSGTYP = 'E'.
    IF SY-SUBRC = 0.
      GT_MSGCOLL-MSGTYP = 'W'.
      MESSAGE ID GT_MSGCOLL-MSGID TYPE GT_MSGCOLL-MSGTYP
                                NUMBER GT_MSGCOLL-MSGNR
                                  WITH GT_MSGCOLL-MSGV1
                                       GT_MSGCOLL-MSGV2
                                       GT_MSGCOLL-MSGV3
                                       GT_MSGCOLL-MSGV4.
    ENDIF.
  ENDLOOP.
ENDFORM.                    " modify_purchase_order_bdc_w2
*&---------------------------------------------------------------------*
*&      Form  change_purchase_order
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CHANGE_PURCHASE_ORDER .
  DATA: LV_EBELN_T(16).

  REFRESH GT_MSG. CLEAR GT_MSG.

  LOOP AT GT_EBAN WHERE CHECK = 'X'.

    GV_TABIX = SY-TABIX.

    IF GT_EBAN-EBELN IS INITIAL OR
       GT_EBAN-EBTYP EQ 'AB'    OR
       GT_EBAN-EBTYP EQ 'LA'.

      CLEAR GT_MSG.
      GT_MSG-MSGID = 'ZPP1'.
      GT_MSG-MSGTY = 'E'.
      GT_MSG-MSGNO = '004'.
      GT_MSG-MSGV1 = '확정 또는 납품 상태입니다.'.
      GT_MSG-REFNO =  GT_EBAN-EBELN.
      GT_MSG-REFIT =  GT_EBAN-EBELP.

      APPEND GT_MSG.    CLEAR GT_MSG.

      CONTINUE.
    ENDIF.

    IF GT_EBAN-LOSSF <> 'X'.
*& 사급자재 정보 발췌...
      REFRESH: GT_MDSB_L, GT_MDSB_W1, GT_MDSB_W2, GT_MDSB_W3.
      CLEAR  : GT_MDSB_L, GT_MDSB_W1, GT_MDSB_W2, GT_MDSB_W3.

      PERFORM SELECT_MDSB_PROC USING 'PO'. "구매오더 생성일 경우
    ENDIF.

    PERFORM BDC_PURCHASE_ORDER_CHANGE.

    IF P_WERKS EQ '1303'.
      PERFORM BDC_PURCHASE_ORDER_TEXT_CHANGE.
    ENDIF.

    MODIFY GT_EBAN.
  ENDLOOP.

*& 메시지 출력...
  CHECK NOT GT_MSG[] IS INITIAL.
  CALL FUNCTION 'Z_TI_POPUP_TO_ERROR_MESSAGE'
    EXPORTING
      XDOCNO_SHOW = 'X'
    TABLES
      XMSG        = GT_MSG.

ENDFORM.                    " change_purchase_order
*&---------------------------------------------------------------------*
*&      Form  bdc_purchase_order_change
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM BDC_PURCHASE_ORDER_CHANGE .
  DATA: LV_ERFMG_T(17).

  REFRESH: GT_BDCDATA, GT_MSGCOLL.
  CLEAR  : GT_BDCDATA, GT_MSGCOLL.

  WRITE: GT_EBAN-MENGE_A         TO LV_ERFMG_T.

  PERFORM DYNPRO USING:
    'X'  'SAPLMEGUI'               '0014',
    ' '  'BDC_OKCODE'              '=MECHOB'.

  PERFORM DYNPRO USING:
    'X'  'SAPLMEGUI'               '0002',
    ' '  'BDC_OKCODE'              '=MEOK',
    ' '  'BDC_CURSOR'              'MEPO_SELECT-EBELN',
    ' '  'MEPO_SELECT-EBELN'        GT_EBAN-EBELN,    "구매오더번호
    ' '  'MEPO_SELECT-BSTYP_F'     'X'.               "구매오더선택

  PERFORM DYNPRO USING:
    'X'  'SAPLMEGUI'               '0014',
    ' '  'BDC_OKCODE'              '=/SAPMP/CE_MUEBS',
    ' '  'BDC_CURSOR'              '/SAPMP/MUEBS',
    ' '  '/SAPMP/MUEBS'            ' '.               "특성조회

  PERFORM DYNPRO USING:
    'X'  'SAPLMEGUI'               '0014',
    ' '  'BDC_OKCODE'              '=/SAPMP/CE_MUEBS',
    ' '  'BDC_CURSOR'              '/SAPMP/MUEBS',
    ' '  '/SAPMP/SCOPE'            'ALL',             "조회범위
    ' '  '/SAPMP/MUEBS'            'MM_001'.          "특성조회

*&  IF gt_eban-length IS INITIAL.
*&  IF gt_eban-length_v IS INITIAL AND                  "조장

*&  IF ( NOT gt_eban-cuobj IS INITIAL ) AND     "구성(내부오브젝트번호)
*&           gt_eban-chg_srv = space    AND             "구성변경
*&           gt_eban-dpcbt  <> space.                   "일반뱃치

  IF GT_EBAN-KZKFG IS INITIAL.
    PERFORM DYNPRO USING:
      'X'  'SAPLMEGUI'             '0014',
      ' '  'BDC_OKCODE'            '=/SAPMP/CE_CONF',
      ' '  'BDC_CURSOR'            'MEPO1211-/SAPMP/CE_ICON(01)'.
  ENDIF.


  PERFORM DYNPRO USING:
    'X'  'SAPLMEGUI'               '0014',
    ' '  'BDC_OKCODE'              '/00',
    ' '  'MEPO1211-MENGE(01)'       LV_ERFMG_T.

  IF GT_EBAN-WERKS = '1201' OR
     GT_EBAN-WERKS = '1304'.
  ELSE.
    PERFORM DYNPRO USING:
      ' '  'MEPO1211-/SAPMP/ATWRT01(01)'  GT_EBAN-FACTOR,
      ' '  'MEPO1211-/SAPMP/ATWRT02(01)'  GT_EBAN-LENGTH.
  ENDIF.

  PERFORM DYNPRO USING:
    ' '  'MEPO1211-/SAPMP/ATWRT03(01)'  GT_EBAN-PACKING_CAT,
    ' '  'MEPO1211-/SAPMP/ATWRT04(01)'  GT_EBAN-PACKING,
    ' '  'MEPO1211-EEIND(01)'           GT_EBAN-LFDAT.

*  PERFORM dynpro USING:
*    'X'  'SAPLMEGUI'               '0014',
*    ' '  'BDC_OKCODE'              '/00',
*    ' '  'MEPO1211-MENGE(01)'           lv_erfmg_t,
*    ' '  'MEPO1211-/SAPMP/ATWRT01(01)'  gt_eban-factor,
*    ' '  'MEPO1211-/SAPMP/ATWRT02(01)'  gt_eban-length,
*    ' '  'MEPO1211-/SAPMP/ATWRT03(01)'  gt_eban-packing_cat,
*    ' '  'MEPO1211-/SAPMP/ATWRT04(01)'  gt_eban-packing,
*    ' '  'MEPO1211-EEIND(01)'           gt_eban-lfdat.

*& 구성부품 Loss율 적용(중량관리)...
  IF GT_EBAN-LOSSF <> 'X' AND
     NOT GT_MDSB_W1[] IS INITIAL.
    LOOP AT GT_MDSB_W1.
      WRITE: GT_MDSB_W1-ERFMG_A  TO LV_ERFMG_T.

      PERFORM DYNPRO USING:                               "자재데이타
        'X'  'SAPLMEGUI'           '0014',
        ' '  'BDC_OKCODE'          '=TABIDT3'.

      PERFORM DYNPRO USING:                               "구성부품
        'X'  'SAPLMEGUI'           '0014',
        ' '  'BDC_OKCODE'          '=MEPO1319BOM'.

      PERFORM DYNPRO USING:                               "찾기
        'X'  'SAPLM61Q'            '0115',
        ' '  'BDC_OKCODE'          '=SUCH',
        ' '  'BDC_CURSOR'          'MDPM-MATNR(01)'.

      PERFORM DYNPRO USING:                               "찾기
        'X'  'SAPLM61Q'            '0300',
        ' '  'BDC_OKCODE'          '=SUCH',
        ' '  'SUCHL-MATNR'          GT_MDSB_W1-MATNR_C. "사급자재

      PERFORM DYNPRO USING:                               "
        'X'  'SAPLM61Q'            '0115',
        ' '  'BDC_OKCODE'          '/00',
        ' '  'MDPM-ERFMG(01)'       LV_ERFMG_T.

      PERFORM DYNPRO USING:                               "
        'X'  'SAPLM61Q'            '0115',
        ' '  'BDC_OKCODE'          '=BACK'.
    ENDLOOP.
  ENDIF.

  PERFORM DYNPRO USING:
    'X'  'SAPLMEGUI'               '0014',
    ' '  'BDC_OKCODE'              '=MESAVE'.

  CALL TRANSACTION 'ME22N'          "Transaction Call.
             USING GT_BDCDATA
           OPTIONS FROM GS_BDCPARAMS
          MESSAGES INTO GT_MSGCOLL.

  READ TABLE GT_MSGCOLL WITH KEY MSGTYP = 'E'.
  IF SY-SUBRC = 0.
    CLEAR GT_MSG.
    MOVE: GT_MSGCOLL-MSGID     TO GT_MSG-MSGID,
          GT_MSGCOLL-MSGTYP    TO GT_MSG-MSGTY,
          GT_MSGCOLL-MSGNR     TO GT_MSG-MSGNO,
          GT_MSGCOLL-MSGV1     TO GT_MSG-MSGV1,
          GT_MSGCOLL-MSGV2     TO GT_MSG-MSGV2,
          GT_MSGCOLL-MSGV3     TO GT_MSG-MSGV3,
          GT_MSGCOLL-MSGV4     TO GT_MSG-MSGV4,
          GT_EBAN-EBELN        TO GT_MSG-REFNO,
          GT_EBAN-EBELP        TO GT_MSG-REFIT.

    APPEND GT_MSG.          CLEAR GT_MSG.

  ELSE.
    IF NOT GT_EBAN-LOSSR IS INITIAL.
      GT_EBAN-LOSSF = 'X'.
    ENDIF.

*& CBO 테이블에 저장...
    PERFORM INSERT_INTO_ZPPT0018_HD.
  ENDIF.

*& 메시지 처리...
  CLEAR GT_MSG.
  LOOP AT GT_MSGCOLL.
    MOVE: GT_MSGCOLL-MSGID     TO GT_MSG-MSGID,
          GT_MSGCOLL-MSGTYP    TO GT_MSG-MSGTY,
          GT_MSGCOLL-MSGNR     TO GT_MSG-MSGNO,
          GT_MSGCOLL-MSGV1     TO GT_MSG-MSGV1,
          GT_MSGCOLL-MSGV2     TO GT_MSG-MSGV2,
          GT_MSGCOLL-MSGV3     TO GT_MSG-MSGV3,
          GT_MSGCOLL-MSGV4     TO GT_MSG-MSGV4,
          GT_EBAN-EBELN        TO GT_MSG-REFNO,
          GT_EBAN-EBELP        TO GT_MSG-REFIT.

    APPEND GT_MSG.          CLEAR GT_MSG.
  ENDLOOP.

ENDFORM.                    " bdc_purchase_order_change
*&---------------------------------------------------------------------*
*&      Form  set_drdn_table
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SET_DRDN_TABLE .
  DATA: LT_DROPDOWN TYPE LVC_T_DROP,
        LS_DROPDOWN TYPE LVC_S_DROP.

  REFRESH LT_DROPDOWN. CLEAR LT_DROPDOWN.
* First listbox (handle '1').
  LS_DROPDOWN-HANDLE  = '1'.
  LS_DROPDOWN-VALUE   = '드럼'.
  APPEND LS_DROPDOWN TO LT_DROPDOWN.

  LS_DROPDOWN-HANDLE  = '1'.
  LS_DROPDOWN-VALUE   = '다발'.
  APPEND LS_DROPDOWN TO LT_DROPDOWN.

  CALL METHOD GCL_GRID->SET_DROP_DOWN_TABLE
    EXPORTING
      IT_DROP_DOWN = LT_DROPDOWN.

ENDFORM.                    " set_drdn_table
*&---------------------------------------------------------------------*
*&      Form  submit_zppr0052
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SUBMIT_ZPPR0052 USING PRT_MODE.
  DATA: LV_PRCNT      TYPE I.

  REFRESH GT_SELTAB. CLEAR GT_SELTAB.
  LOOP AT GT_EBAN WHERE CHECK = 'X'.
*& 완제품인 경우만 꼬리표를 발행...
    IF GT_EBAN-DISPO+2(1) <> 'F'.
      MESSAGE S001 WITH '완제품만 꼬리표발행이 가능합니다.!!!'.
      CLEAR: GT_EBAN-CHECK.
      MODIFY GT_EBAN.
      CONTINUE.
    ENDIF.

    CLEAR GS_SELTAB_WA.
    MOVE: 'P_WERKS'          TO GS_SELTAB_WA-SELNAME,
          'P'                TO GS_SELTAB_WA-KIND,      " PARAMETER
           GT_EBAN-WERKS     TO GS_SELTAB_WA-LOW.
    COLLECT GS_SELTAB_WA   INTO GT_SELTAB.

    CLEAR GS_SELTAB_WA.
    MOVE: 'S_AUFNR'          TO GS_SELTAB_WA-SELNAME,
          'P'                TO GS_SELTAB_WA-KIND,      " PARAMETER
           GT_EBAN-EBELN     TO GS_SELTAB_WA-LOW.
    COLLECT GS_SELTAB_WA   INTO GT_SELTAB.

    CLEAR GS_SELTAB_WA.
    MOVE: 'S_POSNR'          TO GS_SELTAB_WA-SELNAME,
          'P'                TO GS_SELTAB_WA-KIND,      " PARAMETER
           GT_EBAN-EBELP     TO GS_SELTAB_WA-LOW.
    COLLECT GS_SELTAB_WA   INTO GT_SELTAB.


    IF PRT_MODE = '재발행'.
*& 꼬리표번호 제안...
      CLEAR  ZPPT0001.
      SELECT SINGLE TAGNR INTO ZPPT0001-TAGNR
               FROM ZPPT0001
              WHERE WERKS = GT_EBAN-WERKS
                AND AUFNR = GT_EBAN-AUFNR
                AND POSNR = GT_EBAN-EBELP+1(4).
      IF SY-SUBRC = 0.
        CLEAR GS_SELTAB_WA.
        MOVE: 'S_TAGNR'          TO GS_SELTAB_WA-SELNAME,
              'P'                TO GS_SELTAB_WA-KIND,      " PARAMETER
               ZPPT0001-TAGNR    TO GS_SELTAB_WA-LOW.
        COLLECT GS_SELTAB_WA   INTO GT_SELTAB.
      ENDIF.
    ENDIF.

    CLEAR LV_PRCNT.
    IF PRT_MODE = '선발행'.
      LV_PRCNT = 1.
    ELSE.
      IF GT_EBAN-LENGTH_V > 0.
        LV_PRCNT = GT_EBAN-MENGE_A / GT_EBAN-LENGTH_V.
      ELSE.
        LV_PRCNT = 1.
      ENDIF.
    ENDIF.

    CLEAR GS_SELTAB_WA.
    MOVE: 'P_PRCNT'          TO GS_SELTAB_WA-SELNAME,
          'P'                TO GS_SELTAB_WA-KIND,    " PARAMETER
           LV_PRCNT          TO GS_SELTAB_WA-LOW.
    COLLECT GS_SELTAB_WA   INTO GT_SELTAB.

*    IF gt_eban-matkl+1(2) = 'AU'.   "자동차전선
*      CLEAR gs_seltab_wa.
*      MOVE: 'P_PRCNT'          TO gs_seltab_wa-selname,
*            'P'                TO gs_seltab_wa-kind,    " PARAMETER
*             gt_eban-factor    TO gs_seltab_wa-low.
*      COLLECT gs_seltab_wa   INTO gt_seltab.
*    ELSE.
*      CLEAR gs_seltab_wa.
*      MOVE: 'P_PRCNT'          TO gs_seltab_wa-selname,
*            'P'                TO gs_seltab_wa-kind,    " PARAMETER
*            '1'                TO gs_seltab_wa-low.
*      COLLECT gs_seltab_wa   INTO gt_seltab.
*    ENDIF.

*& 꼬리표 발행 여부 체크...
    IF NOT GT_EBAN-EBELN IS INITIAL.
      SELECT SINGLE MANDT INTO ZPPT0001-MANDT
               FROM ZPPT0001
              WHERE WERKS = GT_EBAN-WERKS
                AND AUFNR = GT_EBAN-AUFNR
                AND POSNR = GT_EBAN-EBELP
                AND MATNR = GT_EBAN-MATNR.
      IF SY-SUBRC = 0.
        GT_EBAN-TAG_F = ICON_LED_GREEN.
      ELSE.
        GT_EBAN-TAG_F = ''.
      ENDIF.
    ENDIF.

    MODIFY GT_EBAN.
  ENDLOOP.

*& 꼬리표 발행 프로그램 호출...
  CHECK NOT GT_SELTAB[] IS INITIAL.
  IF PRT_MODE = '선발행'.
    SUBMIT ZPPR0052 WITH SELECTION-TABLE GT_SELTAB
*&                     VIA SELECTION-SCREEN
                     AND RETURN.
  ELSE.
    SUBMIT ZPPR0052 WITH SELECTION-TABLE GT_SELTAB
                     VIA SELECTION-SCREEN
                     AND RETURN.
  ENDIF.
ENDFORM.                    " submit_zppr0052
*&---------------------------------------------------------------------*
*&      Form  create_zppt0001
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CREATE_ZPPT0001 .
  DATA: LV_TAGNR LIKE ZPPT0001-TAGNR,
        LV_SEQNO LIKE ZPPT0038-SEQNO.

  LOOP AT GT_EBAN WHERE CHECK = 'X'.
*& 완제품인 경우만 꼬리표를 생성...
    IF GT_EBAN-DISPO+2(1)  <> 'F' OR
       GT_EBAN-PACKING_CAT IS  INITIAL OR
       GT_EBAN-LENGTH_V IS INITIAL.
      CLEAR: GT_EBAN-CHECK.
      MODIFY GT_EBAN.
      CONTINUE.
    ENDIF.

    CLEAR LV_TAGNR.
    CASE GT_EBAN-MATKL+1(2).
      WHEN 'AU'. "자동차전선
        CHECK NOT GT_EBAN-CHARG IS INITIAL.
        CLEAR  ZPPT0001.
        SELECT SINGLE MANDT INTO ZPPT0001-MANDT
                 FROM ZPPT0001
                WHERE WERKS = GT_EBAN-WERKS
                  AND AUFNR = GT_EBAN-AUFNR
                  AND POSNR = GT_EBAN-EBELP+1(4).
        IF SY-SUBRC <> 0.
*& 꼬리표 채번...
          CONCATENATE GT_EBAN-LFDAT+3(5)
                      GT_EBAN-EBELN INTO LV_TAGNR.

          PERFORM INSERT_ZPPT0001  USING LV_TAGNR.
        ENDIF.
      WHEN  OTHERS.
        CLEAR  ZPPT0001.
        SELECT SINGLE MANDT INTO ZPPT0001-MANDT
                 FROM ZPPT0001
                WHERE WERKS = GT_EBAN-WERKS
                  AND AUFNR = GT_EBAN-AUFNR
                  AND POSNR = GT_EBAN-EBELP+1(4).
        IF SY-SUBRC <> 0.
*& 꼬리표 채번...
          CLEAR: ZPPT0038, LV_SEQNO.
          SELECT MAX( SEQNO ) INTO LV_SEQNO
              FROM ZPPT0038
             WHERE WERKS = GT_EBAN-WERKS
               AND SPGCD = GT_EBAN-MATKL+1(2)   "자재그룹
               AND AUSTD = GT_EBAN-LFDAT        "납품일자
               AND EBELN = GT_EBAN-EBELN.       "구매오더

          LV_SEQNO       = LV_SEQNO + 1.
          ZPPT0038-WERKS = GT_EBAN-WERKS.
          ZPPT0038-SPGCD = GT_EBAN-MATKL+1(2).
          ZPPT0038-AUSTD = GT_EBAN-LFDAT.
          ZPPT0038-EBELN = GT_EBAN-EBELN.
          ZPPT0038-SEQNO = LV_SEQNO.
          MODIFY ZPPT0038.

          CONCATENATE GT_EBAN-MATKL+1(2)
                      GT_EBAN-LFDAT
                      LV_SEQNO     INTO LV_TAGNR.
*& 2012.05.09 CSR:C20120417_90852
          IF GT_EBAN-WERKS EQ '1202' OR
             GT_EBAN-WERKS EQ '1404'.
            SELECT SINGLE * FROM ZPPT0158
             WHERE MATNR = GT_EBAN-MATNR.
            IF SY-SUBRC EQ 0.
              CLEAR : LV_TAGNR.
              CONCATENATE GT_EBAN-MATKL+1(2)
                          GT_EBAN-MATKL+4(3)
                          SY-DATUM+2(6)
                          GT_EBAN-EBELN+7(3)
                          LV_SEQNO+2(3) INTO LV_TAGNR.
            ENDIF.
          ENDIF.

          PERFORM INSERT_ZPPT0001 USING LV_TAGNR.

        ENDIF.
    ENDCASE.
  ENDLOOP.
ENDFORM.                    " create_zppt0001
*&---------------------------------------------------------------------*
*&      Form  insert_zppt0001
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_LV_TAGNR  text
*----------------------------------------------------------------------*
FORM INSERT_ZPPT0001  USING PV_TAGNR.
  DATA: LV_AUFNR       LIKE ZPPT0001-AUFNR.

  WRITE: GT_EBAN-LENGTH  TO GV_LENGTH  LEFT-JUSTIFIED,
         GT_EBAN-FACTOR  TO GV_FACTOR  LEFT-JUSTIFIED.

  CONDENSE: GV_LENGTH NO-GAPS,
            GV_FACTOR NO-GAPS.

  ZPPT0001-WERKS   =  GT_EBAN-WERKS.
  ZPPT0001-AUFNR   =  GT_EBAN-AUFNR.
  ZPPT0001-TAGNR   =  PV_TAGNR.
  ZPPT0001-MATNR   =  GT_EBAN-MATNR.
  ZPPT0001-SPGCD   =  GT_EBAN-MATKL+1(2).
  ZPPT0001-POSNR   =  GT_EBAN-EBELP+1(4).
  ZPPT0001-MGVRG   =  GT_EBAN-LENGTH_V.
  ZPPT0001-REMAIN  =  GT_EBAN-LENGTH_V.
  ZPPT0001-FOSTCNT =  GT_EBAN-FACTOR_V.
  ZPPT0001-MEINS   =  GT_EBAN-MEINS.
  ZPPT0001-OUTFLG  = 'X'.
  ZPPT0001-GIFLG   = 'N'.
  ZPPT0001-GRFLG   = 'N'.
  ZPPT0001-INSPFLG = 'OK'.
  ZPPT0001-WKDAT   = SY-DATUM.

  IF GT_EBAN-MATKL+1(2) = 'AU'.
    ZPPT0001-CHARG =  GT_EBAN-CHARG.
    ZPPT0001-WKINDAT = SY-DATUM.
  ENDIF.

  INSERT ZPPT0001.
ENDFORM.                    " insert_zppt0001
*&---------------------------------------------------------------------*
*&      Form  conversion_exit_alpha_input
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_EBAN_EBELN  text
*      <--P_LV_AUFNR  text
*----------------------------------------------------------------------*
FORM CONVERSION_EXIT_ALPHA_INPUT  USING PV_INPUT
                               CHANGING PV_OUTPUT.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = PV_INPUT
    IMPORTING
      OUTPUT = PV_OUTPUT.

ENDFORM.                    " conversion_exit_alpha_input
*&---------------------------------------------------------------------*
*&      Form  insert_into_zppt0018_hd
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM INSERT_INTO_ZPPT0018_HD .
  SELECT SINGLE MANDT INTO ZPPT0018-MANDT
           FROM ZPPT0018
          WHERE PSWRK  =  GT_EBAN-WERKS
            AND EBELN  =  GT_EBAN-EBELN
            AND EBELP  =  GT_EBAN-EBELP
            AND MATNR  =  GT_EBAN-MATNR
            AND TAGNR  = 'HEADER'.
  IF SY-SUBRC = 0.
    MOVE: ' '                      TO ZPPT0018-LOEKZ.
    MODIFY ZPPT0018.
  ELSE.
    MOVE-CORRESPONDING GT_EBAN     TO ZPPT0018.
    MOVE:  GT_EBAN-WERKS           TO ZPPT0018-PSWRK,
          'HEADER'                 TO ZPPT0018-TAGNR,
           SY-DATUM                TO ZPPT0018-ERDAT,
           SY-UZEIT                TO ZPPT0018-ERTIM,
           SY-UNAME                TO ZPPT0018-ERNAM.
    INSERT ZPPT0018.
  ENDIF.
ENDFORM.                    " insert_into_zppt0018_hd
*&---------------------------------------------------------------------*
*&      Form  read_long_text
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM READ_LONG_TEXT .
  DATA: LT_LINES  LIKE TLINE OCCURS 0 WITH HEADER LINE,
        LV_TDNAME LIKE STXH-TDNAME.

  CONCATENATE GT_EBAN-EBELN GT_EBAN-EBELP INTO LV_TDNAME.

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      ID        = 'F01'     "품목 텍스트 ID
      LANGUAGE  = SY-LANGU
      NAME      = LV_TDNAME
      OBJECT    = 'EKPO'    "구매오더에 대한 텍스트 오브젝트
*&    importing
*&      header    = e_theader
    TABLES
      LINES     = LT_LINES
    EXCEPTIONS
      NOT_FOUND = 01.

  READ TABLE LT_LINES INDEX 1.
  GT_EBAN-LTEXT1 = LT_LINES-TDLINE.

  CLEAR LT_LINES.   REFRESH LT_LINES.
  WRITE GT_EBAN-VBELN  TO LV_TDNAME.
  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      ID        = '0001'    "헤더 텍스트 ID
      LANGUAGE  = SY-LANGU
      NAME      = LV_TDNAME
      OBJECT    = 'VBBK'    "판매오더에 대한 텍스트 오브젝트
*&    importing
*&      header    = e_theader
    TABLES
      LINES     = LT_LINES
    EXCEPTIONS
      NOT_FOUND = 01.

  READ TABLE LT_LINES INDEX 1.
  GT_EBAN-LTEXT2 = LT_LINES-TDLINE.
ENDFORM.                    " read_long_text
*&---------------------------------------------------------------------*
*&      Form  submit_ZED1L1030
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SUBMIT_ZED1L1030 .
*  DATA: lv_sul_no     LIKE zedt1000-sul_no,
*        lv_rev_seq    LIKE zedt1000-rev_seq,
*        lv_gong_seq   LIKE zedt1050-gong_seq.
*
*  REFRESH gt_seltab. CLEAR gt_seltab.
*  READ TABLE gt_eban WITH KEY check = 'X'.
*  CASE gt_eban-mtart.
*    WHEN 'MCFE'.  "완제품
*      PERFORM get_sul_no_fert CHANGING lv_sul_no
*                                       lv_rev_seq.
*
*    WHEN 'MCHF'.  "반제품
*      PERFORM get_sul_no_halb CHANGING lv_sul_no
*                                       lv_rev_seq.
*
*    WHEN  OTHERS.
*  ENDCASE.
*
*  IF lv_sul_no IS INITIAL.
*    MESSAGE s001 WITH '해당 설계번호가 없습니다.!!!'.
*  ELSE.
*    SET PARAMETER ID 'ZED_SUL_NO'  FIELD lv_sul_no.
*    SET PARAMETER ID 'ZED_REV_SEQ' FIELD lv_rev_seq.
*
*    CALL TRANSACTION 'ZED1L1030' AND SKIP FIRST SCREEN.
*  ENDIF.
ENDFORM.                    " submit_ZED1L1030
*&---------------------------------------------------------------------*
*&      Form  get_sul_no_fert
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LV_SUL_NO  text
*      <--P_LV_REV_SEQ  text
*----------------------------------------------------------------------*
FORM GET_SUL_NO_FERT  CHANGING PV_SUL_NO
                               PV_REV_SEQ.

  CLEAR: PV_SUL_NO, PV_REV_SEQ.
  SELECT SINGLE  SUL_NO REV_SEQ
           INTO (PV_SUL_NO, PV_REV_SEQ)
           FROM  ZEDT1000
          WHERE  SPART     =  GT_EBAN-SPART
            AND  WERKS     =  GT_EBAN-WERKS
            AND  MATNR     =  GT_EBAN-MATNR
            AND  SUL_GUBUN = '2'
            AND  STATUS    = 'Z'.
ENDFORM.                    " get_sul_no_fert
*&---------------------------------------------------------------------*
*&      Form  get_sul_no_halb
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_LV_SUL_NO  text
*      <--P_LV_REV_SEQ  text
*----------------------------------------------------------------------*
FORM GET_SUL_NO_HALB  CHANGING PV_SUL_NO
                               PV_REV_SEQ.

  CLEAR: PV_SUL_NO, PV_REV_SEQ.
  SELECT SINGLE  A~SUL_NO A~REV_SEQ
           INTO (PV_SUL_NO, PV_REV_SEQ)
           FROM  ZEDT1050 AS A INNER JOIN ZEDT1000 AS B
                                       ON A~SUL_NO  = B~SUL_NO AND
                                          A~REV_SEQ = B~REV_SEQ
          WHERE  A~MATNR_N   =  GT_EBAN-MATNR
            AND  A~SPART     =  GT_EBAN-SPART
            AND  B~SUL_GUBUN = '2'
            AND  B~STATUS    = 'Z'.
ENDFORM.                    " get_sul_no_halb
*&---------------------------------------------------------------------*
*&      Form  copy_mdsb_l
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM COPY_MDSB_L.

  DATA : LV_W1(1) TYPE C,         "길이관리 체크 유무
         LV_W2(1) TYPE C.         "중량관리 체크 유무

  READ TABLE GT_MDSB_L WITH KEY CHECK = 'X'.

  IF SY-SUBRC = 0.
    LV_W1 = 'X'.
  ENDIF.

  READ TABLE GT_MDSB_W2 WITH KEY CHECK = 'X'.

  IF SY-SUBRC = 0.
    LV_W2 = 'X'.
  ENDIF.

  IF LV_W1 IS NOT INITIAL AND LV_W2 IS NOT INITIAL.
    MESSAGE E001 WITH '길이관리와 중량관리를 동시에 복사할수 없습니다.'.
  ENDIF.

  IF LV_W1 = 'X'.

    LOOP AT GT_MDSB_L WHERE CHECK = 'X'.
      CLEAR: GT_MDSB_L-CHECK.
      MODIFY GT_MDSB_L.

      CLEAR: GT_MDSB_L-BDMNG,
             GT_MDSB_L-CHARG,
             GT_MDSB_L-TAGNR,
             GT_MDSB_L-MBLNR,
             GT_MDSB_L-MJAHR,
             GT_MDSB_L-BUDAT,
             GT_MDSB_L-CPUDT,
             GT_MDSB_L-LOTNO,
             GT_MDSB_L-IV_NO,
             GT_MDSB_L-FLAG1,
             GT_MDSB_L-FLAG2,
             GT_MDSB_L-MBLNR_F,
             GT_MDSB_L-IV_DATE,
             GT_MDSB_L-IV_PRINT_YN,
             GT_MDSB_L-OUT_YN,
             GT_MDSB_L-STATS,  "추가(SJM 25.04.23)
             GT_MDSB_L-ZGUID.  "추가(SJM 25.04.23)

      APPEND GT_MDSB_L.
    ENDLOOP.
  ENDIF.

  IF LV_W2 ='X'.
*(S)배치 미관리 자재에서 행복사 불가 조건 추가(SJM 25.06.05)
    SELECT SINGLE MANDT
      FROM ZGTPPT1010 INTO SY-MANDT
     WHERE MODULE_KIND = GC_MM
       AND CODEGRP     = GC_0300
       AND FLD_01      = P_WERKS.

    IF SY-SUBRC <> 0
*(E)배치 미관리 자재에서 행복사 불가 조건 추가(SJM 25.06.05)
*(S)배치 미관리 자재에서 자재문서 존재시, 행복사 불가처리(SJM 25.04.29)
   AND LINE_EXISTS( GT_MDSB_W2[ CHECK = GC_X MBLNR_F = GC_X ] ).
      "이미 출고된 자재는 행 복사가 불가능합니다.
      MESSAGE S139(ZGTMM01) DISPLAY LIKE 'E'.
    ELSE.
*(E)배치 미관리 자재에서 자재문서 존재시, 행복사 불가처리(SJM 25.04.29)

*(S)배치 미관리 자재에서 꼬리표 존재하는 라인만 행복사 가능(SJM 25.06.09)
      IF LINE_EXISTS( GT_MDSB_W2[ CHECK = GC_X TAGNR = SPACE ] ).
        "꼬리표 관리된 항목만 복사 가능합니다.
        MESSAGE S155(ZGTMM01) DISPLAY LIKE 'E'.
        EXIT.
      ENDIF.
*(E)배치 미관리 자재에서 꼬리표 존재하는 라인만 행복사 가능(SJM 25.06.09)

      LOOP AT GT_MDSB_W2 WHERE CHECK = 'X'.
        CLEAR: GT_MDSB_W2-CHECK.
        MODIFY GT_MDSB_W2.

        CLEAR: GT_MDSB_W2-BDMNG,
               GT_MDSB_W2-CHARG,
               GT_MDSB_W2-TAGNR,
               GT_MDSB_W2-MBLNR,
               GT_MDSB_W2-MJAHR,
               GT_MDSB_W2-BUDAT,
               GT_MDSB_W2-CPUDT,
               GT_MDSB_W2-LOTNO,
               GT_MDSB_W2-IV_NO,
               GT_MDSB_W2-FLAG1,
               GT_MDSB_W2-FLAG2,
               GT_MDSB_W2-MBLNR_F,
               GT_MDSB_W2-IV_DATE,
               GT_MDSB_W2-IV_PRINT_YN,
               GT_MDSB_W2-OUT_YN,
               GT_MDSB_W2-STATS,  "추가(SJM 25.04.23)
               GT_MDSB_W2-ZGUID.  "추가(SJM 25.04.23)

        APPEND GT_MDSB_W2.
      ENDLOOP.
    ENDIF.
  ENDIF.
ENDFORM.                    " copy_mdsb_l
*&---------------------------------------------------------------------*
*&      Form  delete_mdsb_l
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DELETE_MDSB_L .
  DATA : LV_W1(1) TYPE C,         "길이관리 체크 유무
         LV_W2(1) TYPE C.         "중량관리 체크 유무

  READ TABLE GT_MDSB_L WITH KEY CHECK = 'X'.

  IF SY-SUBRC = 0.
    LV_W1 = 'X'.
  ENDIF.

  READ TABLE GT_MDSB_W2 WITH KEY CHECK = 'X'.

  IF SY-SUBRC = 0.
    LV_W2 = 'X'.
  ENDIF.

  IF LV_W1 IS NOT INITIAL AND LV_W2 IS NOT INITIAL.
    MESSAGE E001 WITH '길이관리와 중량관리를 동시에 삭제할수 없습니다.'.
  ENDIF.

  IF LV_W1 = 'X'.
    DELETE GT_MDSB_L WHERE CHECK = 'X'.
  ENDIF.

  IF LV_W2 = 'X'.
    DELETE GT_MDSB_W2 WHERE CHECK = 'X'.
  ENDIF.

ENDFORM.                    " delete_mdsb_l
*&---------------------------------------------------------------------*
*&      Form  get_wu_recs
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_EBAN_MATNR  text
*      -->P_GT_ENAN_WERKS  text
*      -->P_0911   text
*----------------------------------------------------------------------*
FORM GET_WU_RECS  USING    PV_MATNR_H
                           PV_WERKS
                           PV_STLAN
               CHANGING    PV_MATNR_F.

  DATA: LT_LTB     LIKE STPOV   OCCURS 0 WITH HEADER LINE,
        LT_EQUICAT LIKE CSCEQUI OCCURS 0 WITH HEADER LINE,
        LT_KNDCAT  LIKE CSCKND  OCCURS 0 WITH HEADER LINE,
        LT_MATCAT  LIKE CSCMAT  OCCURS 0 WITH HEADER LINE,
        LT_STDCAT  LIKE CSCSTD  OCCURS 0 WITH HEADER LINE,
        LT_TPLCAT  LIKE CSCTPL  OCCURS 0 WITH HEADER LINE,

        LS_SELPOOL LIKE MC29S.

  REFRESH: LT_LTB, LT_EQUICAT, LT_KNDCAT, LT_MATCAT,
           LT_STDCAT, LT_TPLCAT.

  CLEAR  : LT_LTB, LT_EQUICAT, LT_KNDCAT, LT_MATCAT,
           LT_STDCAT, LT_TPLCAT, LS_SELPOOL.

  CALL FUNCTION 'CS_WHERE_USED_MAT'
    EXPORTING
      DATUB                      = SY-DATUM
      DATUV                      = SY-DATUM
      MATNR                      = PV_MATNR_H
*&          postp                      = pm_postp
      STLAN                      = PV_STLAN
      WERKS                      = PV_WERKS
*&          STLTP                      = STLTP_IN
    IMPORTING
      TOPMAT                     = LS_SELPOOL
    TABLES
      WULTB                      = LT_LTB
      EQUICAT                    = LT_EQUICAT
      KNDCAT                     = LT_KNDCAT
      MATCAT                     = LT_MATCAT
      STDCAT                     = LT_STDCAT
      TPLCAT                     = LT_TPLCAT
    EXCEPTIONS
      CALL_INVALID               = 01
      MATERIAL_NOT_FOUND         = 02
      NO_WHERE_USED_REC_FOUND    = 03
      NO_WHERE_USED_REC_SELECTED = 04
      NO_WHERE_USED_REC_VALID    = 05.

  CHECK SY-SUBRC = 0.
  READ TABLE LT_LTB INDEX 1.

  CLEAR  MARA.
  SELECT SINGLE MTART INTO MARA-MTART
           FROM MARA
          WHERE MATNR = LT_LTB-MATNR.
  IF MARA-MTART = 'FERT' OR
     MARA-MTART = 'MCFE'.
    PV_MATNR_F = LT_LTB-MATNR.
  ELSE.
    PERFORM GET_WU_RECS USING LT_LTB-MATNR "반제품
                              LT_LTB-WERKS
                             '1'
                     CHANGING PV_MATNR_F.      "완제품
  ENDIF.
ENDFORM.                    " get_wu_recs
*&---------------------------------------------------------------------*
*&      Form  characteristic_for_pr
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_EBAN_BANFN  text
*      -->P_GT_EBAN_BNFPO  text
*      <--P_GT_EBAN_LENGTH_V  text
*----------------------------------------------------------------------*
FORM CHARACTERISTIC_FOR_PR  USING    PV_BANFN
                                     PV_BNFPO
                            CHANGING PV_LENGTH.

  DATA: LS_RETURN TYPE BAPIRET2_T.
  DATA: LT_CHAR   LIKE E1CUVAL OCCURS 0 WITH HEADER LINE.
  DATA: LV_VALUE_0(16) TYPE P DECIMALS 0,
        LV_VALUE_3(16) TYPE P DECIMALS 3.

  CLEAR: PV_LENGTH.
*& 특성값 가져오기........................
  CALL FUNCTION 'Z_PP_CHARACTERISTIC_FOR_PR'
    EXPORTING
      I_BANFN                      = PV_BANFN
      I_BNFPO                      = PV_BNFPO
    IMPORTING
      E_RETURN                     = LS_RETURN
    TABLES
      T_E1CUVAL                    = LT_CHAR
    EXCEPTIONS
      INSTANCE_NOT_FOUND           = 1
      INTERNAL_ERROR               = 2
      INSTANCE_IS_A_CLASSIFICATION = 3
      OTHERS                       = 4.

  CHECK SY-SUBRC = 0.
  LOOP AT LT_CHAR.
    CASE LT_CHAR-CHARC.
      WHEN 'SAP_MILLCA_LENGTH'.          "조장(기본단위)
        PERFORM CHAR_FLTP_CONVERSION USING LT_CHAR-VALUE
                                  CHANGING PV_LENGTH.

      WHEN  OTHERS.
    ENDCASE.
  ENDLOOP.

ENDFORM.                    " characteristic_for_pr
*&---------------------------------------------------------------------*
*&      Form  convert_po_unit
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM CONVERT_PO_UNIT .
  DATA: LV_MENGE   LIKE EKPO-MENGE.

  LOOP AT GT_EBAN WHERE CHECK = 'X'.
*& 단위수량 컨버젼...
    IF GT_EBAN-MEINS   IS INITIAL OR
       GT_EBAN-MEINS_A IS INITIAL.
    ELSE.
      LV_MENGE = GT_EBAN-MENGE_B.
      PERFORM MD_CONVERT_MATERIAL_UNIT USING GT_EBAN-MATNR
                                             GT_EBAN-MEINS
                                             GT_EBAN-MEINS_A
                                    CHANGING LV_MENGE.
      GT_EBAN-MENGE_A = LV_MENGE.
      MODIFY GT_EBAN.
    ENDIF.

  ENDLOOP.
ENDFORM.                    " convert_po_unit
*&---------------------------------------------------------------------*
*&      Form  submit_zppt0058
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SUBMIT_ZPPT0058.

  DATA : LV_CNT TYPE N,
         LV_TOT TYPE N,
         LV_ERR TYPE N,
         LV_MSG TYPE CHAR50.


  CLEAR : LV_CNT, LV_TOT, LV_ERR, LV_MSG.

  READ TABLE GT_EBAN WITH KEY CHECK = 'X'.

  IF GT_EBAN-BUKRS = '1000' AND            "LS 전선
     GT_EBAN-WERKS NE '1901'.
    REFRESH GT_SELTAB.             CLEAR GT_SELTAB.
    READ TABLE GT_EBAN WITH KEY CHECK = 'X'.

    PERFORM GENERATE_SELTAB_ZPPT0058.
    IF GT_SELTAB[] IS INITIAL.
      MESSAGE S001 WITH '해당 설계번호가 없습니다.!!!'.
    ELSE.
      SUBMIT ZPPR0058 WITH SELECTION-TABLE GT_SELTAB
                       AND RETURN.
    ENDIF.

  ELSEIF GT_EBAN-BUKRS = '2000' OR        "JS 전선
         GT_EBAN-WERKS = '1901'.

    LOOP AT GT_EBAN WHERE CHECK = 'X'.
      REFRESH GT_SELTAB.             CLEAR GT_SELTAB.

      PERFORM GENERATE_SELTAB_ZPPT0058.

      IF GT_SELTAB[] IS INITIAL.

        LV_ERR = LV_ERR + 1.

      ELSE.

        SUBMIT ZPPR0058 WITH SELECTION-TABLE GT_SELTAB
                        AND RETURN.

        LV_CNT = LV_CNT + 1.

      ENDIF.

    ENDLOOP.

    LV_TOT = LV_CNT + LV_ERR.

    IF LV_TOT NE LV_CNT.

      CONCATENATE '총' LV_TOT '건' '중' LV_CNT
                  '건을 출력하였습니다.'
                 INTO LV_MSG SEPARATED BY SPACE.

      CALL FUNCTION 'POPUP_TO_INFORM'
        EXPORTING
          TITEL = '외주설계서 출력 결과'
          TXT1  = LV_MSG
          TXT2  = '출력된 설계서를 확인하세요.'.

    ELSE.

      MESSAGE S002 WITH LV_TOT '건을 출력하였습니다.'.

    ENDIF.

  ENDIF.

*  REFRESH gt_seltab.             CLEAR gt_seltab.
*  READ TABLE gt_eban WITH KEY check = 'X'.
*  PERFORM generate_seltab_zppt0058.
*  IF gt_seltab[] IS INITIAL.
*    MESSAGE s001 WITH '해당 설계번호가 없습니다.!!!'.
*  ELSE.
*    SUBMIT zppr0058 WITH SELECTION-TABLE gt_seltab
*                     AND RETURN.
*  ENDIF.

ENDFORM.                    " submit_zppt0058
*&---------------------------------------------------------------------*
*&      Form  generate_seltab_zppt0058
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GENERATE_SELTAB_ZPPT0058 .
*  DATA: BEGIN OF lt_zedt1050 OCCURS 0,
*          conf_date     LIKE zedt1000-conf_date,
*          sul_no        LIKE zedt1050-sul_no,
*          rev_seq       LIKE zedt1050-rev_seq,
*          gong_seq      LIKE zedt1050-gong_seq,
*        END   OF lt_zedt1050.
*
*  DATA: lv_sul_no       LIKE zedt1000-sul_no,
*        lv_rev_seq      LIKE zedt1000-rev_seq,
*        lv_gong_seq     LIKE zedt1050-gong_seq.
*
**& 설계정보를 읽는다...
*  REFRESH lt_zedt1050.           CLEAR lt_zedt1050.
*
*  SELECT a~sul_no a~rev_seq a~gong_seq
*         b~conf_date
*    INTO CORRESPONDING FIELDS OF TABLE lt_zedt1050
*    FROM zedt1050 AS a INNER JOIN zedt1000 AS b
*                               ON a~sul_no  = b~sul_no AND
*                                  a~rev_seq = b~rev_seq
*   WHERE a~matnr_n   =  gt_eban-matnr
*     AND a~spart     =  gt_eban-spart
*     AND b~sul_gubun = '2'
*     AND b~status    IN ('X', 'Z').    "삭제,확정된 설계
*
*  SORT lt_zedt1050 DESCENDING BY conf_date.
*
*
*  IF lt_zedt1050[] IS INITIAL.   "ZEDT1050에 없으면 1071에서 조회
*
*    IF gt_eban-bukrs = '1000'.
*
*      SELECT DISTINCT a~sul_no a~rev_seq a~gong_seq
*             b~conf_date
*      INTO CORRESPONDING FIELDS OF TABLE lt_zedt1050
*        FROM zedt1071 AS a INNER JOIN zedt1000 AS b
*                                   ON a~sul_no  = b~sul_no AND
*                                      a~rev_seq = b~rev_seq
*       WHERE a~matnr     =  gt_eban-matnr
*         AND b~spart     =  gt_eban-spart
*         AND b~werks     =  gt_eban-werks
*         AND b~sul_gubun = '2'
*         AND b~status    IN ('X', 'Z').    "삭제,확정된 설계
*
*      SORT lt_zedt1050 DESCENDING BY conf_date.
*
*    ELSEIF gt_eban-bukrs = '2000'.
*
*      SELECT DISTINCT a~sul_no a~rev_seq a~gong_seq
*             b~conf_date
*      INTO CORRESPONDING FIELDS OF TABLE lt_zedt1050
*        FROM zedt1071 AS a INNER JOIN zedt1000 AS b
*                                   ON a~sul_no  = b~sul_no AND
*                                      a~rev_seq = b~rev_seq
*       WHERE a~matnr     =  gt_eban-matnr
*         AND b~spart     =  gt_eban-spart
*         AND b~werks     =  gt_eban-werks
*         AND b~sul_gubun IN ('2', '4')
*         AND b~status    IN ('B', 'Z').    "임시로 B,Z 조회
*
*      SORT lt_zedt1050 DESCENDING BY conf_date.
*
**& JS전선 확정,완료 설계가 없을경우(임시)
*      IF lt_zedt1050[] IS INITIAL.
*        SELECT DISTINCT a~sul_no a~rev_seq a~gong_seq
*                b~conf_date
*         INTO CORRESPONDING FIELDS OF TABLE lt_zedt1050
*           FROM zedt1071 AS a INNER JOIN zedt1000 AS b
*                                      ON a~sul_no  = b~sul_no AND
*                                         a~rev_seq = b~rev_seq
*          WHERE a~matnr     =  gt_eban-matnr
*            AND b~spart     =  gt_eban-spart
*            AND b~werks     =  gt_eban-werks
*            AND b~sul_gubun IN ('2', '4')
*            AND b~status    IN ('A', 'B', 'Z').    "임시로 B,Z 조회
*
*        SORT lt_zedt1050 ASCENDING BY conf_date.
*
*      ENDIF.
*    ENDIF.
*  ENDIF.
*
**  SORT lt_zedt1050 DESCENDING BY conf_date.
*  READ TABLE lt_zedt1050 INDEX 1.
*  IF lt_zedt1050-sul_no IS INITIAL.
*    EXIT.
*  ENDIF.
  DATA : LV_SPART    LIKE  MARA-SPART,
         LV_SULNO    LIKE  ZEDT1000-SUL_NO,
         LV_REVSEQ   LIKE  ZEDT1000-REV_SEQ,
         LV_GONG_SEQ LIKE  ZEDT1050-GONG_SEQ,
         LV_PREGONG  LIKE  ZEDT1050-GONG_SEQ,
         LV_ATWRT    TYPE  ATWRT.

  CLEAR : LV_SPART, LV_SULNO, LV_REVSEQ, LV_ATWRT, LV_GONG_SEQ,
          LV_PREGONG.

  SELECT SINGLE SPART
    INTO LV_SPART
    FROM MARA
   WHERE MATNR = GT_EBAN-MATNR.

*& 2007.09.20 반제품 설계번호 조회 로직 보완
  CALL FUNCTION 'Z_ED_GET_SUL_NO'
    EXPORTING
      I_BUKRS    = GT_EBAN-BUKRS
      I_WERKS    = GT_EBAN-WERKS
      I_SPART    = GT_EBAN-SPART
      I_MATNR    = GT_EBAN-MATNR
    IMPORTING
      O_SUL_NO   = LV_SULNO
      O_REV_SEQ  = LV_REVSEQ
      O_GONG_SEQ = LV_GONG_SEQ.

  IF LV_SULNO IS INITIAL.
    EXIT.
  ENDIF.

*& 설계번호...
  CLEAR  GS_SELTAB_WA.
  MOVE: 'P_SULNO'             TO GS_SELTAB_WA-SELNAME,
        'P'                   TO GS_SELTAB_WA-KIND,    " PARAMETER
         LV_SULNO             TO GS_SELTAB_WA-LOW.
  COLLECT GS_SELTAB_WA      INTO GT_SELTAB.

*& 개정번호...
  CLEAR  GS_SELTAB_WA.
  MOVE: 'P_REVSEQ'            TO GS_SELTAB_WA-SELNAME,
        'P'                   TO GS_SELTAB_WA-KIND,    " PARAMETER
         LV_REVSEQ            TO GS_SELTAB_WA-LOW.
  COLLECT GS_SELTAB_WA      INTO GT_SELTAB.

*& 2010.12.08 CSR : C20101208_86809
*& C20101130_81808 처리 내용 원복 처리
*& 2010.12.02 CSR :C20101130_81808
*& 1801 산특은 본공정만 출력
*  IF gt_eban-werks EQ '1801'.
*    lv_pregong = lv_gong_seq.
*  ELSE.
*& 전공정 시퀀스...
  SELECT MIN( GONG_SEQ )    INTO LV_PREGONG
                            FROM ZEDT1010
                           WHERE SUL_NO       = LV_SULNO
                             AND REV_SEQ      = LV_REVSEQ
                             AND AFT_GONG_SEQ = LV_GONG_SEQ.
*  ENDIF.

  CLEAR  GS_SELTAB_WA.
  MOVE: 'S_GONGNO'            TO GS_SELTAB_WA-SELNAME,
        'S'                   TO GS_SELTAB_WA-KIND,    " SELECT-OPTION
        'I'                   TO GS_SELTAB_WA-SIGN,
        'BT'                  TO GS_SELTAB_WA-OPTION,
         LV_PREGONG           TO GS_SELTAB_WA-LOW,
         LV_GONG_SEQ          TO GS_SELTAB_WA-HIGH.
  COLLECT GS_SELTAB_WA      INTO GT_SELTAB.

*& 자재코드...
  CLEAR  GS_SELTAB_WA.
  MOVE: 'P_MATNR'             TO GS_SELTAB_WA-SELNAME,
        'P'                   TO GS_SELTAB_WA-KIND,    " PARAMETER
         GT_EBAN-MATNR        TO GS_SELTAB_WA-LOW.
  COLLECT GS_SELTAB_WA      INTO GT_SELTAB.

*& 구매오더번호...
  CLEAR  GS_SELTAB_WA.
  MOVE: 'P_AUFNR'             TO GS_SELTAB_WA-SELNAME,
        'P'                   TO GS_SELTAB_WA-KIND,    " PARAMETER
         GT_EBAN-EBELN        TO GS_SELTAB_WA-LOW.
  COLLECT GS_SELTAB_WA      INTO GT_SELTAB.

*& 구매오더 수량
  CLEAR  GS_SELTAB_WA.
  MOVE: 'P_MENGE'             TO GS_SELTAB_WA-SELNAME,
        'P'                   TO GS_SELTAB_WA-KIND,    " PARAMETER
         GT_EBAN-MENGE_A      TO GS_SELTAB_WA-LOW.
  COLLECT GS_SELTAB_WA      INTO GT_SELTAB.

*& 구매오더 단위
  CLEAR  GS_SELTAB_WA.
  MOVE: 'P_MEINS'             TO GS_SELTAB_WA-SELNAME,
        'P'                   TO GS_SELTAB_WA-KIND,    " PARAMETER
         GT_EBAN-MEINS_A      TO GS_SELTAB_WA-LOW.
  COLLECT GS_SELTAB_WA      INTO GT_SELTAB.

*& 구분...
  CLEAR  GS_SELTAB_WA.
  MOVE: 'P_GUBUN'             TO GS_SELTAB_WA-SELNAME,
        'P'                   TO GS_SELTAB_WA-KIND,    " PARAMETER
        '1'                   TO GS_SELTAB_WA-LOW.
  COLLECT GS_SELTAB_WA      INTO GT_SELTAB.

*& 호출프로그램 구분...
  CLEAR  GS_SELTAB_WA.
  MOVE: 'P_PROG'              TO GS_SELTAB_WA-SELNAME,
        'P'                   TO GS_SELTAB_WA-KIND,    " PARAMETER
        'ZGTMMR4130'          TO GS_SELTAB_WA-LOW.
  COLLECT GS_SELTAB_WA      INTO GT_SELTAB.



ENDFORM.                    " generate_seltab_zppt0058
*&---------------------------------------------------------------------*
*&      Form  authority_checking_proc
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM AUTHORITY_CHECKING_PROC .
*& MRP관리자에 대한 권한체크
  AUTHORITY-CHECK OBJECT 'ZPP_DISPO'
  ID 'WERKS'  FIELD P_WERKS
  ID 'DISPO'  FIELD S_DISPO-LOW.

  IF SY-SUBRC <> 0.
    MESSAGE E003 WITH 'MRP관리자[' S_DISPO-LOW
                      '] 작업권한을 확인하세요.'.
  ENDIF.


*{ 2007.03.08 회사코드 로직 추가
  DATA : L_BUKRS LIKE T001-BUKRS.
  CLEAR L_BUKRS.
  CALL FUNCTION 'Z_ED_FIND_BUKRS'
    EXPORTING
      I_WERKS = P_WERKS
    IMPORTING
      O_BUKRS = G_BUKRS.
*} 2007.03.08 회사코드 로직 추가

ENDFORM.                    " authority_checking_proc
*&---------------------------------------------------------------------*
*&      Form  copy_po_text
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM COPY_PO_TEXT .

  REFRESH GT_MSG.    CLEAR GT_MSG.

  LOOP AT GT_EBAN WHERE CHECK = 'X'.

    PERFORM SEARCH_SULNO.             "설계번호 조회

    IF GT_SULNO[] IS INITIAL.
      EXIT.
    ENDIF.

    PERFORM SELECT_SULNO.             "설계내용 조회
    PERFORM BUILD_TEXT.               "설계내용 복사
    PERFORM SAVE_TEXT.                "구매오더에 설계내용 저장

  ENDLOOP.

*& 메시지 출력...
  CHECK NOT GT_MSG[] IS INITIAL.
  CALL FUNCTION 'Z_TI_POPUP_TO_ERROR_MESSAGE'
    EXPORTING
      XDOCNO_SHOW = 'X'
    TABLES
      XMSG        = GT_MSG.

ENDFORM.                    " copy_po_text
*&---------------------------------------------------------------------*
*&      Form  search_sulno
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SEARCH_SULNO.

*  DATA: BEGIN OF lt_zedt1050 OCCURS 0,
*          conf_date     LIKE zedt1000-conf_date,
*          sul_no        LIKE zedt1050-sul_no,
*          rev_seq       LIKE zedt1050-rev_seq,
*          gong_seq      LIKE zedt1050-gong_seq,
*        END   OF lt_zedt1050.
*
*  DATA: lv_sul_no       LIKE zedt1000-sul_no,
*        lv_rev_seq      LIKE zedt1000-rev_seq,
*        lv_gong_seq     LIKE zedt1050-gong_seq.
*
**& 설계정보를 읽는다...
*  REFRESH : lt_zedt1050, gt_sulno.
*  CLEAR   : lt_zedt1050, gt_sulno.
*
*  SELECT a~sul_no a~rev_seq a~gong_seq
*         b~conf_date
*    INTO CORRESPONDING FIELDS OF TABLE lt_zedt1050
*    FROM zedt1050 AS a INNER JOIN zedt1000 AS b
*                               ON a~sul_no  = b~sul_no AND
*                                  a~rev_seq = b~rev_seq
*   WHERE a~matnr_n   =  gt_eban-matnr
*     AND a~spart     =  gt_eban-spart
*     AND b~sul_gubun = '2'
*     AND b~status    IN ('X', 'Z').   "삭제,확정 설계
*
*  SORT lt_zedt1050 DESCENDING BY conf_date.
*
*  IF lt_zedt1050[] IS INITIAL.
*
*    IF gt_eban-bukrs = '1000'.
*      SELECT DISTINCT a~sul_no a~rev_seq a~gong_seq
*             b~conf_date
*      INTO CORRESPONDING FIELDS OF TABLE lt_zedt1050
*        FROM zedt1071 AS a INNER JOIN zedt1000 AS b
*                                   ON a~sul_no  = b~sul_no AND
*                                      a~rev_seq = b~rev_seq
*       WHERE a~matnr     =  gt_eban-matnr
*         AND b~spart     =  gt_eban-spart
*         AND b~sul_gubun = '2'
*         AND b~status    IN ('X', 'Z').    "삭제,확정된 설계 제외
*
*      SORT lt_zedt1050 DESCENDING BY conf_date.
*
*    ELSEIF gt_eban-bukrs = '2000'.
*      SELECT DISTINCT a~sul_no a~rev_seq a~gong_seq
*             b~conf_date
*      INTO CORRESPONDING FIELDS OF TABLE lt_zedt1050
*        FROM zedt1071 AS a INNER JOIN zedt1000 AS b
*                                   ON a~sul_no  = b~sul_no AND
*                                      a~rev_seq = b~rev_seq
*       WHERE a~matnr     =  gt_eban-matnr
*         AND b~spart     =  gt_eban-spart
*         AND b~sul_gubun IN ('2', '4')
*         AND b~status    IN ('B', 'Z').    "임시로 B,Z 조회
*
*      SORT lt_zedt1050 DESCENDING BY conf_date.
*
**& JS는 임시로 A상태까지 조회
*      IF lt_zedt1050[] IS INITIAL.
*        SELECT DISTINCT a~sul_no a~rev_seq a~gong_seq
*               b~conf_date
*        INTO CORRESPONDING FIELDS OF TABLE lt_zedt1050
*          FROM zedt1071 AS a INNER JOIN zedt1000 AS b
*                                     ON a~sul_no  = b~sul_no AND
*                                        a~rev_seq = b~rev_seq
*         WHERE a~matnr     =  gt_eban-matnr
*           AND b~spart     =  gt_eban-spart
*           AND b~sul_gubun IN ('2', '4')
*           AND b~status    IN ('A', 'B', 'Z').    "임시로 B,Z 조회
*
*        SORT lt_zedt1050 ASCENDING BY conf_date.
*
*      ENDIF.
*
*    ENDIF.
*
*  ENDIF.
*
**  SORT lt_zedt1050 DESCENDING BY conf_date.
*  READ TABLE lt_zedt1050 INDEX 1.
*  IF lt_zedt1050-sul_no IS INITIAL.
*    EXIT.
*  ENDIF.
  DATA : LV_SPART    LIKE  MARA-SPART,
         LV_SULNO    LIKE  ZEDT1000-SUL_NO,
         LV_REVSEQ   LIKE  ZEDT1000-REV_SEQ,
         LV_GONG_SEQ LIKE  ZEDT1050-GONG_SEQ,
         LV_PREGONG  LIKE  ZEDT1050-GONG_SEQ,
         LV_ATWRT    TYPE  ATWRT.

  CLEAR : LV_SPART, LV_SULNO, LV_REVSEQ, LV_ATWRT, LV_GONG_SEQ,
          LV_PREGONG.

  REFRESH : GT_SULNO.
  CLEAR   : GT_SULNO.

  SELECT SINGLE SPART
    INTO LV_SPART
    FROM MARA
   WHERE MATNR = GT_EBAN-MATNR.

*& 2007.09.20 반제품 설계번호 조회 로직 보완
  CALL FUNCTION 'Z_ED_GET_SUL_NO'
    EXPORTING
      I_BUKRS    = GT_EBAN-BUKRS
      I_WERKS    = GT_EBAN-WERKS
      I_SPART    = GT_EBAN-SPART
      I_MATNR    = GT_EBAN-MATNR
    IMPORTING
      O_SUL_NO   = LV_SULNO
      O_REV_SEQ  = LV_REVSEQ
      O_GONG_SEQ = LV_GONG_SEQ.

  IF LV_SULNO IS INITIAL.
    EXIT.
  ENDIF.
*& 전공정 시퀀스...
  SELECT MIN( GONG_SEQ )    INTO GT_SULNO-GONG_SEQ1
                            FROM ZEDT1010
                           WHERE SUL_NO       = LV_SULNO
                             AND REV_SEQ      = LV_REVSEQ
                             AND AFT_GONG_SEQ = LV_GONG_SEQ.


  MOVE LV_SULNO    TO GT_SULNO-SUL_NO.
  MOVE LV_REVSEQ   TO GT_SULNO-REV_SEQ.
  MOVE LV_GONG_SEQ TO GT_SULNO-GONG_SEQ2.

  APPEND GT_SULNO.   CLEAR GT_SULNO.

ENDFORM.                    " search_sulno
*&---------------------------------------------------------------------*
*&      Form  select_sulno
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SELECT_SULNO .

  READ TABLE GT_SULNO INDEX 1.

  DATA: L_TABIX   LIKE SY-TABIX,
        P_TABIX   LIKE SY-TABIX,
        L_SPEC_YN LIKE ZEDT1030-SPEC_YN,
        L_TEXT    TYPE STRING.

*[CHM2010-00178]-구매 오더 2개 이상 선택 후 설계 정보 복사 시
*                이전 설계 내용(특기사항)이 추가되어 이를 개선함
  REFRESH : GT_S110, GT_S120, GT_S140, GT_S150, GT_S160,
            GT_S165, GT_S170, GT_S180, GT_S041, GT_ROUT, GT_WORK.
  CLEAR   : GT_S110, GT_S120, GT_S140, GT_S150, GT_S160,
            GT_S165, GT_S170, GT_S180, GT_S041, GT_ROUT, GT_WORK,
            WA_S100, ZEDS300.
*[CHM2010-00178]-2020.10.14 By 오바다

  SELECT SINGLE * INTO WA_S100
         FROM ZEDT1000  WHERE SUL_NO   = GT_SULNO-SUL_NO
                          AND REV_SEQ  = GT_SULNO-REV_SEQ.

  PERFORM BASIC_DATA.

  SELECT * INTO TABLE GT_S110
           FROM ZEDV100  WHERE SUL_NO   = GT_SULNO-SUL_NO
                           AND REV_SEQ  = GT_SULNO-REV_SEQ
                           AND GONG_SEQ BETWEEN GT_SULNO-GONG_SEQ1 AND
                               GT_SULNO-GONG_SEQ2
*[S/4 HANA PJT]-설계 정보 sorting 추가
ORDER BY SUL_NO REV_SEQ GONG_SEQ JACK_SEQ.
*[S/4 HANA PJT]-2024.01.10 By 오바다

  SELECT * INTO TABLE GT_S120
           FROM ZEDT1030 WHERE SUL_NO   = GT_SULNO-SUL_NO
                           AND REV_SEQ  = GT_SULNO-REV_SEQ
                           AND GONG_SEQ BETWEEN GT_SULNO-GONG_SEQ1 AND
                               GT_SULNO-GONG_SEQ2
*[S/4 HANA PJT]-설계 정보 sorting 추가
    ORDER BY SUL_NO REV_SEQ GONG_SEQ JACK_SEQ.
*[S/4 HANA PJT]-2024.01.10 By 오바다.

  PERFORM ZEDS300_DISP_DATA_MOVE.

  LOOP AT GT_S110 INTO WA_S110.
    P_TABIX = SY-TABIX.

    LOOP AT GT_S041 INTO WA_S041
                       WHERE SPART   = WA_S100-SPART
                         AND JACK_CD = WA_S110-JACK_CD.
      CLEAR WA_S120.
      READ TABLE GT_S120 INTO WA_S120
                             WITH KEY GONG_SEQ  = WA_S110-GONG_SEQ
                                      JACK_SEQ  = WA_S110-JACK_SEQ
                                      ATTRIBUTE = WA_S041-ATTRIBUTE.

      L_SPEC_YN = WA_S120-SPEC_YN.
      MOVE-CORRESPONDING: WA_S041  TO WA_S120,
                          WA_S110  TO WA_S120.
      IF SY-SUBRC = 0.
        L_TABIX = SY-TABIX.
        IF WA_S041-ATFOR = 'CHAR'.
          IF NOT WA_S120-DATA_CHAR IS INITIAL.
            WA_S120-VALUE = WA_S120-DATA_CHAR.
            CALL FUNCTION 'Z_ED_INPUT_VALUE_CHECK'
              EXPORTING
                IS_ZEDS120 = WA_S120
                I_WERKS    = WA_S100-WERKS
              IMPORTING
                E_XMSG     = WA_XMSG
                E_TEXT     = L_TEXT.

            IF NOT L_TEXT IS INITIAL.
              WA_S120-VALUE = L_TEXT.
              WA_S120-DATA_TEXT = L_TEXT.
            ENDIF.
          ENDIF.
        ELSE.
          IF WA_S120-DATA_NUM <> 0.
            CALL FUNCTION 'Z_ED_DECIMAL_CONVERSION'
              EXPORTING
                INPUT  = WA_S120-DATA_NUM
                ANZDZ  = WA_S120-ANZDZ
              IMPORTING
                OUTPUT = WA_S120-VALUE.

            IF WA_S120-DATA_NUM < 0.
              WA_S120-VALUE = WA_S120-VALUE * -1.
              SHIFT WA_S120-VALUE RIGHT CIRCULAR. "부호앞으로.
              CONDENSE WA_S120-VALUE NO-GAPS.
            ENDIF.
          ENDIF.
        ENDIF.
        WA_S120-SPEC_YN = L_SPEC_YN.   "속성에 저장된 값 유지.
        PERFORM GET_LONG_TEXT.
        MODIFY GT_S120 FROM WA_S120 INDEX L_TABIX.
      ELSE.
        WA_S120-SPEC_YN = ''.   "초기화.
        APPEND WA_S120 TO GT_S120.
      ENDIF.
    ENDLOOP.

    CLEAR WA_ROUT.
    READ TABLE GT_ROUT INTO WA_ROUT
                          WITH KEY GONG_CD = WA_S110-GONG_CD.
    WA_S110-GONG_NM = WA_ROUT-GONG_NM.

    CLEAR WA_WORK.
    READ TABLE GT_WORK INTO WA_WORK
                          WITH KEY JACK_CD = WA_S110-JACK_CD.
    WA_S110-JACK_NM = WA_WORK-JACK_NM.

    MODIFY GT_S110 FROM WA_S110 INDEX P_TABIX.
  ENDLOOP.

  SORT GT_S120 BY SUL_NO REV_SEQ GONG_SEQ JACK_SEQ ATTRIBUTE_NO.

*[S/4 HANA PJT]-설계 정보 sorting 추가, 각 select order by 추가
  SELECT * INTO TABLE GT_S150
           FROM ZEDT1040 WHERE SUL_NO  = GT_SULNO-SUL_NO
                          AND REV_SEQ  = GT_SULNO-REV_SEQ
                          AND GONG_SEQ BETWEEN GT_SULNO-GONG_SEQ1 AND
                               GT_SULNO-GONG_SEQ2
ORDER BY SUL_NO REV_SEQ GONG_SEQ JACK_SEQ GUJO_SEQ1 GUJO_SEQ2.


  SELECT * INTO TABLE GT_S160
           FROM ZEDT1080 WHERE SUL_NO  = GT_SULNO-SUL_NO
                          AND REV_SEQ  = GT_SULNO-REV_SEQ
                          AND GONG_SEQ BETWEEN GT_SULNO-GONG_SEQ1 AND
                               GT_SULNO-GONG_SEQ2
ORDER BY SUL_NO REV_SEQ GONG_SEQ JACK_SEQ LAYER LAYER_SEQ.


  SELECT * INTO TABLE GT_S170
           FROM ZEDT1090 WHERE SUL_NO  = GT_SULNO-SUL_NO
                          AND REV_SEQ  = GT_SULNO-REV_SEQ
                          AND GONG_SEQ BETWEEN GT_SULNO-GONG_SEQ1 AND
                               GT_SULNO-GONG_SEQ2
ORDER BY SUL_NO REV_SEQ GONG_SEQ JACK_SEQ LAYER SEQNO.


  DELETE GT_S170 WHERE SHART = 'C'.      "쉬스작업자재구분

  SELECT * INTO TABLE GT_S180
           FROM ZEDT1100 WHERE SUL_NO  = GT_SULNO-SUL_NO
                          AND REV_SEQ  = GT_SULNO-REV_SEQ
                           AND GONG_SEQ BETWEEN GT_SULNO-GONG_SEQ1 AND
                               GT_SULNO-GONG_SEQ2
ORDER BY SUL_NO REV_SEQ GONG_SEQ JACK_SEQ DYNUM.


  SELECT * INTO TABLE GT_S165
           FROM ZEDT1130 WHERE SUL_NO  = GT_SULNO-SUL_NO
                          AND REV_SEQ  = GT_SULNO-REV_SEQ
                           AND GONG_SEQ BETWEEN GT_SULNO-GONG_SEQ1 AND
                               GT_SULNO-GONG_SEQ2
ORDER BY SUL_NO REV_SEQ GONG_SEQ JACK_SEQ LAYER YH_SEQ.
*[S/4 HANA PJT]-2024.01.10 By 오바다
ENDFORM.                    " select_sulno
*&---------------------------------------------------------------------*
*&      Form  zeds300_disp_data_move
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ZEDS300_DISP_DATA_MOVE .

  DATA: LT_S120      TYPE TABLE OF ZEDS120,
        LS_S120      TYPE ZEDS120,
        LT_DDFIELDS  TYPE DDFIELDS,
        LS_DDFIELDS  TYPE DFIES,
        L_STRING(30) TYPE C,
        LS_DATA      TYPE REF TO DATA.

  FIELD-SYMBOLS <LF_FS>.

  CALL FUNCTION 'CATSXT_GET_DDIC_FIELDINFO'
    EXPORTING
      IM_STRUCTURE_NAME = 'ZEDS300'
    IMPORTING
      EX_DDIC_INFO      = LT_DDFIELDS
    EXCEPTIONS
      FAILED            = 1
      OTHERS            = 2.

  LOOP AT GT_S120 INTO WA_S120
                     WHERE GONG_SEQ = '00'
                       AND JACK_SEQ = '00'.
    APPEND WA_S120 TO LT_S120.
  ENDLOOP.

  CREATE DATA LS_DATA TYPE ZEDS300.

  SORT LT_S120 BY SUL_NO REV_SEQ  GONG_SEQ JACK_SEQ ATTRIBUTE.

  LOOP AT LT_DDFIELDS INTO LS_DDFIELDS.

    CLEAR: LS_S120.
    CONCATENATE 'ls_data->' LS_DDFIELDS-FIELDNAME INTO L_STRING.
    ASSIGN (L_STRING) TO <LF_FS>.
    READ TABLE LT_S120 INTO LS_S120
                          WITH KEY SUL_NO    = GT_SULNO-SUL_NO
                                   REV_SEQ   = GT_SULNO-REV_SEQ
                                   GONG_SEQ  = '00'
                                   JACK_SEQ  = '00'
                                   ATTRIBUTE = LS_DDFIELDS-FIELDNAME
                          BINARY SEARCH.

    CHECK SY-SUBRC = 0.

    IF LS_DDFIELDS-DATATYPE = 'DEC' OR
       LS_DDFIELDS-DATATYPE = 'NUMC'.
      MOVE LS_S120-DATA_NUM  TO <LF_FS>.
    ELSE.
      MOVE LS_S120-DATA_CHAR TO <LF_FS>.
    ENDIF.

  ENDLOOP.

  ASSIGN  LS_DATA->* TO <LF_FS>.
  MOVE <LF_FS> TO ZEDS300.

ENDFORM.                    " zeds300_disp_data_move
*&---------------------------------------------------------------------*
*&      Form  get_long_text
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM GET_LONG_TEXT .
  CHECK ( WA_S120-ZCOMMENT = GC_CMT_LONGTEXT
     OR   WA_S120-ZCOMMENT = GC_MK_TEXT )
    AND NOT WA_S120-DATA_CHAR IS INITIAL.

  CLEAR WA_THEAD.
  WA_THEAD-TDID     = GC_TDID_ZED1.
  WA_THEAD-TDSPRAS  = SY-LANGU.
  WA_THEAD-TDOBJECT = GC_TDOBJECT_ZEDJACK.
  WA_THEAD-TDNAME   = WA_S120-DATA_CHAR.

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      ID                      = WA_THEAD-TDID
      LANGUAGE                = WA_THEAD-TDSPRAS
      NAME                    = WA_THEAD-TDNAME
      OBJECT                  = WA_THEAD-TDOBJECT
    IMPORTING
      HEADER                  = WA_THEAD
    TABLES
      LINES                   = GT_LONG
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
    CLEAR WA_S120-VALUE.
    EXIT.
  ENDIF.

  CLEAR WA_S140.
  MOVE-CORRESPONDING WA_S120 TO WA_S140.
  WA_S140-TLINE[] = GT_LONG[].
  APPEND WA_S140 TO GT_S140.

  CLEAR GT_LONG.
  READ TABLE GT_LONG INDEX 1.

  WA_S120-VALUE = GT_LONG-TDLINE.
ENDFORM.                    " get_long_text
*&---------------------------------------------------------------------*
*&      Form  build_text
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM BUILD_TEXT.
  DATA: L_EXIST,
        LFM_NAME       TYPE RS38L_FNAM,    " CALL할 SMARTFORM
        L_SSFC         TYPE SSFCTRLOP,
        L_TDSFNAME     TYPE TDSFNAME,
        LV_OUTDIA(6)   TYPE C,
        LV_THICK(6)    TYPE C,
        LV_JAJE_QTY(9) TYPE C.

  REFRESH : GT_LINE, WA_S044.
  CLEAR: GT_S044[], GT_S044, WA_S044, L_SSFC, GT_LINE,
         LV_OUTDIA, LV_THICK, LV_JAJE_QTY.

  SORT GT_S110 BY GONG_SEQ JACK_SEQ.

  LOOP AT GT_S110 INTO WA_S110.
    CLEAR WA_WORK.
    READ TABLE GT_WORK INTO WA_WORK
                       WITH KEY JACK_CD = WA_S110-JACK_CD.
    CALL FUNCTION 'FUNCTION_EXISTS'
      EXPORTING
        FUNCNAME           = WA_WORK-FNAME_PRN
      EXCEPTIONS
        FUNCTION_NOT_EXIST = 1
        OTHERS             = 2.

    IF SY-SUBRC <> 0.
      CONTINUE.
    ENDIF.

    CLEAR ZEDS110.
    ZEDS110 = WA_S110.

    CASE WA_S100-SPART.
      WHEN '31'.  "가공선.
        CALL FUNCTION WA_WORK-FNAME_PRN
          EXPORTING
            IS_ZEDS100 = WA_S100
            IS_ZEDS110 = ZEDS110
            IS_ZEDS300 = ZEDS300
          TABLES
            IT_ZEDS110 = GT_S110
            IT_ZEDS120 = GT_S120
            IT_ZEDS140 = GT_S140
            IT_ZEDS150 = GT_S150
            IT_ZEDS170 = GT_S170
            IT_ZEDS165 = GT_S165
            IT_ZEDS044 = GT_S044.
      WHEN '23' OR '30'.       "전력/피복.
        CALL FUNCTION WA_WORK-FNAME_PRN
          EXPORTING
            IS_ZEDS100 = WA_S100
            IS_ZEDS110 = ZEDS110
            IS_ZEDS300 = ZEDS300
          TABLES
            IT_ZEDS110 = GT_S110
            IT_ZEDS120 = GT_S120
            IT_ZEDS140 = GT_S140
            IT_ZEDS150 = GT_S150
            IT_ZEDS170 = GT_S170
            IT_ZEDS044 = GT_S044.
      WHEN OTHERS.
        CALL FUNCTION WA_WORK-FNAME_PRN
          EXPORTING
            IS_ZEDS100 = WA_S100
            IS_ZEDS110 = ZEDS110
          TABLES
            IT_ZEDS110 = GT_S110
            IT_ZEDS120 = GT_S120
            IT_ZEDS140 = GT_S140
            IT_ZEDS150 = GT_S150
            IT_ZEDS160 = GT_S160
            IT_ZEDS170 = GT_S170
            IT_ZEDS180 = GT_S180
            IT_ZEDS044 = GT_S044.
    ENDCASE.
  ENDLOOP.

  CHECK NOT GT_S044[] IS INITIAL.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
    EXPORTING
      INPUT  = GT_EBAN-MATNR
    IMPORTING
      OUTPUT = GT_EBAN-MATNR.

  CONCATENATE '품명규격 : ' GT_EBAN-TXZ01 INTO GT_LINE-TDLINE SEPARATED
  BY SPACE.

  APPEND GT_LINE.

  CONCATENATE '자재코드 : ' GT_EBAN-MATNR '    ' '구매오더번호 :'
  GT_EBAN-EBELN
              INTO GT_LINE-TDLINE SEPARATED BY SPACE.

  APPEND GT_LINE.

  MOVE '+++++' TO GT_LINE-TDLINE.             "설계내용 시작

  APPEND GT_LINE.

  MOVE '$공정명$작업명$내용$두께$외경$투입자재$~' TO GT_LINE-TDLINE.

  APPEND GT_LINE.

  LOOP AT GT_S044 INTO WA_S044.

    CONCATENATE '$' WA_S044-GONG_NM '$' WA_S044-JACK_NM '$'
    WA_S044-CONTENT+0(62) '$'
                INTO GT_LINE-TDLINE.

    IF WA_S044-THICK IS INITIAL.         "두께

      CONCATENATE GT_LINE-TDLINE '$' INTO GT_LINE-TDLINE.

    ELSE.

      LV_THICK = WA_S044-THICK.

      CONCATENATE GT_LINE-TDLINE LV_THICK '$' INTO GT_LINE-TDLINE.

      CLEAR LV_THICK.
    ENDIF.

    IF WA_S044-OUT_DIA IS INITIAL.       "외경

      CONCATENATE GT_LINE-TDLINE '$' INTO GT_LINE-TDLINE.

    ELSE.

      LV_OUTDIA = WA_S044-OUT_DIA.

      CONCATENATE GT_LINE-TDLINE LV_OUTDIA '$' INTO GT_LINE-TDLINE.

      CLEAR LV_OUTDIA.

    ENDIF.

    CONCATENATE GT_LINE-TDLINE WA_S044-JAJE_NM '$~' INTO GT_LINE-TDLINE.

    APPEND GT_LINE.    CLEAR GT_LINE.

  ENDLOOP.

ENDFORM.                    " build_text

*&---------------------------------------------------------------------*
*&      Form  basic_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM BASIC_DATA .
*{ 2007.03.08 회사코드 로직 추가
  SELECT * INTO TABLE GT_S041
           FROM ZEDT0000 WHERE BUKRS = G_BUKRS
                         AND   SPART = WA_S100-SPART.


  SELECT * INTO CORRESPONDING FIELDS OF TABLE GT_ROUT
           FROM ZEDV001 WHERE BUKRS = G_BUKRS
                        AND   SPART = WA_S100-SPART.

  SELECT * INTO CORRESPONDING FIELDS OF TABLE GT_WORK
           FROM ZEDV002 WHERE BUKRS = G_BUKRS
                        AND   SPART = WA_S100-SPART.
*} 2007.03.08 회사코드 로직 추가
*  SELECT * INTO TABLE GT_S041
*           FROM ZEDT0000 WHERE SPART = WA_S100-SPART.
*
*
*  SELECT * INTO CORRESPONDING FIELDS OF TABLE GT_ROUT
*           FROM ZEDV001 WHERE SPART = WA_S100-SPART.
*
*  SELECT * INTO CORRESPONDING FIELDS OF TABLE GT_WORK
*           FROM ZEDV002 WHERE SPART = WA_S100-SPART.
ENDFORM.                    " basic_data
*&---------------------------------------------------------------------*
*&      Form  save_text
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM SAVE_TEXT.

  REFRESH : GT_BAPI_TEXTITEM, GT_BAPI_ITEM, GT_BAPI_ITEMX.
  CLEAR  : GT_BAPI_TEXTITEM, GT_BAPI_ITEM, GT_BAPI_ITEMX.

  LOOP AT GT_LINE.

    GT_BAPI_TEXTITEM-PO_NUMBER = GT_EBAN-EBELN.
    GT_BAPI_TEXTITEM-PO_ITEM   = GT_EBAN-EBELP.
    GT_BAPI_TEXTITEM-TEXT_ID   = 'F01'.
    GT_BAPI_TEXTITEM-TEXT_FORM = '*'.
    GT_BAPI_TEXTITEM-TEXT_LINE = GT_LINE-TDLINE.

    APPEND GT_BAPI_TEXTITEM. CLEAR GT_BAPI_TEXTITEM.

  ENDLOOP.


*& P/O Item 구성...
  GT_BAPI_ITEM-PO_ITEM            = GT_EBAN-EBELP.
  "구매문서 품목번호
  APPEND GT_BAPI_ITEM.         CLEAR GT_BAPI_ITEM.

*& P/O Item(변경툴바) 구성...
  GT_BAPI_ITEMX-PO_ITEM           = GT_EBAN-EBELP.
  "구매문서 품목번호
  APPEND GT_BAPI_ITEMX.        CLEAR GT_BAPI_ITEMX.

*& 구매오더를 변경한다...
  CALL FUNCTION 'BAPI_PO_CHANGE'
    EXPORTING
      PURCHASEORDER = GT_EBAN-EBELN
      TESTRUN       = GV_TESTRUN
    TABLES
      RETURN        = GT_RET2
      POTEXTITEM    = GT_BAPI_TEXTITEM
      POITEM        = GT_BAPI_ITEM
      POITEMX       = GT_BAPI_ITEMX.

  READ TABLE GT_RET2 WITH KEY TYPE = 'E'.

  IF SY-SUBRC <> 0.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.

    MOVE: GT_RET2-LOG_NO      TO GT_MSG-LOGNO,
          GT_RET2-LOG_MSG_NO  TO GT_MSG-MSGSQ,
          GT_RET2-ID          TO GT_MSG-MSGID,
          GT_RET2-TYPE        TO GT_MSG-MSGTY,
          GT_RET2-NUMBER      TO GT_MSG-MSGNO,
          GT_RET2-MESSAGE_V1  TO GT_MSG-MSGV1,
          GT_RET2-MESSAGE_V2  TO GT_MSG-MSGV2,
          GT_RET2-MESSAGE_V3  TO GT_MSG-MSGV3,
          GT_RET2-MESSAGE_V4  TO GT_MSG-MSGV4,
          GT_RET2-MESSAGE     TO GT_MSG-MSGTX,
          GT_EBAN-EBELN       TO GT_MSG-REFNO,
          GT_EBAN-EBELP       TO GT_MSG-REFIT.

    APPEND GT_MSG.         CLEAR GT_MSG.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    MOVE: GT_RET2-LOG_NO      TO GT_MSG-LOGNO,
          GT_RET2-LOG_MSG_NO  TO GT_MSG-MSGSQ,
          GT_RET2-ID          TO GT_MSG-MSGID,
          GT_RET2-TYPE        TO GT_MSG-MSGTY,
          GT_RET2-NUMBER      TO GT_MSG-MSGNO,
          GT_RET2-MESSAGE_V1  TO GT_MSG-MSGV1,
          GT_RET2-MESSAGE_V2  TO GT_MSG-MSGV2,
          GT_RET2-MESSAGE_V3  TO GT_MSG-MSGV3,
          GT_RET2-MESSAGE_V4  TO GT_MSG-MSGV4,
          GT_RET2-MESSAGE     TO GT_MSG-MSGTX,
          GT_EBAN-EBELN       TO GT_MSG-REFNO,
          GT_EBAN-EBELP       TO GT_MSG-REFIT.

    APPEND GT_MSG.         CLEAR GT_MSG.
  ENDIF.

ENDFORM.                    " save_text
*&---------------------------------------------------------------------*
*&      Form  read_po_text
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_EBELN  text
*      -->P_EBELP  text
*----------------------------------------------------------------------*
FORM READ_PO_TEXT  USING    P_EBELN
                            P_EBELP.
  DATA: LT_LINES  LIKE TLINE OCCURS 0 WITH HEADER LINE,
        LV_TDNAME LIKE STXH-TDNAME,
        LV_LAST   TYPE I,           "텍스트 마지막 위치
        LV_FIND1  TYPE I,           "'$' 검색 위치
        LV_FIND2  TYPE I,           "'$' 검색 종료 위치
        LV_FIND3  TYPE I,           " text 길이
        LV_CNT    TYPE I,           "
        LV_CHECK  TYPE C.           "설계내용 시작 체크용

  DATA: LV_TEXT1(178) TYPE C,
        LV_TEXT2(178) TYPE C,
        LT_EDIT1(178) TYPE C OCCURS 0 WITH HEADER LINE,
        LT_EDIT2(178) TYPE C OCCURS 0 WITH HEADER LINE.

  REFRESH: GT_TEXTEDIT_LINES, LT_EDIT1, LT_EDIT2.
  CLEAR  : GT_TEXTEDIT_LINES, LV_TEXT1, LV_TEXT2, LV_LAST, LT_EDIT1,
  LT_EDIT2.

  CONCATENATE GT_EBAN-EBELN GT_EBAN-EBELP INTO LV_TDNAME.

  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      ID        = 'F01'     "품목 텍스트 ID
      LANGUAGE  = SY-LANGU
      NAME      = LV_TDNAME
      OBJECT    = 'EKPO'    "구매오더에 대한 텍스트 오브젝트
    TABLES
      LINES     = LT_LINES
    EXCEPTIONS
      NOT_FOUND = 01.

  CLEAR LV_CHECK.

*& '+++++'가 있는 다음 라인 부터 130칼럼 이상되는 경우 떨어진 라인을
*하나로 합침
  LOOP AT LT_LINES.

    IF LV_CHECK IS INITIAL.

      FIND '+++++' IN LT_LINES-TDLINE MATCH OFFSET LV_FIND1.

      IF SY-SUBRC = 0.                                  "~ 검색 성공

        LV_CHECK = 'X'.

      ENDIF.

      MOVE LT_LINES-TDLINE TO LV_TEXT1.

      MOVE LV_TEXT1 TO LT_EDIT1.

      APPEND LT_EDIT1.

      CLEAR LV_TEXT1.

    ELSE.

      LV_LAST = STRLEN( LT_LINES-TDLINE ) - 1.

      MOVE LT_LINES-TDLINE TO LV_TEXT1.

*IF lt_lines-tdline+lv_last(1) = '~'.    "마지막 위치가 '~'이면 append
*
*        IF lv_text2 IS NOT INITIAL.
*
*          CONCATENATE lv_text2 lv_text1 INTO lv_text1.
*
*          CLEAR lv_text2.
*
*        ENDIF.

      MOVE LV_TEXT1 TO LT_EDIT1.

      APPEND LT_EDIT1.

      CLEAR LV_TEXT1.

    ENDIF.

  ENDLOOP.


  CLEAR LV_CHECK.
**& 단락 구분용 $를 삭제하고 단락별 데이타 복사

  LOOP AT LT_EDIT1.
    "$ 삭제 및 위치 조정

*& lv_check가 'X'가 아닐 경우 '+++++'를 검색하여 없으면 한라인 복사
*& 있으면 '+++++'를 지우고 라인 복사후 설계 내용 출력

    IF LV_CHECK IS INITIAL.

      FIND '+++++' IN LT_EDIT1 MATCH OFFSET LV_FIND1.

      IF SY-SUBRC = 0.                                  "~ 검색 성공

        REPLACE '+++++' IN LT_EDIT1 WITH ''.

        DO 130 TIMES.

          CONCATENATE LT_EDIT2 '-' INTO LT_EDIT2.

        ENDDO.

        APPEND LT_EDIT2.

        CLEAR  LT_EDIT2.

        LV_CHECK = 'X'.

      ELSE.

        MOVE LT_EDIT1 TO LT_EDIT2.

        APPEND LT_EDIT2.

        CLEAR LT_EDIT2.

        CONTINUE.
      ENDIF.

    ELSE.

      IF LT_EDIT1+0(1) = '$'.                    "시작 $는 삭제

        LT_EDIT1+0(1) = SPACE.

      ENDIF.

      REPLACE '~' IN LT_EDIT1 WITH ''.           "행 분리 ~ 삭제

*& $가 있는 위치를 찿아 $를 삭제하고 내용을 복사
      DO.

        FIND '$' IN LT_EDIT1 MATCH OFFSET LV_FIND1.  "$위치 검색

        LV_FIND1 = LV_FIND1 - 1.                     "$위치 -1 위치 검색

        IF LV_FIND1 < 0.

          EXIT.

        ENDIF.

        CASE LV_CNT.     "$ 변환 횟수에 따른 위치 조정

          WHEN 0.

            IF LV_FIND1 <> 0.      "$가 없는 경우 2줄로 나뉜 경우

              CONCATENATE '|' LT_EDIT1+1(LV_FIND1) INTO LT_EDIT2+0(9).

            ELSE.

              LT_EDIT2+0(9) = '|'.

            ENDIF.
            LV_FIND1 = LV_FIND1 + 1.
            LV_FIND2 = LV_FIND1.

            LT_EDIT1+1(LV_FIND1) = ''.

            MODIFY LT_EDIT1.

          WHEN 1.

            LV_FIND3 = LV_FIND1 - LV_FIND2 + 1.

            IF LV_FIND3 = 0.
              LT_EDIT2+9(14) = '|'.
              EXIT.
            ENDIF.

            CONCATENATE '|' LT_EDIT1+LV_FIND2(LV_FIND3) INTO
            LT_EDIT2+9(14).

            LV_FIND1 = LV_FIND1 + 1.
            LV_FIND2 = LV_FIND1.

            LT_EDIT1+1(LV_FIND1) = ''.

            MODIFY LT_EDIT1.

          WHEN 2.

            LV_FIND3 = LV_FIND1 - LV_FIND2 + 1.

            IF LV_FIND3 = 0.
              LT_EDIT2+23(58) = '|'.
              EXIT.
            ENDIF.

            CONCATENATE '|' LT_EDIT1+LV_FIND2(LV_FIND3) INTO
            LT_EDIT2+23(58).

            LV_FIND1 = LV_FIND1 + 1.
            LV_FIND2 = LV_FIND1.

            LT_EDIT1+1(LV_FIND1) = ''.

            MODIFY LT_EDIT1.

          WHEN 3.

            LV_FIND3 = LV_FIND1 - LV_FIND2 + 1.

            IF LV_FIND3 = 0.
              LT_EDIT2+81(8) = '|'.
              EXIT.

            ENDIF.

            CONCATENATE '|' LT_EDIT1+LV_FIND2(LV_FIND3) INTO
            LT_EDIT2+81(8).

            LV_FIND1 = LV_FIND1 + 1.
            LV_FIND2 = LV_FIND1.

            LT_EDIT1+1(LV_FIND1) = ''.

            MODIFY LT_EDIT1.

          WHEN 4.

            LV_FIND3 = LV_FIND1 - LV_FIND2 + 1.

            IF LV_FIND3 = 0.
              LT_EDIT2+89(8) = '|'.
              EXIT.

            ENDIF.

            CONCATENATE '|' LT_EDIT1+LV_FIND2(LV_FIND3) INTO
            LT_EDIT2+89(8).

            LV_FIND1 = LV_FIND1 + 1.
            LV_FIND2 = LV_FIND1.

            LT_EDIT1+1(LV_FIND1) = ''.

            MODIFY LT_EDIT1.

          WHEN 5.

            LV_FIND3 = LV_FIND1 - LV_FIND2 + 1.

            IF LV_FIND3 = 0.
              LT_EDIT2+97(32) = '|'.
              EXIT.
            ENDIF.

            CONCATENATE '|' LT_EDIT1+LV_FIND2(LV_FIND3) INTO
            LT_EDIT2+97(33).

            LV_FIND1 = LV_FIND1 + 1.
            LV_FIND2 = LV_FIND1.

            LT_EDIT1+1(LV_FIND1) = ''.

            MODIFY LT_EDIT1.

        ENDCASE.

        IF LV_CNT = 5.
          EXIT.
        ENDIF.

        LV_CNT = LV_CNT + 1.

      ENDDO.


      APPEND LT_EDIT2.

      CLEAR : LV_CNT, LT_EDIT2.
    ENDIF.

  ENDLOOP.

  GT_TEXTEDIT_LINES[] = LT_EDIT2[].


ENDFORM.                    " read_po_text
*&---------------------------------------------------------------------*
*&      Form  F4_FOR_VARIANT
*&---------------------------------------------------------------------*
FORM F4_FOR_VARIANT  USING    P_VARI.

  CLEAR ALV_VARIANT.

  ALV_VARIANT-REPORT = SY-REPID.

  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
    EXPORTING
      IS_VARIANT    = ALV_VARIANT
      I_SAVE        = 'A'
    IMPORTING
      E_EXIT        = G_EXIT
      ES_VARIANT    = ALV_VARIANT
    EXCEPTIONS
      NOT_FOUND     = 1
      PROGRAM_ERROR = 2
      OTHERS        = 3.

  IF SY-SUBRC EQ 0 AND G_EXIT IS INITIAL.
    P_VARI = ALV_VARIANT-VARIANT.
  ELSE.
    MESSAGE ID SY-MSGID TYPE 'S' NUMBER SY-MSGNO
            WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ENDIF.

ENDFORM.                    " F4_FOR_VARIANT
**&---------------------------------------------------------------------
**
**&      Form  GET_DEFAULT_VARIANT
**&---------------------------------------------------------------------
**
**       text
**----------------------------------------------------------------------
**
**  -->  p1        text
**  <--  p2        text
**----------------------------------------------------------------------
**
*FORM get_default_variant.
*
*  alv_variant-report = sy-repid.
*
*  IF p_vari IS INITIAL AND gs_variant IS INITIAL.
*
*    CALL FUNCTION 'REUSE_ALV_VARIANT_DEFAULT_GET'
*      EXPORTING
*        i_save     = 'A'
*      CHANGING
*        cs_variant = alv_variant
*      EXCEPTIONS
*        not_found  = 2.
*
*    IF sy-subrc = 0.
*      p_vari = alv_variant-variant.
*      gs_variant = alv_variant-variant.
*    ENDIF.
*  ELSE.
*
*      p_vari = gs_variant.
*      alv_variant-variant = gs_variant.
*
*  ENDIF.
*
*ENDFORM.                    " GET_DEFAULT_VARIANT
*&---------------------------------------------------------------------*
*&      Form  delete_pr
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM DELETE_PR.
  DATA  : LV_MENGE LIKE EKPO-MENGE.
  CLEAR : GV_TABIX, LV_MENGE.
  REFRESH GT_MSG. CLEAR GT_MSG.

  LOOP AT GT_EBAN WHERE CHECK = 'X'.
    GV_TABIX = SY-TABIX.

*(S)구매요청이 없으면 삭제 불가처리(SJM 25.04.28)
    IF GT_EBAN-BANFN IS INITIAL.
      "삭제할 구매요청번호가 없습니다.
      PERFORM SET_POP_MSG USING 'ZGTMM01' 'E' '138' ' ' ' ' ' '.

      GT_EBAN-CHECK = SPACE.
      MODIFY GT_EBAN TRANSPORTING CHECK.
      CONTINUE.
    ENDIF.
*(E)구매요청이 없으면 삭제 불가처리(SJM 25.04.28)

*& 해당 구매요청이 구매오더로 전환된건이 있으면 에러 처리

    SELECT SUM( MENGE )
      INTO LV_MENGE
      FROM EKPO
     WHERE BANFN = GT_EBAN-BANFN
       AND BNFPO = GT_EBAN-BNFPO
       AND LOEKZ = SPACE.

    IF LV_MENGE > 0 .   "구매요청으로 구매오더 전환된 건이 있으면 에러
      CLEAR GT_MSG.
      GT_MSG-MSGID = 'ZPP1'.
      GT_MSG-MSGTY = 'E'.
      GT_MSG-MSGNO = '004'.
      GT_MSG-MSGV1 = '구매오더로 전환된 구매요청이 있습니다.'.
      GT_MSG-REFNO =  GT_EBAN-BANFN.
      GT_MSG-REFIT =  GT_EBAN-BNFPO.

      APPEND GT_MSG.    CLEAR GT_MSG.

      GT_EBAN-CHECK = ''.
      MODIFY GT_EBAN.
      CONTINUE.
    ENDIF.

*& 구매오더 삭제...
    PERFORM BAPI_PR_DELETE.

  ENDLOOP.

  IF NOT GT_MSG[] IS INITIAL.
    CALL FUNCTION 'Z_TI_POPUP_TO_ERROR_MESSAGE'
      EXPORTING
        XDOCNO_SHOW = 'X'
      TABLES
        XMSG        = GT_MSG.
  ENDIF.

ENDFORM.                    " delete_pr
*&---------------------------------------------------------------------*
*&      Form  bapi_pr_delete
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM BAPI_PR_DELETE .

  DATA : LV_BANFN   LIKE EBAN-BANFN.

  REFRESH : GT_EBAN_DEL, GT_RET2.
  CLEAR   : GT_EBAN_DEL, GT_RET2.

  GT_EBAN_DEL-PREQ_ITEM  = GT_EBAN-BNFPO.
  GT_EBAN_DEL-DELETE_IND = 'X'.

  APPEND GT_EBAN_DEL.

*& 구매요청을 삭제한다.
  CALL FUNCTION 'BAPI_REQUISITION_DELETE'
    EXPORTING
      NUMBER                      = GT_EBAN-BANFN
    TABLES
      REQUISITION_ITEMS_TO_DELETE = GT_EBAN_DEL
      RETURN                      = GT_RET1.

  READ TABLE GT_RET1 WITH KEY TYPE = 'E'.
  IF SY-SUBRC <> 0.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.

    CLEAR GT_MSG.

    GT_MSG-MSGID = 'ZPP1'.
    GT_MSG-MSGTY = 'S'.
    GT_MSG-MSGNO = '004'.
    GT_MSG-MSGV1 =  GT_RET1-MESSAGE.
    GT_MSG-REFNO =  GT_EBAN-BANFN.
    GT_MSG-REFIT =  GT_EBAN-BNFPO.

    APPEND GT_MSG.    CLEAR GT_MSG.

  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    CLEAR GT_MSG.
    LOOP AT GT_RET1.

      GT_MSG-MSGID = 'ZPP1'.
      GT_MSG-MSGTY = 'E'.
      GT_MSG-MSGNO = '004'.
      GT_MSG-MSGV1 =  GT_RET1-MESSAGE.
      GT_MSG-REFNO =  GT_EBAN-BANFN.
      GT_MSG-REFIT =  GT_EBAN-BNFPO.

      APPEND GT_MSG.         CLEAR GT_MSG.

    ENDLOOP.

  ENDIF.

ENDFORM.                    " bapi_pr_delete
*&---------------------------------------------------------------------*
*&      Form  pr_end_check
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_EBAN_MATNR  text
*      -->P_GT_EBAN_MENGE_A  text
*      -->P_GT_EBAN_MEINS_A  text
*      -->P_GT_EBAN_BANFN  text
*      -->P_GT_EBAN_BNFPO  text
*----------------------------------------------------------------------*
FORM PR_END_CHECK  USING    P_MATNR
                            P_BANFN
                            P_BNFPO
                            P_FLAG.

  DATA : LV_MENGE   TYPE EBAN-MENGE,
         LV_MEINS   TYPE EBAN-MEINS,
         LV_MENGE_A TYPE EKPO-MENGE,
         LV_MEINS_A TYPE EKPO-MEINS,
         LV_DIVIDE  TYPE EBAN-MENGE,
         LV_EBAKZ   TYPE EBAN-EBAKZ,
         LV_AFNAM   TYPE EBAN-AFNAM.    "구매요청인

  CLEAR : LV_MENGE, LV_MEINS, LV_MENGE_A, LV_MEINS_A, LV_DIVIDE,
  LV_EBAKZ,
          LV_AFNAM.


*& 구매요청 수량과 구매오더 생성 수량을 단위가 틀릴 경우 환산하여
*& 90%이상이 구매오더 전환되었는지 확인후 구매요청 변경 BDC 수행

  IF P_FLAG IS INITIAL.     "구매오더 생성시

    SELECT SINGLE MENGE MEINS EBAKZ AFNAM
      INTO (LV_MENGE, LV_MEINS, LV_EBAKZ, LV_AFNAM)
      "구매요청 수량,단위,마감지시자
      FROM EBAN
     WHERE BANFN = P_BANFN
       AND BNFPO = P_BNFPO.

    SELECT MEINS SUM( MENGE )
      INTO (LV_MEINS_A, LV_MENGE_A)
      FROM EKPO
     WHERE BANFN = P_BANFN
       AND BNFPO = P_BNFPO
       AND LOEKZ = SPACE
     GROUP BY MEINS
     ORDER BY MEINS.
    ENDSELECT.

    IF LV_MEINS <> LV_MEINS_A.
      "구매요청단위와 구매오더 단위가 틀리면

      PERFORM MD_CONVERT_MATERIAL_UNIT USING P_MATNR
                                             LV_MEINS_A
                                             LV_MEINS
                                     CHANGING LV_MENGE_A.
    ENDIF.


    LV_DIVIDE = LV_MENGE_A / LV_MENGE.

    IF LV_DIVIDE > '0.9' AND      "구매오더가 구매요청의 90% 이상이고
       LV_EBAKZ IS INITIAL.       "구매요청에 마감지시자가 없는 경우

*& 구매요청 마감지시자 BDC 수행
      PERFORM ME52_GENERATE_BDC_DATA USING P_BANFN
                                           P_BNFPO
                                           'X'
                                           LV_AFNAM.
      PERFORM ME52_CALL_TRANSACTION.

    ENDIF.

  ELSE.                           "'X' 구매오더 삭제시

*& 구매요청 요청인, 마감지시자 언체크 BDC 수행

    SELECT SINGLE EBAKZ AFNAM
     INTO (LV_EBAKZ, LV_AFNAM) "마감지시자
     FROM EBAN
    WHERE BANFN = P_BANFN
      AND BNFPO = P_BNFPO.

*& 구매요청 마감지시자 BDC 수행
    PERFORM ME52_GENERATE_BDC_DATA USING P_BANFN
                                         P_BNFPO
                                         ' '
                                         LV_AFNAM.
    PERFORM ME52_CALL_TRANSACTION.

  ENDIF.











ENDFORM.                    " pr_end_check
*&---------------------------------------------------------------------*
*&      Form  me52_generate_bdc_data
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ME52_GENERATE_BDC_DATA USING P_BANFN
                                  P_BNFPO
                                  P_FLAG
                                  P_AFNAM.

  REFRESH: GT_BDCDATA, GT_MSGCOLL.
  CLEAR  : GT_BDCDATA, GT_MSGCOLL.

  PERFORM DYNPRO USING:
    'X'  'SAPMM06B'               '0105',
    ' '  'BDC_CURSOR'             'EBAN-BANFN',
    ' '  'BDC_OKCODE'              '/00',
    ' '  'EBAN-BANFN'             P_BANFN.

  PERFORM DYNPRO USING:
    'X'  'SAPMM06B'               '0106',
    ' '  'BDC_CURSOR'             'RM06B-BNFPO',
    ' '  'BDC_OKCODE'              '/00',
    ' '  'RM06B-BNFPO'            P_BNFPO.

  PERFORM DYNPRO USING:
   'X'  'SAPMM06B'               '0106',
   ' '  'BDC_CURSOR'             'EBAN-BNFPO(01)',
   ' '  'BDC_OKCODE'              '=DETA',
   ' '  'RM06B-BNFPO'            P_BNFPO,
   ' '  'RM06B-TCSELFLAG(01)'     'X'.


  IF P_AFNAM IS INITIAL.

    P_AFNAM = 'RFC_APO'.  "구매요청인이 없으면 RFC_APO로 입력

    PERFORM DYNPRO USING:
      'X'  'SAPMM06B'               '0102',
      ' '  'BDC_CURSOR'             'EBAN-AFNAM',
      ' '  'BDC_OKCODE'             '=BU',
      ' '  'EBAN-AFNAM'             P_AFNAM,
      ' '  'EBAN-EBAKZ'             P_FLAG.


  ELSE.
    PERFORM DYNPRO USING:
     'X'  'SAPMM06B'               '0102',
      ' '  'BDC_CURSOR'             'EBAN-EBAKZ',
      ' '  'BDC_OKCODE'             '=BU',
      ' '  'EBAN-EBAKZ'             P_FLAG.

  ENDIF.



ENDFORM.                    " me52_generate_bdc_data
*&---------------------------------------------------------------------*
*&      Form  me52_call_transaction
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM ME52_CALL_TRANSACTION .

  GS_BDCPARAMS-NOBINPT  = ' '.   " BI 세션

  CALL TRANSACTION 'ME52'          "Transaction Call.
              USING GT_BDCDATA
            OPTIONS FROM GS_BDCPARAMS
           MESSAGES INTO GT_MSGCOLL.

  READ TABLE GT_MSGCOLL WITH KEY MSGTYP = 'E'.
  IF SY-SUBRC = 0.
    CLEAR GT_MSG.
    MOVE: GT_MSGCOLL-MSGID    TO GT_MSG-MSGID,
          GT_MSGCOLL-MSGTYP   TO GT_MSG-MSGTY,
          GT_MSGCOLL-MSGNR    TO GT_MSG-MSGNO,
          GT_MSGCOLL-MSGV1    TO GT_MSG-MSGV1,
          GT_MSGCOLL-MSGV2    TO GT_MSG-MSGV2,
          GT_MSGCOLL-MSGV3    TO GT_MSG-MSGV3,
          GT_MSGCOLL-MSGV4    TO GT_MSG-MSGV4,
          GT_EBAN-BANFN       TO GT_MSG-REFNO,
          GT_EBAN-BNFPO       TO GT_MSG-REFIT.

    APPEND GT_MSG.         CLEAR GT_MSG.

  ENDIF.

ENDFORM.                    " me52_call_transaction
*&---------------------------------------------------------------------*
*&      Form  SEARCH_HELP_FOR_ZCERTI
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      <--P_GT_EBAN_ZCERTI  text
*----------------------------------------------------------------------*
FORM SEARCH_HELP_FOR_ZCERTI  CHANGING P_ZCERTI.

  DATA: BEGIN OF LT_ZCERTI OCCURS 0,
          ZCERTI LIKE ZMMT0155-ZCERTI,
          ZTEXT  TYPE CHAR10,
        END   OF LT_ZCERTI.

  DATA : LT_FIELD        LIKE HELP_VALUE OCCURS 0 WITH HEADER LINE,
         LS_SELECTFIELD  LIKE HELP_INFO-FIELDNAME,
         LS_SELECT_VALUE LIKE HELP_INFO-FLDVALUE,
         LV_TABIX        LIKE SY-TABIX.

  CLEAR : LT_ZCERTI, LT_ZCERTI[], LT_FIELD, LT_FIELD[].

  LT_ZCERTI-ZCERTI = 'A'.
  LT_ZCERTI-ZTEXT  = 'LS'.

  APPEND LT_ZCERTI.

  LT_ZCERTI-ZCERTI = 'B'.
  LT_ZCERTI-ZTEXT  = '업체'.

  APPEND LT_ZCERTI.

  LT_FIELD-TABNAME     = 'ZMMT0155'.
  LT_FIELD-FIELDNAME   = 'ZCERTI'.
  LT_FIELD-SELECTFLAG  = 'X'.
  APPEND LT_FIELD. CLEAR LT_FIELD.

*& 아래 부분이 F4를 눌렀을 때, Hit List를 보여준다.
  LT_FIELD-TABNAME     = 'ZMMT0155'.
  LT_FIELD-FIELDNAME   = 'ZTEXT'.
  LT_FIELD-SELECTFLAG  = ' '.
  APPEND LT_FIELD. CLEAR LT_FIELD.

  CALL FUNCTION 'HELP_VALUES_GET_NO_DD_NAME'
    EXPORTING
      TITEL                        = '인증구분 선택'
      SELECTFIELD                  = LS_SELECTFIELD
    IMPORTING
      IND                          = LV_TABIX
      SELECT_VALUE                 = LS_SELECT_VALUE
    TABLES
      FIELDS                       = LT_FIELD
      FULL_TABLE                   = LT_ZCERTI
    EXCEPTIONS
      FULL_TABLE_EMPTY             = 1
      NO_TABLESTRUCTURE_GIVEN      = 2
      NO_TABLEFIELDS_IN_DICTIONARY = 3
      MORE_THEN_ONE_SELECTFIELD    = 4
      NO_SELECTFIELD               = 5
      OTHERS                       = 6.

  CHECK NOT LV_TABIX IS INITIAL.
  READ TABLE LT_ZCERTI INDEX LV_TABIX.
  P_ZCERTI = LT_ZCERTI-ZCERTI.

ENDFORM.                    " SEARCH_HELP_FOR_ZCERTI
*&---------------------------------------------------------------------*
*&      Form  BDC_PURCHASE_ORDER_TEXT_CHANGE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*  -->  p1        text
*  <--  p2        text
*----------------------------------------------------------------------*
FORM BDC_PURCHASE_ORDER_TEXT_CHANGE .
  REFRESH : GT_BAPI_TEXTITEM, GT_BAPI_ITEM, GT_BAPI_ITEMX.
  CLEAR  : GT_BAPI_TEXTITEM, GT_BAPI_ITEM, GT_BAPI_ITEMX.

  GT_BAPI_TEXTITEM-PO_NUMBER = GT_EBAN-EBELN.
  GT_BAPI_TEXTITEM-PO_ITEM   = GT_EBAN-EBELP.
  GT_BAPI_TEXTITEM-TEXT_ID   = 'F04'.
  GT_BAPI_TEXTITEM-TEXT_FORM = '*'.
  GT_BAPI_TEXTITEM-TEXT_LINE = GT_EBAN-ZCERTI.

  APPEND GT_BAPI_TEXTITEM. CLEAR GT_BAPI_TEXTITEM.

*& P/O Item 구성...
  GT_BAPI_ITEM-PO_ITEM            = GT_EBAN-EBELP.
  "구매문서 품목번호
  APPEND GT_BAPI_ITEM.         CLEAR GT_BAPI_ITEM.

*& P/O Item(변경툴바) 구성...
  GT_BAPI_ITEMX-PO_ITEM           = GT_EBAN-EBELP.
  "구매문서 품목번호
  APPEND GT_BAPI_ITEMX.        CLEAR GT_BAPI_ITEMX.

*& 구매오더를 변경한다...
  CALL FUNCTION 'BAPI_PO_CHANGE'
    EXPORTING
      PURCHASEORDER = GT_EBAN-EBELN
      TESTRUN       = GV_TESTRUN
    TABLES
      RETURN        = GT_RET2
      POTEXTITEM    = GT_BAPI_TEXTITEM
      POITEM        = GT_BAPI_ITEM
      POITEMX       = GT_BAPI_ITEMX.

  READ TABLE GT_RET2 WITH KEY TYPE = 'E'.

  IF SY-SUBRC <> 0.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.

    MOVE: GT_RET2-LOG_NO      TO GT_MSG-LOGNO,
          GT_RET2-LOG_MSG_NO  TO GT_MSG-MSGSQ,
          GT_RET2-ID          TO GT_MSG-MSGID,
          GT_RET2-TYPE        TO GT_MSG-MSGTY,
          GT_RET2-NUMBER      TO GT_MSG-MSGNO,
          GT_RET2-MESSAGE_V1  TO GT_MSG-MSGV1,
          GT_RET2-MESSAGE_V2  TO GT_MSG-MSGV2,
          GT_RET2-MESSAGE_V3  TO GT_MSG-MSGV3,
          GT_RET2-MESSAGE_V4  TO GT_MSG-MSGV4,
          GT_RET2-MESSAGE     TO GT_MSG-MSGTX,
          GT_EBAN-EBELN       TO GT_MSG-REFNO,
          GT_EBAN-EBELP       TO GT_MSG-REFIT.

    APPEND GT_MSG.         CLEAR GT_MSG.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    MOVE: GT_RET2-LOG_NO      TO GT_MSG-LOGNO,
          GT_RET2-LOG_MSG_NO  TO GT_MSG-MSGSQ,
          GT_RET2-ID          TO GT_MSG-MSGID,
          GT_RET2-TYPE        TO GT_MSG-MSGTY,
          GT_RET2-NUMBER      TO GT_MSG-MSGNO,
          GT_RET2-MESSAGE_V1  TO GT_MSG-MSGV1,
          GT_RET2-MESSAGE_V2  TO GT_MSG-MSGV2,
          GT_RET2-MESSAGE_V3  TO GT_MSG-MSGV3,
          GT_RET2-MESSAGE_V4  TO GT_MSG-MSGV4,
          GT_RET2-MESSAGE     TO GT_MSG-MSGTX,
          GT_EBAN-EBELN       TO GT_MSG-REFNO,
          GT_EBAN-EBELP       TO GT_MSG-REFIT.

    APPEND GT_MSG.         CLEAR GT_MSG.
  ENDIF.

ENDFORM.                    " BDC_PURCHASE_ORDER_TEXT_CHANGE
*&---------------------------------------------------------------------*
*&      Form  ZMM_EKPO_READ_TEXT
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_EBAN_EBELN  text
*      -->P_GT_EBAN_EBELP  text
*      <--P_GT_EBAN_ZCERTI  text
*----------------------------------------------------------------------*
FORM ZMM_EKPO_READ_TEXT  USING    PV_EBELN
                                  PV_EBELP
                         CHANGING PV_ZCERTI.

  DATA : LT_LINES  LIKE TLINE OCCURS 0 WITH HEADER LINE,
         LV_TDNAME LIKE STXH-TDNAME,
         LV_GUBUN  TYPE C.

  CLEAR : LV_TDNAME, LT_LINES, LT_LINES[], LV_GUBUN.

  CONCATENATE PV_EBELN PV_EBELP INTO LV_TDNAME.


  CALL FUNCTION 'READ_TEXT'
    EXPORTING
      ID        = 'F04'     "품목 텍스트 ID
      LANGUAGE  = SY-LANGU
      NAME      = LV_TDNAME
      OBJECT    = 'EKPO'    "구매오더에 대한 텍스트 오브젝트
    TABLES
      LINES     = LT_LINES
    EXCEPTIONS
      NOT_FOUND = 01.

  READ TABLE LT_LINES INDEX 1.

  LV_GUBUN = LT_LINES-TDLINE.

  IF LV_GUBUN IS INITIAL.   "값이 없으면 업체인증 B
    LV_GUBUN = 'B'.
  ENDIF.

  PV_ZCERTI = LV_GUBUN.

ENDFORM.                    " ZMM_EKPO_READ_TEXT
*&---------------------------------------------------------------------*
*&      Form  SEARCH_HELP_FOR_TAGNR_L
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_MDSB_L_WERKS  text
*      -->P_GT_MDSB_L_MATNR_C  text
*      <--P_GT_MDSB_L_CHARG  text
*      <--P_GT_MDSB_L_LGORT  text
*      <--P_GT_MDSB_L_TAGNR  text
*----------------------------------------------------------------------*
FORM SEARCH_HELP_FOR_TAGNR_L  USING    PV_WERKS
                                       PV_MATNR_C
                              CHANGING PV_CHARG
                                       PV_LGORT
                                       PV_TAGNR
                                       PV_BDMNG.

  DATA: LV_TABIX LIKE SY-TABIX,
        LV_INDEX LIKE SY-INDEX.

  DATA: BEGIN OF LT_CHARG OCCURS 0,
          LGORT LIKE MCHB-LGORT,
          MBEST LIKE RMCP2-MBEST,
          CHARG LIKE MCHB-CHARG,
        END   OF LT_CHARG.

  DATA: BEGIN OF LT_TAGNR OCCURS 0,
          LGORT  LIKE ZPPT0001-LGORT,
          MBEST  LIKE RMCP2-MBEST,
          CHARG  LIKE ZPPT0001-CHARG,
          TAGNR  LIKE ZPPT0001-TAGNR,
          REMAIN LIKE ZPPT0001-REMAIN,
        END   OF LT_TAGNR.

  REFRESH: GT_DYNPUPDATE,  GT_DYNPREAD, GT_FIELD.
  CLEAR  : GT_DYNPUPDATE,  GT_DYNPREAD, GT_FIELD.
  CLEAR  : GS_SELECTFIELD, GS_SELECT_VALUE.

*& 뱃치재고(MCHB) 테이블로 부터 뱃치번호를 가져온다.
  REFRESH : LT_CHARG, LT_TAGNR.
  CLEAR   : LT_CHARG, LT_TAGNR.

  SELECT LGORT CLABS CHARG
    INTO (MCHB-LGORT, MCHB-CLABS, MCHB-CHARG)
           FROM MCHB
          WHERE MATNR = PV_MATNR_C
            AND WERKS = PV_WERKS
            AND CLABS > 0.
    MOVE: MCHB-LGORT    TO LT_CHARG-LGORT,
          MCHB-CLABS    TO LT_CHARG-MBEST,
          MCHB-CHARG    TO LT_CHARG-CHARG.
    APPEND LT_CHARG. CLEAR LT_CHARG.
  ENDSELECT.

  SORT LT_CHARG BY CHARG.

  LOOP AT LT_CHARG.

    SELECT LGORT REMAIN CHARG TAGNR
     APPENDING CORRESPONDING FIELDS OF TABLE LT_TAGNR
            FROM ZPPT0001
           WHERE WERKS = PV_WERKS
             AND MATNR = PV_MATNR_C
             AND CHARG = LT_CHARG-CHARG
             AND REMAIN > 0
             AND GIFLG = 'N'
             AND GRFLG = 'Y'.
  ENDLOOP.

  LOOP AT LT_TAGNR.

    MOVE LT_TAGNR-REMAIN TO LT_TAGNR-MBEST.
    MODIFY LT_TAGNR.

  ENDLOOP.

  SORT LT_TAGNR BY TAGNR.

*& 아래 부분이 F4를 눌렀을 때, Hit List를 보여준다.
  GT_FIELD-TABNAME     = 'ZPPT0001'.
  GT_FIELD-FIELDNAME   = 'LGORT'.
  GT_FIELD-SELECTFLAG  = ' '.
  APPEND GT_FIELD. CLEAR GT_FIELD.

  GT_FIELD-TABNAME     = 'RMCP2'.
  GT_FIELD-FIELDNAME   = 'MBEST'.
  GT_FIELD-SELECTFLAG  = ' '.
  APPEND GT_FIELD. CLEAR GT_FIELD.

  GT_FIELD-TABNAME     = 'ZPPT0001'.
  GT_FIELD-FIELDNAME   = 'CHARG'.
  GT_FIELD-SELECTFLAG  = ' '.
  APPEND GT_FIELD. CLEAR GT_FIELD.

  GT_FIELD-TABNAME     = 'ZPPT0001'.
  GT_FIELD-FIELDNAME   = 'TAGNR'.
  GT_FIELD-SELECTFLAG  = 'X'.
  APPEND GT_FIELD. CLEAR GT_FIELD.

  CALL FUNCTION 'HELP_VALUES_GET_NO_DD_NAME'
    EXPORTING
      TITEL                        = '꼬리표 선택'
      SELECTFIELD                  = GS_SELECTFIELD
    IMPORTING
      IND                          = LV_TABIX
      SELECT_VALUE                 = GS_SELECT_VALUE
    TABLES
      FIELDS                       = GT_FIELD
      FULL_TABLE                   = LT_TAGNR
    EXCEPTIONS
      FULL_TABLE_EMPTY             = 1
      NO_TABLESTRUCTURE_GIVEN      = 2
      NO_TABLEFIELDS_IN_DICTIONARY = 3
      MORE_THEN_ONE_SELECTFIELD    = 4
      NO_SELECTFIELD               = 5
      OTHERS                       = 6.

  CHECK NOT LV_TABIX IS INITIAL.
  READ TABLE LT_TAGNR INDEX LV_TABIX.
  PV_CHARG = LT_TAGNR-CHARG.
  PV_LGORT = LT_TAGNR-LGORT.
  PV_TAGNR = LT_TAGNR-TAGNR.
  PV_BDMNG = LT_TAGNR-MBEST.

ENDFORM.                    " SEARCH_HELP_FOR_TAGNR_L
*&---------------------------------------------------------------------*
*&      Form  CHECK_NEW_EBAN
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_GT_EBAN_NPURC  text
*----------------------------------------------------------------------*
FORM CHECK_NEW_EBAN  USING    P_NPURC.

  DATA : LV_EBELN   TYPE EKKO-EBELN.

  CLEAR : LV_EBELN.

  SELECT SINGLE A~EBELN
    INTO LV_EBELN
    FROM EKPO AS A INNER JOIN EKKO AS B
                           ON A~EBELN = B~EBELN
   WHERE A~MATNR   EQ GT_EBAN-MATNR
     AND A~WERKS   EQ GT_EBAN-WERKS
     AND A~LOEKZ   EQ SPACE
     AND B~LIFNR   EQ GT_EBAN-LIFNR
     AND B~LOEKZ   EQ  SPACE
     AND B~AEDAT   <  GT_EBAN-AEDAT.

  IF LV_EBELN IS INITIAL.
    P_NPURC = 'X'.
  ENDIF.

ENDFORM.                    "CHECK_NEW_EBAN
*&---------------------------------------------------------------------*
*& Form GET_TAG_NUMBER_2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_MOD_CELLS_VALUE
*&      --> GT_MDSB_L_WERKS
*&      --> GT_MDSB_L_MATNR_C
*&      <-- GT_MDSB_L_TAGNR
*&      <-- GT_MDSB_L_BDMNG
*&---------------------------------------------------------------------*
FORM GET_TAG_NUMBER_2   USING    PV_VALUE
                                 PV_WERKS
                                 PV_MATNR_C
                        CHANGING PV_TAGNR
                                 PV_BDMNG
                                 PV_LGORT.
  CLEAR  ZPPT0001.

  SELECT SINGLE LGORT
    INTO PV_LGORT
    FROM MCHB
   WHERE MATNR = PV_MATNR_C
     AND WERKS = PV_WERKS
     AND CHARG = PV_VALUE
     AND CLABS > 0.

  SELECT SINGLE TAGNR REMAIN
    INTO (PV_TAGNR, PV_BDMNG)
    FROM ZPPT0001
   WHERE WERKS = PV_WERKS
     AND MATNR = PV_MATNR_C
     AND CHARG = PV_VALUE.

ENDFORM.
