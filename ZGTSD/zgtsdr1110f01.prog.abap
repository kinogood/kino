*&---------------------------------------------------------------------*
*& Include          ZSDR1006F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form F4_FILENAME
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM F4_FILENAME .


  DATA : LT_RETURN LIKE DDSHRETVAL OCCURS 0 WITH HEADER LINE,
         LT_FIELDS LIKE DYNPREAD OCCURS 0 WITH HEADER LINE.

  RANGES :  LR_VKORG FOR VBAK-VKORG,
            LR_VTWEG FOR VBAK-VTWEG,
            LR_SPART FOR VBAK-SPART,
            LR_VKBUR FOR VBAK-VKBUR,
            LR_VKGRP FOR VBAK-VKGRP,
            LR_BONEM FOR ZKONA-BONEM.
  CLEAR   : LR_VKORG, LR_VTWEG, LR_SPART, LR_VKBUR, LR_VKGRP, LR_BONEM.
  REFRESH : LR_VKORG, LR_VTWEG, LR_SPART, LR_VKBUR, LR_VKGRP, LR_BONEM.


  DATA : BEGIN OF LS_VALUE,
           KNUMA TYPE ZKONA-KNUMA,    "계약
           VKORG TYPE ZKONA-VKORG,    "영업조직
           VTWEG TYPE ZKONA-VTWEG,    "유통경로
           SPART TYPE ZKONA-SPART,    "제품군
           VKBUR TYPE ZKONA-VKBUR,    "영업팀
           VKGRP TYPE ZKONA-VKGRP,    "영업그룹
           BONEM TYPE ZKONA-BONEM,    "에이전트(리베이트 수령인)
         END OF LS_VALUE.
  DATA : LT_VALUE LIKE TABLE OF LS_VALUE.


*- SELECTION SCREEN 값 읽어오기
  LT_FIELDS-FIELDNAME = 'PA_VKORG'. "영업조직
  APPEND LT_FIELDS.
  PERFORM GET_SCREEN_VALUE TABLES : LT_FIELDS USING 'SO_VTWEG-' ,
                                    LT_FIELDS USING 'SO_SPART-' ,
                                    LT_FIELDS USING 'SO_VKBUR-' ,
                                    LT_FIELDS USING 'SO_VKGRP-' ,
                                    LT_FIELDS USING 'SO_BONEM-' .


*  LT_FIELDS-FIELDNAME = 'SO_VKORG-LOW'. "영업조직
*  APPEND LT_FIELDS.
*  LT_FIELDS-FIELDNAME = 'SO_VTWEG-LOW'. "유통경로
*  APPEND LT_FIELDS.
*  LT_FIELDS-FIELDNAME = 'SO_SPART-LOW'. "제품군
*  APPEND LT_FIELDS.
*  LT_FIELDS-FIELDNAME = 'SO_VKBUR-LOW'. "사업장
*  APPEND LT_FIELDS.
*  LT_FIELDS-FIELDNAME = 'SO_VKGRP-LOW'. "영업그룹
*  APPEND LT_FIELDS.
*  LT_FIELDS-FIELDNAME = 'SO_BONEM-LOW'. "AGENT
*  APPEND LT_FIELDS.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      DYNAME               = SY-CPROG
      DYNUMB               = SY-DYNNR
    TABLES
      DYNPFIELDS           = LT_FIELDS
    EXCEPTIONS
      INVALID_ABAPWORKAREA = 1
      INVALID_DYNPROFIELD  = 2
      INVALID_DYNPRONAME   = 3
      INVALID_DYNPRONUMMER = 4
      INVALID_REQUEST      = 5
      NO_FIELDDESCRIPTION  = 6
      INVALID_PARAMETER    = 7
      UNDEFIND_ERROR       = 8
      DOUBLE_CONVERSION    = 9
      STEPL_NOT_FOUND      = 10
      OTHERS               = 11.

*  READ TABLE LT_FIELDS WITH KEY FIELDNAME = 'PA_VKORG'.



  SELECT KNUMA
         VKORG
         VTWEG
         SPART
         VKBUR
         VKGRP
         BONEM
    INTO CORRESPONDING FIELDS OF TABLE LT_VALUE
    FROM ZKONA
   WHERE VKORG EQ PA_VKORG
     AND VTWEG IN SO_VTWEG
     AND SPART IN SO_SPART
     AND VKBUR IN SO_VKBUR
     AND VKGRP IN SO_VKGRP
     AND BONEM IN SO_BONEM.

*- Search Help 출력
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'KNUMA'
      DYNPPROG        = SY-CPROG
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = 'SO_KNUMA-LOW'
      VALUE_ORG       = 'S'  "'C'
    TABLES
      VALUE_TAB       = LT_VALUE
      RETURN_TAB      = LT_RETURN
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_SCREEN_VALUE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_SCREEN_VALUE  TABLES PT_FIELDS STRUCTURE DYNPREAD
                        USING PV_FIELD.


  DATA : LV_OPTION(6) VALUE 'OPTION',
         LV_LOW(3)    VALUE 'LOW',
         LV_SIGN(4)   VALUE 'SIGN',
         LV_HIGH(4)   VALUE 'HIGH',
         LV_FIELD(20).


*   CONCATENATE PV_FIELD LV_OPTION INTO LV_FIELD.
*   PT_FIELDS-FIELDNAME = LV_FIELD.
*   APPEND PT_FIELDS.
*   CLEAR PT_FIELDS.

  CONCATENATE PV_FIELD LV_LOW INTO LV_FIELD.
  PT_FIELDS-FIELDNAME = LV_FIELD.
  APPEND PT_FIELDS.
  CLEAR PT_FIELDS.

*   CONCATENATE PV_FIELD LV_SIGN INTO LV_FIELD.
*   PT_FIELDS-FIELDNAME = LV_FIELD.
*   APPEND PT_FIELDS.
*   CLEAR PT_FIELDS.
*
  CONCATENATE PV_FIELD LV_HIGH INTO LV_FIELD.
  PT_FIELDS-FIELDNAME = LV_FIELD.
  APPEND PT_FIELDS.
  CLEAR PT_FIELDS.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form AUTHORITY_CHECK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM AUTHORITY_CHECK .

  DATA: LV_SUBRC  LIKE SY-SUBRC.

  DATA : BEGIN OF LT_VTWEG OCCURS 0,
           VTWEG LIKE TVTW-VTWEG,
         END   OF LT_VTWEG.

  DATA : BEGIN OF LT_SPART OCCURS 0,
           SPART LIKE TSPA-SPART,
         END   OF LT_SPART.

  CLEAR : LV_SUBRC.

*___영업조직 권한
  CALL FUNCTION 'ZGTSD_AUTHORIZATION_CHECK'
    EXPORTING
      I_VKORG = PA_VKORG
      I_TYPE  = '1'
    IMPORTING
      E_SUBRC = LV_SUBRC.

  IF LV_SUBRC <> 0.
    MESSAGE E200 WITH PA_VKORG.

  ENDIF.

  CLEAR : LV_SUBRC.

*___유통경로 권한
  SELECT VTWEG
    INTO TABLE LT_VTWEG
    FROM TVTW
   WHERE VTWEG IN SO_VTWEG.

  LOOP AT LT_VTWEG.
    CALL FUNCTION 'ZGTSD_AUTHORIZATION_CHECK'
      EXPORTING
        I_VTWEG = LT_VTWEG-VTWEG
        I_TYPE  = '2'
      IMPORTING
        E_SUBRC = LV_SUBRC.

    IF LV_SUBRC <> 0.
      MESSAGE E201 WITH LT_VTWEG-VTWEG.

    ENDIF.
  ENDLOOP.


  CLEAR : LV_SUBRC.

*___제품군 권한
  SELECT SPART
    INTO TABLE LT_SPART
    FROM TSPA
   WHERE SPART IN SO_SPART.

  LOOP AT LT_SPART.
    CALL FUNCTION 'ZGTSD_AUTHORIZATION_CHECK'
      EXPORTING
        I_VTWEG = LT_SPART-SPART
        I_TYPE  = '3'
      IMPORTING
        E_SUBRC = LV_SUBRC.

    IF LV_SUBRC <> 0.
      MESSAGE E202 WITH LT_VTWEG-VTWEG.

    ENDIF.
  ENDLOOP.

*-영업그룹
  SELECT VKGRP
    FROM TVBVK
   WHERE VKGRP IN @SO_VKGRP
    INTO TABLE @DATA(LT_VKGRP).

  LOOP AT LT_VKGRP INTO DATA(LS_VKGRP).
    CALL FUNCTION 'ZGTSD_AUTHORIZATION_CHECK'
      EXPORTING
        I_VKGRP = LS_VKGRP-VKGRP
        I_TYPE  = '7'
      IMPORTING
        E_SUBRC = LV_SUBRC.

    IF LV_SUBRC <> 0.
      MESSAGE E203 WITH LS_VKGRP-VKGRP.

    ENDIF.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM GET_DATA .

  DATA : LV_YEAR TYPE GJAHR,
         LT_ITAB LIKE TABLE OF GS_ITAB,
         LV_CHK.
  DATA : LT_KONV TYPE TABLE OF KONV WITH HEADER LINE.
  DATA : LV_KOSRT TYPE KONH-KOSRT.


  DATA : BEGIN OF LS_ITAB,
*    VBELN    TYPE VBRK-VBELN  ,     " 빌링헤더
*    POSNR    TYPE VBRP-POSNR  ,     " 빌링아이템
           BELNR_2 TYPE BKPF-BELNR,
           WRBTR_2 TYPE ZSD0017T-WRBTR,   " 지급전표금액
           WAERK_2 TYPE ZSD0017T-WAERK,   " 지급전표통화
           DMBTR_2 TYPE BSEG-DMBTR  ,     " 지급전표 총액(원)
           BLDAT_2 TYPE BKPF-BLDAT  ,     " 지급전표 증빙일
           BUDAT_2 TYPE BKPF-BUDAT  ,     " 지급전표 전기일
           KURSF_2 TYPE BKPF-KURSF  ,     " 지급전표 환율
           FBUDA2  TYPE ZSD0017T-FBUDA2.  " 년월
  DATA : END OF LS_ITAB.
  DATA : LT_ITAB2 LIKE TABLE OF LS_ITAB.
*  SELECT *
*    FROM ZSD0018T AS A
*   INNER JOIN VBRK AS B
*      ON A~VBELN EQ B~VBELN
*   INNER JOIN VBRP AS C
*      ON A~VBELN EQ C~VBELN
*     AND A~POSNR EQ C~POSNR
*   INNER JOIN ZKONA AS D
*      ON A~KNUMA EQ D~KNUMA
*    INTO CORRESPONDING FIELDS OF TABLE @GT_ITAB
*   WHERE D~VKORG EQ @PA_VKORG
*     AND D~VTWEG IN @SO_VTWEG
*     AND D~SPART IN @SO_SPART
*     AND D~VKBUR IN @SO_VKBUR
*     AND D~VKGRP IN @SO_VKGRP
*     AND D~BONEM IN @SO_BONEM
*     AND D~KNUMA IN @SO_KNUMA
*     AND B~FKDAT IN @SO_FKDAT.

  SELECT B~VBELN           " 빌링
         C~POSNR           " 빌링품목
         G~KOSRT AS KNUMA  " 계약번호
         F~KSCHL           " 조건유형
         F~KNUMV           " 조건번호
         C~AUBEL           " 판매오더
         C~AUPOS           " 판매품목
         D~VKORG           " 영업조직
         D~VTWEG           " 유통경로
         D~SPART           " 제품군
         D~VKBUR           " 영업팀
         D~VKGRP           " 영업그룹
         B~KUNAG           " 고객
         H~NAME1           " 고객 이름
         A~LIFNR AS BONEM  " 에이전트
         I~NAME1 AS L_NAME1" 에이전트 이름
         B~FKDAT           " 매출일자
         C~NETWR           " 매출액
         B~WAERK           " 통화
         F~KBETR           " 조건값(커미션금액)
         F~KWERT           " 조건값(커미션금액)
         F~WAERS           " 통화
    FROM VBPA AS A INNER JOIN VBRK AS B
                   ON A~VBELN = B~VBELN
                   INNER JOIN VBRP AS C
                   ON A~VBELN = C~VBELN
                   INNER JOIN VBAK AS D
                   ON C~AUBEL = D~VBELN
                   INNER JOIN VBAP AS E
                   ON C~AUBEL = E~VBELN
                  AND C~AUPOS = E~POSNR
                   INNER JOIN V_KONV_CDS AS F
                   ON B~KNUMV = F~KNUMV
                  AND C~POSNR = F~KPOSN
*->[CHG]----------------------------------------S
                   INNER JOIN KONH AS G
                   ON F~KNUMH = G~KNUMH
                   INNER JOIN ZKONA AS Z
                   ON G~KOSRT = Z~KNUMA AND
                      A~LIFNR = Z~BONEM
*-<[CHG]----------------------------------------E
                   LEFT OUTER JOIN KNA1 AS H
                   ON H~KUNNR = B~KUNAG
                   LEFT OUTER JOIN LFA1 AS I
                   ON I~LIFNR = A~LIFNR
    INTO CORRESPONDING FIELDS OF TABLE LT_ITAB
*->[CHG]----------------------------------------S
   WHERE A~PARVW IN ('ZG','ZH')
     AND F~KSCHL BETWEEN 'ZBO1' AND 'ZBO8' " 조건유형
*-<[CHG]----------------------------------------E
     AND B~FKART  = 'F2'                   " 청구(송장)
     AND B~FKSTO <> 'X'                    " 취소문서
     AND A~LIFNR IN SO_BONEM               " AGENT
*     AND G~KNUMA IN SO_KNUMA               " 계약번호
     AND B~FKDAT IN SO_FKDAT               " 매출일자
     AND F~KWERT <> 0                      " 커미션금액
     AND B~VKORG = PA_VKORG                " 영업 조직
     AND B~VTWEG IN SO_VTWEG               " 유통 경로
     AND B~SPART IN SO_SPART               " 제품군
     AND C~VKBUR IN SO_VKBUR               " 영업팀
     AND C~VKGRP IN SO_VKGRP               " 영업 그룹
     AND B~VBELN IN SO_VBELN               " 대금청구문서
     AND D~VBELN IN SO_AUBEL               " 판매오더
*->[CHG]----------------------------------------S
     AND G~KOSRT IN SO_KNUMA              "계약번호
*-<[CHG]----------------------------------------E
     ORDER BY B~VBELN C~POSNR.


* 커미션 계약 : 조회조건의 커미션 계약
  LOOP AT LT_ITAB  INTO DATA(LS_DATA) .
    DATA(LV_INDEX) = SY-TABIX.
    CLEAR : LT_KONV, LT_KONV[].
    CLEAR : LV_KOSRT.

*___ 조건에서 리베이트 찾기
    SELECT *
      INTO CORRESPONDING FIELDS OF TABLE LT_KONV
      FROM V_KONV_CDS
     WHERE KNUMV EQ LS_DATA-KNUMV
       AND KPOSN EQ LS_DATA-POSNR
*->[CHG]----------------------------------------S
       AND KSCHL EQ LS_DATA-KSCHL
*       AND ( KSCHL EQ 'ZBO1' OR
*             KSCHL EQ 'ZBO2' OR
*             KSCHL EQ 'ZBO3' OR
*             KSCHL EQ 'ZBO4' OR
*             KSCHL EQ 'ZBO5' OR
*             KSCHL EQ 'ZBO6' OR
*             KSCHL EQ 'ZBO7' )
*-<[CHG]----------------------------------------E
       AND KWERT <> 0
       AND KVSL1 = 'ERB'.

    IF SY-SUBRC <> 0 .
      DELETE LT_ITAB .
      CONTINUE.
    ENDIF.

*___ 계약번호 가져오기
    READ TABLE LT_KONV INDEX 1.
    SELECT SINGLE KOSRT
      INTO LV_KOSRT
      FROM KONH
     WHERE KNUMH = LT_KONV-KNUMH.

    IF LV_KOSRT IS INITIAL.
      DELETE LT_ITAB .
      CONTINUE.
    ELSE.
      LS_DATA-KNUMA = LV_KOSRT.
    ENDIF.

*__ 조회조건과 계약번호 일치 여부
    IF LS_DATA-KNUMA NOT IN SO_KNUMA AND SO_KNUMA[] IS NOT INITIAL.
      DELETE LT_ITAB .
      CONTINUE.
    ENDIF.

*___계약 내용 가져오기
    SELECT SINGLE
                  BOTEXT
                  DATAB
                  DATBI
      INTO CORRESPONDING FIELDS OF LS_DATA
      FROM ZKONA
     WHERE KNUMA EQ LS_DATA-KNUMA.

    MODIFY LT_ITAB FROM LS_DATA INDEX LV_INDEX.

    CLEAR LV_INDEX.
  ENDLOOP.



  LOOP AT LT_ITAB INTO GS_ITAB.
*__ 조건유형_요율인 경우 통화가 빈 값 -> 매출통화
    IF GS_ITAB-WAERS IS INITIAL.
      GS_ITAB-WAERS = GS_ITAB-WAERK.
      GS_ITAB-KBETR = GS_ITAB-KWERT.
    ENDIF.
    GS_ITAB-KRW = 'KRW'.


*__ 정산오더 (ZSD0018T)
    SELECT SINGLE VBELN_SE KWERT_K KWAEH
      FROM ZSD0018T
      INTO (GS_ITAB-VBELN_SE, GS_ITAB-KWERT_K, GS_ITAB-KWAEH)
*->[CHG]----------------------------------------S
     WHERE KNUMA EQ GS_ITAB-KNUMA
       AND VBELN EQ GS_ITAB-VBELN
       AND POSNR EQ GS_ITAB-POSNR.
*     WHERE VBELN EQ GS_ITAB-VBELN
*       AND POSNR EQ GS_ITAB-POSNR.
*-<[CHG]----------------------------------------E

*__ 미지급 전표 (ZSD0016T)
    CLEAR : LV_YEAR.
    LV_YEAR = GS_ITAB-FKDAT.

    SELECT SINGLE A~BELNR A~WRBTR A~WAERK
                  B~KURSF B~BLDAT B~BUDAT
                  C~DMBTR
      FROM ZSD0016T AS A INNER JOIN BKPF AS B
                         ON A~BELNR  EQ B~BELNR
                         INNER JOIN BSEG AS C
                         ON A~BELNR  EQ C~BELNR
      INTO (GS_ITAB-BELNR_1, GS_ITAB-WRBTR_1,
            GS_ITAB-WAERK_1, GS_ITAB-KURSF_1,
            GS_ITAB-BLDAT_1, GS_ITAB-BUDAT_1,
            GS_ITAB-DMBTR_1)
     WHERE A~KNUMA  EQ GS_ITAB-KNUMA
       AND A~VBELN  EQ GS_ITAB-VBELN_SE    "정산오더
       AND A~VBELN2 EQ GS_ITAB-VBELN       "빌링
       AND B~GJAHR  EQ LV_YEAR
       AND C~GJAHR  EQ LV_YEAR.            "년도

*__ 지급 전표 (ZSD0017T)
    CLEAR : LT_ITAB2, LT_ITAB2[].

    SELECT BELNR2 AS BELNR_2  WRBTR AS WRBTR_2
           WAERK  AS WAERK_2  FBUDA2
      FROM ZSD0017T
      INTO CORRESPONDING FIELDS OF TABLE LT_ITAB2
     WHERE KNUMA  EQ GS_ITAB-KNUMA    "커미션번호
       AND VBELN  EQ GS_ITAB-VBELN_SE "정산오더와
       AND VBELN2 EQ GS_ITAB-VBELN.   "빌링

    PERFORM CONVERSION_EXIT_ALPHA USING: 'O' GS_ITAB-KUNAG,
                                         'O' GS_ITAB-BONEM,
                                         'O' GS_ITAB-KNUMA.

    SELECT SINGLE BEZEI
      FROM TVKBT
      INTO GS_ITAB-BEZEI_1
     WHERE VKBUR = GS_ITAB-VKBUR
       AND SPRAS = SY-LANGU.

    SELECT SINGLE BEZEI
      FROM TVGRT
      INTO GS_ITAB-BEZEI_2
     WHERE VKGRP = GS_ITAB-VKGRP
       AND SPRAS = SY-LANGU.

    IF LT_ITAB2[] IS NOT INITIAL.

      LOOP AT LT_ITAB2 INTO LS_ITAB.
        SELECT SINGLE A~KURSF AS KURSF_2
                      A~BLDAT AS BLDAT_2
                      A~BUDAT AS BUDAT_2
                      B~DMBTR AS DMBTR_2
          FROM BKPF AS A INNER JOIN BSEG AS B
                         ON A~BELNR EQ B~BELNR
          INTO (LS_ITAB-KURSF_2, LS_ITAB-BLDAT_2,
                LS_ITAB-BUDAT_2, LS_ITAB-DMBTR_2)
         WHERE A~BELNR EQ LS_ITAB-BELNR_2
           AND A~GJAHR EQ LS_ITAB-FBUDA2(4)
           AND B~GJAHR EQ LS_ITAB-FBUDA2(4)
           AND A~STBLG EQ SPACE. "역분개전표 없는 경우(수기로 삭제한 경우 제외)

        IF SY-SUBRC EQ 0.
          MOVE-CORRESPONDING LS_ITAB TO GS_ITAB.
          APPEND GS_ITAB TO GT_ITAB.
          LV_CHK = 'X'.
        ENDIF.

      ENDLOOP.
    ENDIF.


    IF LV_CHK EQ 'X'.
      CLEAR : LV_CHK.
    ELSE.
      APPEND GS_ITAB TO GT_ITAB.
    ENDIF.

  ENDLOOP.

*->[CHG]----------------------------------------S
*  CLEAR : LT_ITAB, LT_ITAB[], GS_ITAB.
**__ Mig Data 추가 / Mig데이터는 품목의 커미션 금액은 알 수 없음
*  SELECT B~VBELN             " 빌링
*         C~POSNR             " 빌링품목
*         A~KNUMA             " 계약번호
**         F~KSCHL            " 조건유형
**         F~KNUMV            " 조건번호
*         C~AUBEL             " 판매오더
*         C~AUPOS             " 판매품목
*         D~VKORG             " 영업조직
*         D~VTWEG             " 유통경로
*         D~SPART             " 제품군
*         D~VKBUR             " 영업팀
*         D~VKGRP             " 영업그룹
*         B~KUNAG             " 고객
*         H~NAME1             " 고객 이름
*         F~LIFNR   AS BONEM  " 에이전트
*         I~NAME1   AS L_NAME1" 에이전트 이름
*         B~FKDAT             " 매출일자
*         C~NETWR             " 매출액
*         B~WAERK             " 통화
*         A~KWERT_K           " 조건값(커미션금액)
*         A~KWAEH             " 통화
*    FROM ZSD0018T AS A INNER JOIN ZVBRK_R3 AS B
*                       ON A~VBELN = B~VBELN
*                       INNER JOIN ZVBRP_R3 AS C
*                       ON B~VBELN = C~VBELN
*                      AND A~POSNR = C~POSNR
*                       INNER JOIN ZVBAK_R3 AS D
*                       ON C~AUBEL = D~VBELN
*                       INNER JOIN ZVBAP_R3 AS E
*                       ON C~AUBEL = E~VBELN
*                      AND C~AUPOS = E~POSNR
*                       INNER JOIN ZVBPA_R3 AS F
*                       ON D~VBELN = F~VBELN
*                       LEFT OUTER JOIN KNA1 AS H
*                       ON H~KUNNR = B~KUNAG
*                       LEFT OUTER JOIN LFA1 AS I
*                       ON I~LIFNR = F~LIFNR
*    INTO CORRESPONDING FIELDS OF TABLE LT_ITAB
*   WHERE F~PARVW  = 'ZG'
**     AND F~KSCHL BETWEEN 'ZBO1' AND 'ZBO7' " 조건유형
*     AND B~FKART  = 'F2'                   " 청구(송장)
*     AND B~FKSTO <> 'X'                    " 취소문서
*     AND F~LIFNR IN SO_BONEM               " AGENT
*     AND A~KNUMA IN SO_KNUMA               " 계약번호
*     AND B~FKDAT IN SO_FKDAT               " 매출일자
*     AND A~KWERT_K <> 0                    " 커미션금액
*     AND D~VKORG = PA_VKORG                " 영업 조직
*     AND D~VTWEG IN SO_VTWEG               " 유통 경로
*     AND D~SPART IN SO_SPART               " 제품군
*     AND D~VKBUR IN SO_VKBUR               " 영업팀
*     AND D~VKGRP IN SO_VKGRP               " 영업 그룹
*     AND B~VBELN IN SO_VBELN               " 대금청구문서
*     AND D~VBELN IN SO_AUBEL               " 판매오더
*     ORDER BY B~VBELN C~POSNR.
*
*
*  LOOP AT LT_ITAB INTO GS_ITAB.
**__ Mig 데이터는 이미 매출 및 정산오더까지 생성, 한번에 Select해옴
*    GS_ITAB-KRW = 'KRW'.
*
**__ 매출문서는 Mig대상이 아니므로 정산오더 품목 값을 그대로 반영
*    GS_ITAB-KBETR = GS_ITAB-KWERT_K.
*    GS_ITAB-WAERS = GS_ITAB-KBETR.
*
**__ 미지급 전표 (ZSD0016T)
*    CLEAR : LV_YEAR.
*    LV_YEAR = '2023'. "MIG 미지급전표 2023년으로 기표
*
*    SELECT SINGLE A~BELNR A~WRBTR A~WAERK
*                  B~KURSF B~BLDAT B~BUDAT C~DMBTR
*      FROM ZSD0016T AS A INNER JOIN BKPF AS B
*                         ON A~BELNR  EQ B~BELNR
*                         INNER JOIN BSEG AS C
*                         ON A~BELNR  EQ C~BELNR
*      INTO (GS_ITAB-BELNR_1, GS_ITAB-WRBTR_1,
*            GS_ITAB-WAERK_1, GS_ITAB-KURSF_1,
*            GS_ITAB-BLDAT_1, GS_ITAB-BUDAT_1,
*            GS_ITAB-DMBTR_1)
*     WHERE A~KNUMA  EQ GS_ITAB-KNUMA
*       AND A~VBELN  EQ GS_ITAB-VBELN_SE    "정산오더
*       AND A~VBELN2 EQ GS_ITAB-VBELN       "빌링
*       AND B~GJAHR  EQ LV_YEAR
*       AND C~GJAHR  EQ LV_YEAR.            "년도
*
**__ 지급 전표 (ZSD0017T)
*    CLEAR : LT_ITAB2, LT_ITAB2[].
*
*    SELECT BELNR2 AS BELNR_2
*           WRBTR  AS WRBTR_2
*           WAERK  AS WAERK_2
*           FBUDA2
*      FROM ZSD0017T
*      INTO CORRESPONDING FIELDS OF TABLE LT_ITAB2
*     WHERE KNUMA  EQ GS_ITAB-KNUMA
*       AND VBELN  EQ GS_ITAB-VBELN_SE "정산오더와 커미션 번호 조건으로만
*       AND VBELN2 EQ GS_ITAB-VBELN.
*
*    PERFORM CONVERSION_EXIT_ALPHA USING: 'O' GS_ITAB-KUNAG,
*                                         'O' GS_ITAB-BONEM,
*                                         'O' GS_ITAB-KNUMA.
*
*    SELECT SINGLE BEZEI
*      FROM TVKBT
*      INTO GS_ITAB-BEZEI_1
*     WHERE VKBUR = GS_ITAB-VKBUR
*       AND SPRAS = SY-LANGU.
*
*    SELECT SINGLE BEZEI
*      FROM TVGRT
*      INTO GS_ITAB-BEZEI_2
*     WHERE VKGRP = GS_ITAB-VKGRP
*       AND SPRAS = SY-LANGU.
*
*    IF LT_ITAB2[] IS NOT INITIAL.
*
*      CLEAR : LV_YEAR.
*      IF LS_ITAB-BELNR_2(1) = '9'. "Mig 지급전표
*        LV_YEAR = '2023'.
*      ELSE.
*        LV_YEAR = LS_ITAB-FBUDA2(4). "S/4HANA에서 생성한 지급전표
*      ENDIF.
*
*      LOOP AT LT_ITAB2 INTO LS_ITAB.
*        SELECT SINGLE A~KURSF AS KURSF_2 A~BLDAT AS BLDAT_2
*                      A~BUDAT AS BUDAT_2 B~DMBTR AS DMBTR_2
*          FROM BKPF AS A INNER JOIN BSEG AS B
*                         ON A~BELNR EQ B~BELNR
*          INTO (LS_ITAB-KURSF_2, LS_ITAB-BLDAT_2,
*                LS_ITAB-BUDAT_2, LS_ITAB-DMBTR_2)
*         WHERE A~BELNR EQ LS_ITAB-BELNR_2
*           AND A~GJAHR EQ LV_YEAR
*           AND B~GJAHR EQ LV_YEAR
*           AND A~STBLG EQ SPACE. "역분개전표 없는 경우(수기로 삭제한 경우 제외)
*
*
*        IF SY-SUBRC EQ 0.
*          MOVE-CORRESPONDING LS_ITAB TO GS_ITAB.
*          APPEND GS_ITAB TO GT_ITAB.
*          LV_CHK = 'X'.
*        ENDIF.
*
*      ENDLOOP.
*    ENDIF.
*
*
*    IF LV_CHK EQ 'X'.
*      CLEAR : LV_CHK.
*    ELSE.
*      APPEND GS_ITAB TO GT_ITAB.
*    ENDIF.
*
*  ENDLOOP.
*-<[CHG]----------------------------------------E

  SORT GT_ITAB BY KNUMA VBELN POSNR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CREATE_CONTROLS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CREATE_CONTROLS .

*- DOCKING CONTAINER
  CREATE OBJECT G_DOCKING_CONTAINER
    EXPORTING
      REPID     = SY-REPID
      DYNNR     = SY-DYNNR
      EXTENSION = 500
      SIDE      = CL_GUI_DOCKING_CONTAINER=>DOCK_AT_TOP.

  CREATE OBJECT GRID
    EXPORTING
      I_PARENT = G_DOCKING_CONTAINER.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_EVENT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SET_EVENT .

  CALL METHOD GRID->REGISTER_EDIT_EVENT
    EXPORTING
      I_EVENT_ID = CL_GUI_ALV_GRID=>MC_EVT_MODIFIED.

  CREATE OBJECT EVENT_RECEIVER.
  SET HANDLER EVENT_RECEIVER->HANDLE_TOP_OF_PAGE   FOR GRID.
  SET HANDLER EVENT_RECEIVER->HANDLE_DOUBLE_CLICK  FOR GRID.
  SET HANDLER EVENT_RECEIVER->HANDLE_HOTSPOT_CLICK FOR GRID.
  SET HANDLER EVENT_RECEIVER->HANDLE_TOOLBAR       FOR GRID.
  SET HANDLER EVENT_RECEIVER->HANDLE_USER_COMMAND  FOR GRID.
  SET HANDLER EVENT_RECEIVER->HANDLE_DATA_CHANGED  FOR GRID.
  SET HANDLER EVENT_RECEIVER->HANDLE_ONF4          FOR GRID.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form ALV_LAYOUT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM ALV_LAYOUT .

  GS_LAYOUT-SEL_MODE   = 'A'.
  GS_LAYOUT-ZEBRA      = 'X'.
  GS_LAYOUT-CWIDTH_OPT = 'X'.
*  GS_LAYOUT-STYLEFNAME = 'CELLTAB'.
  "26.09 불필요 주석처리
*  GS_LAYOUT-CTAB_FNAME = 'COLTAB'.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXCLUDE_TB_FUNCTIONS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM EXCLUDE_TB_FUNCTIONS  CHANGING PT_EXCLUDE TYPE UI_FUNCTIONS.

  DATA LS_EXCLUDE TYPE UI_FUNC.

  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_UNDO.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_COPY_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_DELETE_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_INSERT_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_COPY.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_CUT.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_PASTE_NEW_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_LOC_APPEND_ROW.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_GRAPH.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_INFO.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_DETAIL.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.
  LS_EXCLUDE = CL_GUI_ALV_GRID=>MC_FC_REFRESH.
  APPEND LS_EXCLUDE TO PT_EXCLUDE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_VARIANT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SET_VARIANT .

  GS_VARIANT-REPORT   = SY-CPROG.
  GS_VARIANT-USERNAME = SY-UNAME.
  GS_VARIANT-HANDLE   = SY-DYNNR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FIELDCAT_INIT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM FIELDCAT_INIT .


  PERFORM SET_FIELD_CATALOG
    USING : 'X' 'KNUMA'     '커미션번호'        ' '  'X' ' ',
            'X' 'VBELN'     '빌링문서'          ' '  'X' ' ',
            'X' 'POSNR'     '빌링품목'          ' '  ' ' ' ',
            ' ' 'AUBEL'     'S/O'               ' '  'X' ' ',
            ' ' 'AUPOS'     'S/O품목'           ' '  ' ' ' ',
            ' ' 'VKBUR'     '영업팀'            ' '  ' ' ' ',
            ' ' 'BEZEI_1'   '영업팀명'          ' '  ' ' ' ',
            ' ' 'VKGRP'     '영업그룹'          ' '  ' ' ' ',
            ' ' 'BEZEI_2'   '영업그룹명'        ' '  ' ' ' ',
            ' ' 'KUNAG'     '고객'              ' '  'X' ' ',
            ' ' 'NAME1'     '고객명'            ' '  ' ' ' ',

            ' ' 'BONEM'     '에이전트'          ' '  'X' ' ',
            ' ' 'L_NAME1'   '에이전트명'        ' '  ' ' ' ',
            ' ' 'NETWR'     '매출금액'          ' '  ' ' ' ',
            ' ' 'WAERK'     '매출통화'          ' '  ' ' ' ',
*            ' ' 'KSCHL'     '조건유형'     '5'  ' ',
*            ' ' 'KWERT'     '빌링커미션금액'   ' '  ' ' ' ',
            ' ' 'KBETR'     '빌링커미션금액'    ' '  ' ' ' ',
            ' ' 'WAERS'     '빌링커미션통화'    ' '  ' ' ' ',
            ' ' 'FKDAT'     '매출일자'          ' '  ' ' ' ',
            ' ' 'VBELN_SE'  '정산오더'          ' '  'X' ' ',
            ' ' 'KWERT_K'   '정산커미션금액'    ' '  ' ' ' ',
            ' ' 'KWAEH'     '정산커미션통화'    ' '  ' ' ' ',
*            ' ' 'KNUMV'     '
            ' ' 'BELNR_1'   '미지급전표'        ' '  'X' 'C300',
            ' ' 'WRBTR_1'   '금액(미지급)'      ' '  ' ' 'C300',
            ' ' 'WAERK_1'   '통화(미지급)'      ' '  ' ' 'C300',
            ' ' 'DMBTR_1'   '총액(미지급[원])'  ' '  ' ' 'C300',
            ' ' 'BLDAT_1'   '증빙일(미지급)'    ' '  ' ' 'C300',
            ' ' 'BUDAT_1'   '전기일(미지급)'    ' '  ' ' 'C300',
            ' ' 'KURSF_1'   '환율(미지급)'      ' '  ' ' 'C300',

            ' ' 'BELNR_2'   '지급전표'          ' '  'X' 'C600',
            ' ' 'WRBTR_2'   '금액(지급)'        ' '  ' ' 'C600',
            ' ' 'WAERK_2'   '통화(지급)'        ' '  ' ' 'C600',
            ' ' 'DMBTR_2'   '금액(지급[원])'    ' '  ' ' 'C600',
            ' ' 'BLDAT_2'   '증빙일(지급)'      ' '  ' ' 'C600',
            ' ' 'BUDAT_2'   '전기일(지급)'      ' '  ' ' 'C600',
            ' ' 'KURSF_2'   '환율(지급)'        ' '  ' ' 'C600'.
*            ' ' 'KRW'        '원'               ' ' ' '.



*            ' ' ' ' '정가' ' ',
*            ' ' ' ' '통화' ' ',
*            ' ' ' ' '최초출하일' ' '.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELD_CATALOG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM SET_FIELD_CATALOG  USING   PV_KEY
                                PV_FIELDNAME
                                PV_TEXT
                                PV_OUTPUTLEN
                                PV_HOTSPOT"PV_JUST
                                PV_EMPHASIZE.

  GS_FIELDCAT-KEY       = PV_KEY.
  GS_FIELDCAT-FIELDNAME = PV_FIELDNAME.
  GS_FIELDCAT-COLTEXT   = PV_TEXT.
  GS_FIELDCAT-SCRTEXT_L   = PV_TEXT.  "26.09 카탈로그 정리
  GS_FIELDCAT-OUTPUTLEN = PV_OUTPUTLEN.
*  GS_FIELDCAT-JUST      = PV_JUST.
  GS_FIELDCAT-HOTSPOT   = PV_HOTSPOT.
  GS_FIELDCAT-EMPHASIZE = PV_EMPHASIZE.

*--------------------------------------------------------------------*
**--> 26.09 통화키 재정리
*--------------------------------------------------------------------*
  CASE PV_FIELDNAME.
    WHEN 'NETWR'.
      GS_FIELDCAT-CFIELDNAME = 'WAERK'.
    WHEN 'KBETR'.
      GS_FIELDCAT-CFIELDNAME = 'WAERS'.
    WHEN 'KWERT_K'.
      GS_FIELDCAT-CFIELDNAME = 'KWAEH'.
    WHEN 'WRBTR_1'.
      GS_FIELDCAT-CFIELDNAME = 'WAERK_1'.
    WHEN 'DMBTR_1' OR 'DMBTR_2'.
      GS_FIELDCAT-CURRENCY = 'KRW'.
    WHEN 'WRBTR_2'.
      GS_FIELDCAT-CFIELDNAME = 'WAERK_2'.

  ENDCASE.
*  CASE PV_FIELDNAME.
*    WHEN 'KWERT' OR 'KBETR'.
*      GS_FIELDCAT-CFIELDNAME = 'WAERS'.
*    WHEN 'NETWR'.
*      GS_FIELDCAT-CFIELDNAME = 'WAERK'.
*    WHEN 'WRBTR_1'.
*      GS_FIELDCAT-CFIELDNAME = 'WAERK_1'.
*    WHEN 'DMBTR_1' OR 'DMBTR_2'.
*      GS_FIELDCAT-CFIELDNAME = 'KRW'.
*    WHEN OTHERS.
*  ENDCASE.


*--------------------------------------------------------------------*
  APPEND GS_FIELDCAT TO GT_FIELDCAT.
  CLEAR : GS_FIELDCAT.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONVERSION_EXIT_ALPHA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CONVERSION_EXIT_ALPHA  USING PV_FLAG
                                  PV_VALUE.

  IF PV_FLAG = 'I'.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        INPUT  = PV_VALUE
      IMPORTING
        OUTPUT = PV_VALUE.
  ELSE.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = PV_VALUE
      IMPORTING
        OUTPUT = PV_VALUE.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_TRAN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM CALL_TRAN  USING    P_COLUMN_ID TYPE LVC_S_COL
                         P_ROW_NO    TYPE LVC_S_ROW.


  CLEAR : GS_ITAB.

  CHECK P_ROW_NO-ROWTYPE+0(1) IS INITIAL.

  GS_ITAB = GT_ITAB[ P_ROW_NO-INDEX ].

  IF SY-SUBRC EQ 0.

    CASE P_COLUMN_ID.
      WHEN 'KNUMA'.    "커미션 계약
        CHECK GS_ITAB-KNUMA IS NOT INITIAL.

        SET PARAMETER ID 'CAL' FIELD 'X'.
        SET PARAMETER ID 'REQ' FIELD GS_ITAB-KNUMA.
        CALL TRANSACTION 'ZGTSDR1103' AND SKIP FIRST SCREEN.
*        CALL TRANSACTION 'ZVBO3' AND SKIP FIRST SCREEN.

      WHEN 'VBELN'.    "매출문서 조회
        CHECK GS_ITAB-VBELN IS NOT INITIAL.

        SET PARAMETER ID 'VF' FIELD GS_ITAB-VBELN.
        CALL TRANSACTION 'VF03' AND SKIP FIRST SCREEN.

      WHEN 'AUBEL'.    "판매오더 조회
        CHECK GS_ITAB-AUBEL IS NOT INITIAL.

        SET PARAMETER ID 'AUN' FIELD GS_ITAB-AUBEL.
        CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.

      WHEN 'KUNAG'.    "고객코드 조회
        CHECK GS_ITAB-KUNAG IS NOT INITIAL.

        SET PARAMETER ID 'KUN' FIELD GS_ITAB-KUNAG.
        SET PARAMETER ID 'VKO' FIELD GS_ITAB-VKORG.
        SET PARAMETER ID 'VTW' FIELD GS_ITAB-VTWEG.
        SET PARAMETER ID 'SPA' FIELD GS_ITAB-SPART.
        CALL TRANSACTION 'VD03' AND SKIP FIRST SCREEN.

      WHEN 'BONEM'.     " 에이전트 조회
        CHECK GS_ITAB-BONEM IS NOT INITIAL.

        SET PARAMETER ID 'KUN' FIELD GS_ITAB-BONEM.
        SET PARAMETER ID 'VKO' FIELD GS_ITAB-VKORG.
        SET PARAMETER ID 'VTW' FIELD GS_ITAB-VTWEG.
        SET PARAMETER ID 'SPA' FIELD GS_ITAB-SPART.
        CALL TRANSACTION 'VD03' AND SKIP FIRST SCREEN.

      WHEN 'VBELN_SE'.   " 정산오더 조회
        CHECK GS_ITAB-VBELN_SE IS NOT INITIAL.

        SET PARAMETER ID 'AUN' FIELD GS_ITAB-VBELN_SE.
        CALL TRANSACTION 'VA03' AND SKIP FIRST SCREEN.

      WHEN 'BELNR_1'.    " 미지급전표 조회
        CHECK GS_ITAB-BELNR_1 IS NOT INITIAL.

        SET PARAMETER ID 'BLN' FIELD GS_ITAB-BELNR_1.
        SET PARAMETER ID 'BUK' FIELD GS_ITAB-VKORG.
        SET PARAMETER ID 'GJR' FIELD GS_ITAB-BLDAT_1(4).
        CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.

      WHEN 'BELNR_2'.    " 지급전표 조회
        CHECK GS_ITAB-BELNR_2 IS NOT INITIAL.

        SET PARAMETER ID 'BLN' FIELD GS_ITAB-BELNR_2.
        SET PARAMETER ID 'BUK' FIELD GS_ITAB-VKORG.
        SET PARAMETER ID 'GJR' FIELD GS_ITAB-BLDAT_2(4).
        CALL TRANSACTION 'FB03' AND SKIP FIRST SCREEN.

    ENDCASE.

  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form INITIALIZATION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM INITIALIZATION .

*-영업조직
  PA_VKORG = GC_VKORG_6000.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_KNUMA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM F4_KNUMA  USING    PV_FNAME.
  DATA : LT_RETURN LIKE DDSHRETVAL OCCURS 0 WITH HEADER LINE,
         LT_FIELDS LIKE DYNPREAD OCCURS 0 WITH HEADER LINE.

  RANGES :  LR_VKORG FOR VBAK-VKORG,
            LR_VTWEG FOR VBAK-VTWEG,
            LR_SPART FOR VBAK-SPART,
            LR_VKBUR FOR VBAK-VKBUR,
            LR_VKGRP FOR VBAK-VKGRP,
            LR_BONEM FOR ZKONA-BONEM.
  CLEAR   : LR_VKORG, LR_VTWEG, LR_SPART, LR_VKBUR, LR_VKGRP, LR_BONEM.
  REFRESH : LR_VKORG, LR_VTWEG, LR_SPART, LR_VKBUR, LR_VKGRP, LR_BONEM.


  DATA : BEGIN OF LS_VALUE,
           KNUMA TYPE ZKONA-KNUMA,    "계약
           VKORG TYPE ZKONA-VKORG,    "영업조직
           VTWEG TYPE ZKONA-VTWEG,    "유통경로
           SPART TYPE ZKONA-SPART,    "제품군
           VKBUR TYPE ZKONA-VKBUR,    "영업팀
           VKGRP TYPE ZKONA-VKGRP,    "영업그룹
           BONEM TYPE ZKONA-BONEM,    "에이전트(리베이트 수령인)
         END OF LS_VALUE.
  DATA : LT_VALUE LIKE TABLE OF LS_VALUE.


*- SELECTION SCREEN 값 읽어오기
  LT_FIELDS-FIELDNAME = 'PA_VKORG'. "영업조직
  APPEND LT_FIELDS.
  PERFORM GET_SCREEN_VALUE TABLES : LT_FIELDS USING 'SO_VTWEG-' ,
                                    LT_FIELDS USING 'SO_SPART-' ,
                                    LT_FIELDS USING 'SO_VKBUR-' ,
                                    LT_FIELDS USING 'SO_VKGRP-' ,
                                    LT_FIELDS USING 'SO_BONEM-' .


*  LT_FIELDS-FIELDNAME = 'SO_VKORG-LOW'. "영업조직
*  APPEND LT_FIELDS.
*  LT_FIELDS-FIELDNAME = 'SO_VTWEG-LOW'. "유통경로
*  APPEND LT_FIELDS.
*  LT_FIELDS-FIELDNAME = 'SO_SPART-LOW'. "제품군
*  APPEND LT_FIELDS.
*  LT_FIELDS-FIELDNAME = 'SO_VKBUR-LOW'. "사업장
*  APPEND LT_FIELDS.
*  LT_FIELDS-FIELDNAME = 'SO_VKGRP-LOW'. "영업그룹
*  APPEND LT_FIELDS.
*  LT_FIELDS-FIELDNAME = 'SO_BONEM-LOW'. "AGENT
*  APPEND LT_FIELDS.

  CALL FUNCTION 'DYNP_VALUES_READ'
    EXPORTING
      DYNAME               = SY-CPROG
      DYNUMB               = SY-DYNNR
    TABLES
      DYNPFIELDS           = LT_FIELDS
    EXCEPTIONS
      INVALID_ABAPWORKAREA = 1
      INVALID_DYNPROFIELD  = 2
      INVALID_DYNPRONAME   = 3
      INVALID_DYNPRONUMMER = 4
      INVALID_REQUEST      = 5
      NO_FIELDDESCRIPTION  = 6
      INVALID_PARAMETER    = 7
      UNDEFIND_ERROR       = 8
      DOUBLE_CONVERSION    = 9
      STEPL_NOT_FOUND      = 10
      OTHERS               = 11.


  SELECT KNUMA
         VKORG
         VTWEG
         SPART
         VKBUR
         VKGRP
         BONEM
    INTO CORRESPONDING FIELDS OF TABLE LT_VALUE
    FROM ZKONA
   WHERE VKORG EQ PA_VKORG
     AND VTWEG IN SO_VTWEG
     AND SPART IN SO_SPART
     AND VKBUR IN SO_VKBUR
     AND VKGRP IN SO_VKGRP
     AND BONEM IN SO_BONEM.

*- Search Help 출력
  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'KNUMA'
      DYNPPROG        = SY-CPROG
      DYNPNR          = SY-DYNNR
      DYNPROFIELD     = PV_FNAME
      VALUE_ORG       = 'S'  "'C'
    TABLES
      VALUE_TAB       = LT_VALUE
      RETURN_TAB      = LT_RETURN
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_VTWEG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM F4_VTWEG  USING    PV_FNAME.

  SELECT A~VKORG,A~VTWEG,B~VTEXT
    FROM TVKOV AS A INNER JOIN TVTWT AS B
                    ON A~VTWEG = B~VTWEG AND
                       B~SPRAS = @SY-LANGU
   WHERE A~VKORG EQ @PA_VKORG
    INTO TABLE @DATA(LT_VALUE).
  SORT LT_VALUE BY VKORG VTWEG.
  CHECK LT_VALUE[] IS NOT INITIAL.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      RETFIELD        = 'VTWEG'
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
*& Form F4_SPART
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM F4_SPART  USING   PV_FNAME.

  SELECT VKORG,VTWEG,SPART
    FROM TVTA
   WHERE VKORG EQ @PA_VKORG
    INTO TABLE @DATA(LT_VALUE).

  SORT LT_VALUE BY VKORG VTWEG SPART.
  DELETE ADJACENT DUPLICATES FROM LT_VALUE COMPARING VKORG VTWEG SPART.

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
FORM F4_VKBUR  USING  PV_FNAME.

  SELECT DISTINCT A~VKBUR,B~BEZEI
    FROM TVKBZ AS A INNER JOIN TVKBT AS B
                    ON A~VKBUR = B~VKBUR

   WHERE A~VKORG EQ @PA_VKORG
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
FORM F4_VKGRP  USING  PV_FNAME.
  RANGES: LR_VKBUR FOR VBAK-VKBUR.

  LR_VKBUR[] = CORRESPONDING #( SO_VKBUR[] ).

  SELECT DISTINCT A~VKBUR,B~BEZEI,A~VKGRP,C~BEZEI AS VKGRP_TXT
    FROM TVKBZ AS H INNER JOIN TVBVK AS A
                    ON H~VKBUR = A~VKBUR
                    INNER JOIN TVKBT AS B
                    ON A~VKBUR = B~VKBUR AND
                       B~SPRAS = @SY-LANGU
                    INNER JOIN TVGRT AS C
                    ON A~VKGRP = C~VKGRP AND
                       C~SPRAS = @SY-LANGU
   WHERE H~VKORG EQ @PA_VKORG
     AND A~VKBUR IN @LR_VKBUR
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
