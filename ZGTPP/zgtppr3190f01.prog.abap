*&---------------------------------------------------------------------*
*& INCLUDE          ZGTPPR3190F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& FORM SELECT_ALV_VARIANT
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      <-- P_LAYO
*&---------------------------------------------------------------------*
FORM SELECT_ALV_VARIANT  CHANGING PV_LAYO TYPE DISVARIANT-VARIANT.

  DATA: LS_VARIANT TYPE DISVARIANT.

  LS_VARIANT-REPORT = SY-REPID.

  CALL FUNCTION 'REUSE_ALV_VARIANT_F4'
    EXPORTING
      IS_VARIANT    = LS_VARIANT
      I_SAVE        = 'A'
    IMPORTING
      ES_VARIANT    = LS_VARIANT
    EXCEPTIONS
      NOT_FOUND     = 1
      PROGRAM_ERROR = 2.
  IF SY-SUBRC <> 0.
    MESSAGE ID SY-MSGID TYPE 'S' NUMBER SY-MSGNO
      WITH SY-MSGV1 SY-MSGV2 SY-MSGV3 SY-MSGV4.
  ELSE.
    PV_LAYO = LS_VARIANT-VARIANT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM GET_DATA
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM GET_DATA .

  "---판매오더 재고 추출
  "공급업체코드"를 입력한 안한경우
  IF S_LIFNR[] IS INITIAL.
    CLEAR: GT_DATA1.
    SELECT A~MATNR, A~MTART, A~MATKL, A~MEINS,
           B~WERKS, B~LGORT, B~CHARG, B~SOBKZ, B~VBELN,
           B~POSNR, B~KALAB, B~KAINS, B~KASPE,
           C~ZPJNO, C~BSTNK,
           D~TAGNR, D~MGVRG, D~FOSTCNT, D~REMAIN, D~BKTXT, D~AUFNR
      FROM MARA AS A
      JOIN MSKA AS B ON A~MATNR = B~MATNR
      JOIN VBAK AS C ON B~VBELN = C~VBELN
      LEFT JOIN ZPPT0001 AS D ON D~MATNR = B~MATNR
                             AND D~WERKS = B~WERKS
                            AND D~CHARG = B~CHARG
      WHERE B~WERKS EQ @P_WERKS  "플랜트
        AND B~MATNR IN @S_MATNR "자재코드
        AND A~MTART IN @S_MTART "자재유형
        AND A~MATKL IN @S_MATKL "자재그룹
        AND B~LGORT IN @S_LGORT "저장위치
        AND B~CHARG IN @S_CHARG "배치번호
        AND C~ZPJNO IN @S_PRJNO "프로젝트번호
        AND C~BSTNK IN @S_PONO  "PO번호
        AND B~VBELN IN @S_VBELN "판매오더
        AND B~POSNR IN @S_POSNR "판매오더 아이템
        AND ( B~KALAB > 0 OR B~KAINS > 0 OR B~KASPE > 0 )
        AND D~TAGNR IN @S_TAGNR
       INTO CORRESPONDING FIELDS OF TABLE @GT_DATA1.
    SORT GT_DATA1 BY WERKS MATNR.
  ENDIF.

  " ---공급업체 재고 추출
  " 저장위치","판매오더" 혹은 "판매오더 아이템" 를
  " 입력이 안된 경우에만 수행
  " 프로젝트번호, PO번호 입력 안된 경우도  추가
  IF S_LGORT[] IS INITIAL AND
     S_VBELN[] IS INITIAL AND
     S_POSNR[] IS INITIAL AND
     S_PRJNO[] IS INITIAL AND
     S_PONO[]  IS INITIAL AND
     S_TAGNR[] IS INITIAL.
    CLEAR: GT_DATA2.
    SELECT A~MATNR, A~MTART, A~MATKL, A~MEINS,
           B~WERKS, B~CHARG, B~SOBKZ, B~LIFNR,
           B~LBLAB AS KALAB,
           B~LBINS AS KAINS
      FROM MARA AS A
      JOIN MSLB AS B ON A~MATNR = B~MATNR
     WHERE B~WERKS EQ @P_WERKS "플랜트
       AND B~MATNR IN @S_MATNR "자재코드
       AND A~MTART IN @S_MTART "자재유형
       AND A~MATKL IN @S_MATKL "자재그룹
       AND B~CHARG IN @S_CHARG "배치번호
*       AND  @S_PRJNO 프로젝트번호 조건 추가 예정(TBD)
*       AND  @S_PRDNO 제조지시번호 조건 추가 예정(TBD)
       AND B~LIFNR IN @S_LIFNR "공급업체코드
      INTO CORRESPONDING FIELDS OF TABLE @GT_DATA2.
    SORT GT_DATA2 BY WERKS MATNR.
  ENDIF.

  "---배치 재고 추출
  "공급업체코드 "판매오더" 혹은 "판매오더 아이템" 를
  " 입력이 안된 경우에만 수행
  " 프로젝트번호, PO번호 입력 안된 경우도  추가
  IF S_LIFNR[] IS INITIAL AND
     S_VBELN[] IS INITIAL AND
     S_POSNR[] IS INITIAL AND
     S_PRJNO[] IS INITIAL AND
     S_PONO[]  IS INITIAL.
    CLEAR: GT_DATA3.
    SELECT A~MATNR, A~MTART, A~MATKL, A~MEINS,
           B~WERKS, B~LGORT, B~CHARG,
           B~CLABS AS KALAB,
           B~CINSM AS KAINS,
           B~CSPEM AS KASPE,
           C~TAGNR, C~MGVRG, C~FOSTCNT, C~REMAIN, C~BKTXT, C~AUFNR
      FROM MARA AS A
      JOIN MCHB AS B ON A~MATNR = B~MATNR
      LEFT JOIN ZPPT0001 AS C ON C~MATNR EQ B~MATNR
                             AND C~WERKS EQ B~WERKS
                             AND C~CHARG EQ B~CHARG
     WHERE B~WERKS EQ @P_WERKS "플랜트
       AND B~MATNR IN @S_MATNR "자재코드
       AND A~MTART IN @S_MTART "자재유형
       AND A~MATKL IN @S_MATKL "자재그룹
       AND B~LGORT IN @S_LGORT "저장위치
       AND B~CHARG IN @S_CHARG "배치번호
*         AND  @S_PRJNO 프로젝트번호 조건 추가 예정(TBD)
*         AND  @S_PRDNO 제조지시번호 조건 추가 예정(TBD)
       AND ( B~CLABS > 0 OR B~CINSM > 0 OR B~CSPEM > 0 )
       AND C~TAGNR IN @S_TAGNR
      INTO CORRESPONDING FIELDS OF TABLE @GT_DATA3.
    SORT GT_DATA3 BY WERKS MATNR.
  ENDIF.

  "---플랜트 재고 추출
  " 배치번호 "판매오더" 혹은 "판매오더 아이템" 를
  " 입력이 안된 경우에만 수행
  " 프로젝트번호, PO번호 입력 안된 경우도  추가
  " 공급업체 입력 안된 경우도 추가
  IF S_CHARG[] IS INITIAL AND
     S_VBELN[] IS INITIAL AND
     S_POSNR[] IS INITIAL AND
     S_PRJNO[] IS INITIAL AND
     S_PONO[]  IS INITIAL AND
     S_LIFNR[] IS INITIAL AND
     S_TAGNR[] IS INITIAL.
    CLEAR: GT_DATA4.
    SELECT A~MATNR, A~MTART, A~MATKL, A~MEINS,
           B~WERKS, B~LGORT,
           B~LABST AS KALAB,
           B~INSME AS KAINS,
           B~SPEME AS KASPE
      FROM MARA AS A
      JOIN MARD AS B ON A~MATNR = B~MATNR
     WHERE B~WERKS EQ @P_WERKS "플랜트
       AND B~MATNR IN @S_MATNR "자재코드
       AND A~MTART IN @S_MTART "자재유형
       AND A~MATKL IN @S_MATKL "자재그룹
       AND B~LGORT IN @S_LGORT "저장위치
       AND A~XCHPF NE @GC_X    "배치재고는 제외
       AND ( B~LABST > 0 OR B~INSME > 0 OR B~SPEME > 0 )
      INTO CORRESPONDING FIELDS OF TABLE @GT_DATA4.
    SORT GT_DATA4 BY WERKS MATNR.
  ENDIF.

  REFRESH GT_DATA.

  IF GT_DATA1[] IS NOT INITIAL.
    LOOP AT GT_DATA1 INTO GS_DATA1.
      GS_DATA = CORRESPONDING #( GS_DATA1 ).
      APPEND GS_DATA TO GT_DATA.
    ENDLOOP.
  ENDIF.

  IF GT_DATA2[] IS NOT INITIAL.
    LOOP AT GT_DATA2 INTO GS_DATA2.
      GS_DATA = CORRESPONDING #( GS_DATA2 ).
      APPEND GS_DATA TO GT_DATA.
    ENDLOOP.
  ENDIF.

  IF GT_DATA3[] IS NOT INITIAL.
    LOOP AT GT_DATA3 INTO GS_DATA3.
      GS_DATA = CORRESPONDING #( GS_DATA3 ).
      APPEND GS_DATA TO GT_DATA.
    ENDLOOP.
  ENDIF.

  IF GT_DATA4[] IS NOT INITIAL.
    LOOP AT GT_DATA4 INTO GS_DATA4.
      GS_DATA = CORRESPONDING #( GS_DATA4 ).
      APPEND GS_DATA TO GT_DATA.
    ENDLOOP.
  ENDIF.

**  완제품 외주 품목의 공급업체코드 추출
*  DATA : BEGIN OF LS_CHK_BSTNK,
*           BSTNK TYPE VBAK-BSTNK,
*         END OF LS_CHK_BSTNK.
*  DATA: LT_CHK_BSTNK LIKE TABLE OF LS_CHK_BSTNK.
*
*  LT_CHK_BSTNK = VALUE #( FOR LW_DATA IN GT_DATA WHERE ( MTART = GC_MCFE
*                                                   AND   BSTNK IS NOT INITIAL )
*                                                       ( BSTNK = LW_DATA-BSTNK ) ).
*  SORT LT_CHK_BSTNK BY BSTNK.
*  DELETE ADJACENT DUPLICATES FROM LT_CHK_BSTNK COMPARING BSTNK.
*  IF LT_CHK_BSTNK IS NOT INITIAL.
*    SELECT DISTINCT
*           B~JOB_NO AS BSTNK,
*           D~LIFNR AS LIFNR_PROJ,
*           F~NAME1 AS NAME1_PROJ,
*           B~LINE_NO,
*           B~SERIAL_INFO
*      FROM @LT_CHK_BSTNK AS A
*      JOIN ZGTMM_CV_BD_JOBLS_PRPO AS B ON B~JOB_NO = A~BSTNK
*      JOIN EKPO AS C ON C~EBELN = B~EBELN
*                    AND C~EBELP = B~EBELP
*      JOIN EKKO AS D ON D~EBELN = C~EBELN
*      JOIN MARA AS E ON E~MATNR = C~MATNR
*                    AND E~MTART = @GC_MCFE
*      JOIN LFA1 AS F ON F~LIFNR = D~LIFNR
*     ORDER BY B~JOB_NO
*      INTO CORRESPONDING FIELDS OF TABLE @GT_BSTNK_INFOR.
*  ENDIF.

  "플랜트 내역
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE GT_T001W
    FROM T001W
     FOR ALL ENTRIES IN GT_DATA
   WHERE WERKS = GT_DATA-WERKS.
  SORT GT_T001W BY WERKS.

  "자재내역 발췌
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE GT_MAKT
    FROM MAKT
     FOR ALL ENTRIES IN GT_DATA
   WHERE MATNR = GT_DATA-MATNR
     AND SPRAS = SY-LANGU.
  SORT GT_MAKT BY MATNR .

  "자재 유형 내역
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE GT_T134T
    FROM T134T
     FOR ALL ENTRIES IN GT_DATA
   WHERE MTART = GT_DATA-MTART
     AND SPRAS = SY-LANGU.
  SORT GT_T134T BY MTART .

  "자재 그룹 내역
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE GT_T023T
    FROM T023T
     FOR ALL ENTRIES IN GT_DATA
   WHERE MATKL = GT_DATA-MATKL
     AND SPRAS = SY-LANGU.
  SORT GT_T023T BY MATKL .

  "저장 위치 내역 추출
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE GT_T001L
    FROM T001L
     FOR ALL ENTRIES IN GT_DATA
   WHERE WERKS = GT_DATA-WERKS
     AND LGORT = GT_DATA-LGORT.
  SORT GT_T001L BY WERKS .

  "업체명 추출
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE GT_LFA1
    FROM LFA1
     FOR ALL ENTRIES IN GT_DATA
   WHERE LIFNR = GT_DATA-LIFNR.
  SORT GT_LFA1 BY LIFNR .

  "프로젝트 내역 추출
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE GT_ZSD0106T
    FROM ZSD0106T
     FOR ALL ENTRIES IN GT_DATA
   WHERE ZPJNO = GT_DATA-ZPJNO.
  SORT GT_ZSD0106T BY ZPJNO .

  "배치속성추출
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE GT_MCH1
    FROM MCH1
     FOR ALL ENTRIES IN GT_DATA
   WHERE MATNR = GT_DATA-MATNR
     AND CHARG = GT_DATA-CHARG.
  SORT GT_MCH1 BY MATNR CHARG.

  "자재 배치 유형 추출
  SELECT MATNR DPCBT
    INTO CORRESPONDING FIELDS OF TABLE GT_DPCBT
    FROM MARC
     FOR ALL ENTRIES IN GT_DATA
   WHERE MATNR = GT_DATA-MATNR
        AND WERKS = GT_DATA-WERKS.
  SORT GT_DPCBT BY MATNR.

*  "특성 필드 ADD DATA 추출
*  SELECT *
*    INTO CORRESPONDING FIELDS OF TABLE @GT_T1010
*    FROM ZGTPPT1010
*   WHERE MODULE_KIND = @GC_PP
*     AND CODEGRP     = @GC_4020.

  "VBAP
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE @GT_VBAP
    FROM ZGTSD_CV_SO_ITEM
     FOR ALL ENTRIES IN @GT_DATA
   WHERE VBELN = @GT_DATA-VBELN
     AND POSNR = @GT_DATA-POSNR.
  SORT GT_VBAP BY VBELN POSNR.

  REFRESH GT_LIST_SD.
  PERFORM CALL_1320_PROGRAM TABLES GT_LIST_SD.
  SORT GT_LIST_SD BY VBELN POSNR.

  "꼬리표 정보
*  SELECT *
*    FROM ZPPT0001
*     FOR ALL ENTRIES IN @GT_DATA
*   WHERE MATNR = @GT_DATA-MATNR
*     AND WERKS = @GT_DATA-WERKS
*     AND CHARG = @GT_DATA-CHARG
*    INTO CORRESPONDING FIELDS OF TABLE @GT_TAGNR.
*  SORT GT_TAGNR BY MATNR WERKS CHARG.

*** START. 재질 및 중량 추가 추출 2026.07.25
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE GT_TKGW
    FROM /NFM/TKGW
     FOR ALL ENTRIES IN GT_DATA
   WHERE MATNR = GT_DATA-MATNR
        AND WERKS = GT_DATA-WERKS.
  SORT GT_TKGW BY MATNR.
*** END. 재질 및 중량 추가 추출 2026.07.25

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM MODIFY_DATA
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM MODIFY_DATA .

  DATA : LV_OBJECT TYPE VBAP-MATNR.
  DATA : LV_MGVRG TYPE ZMGVRG.
  DATA : LV_EBELN TYPE EBELN.

  DATA : LT_MATNR TYPE RANGE_T_MATNR.
  DATA : LT_LINK_DETAIL TYPE TABLE OF ZGTPPS1005.
  DATA : LT_LINK_STOCK  TYPE TABLE OF ZGTPPS1006.
  DATA : LV_MENGE TYPE MENGE_D.


  LOOP AT GT_DATA INTO GS_DATA.
    "플랜트
    GS_DISP-WERKS = GS_DATA-WERKS.

    " 플랜트명
    CLEAR GS_T001W.
    READ TABLE GT_T001W INTO GS_T001W WITH KEY WERKS = GS_DATA-WERKS.
    IF SY-SUBRC = 0.
      GS_DISP-NAME1 = GS_T001W-NAME1.
    ENDIF.

    "자재코드 내역
    CLEAR GS_MAKT.
    READ TABLE GT_MAKT INTO GS_MAKT WITH KEY MATNR = GS_DATA-MATNR.
    IF SY-SUBRC = 0.
      GS_DISP-MAKTX = GS_MAKT-MAKTX.
    ENDIF.

*    "배치 속성 내역
*    CLEAR GS_MCH1.
*    READ TABLE GT_MCH1 INTO GS_MCH1 WITH KEY MATNR = GS_DATA-MATNR
*                                             CHARG = GS_DATA-CHARG.
*    IF SY-SUBRC = 0.
*      GS_DISP-ZZLINE_NO = GS_MCH1-ZZLINE_NO.
*      GS_DISP-ZZSERIAL_INFO = GS_MCH1-ZZSERIAL_INFO.
*    ENDIF.

*    "배치 유형
    CLEAR : GS_DPCBT.
    READ TABLE GT_DPCBT INTO GS_DPCBT WITH KEY MATNR = GS_DATA-MATNR.
    IF SY-SUBRC = 0 AND GS_DPCBT-DPCBT = 'A'. "FACTOR 배치

      CLEAR: GT_CHAR[].
      CALL FUNCTION 'ZQC01_BATCH_VALUES_READ'
        EXPORTING
          I_VAL_MATNR                  = GS_DATA-MATNR
          I_VAL_WERKS                  = GS_DATA-WERKS
          I_VAL_CHARGE                 = GS_DATA-CHARG
        TABLES
          T_VAL_TAB                    = GT_CHAR
        EXCEPTIONS
          INSTANCE_NOT_FOUND           = 1
          INSTANCE_IS_A_CLASSIFICATION = 2
          INVALID_DATA                 = 3
          OTHERS                       = 4.

      "개별조장길이
      DATA(LV_ATWRT) = VALUE #( GT_CHAR[ ATNAM = 'SAP_MILLCA_LENGTH' ]-ATWRT OPTIONAL ).
      REPLACE ALL OCCURRENCES OF ',' IN LV_ATWRT WITH ''.
      CLEAR: LV_MGVRG.
      LV_MGVRG = LV_ATWRT.

      GS_DISP-MGVRG = LV_ATWRT.      "개별조장길이 = 배치번호

      IF GS_DISP-MGVRG EQ 0.
        "조장 수 = 1
        GS_DISP-FOSTCNT = 1.
      ELSE.
        "조장 수 = 가용재고 / 개별조장길이
        GS_DISP-FOSTCNT = GS_DATA-KALAB / GS_DISP-MGVRG.
      ENDIF.

      "잔량 = 재고수량(가용) + 재고수량(품질) + 재고수량(보류)
      GS_DISP-REMAIN = GS_DISP-KALAB + GS_DISP-KAINS + GS_DISP-KASPE.

*    ELSE.
*      "꼬리표
*      CLEAR GS_TAGNR.
*      READ TABLE GT_TAGNR INTO GS_TAGNR WITH KEY WERKS = GS_DATA-WERKS
*                                                 MATNR = GS_DATA-MATNR
*                                                 CHARG = GS_DATA-CHARG.
*      IF SY-SUBRC EQ 0.
*        GS_DISP-TAGNR = GS_TAGNR-TAGNR.
*        GS_DISP-MGVRG = GS_TAGNR-MGVRG.
*        GS_DISP-FOSTCNT = GS_TAGNR-FOSTCNT.
*        GS_DISP-REMAIN = GS_TAGNR-REMAIN.
*      ENDIF.
    ELSE.
***  Single Unit 배치 or 일반 배치인 경우
      GS_DISP-TAGNR   = GS_DATA-TAGNR.
      IF GS_DATA-KALAB IS NOT INITIAL.     "가용재고
        GS_DISP-MGVRG   = GS_DATA-KALAB.
      ELSEIF GS_DATA-KAINS IS NOT INITIAL. "품질검사재고
        GS_DISP-MGVRG   = GS_DATA-KAINS.
      ELSEIF GS_DATA-KASPE IS NOT INITIAL. "보류재고
        GS_DISP-MGVRG   = GS_DATA-KASPE.
      ENDIF.
      GS_DISP-FOSTCNT = 1.
      GS_DISP-REMAIN  = GS_DATA-REMAIN.
    ENDIF.

*    CLEAR : GT_CHAR[], GT_CHAR2[].
*
*    IF GS_DATA-CHARG IS NOT INITIAL.
*      CALL FUNCTION 'ZQC01_BATCH_VALUES_READ'
*        EXPORTING
*          I_VAL_MATNR                  = GS_DATA-MATNR
*          I_VAL_WERKS                  = GS_DATA-WERKS
*          I_VAL_CHARGE                 = GS_DATA-CHARG
*        TABLES
*          T_VAL_TAB                    = GT_CHAR
*        EXCEPTIONS
*          INSTANCE_NOT_FOUND           = 1
*          INSTANCE_IS_A_CLASSIFICATION = 2
*          INVALID_DATA                 = 3
*          OTHERS                       = 4.
*    ELSE.
*      IF GS_DATA-VBELN IS NOT INITIAL AND
*         GS_DATA-CHARG IS INITIAL.
*        CLEAR: GS_VBAP.
*        READ TABLE GT_VBAP INTO GS_VBAP WITH KEY VBELN = GS_DATA-VBELN
*                                                 POSNR = GS_DATA-POSNR
*                                                 BINARY SEARCH.
*        IF SY-SUBRC = 0.
*          CLEAR: LV_OBJECT.
*          LV_OBJECT = GS_VBAP-MATNR.
*        ENDIF.
*
*        CALL FUNCTION 'Z_LE_GET_CHARACTERISTIC'
*          EXPORTING
*            I_VBELN                      = GS_DATA-VBELN
*            I_POSNR                      = GS_DATA-POSNR
*            I_OBJECT                     = LV_OBJECT
*            I_WERKS                      = GS_DATA-WERKS
**       IMPORTING
**           ET_RETURN                    =
*          TABLES
*            GT_LIST                      = GT_CHAR2
*          EXCEPTIONS
*            INSTANCE_NOT_FOUND           = 1
*            INSTANCE_IS_A_CLASSIFICATION = 2
*            INVALID_DATA                 = 3
*            OTHERS                       = 4.
**      ELSEIF   P_R2 = 'X' OR P_R3 = 'X'.
**        READ TABLE GT_VBAP INTO GS_VBAP WITH KEY VBELN = GS_DATA-VBELN
**                                                 POSNR = GS_DATA-POSNR
**                                                 BINARY SEARCH.
**        IF SY-SUBRC = 0.
**          LV_OBJECT = GS_VBAP-MATNR.
**        ENDIF.
**
**        CALL FUNCTION 'Z_LE_GET_CHARACTERISTIC'
**          EXPORTING
**            I_VBELN                      = GS_DATA-VBELN
**            I_POSNR                      = GS_DATA-POSNR
**            I_OBJECT                     = LV_OBJECT
**            I_WERKS                      = GS_DATA-WERKS
***       IMPORTING
***           ET_RETURN                    =
**          TABLES
**            GT_LIST                      = GT_CHAR2
**          EXCEPTIONS
**            INSTANCE_NOT_FOUND           = 1
**            INSTANCE_IS_A_CLASSIFICATION = 2
**            INVALID_DATA                 = 3
**            OTHERS                       = 4.
*      ENDIF.
*    ENDIF.

    "자재코드
*    CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
*      EXPORTING
*        INPUT  = GS_DATA-MATNR
*      IMPORTING
*        OUTPUT = GS_DATA-MATNR.

    GS_DISP-MATNR  = GS_DATA-MATNR.

    "자재유형
    GS_DISP-MTART = GS_DATA-MTART.

    "자재유형내역
    CLEAR GS_T134T.
    READ TABLE GT_T134T INTO GS_T134T WITH KEY MTART = GS_DATA-MTART.
    IF SY-SUBRC = 0.
      GS_DISP-MTBEZ = GS_T134T-MTBEZ.
    ENDIF.

    "자재그룹
    GS_DISP-MATKL = GS_DATA-MATKL.

    "자재그룹내역
    CLEAR GS_T023T.
    READ TABLE GT_T023T INTO GS_T023T WITH KEY MATKL = GS_DATA-MATKL.
    IF SY-SUBRC = 0.
      GS_DISP-WGBEZ = GS_T023T-WGBEZ.
    ENDIF.

    "저장위치
    GS_DISP-LGORT = GS_DATA-LGORT.

    "저장위치 내역
    CLEAR GS_T001L.
    READ TABLE GT_T001L INTO GS_T001L WITH KEY WERKS = GS_DATA-WERKS
                                               LGORT = GS_DATA-LGORT.
    IF SY-SUBRC = 0.
      GS_DISP-LGOBE = GS_T001L-LGOBE.
    ENDIF.

    "배치번호
    GS_DISP-CHARG = GS_DATA-CHARG.

    "특별 재고 지시자
    GS_DISP-SOBKZ = GS_DATA-SOBKZ.

    "공급업체 번호
    GS_DISP-LIFNR = GS_DATA-LIFNR.

    "공급업체명
    CLEAR GS_LFA1.
    READ TABLE GT_LFA1 INTO GS_LFA1 WITH KEY LIFNR = GS_DATA-LIFNR.
    IF SY-SUBRC = 0.
      GS_DISP-NAME2 = GS_LFA1-NAME1.
    ENDIF.

    "프로젝트 내역
    CLEAR GS_ZSD0106T.
    READ TABLE GT_ZSD0106T INTO GS_ZSD0106T WITH KEY ZPJNO = GS_DATA-ZPJNO.
    IF SY-SUBRC = 0.
      GS_DISP-PRJNM = GS_ZSD0106T-ZPTXT.
    ENDIF.

*    "제조 지시 내역
*    CLEAR GT_ZGTEDT2121.
*    READ TABLE GT_ZGTEDT2121 WITH KEY  ZWERKS = GS_DATA-WERKS
*                                      ZJOB_NO = GS_DATA-BSTNK.
*    IF SY-SUBRC = 0.
*      GS_DISP-PRDNM = GT_ZGTEDT2121-ZJOB_NAME.
*    ENDIF.

    GS_DISP-VBELN = GS_DATA-VBELN.  "판매오더
    GS_DISP-POSNR = GS_DATA-POSNR.  "판매오더 품목
    GS_DISP-ZPJNO = GS_DATA-ZPJNO.  "프로젝트번호
    GS_DISP-BSTNK = GS_DATA-BSTNK.  "PO번호
    GS_DISP-KALAB = GS_DATA-KALAB.  "재고수량(가용)
    GS_DISP-KAINS = GS_DATA-KAINS.  "재고수량(품질)
    GS_DISP-KASPE = GS_DATA-KASPE.  "재고수량(보류)
    GS_DISP-MEINS = GS_DATA-MEINS.  "단위

**  완제품 외주 품목의 공급업체코드 추출(20250731)
*    IF GS_DATA-MTART = GC_MCFE AND GS_DATA-BSTNK IS NOT INITIAL.
*      CLEAR GS_BSTNK_INFOR.
*      READ TABLE GT_BSTNK_INFOR INTO GS_BSTNK_INFOR
*                                WITH KEY BSTNK = GS_DATA-BSTNK
**                                         LINE_NO = GS_DISP-ZZLINE_NO
**                                         SERIAL_INFO = GS_DISP-ZZSERIAL_INFO
*                                         BINARY SEARCH.
*      IF SY-SUBRC EQ 0.
*        GS_DISP-LIFNR_PROJ = GS_BSTNK_INFOR-LIFNR_PROJ.
*        GS_DISP-NAME1_PROJ = GS_BSTNK_INFOR-NAME1_PROJ.
*      ENDIF.
*    ENDIF.

*    GS_DISP-TAGNR   = GS_DATA-TAGNR.
*    GS_DISP-MGVRG   = GS_DATA-MGVRG.
*    GS_DISP-FOSTCNT = GS_DATA-FOSTCNT.
*    GS_DISP-REMAIN  = GS_DATA-REMAIN.
    GS_DISP-BKTXT   = GS_DATA-BKTXT.

    "영업소
    IF GS_DISP-VBELN IS NOT INITIAL.
      SELECT SINGLE VKORG, VKGRP
        FROM VBAK
       WHERE VBELN EQ @GS_DISP-VBELN
        INTO (@DATA(LV_VKORG), @DATA(LV_VKGRP)).

      IF LV_VKORG IS NOT INITIAL AND LV_VKGRP IS NOT INITIAL.
        CALL FUNCTION 'ZGTSD_GET_ZZYUSCD'
          EXPORTING
            I_VKORG   = LV_VKORG
            I_VKGRP   = LV_VKGRP
            I_KDKG4   = '00'
          IMPORTING
            E_ZZYUSCD = GS_DISP-ZZYUSCD.

        CLEAR: LV_VKORG, LV_VKGRP.
      ENDIF.
    ENDIF.

    "꼬리표 생산오더/구매오더
    IF GS_DATA-AUFNR IS NOT INITIAL.
      "생산오더인지 확인
      SELECT SINGLE AUFNR
        FROM AUFK
       WHERE AUFNR EQ @GS_DATA-AUFNR
        INTO @GS_DISP-AUFNR.

      IF GS_DISP-AUFNR IS INITIAL.
        CLEAR: LV_EBELN.
        CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
          EXPORTING
            INPUT  = GS_DATA-AUFNR
          IMPORTING
            OUTPUT = LV_EBELN.

        "구매오더인지 확인
        SELECT SINGLE EBELN
          FROM EKKO
         WHERE EBELN EQ @LV_EBELN
          INTO @GS_DISP-EBELN.

      ELSE.
        IF P_C1 EQ 'X'.
          IF GS_DISP-MTART EQ 'MCFE'.
            "투입드럼/내역 추출
            SELECT SINGLE B~MATNR, C~MAKTX
              FROM MATDOC AS A
              JOIN MARA AS B ON B~MATNR EQ A~MATNR
              LEFT JOIN MAKT AS C ON C~MATNR EQ B~MATNR
                                 AND C~SPRAS EQ @SY-LANGU
             WHERE A~AUFNR EQ @GS_DISP-AUFNR
               AND A~WERKS EQ @GS_DISP-WERKS
               AND A~BWART EQ '261'
               AND B~MTART IN ('MRM1', 'MRM2', 'MRM3')
               AND A~CANCELLED EQ @SPACE
               AND A~REVERSAL_MOVEMENT EQ @SPACE
              INTO (@GS_DISP-DRUM, @GS_DISP-MAKTX_DRUM).
          ENDIF.
        ENDIF.
      ENDIF.
    ENDIF.

    IF S_AUFNR[] IS NOT INITIAL.
      IF GS_DISP-AUFNR NOT IN S_AUFNR.
        GS_DISP-DEL = 'X'.
      ENDIF.
    ENDIF.

    IF S_EBELN[] IS NOT INITIAL.
      IF GS_DISP-EBELN NOT IN S_EBELN.
        GS_DISP-DEL = 'X'.
      ENDIF.
    ENDIF.

    "MRP관리자 추출
    SELECT SINGLE A~DISPO, B~DSNAM
      FROM MARC AS A
      JOIN T024D AS B ON B~WERKS EQ A~WERKS
                     AND B~DISPO EQ A~DISPO
     WHERE A~MATNR EQ @GS_DATA-MATNR
       AND A~WERKS EQ @GS_DATA-WERKS
      INTO (@GS_DISP-DISPO, @GS_DISP-DSNAM).

    IF S_DISPO[] IS NOT INITIAL.
      IF GS_DISP-DISPO NOT IN S_DISPO.
        GS_DISP-DEL = 'X'.
      ENDIF.
    ENDIF.

    "COLOR 정보
    SELECT SINGLE COLORBASE, PDCACOLORSTRIPE, PDCACOLORSTRIPENO
      FROM ZGTCVMSTVAL
     WHERE WERKS EQ @GS_DATA-WERKS
       AND MATNR EQ @GS_DATA-MATNR
      INTO (@GS_DISP-COLOR, @GS_DISP-COLOR_STRIPE, @GS_DISP-COLOR_STR_NO).

    "주문 할당 정보 추출
    IF P_C2 EQ 'X'.
      IF GS_DATA-VBELN IS INITIAL.
        CLEAR: LT_MATNR, LT_MATNR[].
        LT_MATNR = VALUE #( SIGN = 'I' OPTION = 'EQ' ( LOW = GS_DATA-MATNR ) ).

        CLEAR: LT_LINK_DETAIL[], LT_LINK_STOCK[].
        CALL FUNCTION 'ZGTPP_GET_STOCK_LINK_INFO'
          EXPORTING
            I_WERKS        = GS_DATA-WERKS
            I_LGORT        = GS_DATA-LGORT
            IT_MATNR       = LT_MATNR
            I_CHARG        = GS_DATA-CHARG
          TABLES
            OT_LINK_DETAIL = LT_LINK_DETAIL
            OT_LINK_STOCK  = LT_LINK_STOCK.

        READ TABLE LT_LINK_STOCK INTO DATA(LS_LINK_STOCK) INDEX 1.

        IF SY-SUBRC EQ 0.
          "기할당수량/조장
          IF LS_LINK_STOCK-LABST2 LE 0.
            GS_DISP-LABST2     = 0.
            GS_DISP-LABST2_CNT = 0.
          ELSE.
            GS_DISP-LABST2 = LS_LINK_STOCK-LABST2.

            CASE GS_DPCBT-DPCBT.
              WHEN 'C'.
                GS_DISP-LABST2_CNT = 1.
              WHEN OTHERS.
                IF GS_DISP-MGVRG EQ 0.
                  GS_DISP-LABST2_CNT = 1.
                ELSE.
                  GS_DISP-LABST2_CNT = GS_DISP-LABST2 / GS_DISP-MGVRG.
                ENDIF.
            ENDCASE.
          ENDIF.

          "미할당수량/조장
          IF LS_LINK_STOCK-LABST3 LE 0.
            GS_DISP-LABST3 = 0.
            GS_DISP-LABST3_CNT = 0.
          ELSE.
            GS_DISP-LABST3 = LS_LINK_STOCK-LABST3.

            CASE GS_DPCBT-DPCBT.
              WHEN 'C'.
                GS_DISP-LABST3_CNT = 1.
              WHEN OTHERS.
                IF GS_DISP-MGVRG EQ 0.
                  GS_DISP-LABST3_CNT = 1.
                ELSE.
                  GS_DISP-LABST3_CNT = GS_DISP-LABST3 / GS_DISP-MGVRG.
                ENDIF.
            ENDCASE.
          ENDIF.
        ENDIF.

      ENDIF.
    ENDIF.

    READ TABLE GT_TKGW INTO GS_TKGW WITH KEY MATNR = GS_DISP-MATNR
                                    BINARY SEARCH.
    IF SY-SUBRC = 0.
      GS_DISP-NES = GS_TKGW-NES.    "재질
      GS_DISP-KGU_URE = GS_TKGW-KGW * GS_DISP-KALAB / GS_TKGW-KGU. "중량(가용)
      GS_DISP-KGU_INS = GS_TKGW-KGW * GS_DISP-KAINS / GS_TKGW-KGU. "중량(품질)
    ENDIF.

* 거부사유, 납품상태 추가
    IF GS_DATA-KALAB > 0 OR GS_DATA-KAINS > 0 OR GS_DATA-KASPE > 0.
      READ TABLE GT_VBAP INTO DATA(LS_VBAP) WITH KEY VBELN = GS_DATA-VBELN
                                                     POSNR = GS_DATA-POSNR.
      IF SY-SUBRC EQ 0.
        SELECT SINGLE CONCAT_WITH_SPACE( ABGRU, BEZEI, 1 )
          FROM TVAGT
         WHERE SPRAS = @SY-LANGU
           AND ABGRU = @LS_VBAP-ABGRU
          INTO @GS_DISP-ABGRU_T.


        CLEAR LV_MENGE.

        READ TABLE GT_LIST_SD INTO DATA(LS_LIST_SD) WITH KEY VBELN = GS_DATA-VBELN
                                                             POSNR = GS_DATA-POSNR
                                                             BINARY SEARCH.
        IF SY-SUBRC EQ 0.
          LV_MENGE = LS_LIST_SD-DO_OPEN.
        ENDIF.
        WRITE LV_MENGE TO GS_DISP-MENGE01 UNIT LS_VBAP-VRKME.
        CONDENSE GS_DISP-MENGE01.

        GS_DISP-VRKME = LS_VBAP-VRKME.
      ENDIF.

    ENDIF.

    APPEND GS_DISP TO GT_DISP.
    CLEAR : GS_DISP, GS_DATA.
  ENDLOOP.

*  IF S_TAGNR[] IS NOT INITIAL.
*    DELETE GT_DISP WHERE TAGNR NOT IN S_TAGNR.
*  ENDIF.

  DELETE GT_DISP WHERE DEL = 'X'.

  SORT GT_DISP BY WERKS MATNR LGORT CHARG TAGNR VBELN POSNR LIFNR.
  DELETE ADJACENT DUPLICATES FROM GT_DISP
         COMPARING WERKS MATNR LGORT CHARG TAGNR VBELN POSNR LIFNR.


ENDFORM.
*&---------------------------------------------------------------------*
*& FORM CLS_OBJT_RTN
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM CLS_OBJT_RTN .
  CLEAR: GT_FIELDCAT_0100[], GS_LAYOUT_0100, GT_EXCLUDE_0100[],
         GT_EXCLUDE_0100,
         GV_OK_CODE, GV_DBCNT,
         GT_DISP[].

  CALL METHOD GO_CONTAIN_0100->FREE.
  CLEAR : GO_CONTAIN_0100, GO_GRID_0100.
  CALL METHOD CL_GUI_CFW=>FLUSH.
  LEAVE TO SCREEN 0.
ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SET_OBJECT_GRID_0100
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
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
*& FORM SET_LAYOUT_GRID_0100
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM SET_LAYOUT_GRID_0100 .
  CLEAR GS_LAYOUT_0100.
*  GS_LAYOUT_0100-ZEBRA      = GC_X.
  GS_LAYOUT_0100-COL_OPT    = GC_X.
  GS_LAYOUT_0100-CWIDTH_OPT = GC_X.
*  GS_LAYOUT_0100-NO_ROWINS  = GC_X.
  GS_LAYOUT_0100-SEL_MODE   = GC_D.
*  GS_LAYOUT_0100-EDIT       = GC_X.
*  GS_LAYOUT_0100-STYLEFNAME = 'CELL_STY'.
ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SET_VARIANT_GRID_0100
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM SET_VARIANT_GRID_0100 .
  IF P_LAYO IS NOT INITIAL.
    GS_VARIANT_0100-VARIANT = P_LAYO.
  ENDIF.
  GS_VARIANT_0100-REPORT = SY-REPID.
  GS_VARIANT_0100-USERNAME = SY-UNAME.
ENDFORM.
*&---------------------------------------------------------------------*
*& FORM SET_FIELDCAT_GRID_0100
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_0100 .
  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR3190TOP'
      I_INTERNAL_TABNAME     = 'GS_DISP'
    CHANGING
      CT_FIELDCAT            = LT_FCAT_SLIS
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.

  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT_SLIS
    IMPORTING
      ET_FIELDCAT_LVC = GT_FIELDCAT_0100[]
    TABLES
      IT_DATA         = GT_DISP
    EXCEPTIONS
      OTHERS          = 1.

  LOOP AT GT_FIELDCAT_0100 ASSIGNING FIELD-SYMBOL(<LS_FCAT>).
    CASE <LS_FCAT>-FIELDNAME.
      WHEN 'WERKS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F01. "플랜트
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-KEY = GC_X.
      WHEN 'WGBEZ'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F02. "자재그룹내역
        <LS_FCAT>-JUST = GC_L.
        <LS_FCAT>-KEY = GC_X.
      WHEN 'MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F03. "자재코드
        <LS_FCAT>-JUST = GC_C.
        <LS_FCAT>-KEY = GC_X.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F04. "자재내역
        <LS_FCAT>-JUST = GC_L.
      WHEN 'MTBEZ'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F05. "자재유형내역
        <LS_FCAT>-JUST = GC_L.
      WHEN 'LGORT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F06. "저장위치
        <LS_FCAT>-JUST = GC_C.
        CLEAR: <LS_FCAT>-KEY.
      WHEN 'CHARG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F07. "배치번호
        <LS_FCAT>-JUST = GC_C.
        CLEAR: <LS_FCAT>-KEY.
      WHEN 'TAGNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F08. "꼬리표번호
        <LS_FCAT>-JUST = GC_C.
        CLEAR: <LS_FCAT>-KEY.
      WHEN 'VBELN'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F09. "판매오더
        <LS_FCAT>-JUST = GC_C.
        CLEAR: <LS_FCAT>-KEY.
      WHEN 'POSNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F10. "판매오더품목
        <LS_FCAT>-JUST = GC_C.
        CLEAR: <LS_FCAT>-KEY.
      WHEN 'ZZYUSCD'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F55. "영업소
        <LS_FCAT>-JUST = GC_C.
      WHEN 'LIFNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F11. "공급업체번호
        <LS_FCAT>-JUST = GC_C.
        CLEAR: <LS_FCAT>-KEY.
      WHEN 'SOBKZ'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F12. "특별재고지시자
        <LS_FCAT>-JUST = GC_C.
        CLEAR: <LS_FCAT>-KEY.
      WHEN 'KALAB'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F13. "재고수량(가용)
        <LS_FCAT>-JUST = GC_R.
        <LS_FCAT>-EMPHASIZE	 = 'C500'.
        <LS_FCAT>-QFIELDNAME = 'MEINS'.
      WHEN 'MEINS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F14. "재고단위
        <LS_FCAT>-EMPHASIZE	 = 'C500'.
        <LS_FCAT>-JUST = GC_C.
      WHEN 'MGVRG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F15. "개별조장길이
        <LS_FCAT>-JUST = GC_C.
      WHEN 'FOSTCNT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F16. "조장수
        <LS_FCAT>-JUST = GC_C.
      WHEN 'REMAIN'.
*        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F24. "잔량
*        <LS_FCAT>-JUST = GC_R.
        <LS_FCAT>-TECH = GC_X.
      WHEN 'KAINS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F17. "재고수량(품질)
        <LS_FCAT>-JUST = GC_R.
        <LS_FCAT>-EMPHASIZE	 = 'C500'.
        <LS_FCAT>-QFIELDNAME = 'MEINS'.
      WHEN 'NES'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F39. "재질
        CLEAR <LS_FCAT>-KEY.
        <LS_FCAT>-EMPHASIZE	 = 'C400'.
        <LS_FCAT>-JUST = GC_C.
      WHEN 'KGU_URE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F40. "중량(가용)
        <LS_FCAT>-JUST = GC_R.
        <LS_FCAT>-EMPHASIZE	 = 'C400'.
        <LS_FCAT>-QFIELDNAME = 'MEINS'.
      WHEN 'KGU_INS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F41. "중량(품질)
        <LS_FCAT>-JUST = GC_R.
        <LS_FCAT>-EMPHASIZE	 = 'C400'.
        <LS_FCAT>-QFIELDNAME = 'MEINS'.
      WHEN 'MATKL'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F18. "자재그룹
        <LS_FCAT>-JUST = GC_C.
      WHEN 'MTART'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F19. "자재유형
        <LS_FCAT>-JUST = GC_C.
      WHEN 'BSTNK'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F20. "PO번호
        <LS_FCAT>-JUST = GC_C.
      WHEN 'ZPJNO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F21. "프로젝트번호
        <LS_FCAT>-JUST = GC_C.
      WHEN 'PRJNM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F22. "프로젝트내역
        <LS_FCAT>-JUST = GC_L.
      WHEN 'KASPE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F23. "재고수량(보류)
        <LS_FCAT>-JUST = GC_R.
        <LS_FCAT>-QFIELDNAME = 'MEINS'.
      WHEN 'AUFNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F25. "생산오더
        <LS_FCAT>-JUST = GC_C.
        CLEAR: <LS_FCAT>-KEY.
      WHEN 'EBELN'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F26. "구매오더
        <LS_FCAT>-JUST = GC_C.
        CLEAR: <LS_FCAT>-KEY.
      WHEN 'DSNAM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F27. "MRP관리자내역
        <LS_FCAT>-JUST = GC_L.
      WHEN 'DISPO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F28. "MRP관리자
        <LS_FCAT>-JUST = GC_C.
      WHEN 'BKTXT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F29. "비고
        <LS_FCAT>-JUST = GC_L.
      WHEN 'DRUM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F30. "투입드럼
        <LS_FCAT>-JUST = GC_C.
      WHEN 'MAKTX_DRUM'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F31. "투입드럼내역
        <LS_FCAT>-JUST = GC_L.
      WHEN 'COLOR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F32. "색상(BASE)
        <LS_FCAT>-JUST = GC_C.
      WHEN 'COLOR_STRIPE'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F33. "색상(STRIPE)
        <LS_FCAT>-JUST = GC_C.
      WHEN 'COLOR_STR_NO'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F34. "색상(STRIPE)수
        <LS_FCAT>-JUST = GC_C.
      WHEN 'LABST2'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F35. "기할당수량
        <LS_FCAT>-JUST = GC_R.
      WHEN 'LABST2_CNT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F36. "기할당조장수
        <LS_FCAT>-JUST = GC_C.
      WHEN 'LABST3'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F37. "미할당수량
        <LS_FCAT>-JUST = GC_R.
      WHEN 'LABST3_CNT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F38. "미할당조장수
        <LS_FCAT>-JUST = GC_C.
      WHEN 'ABGRU_T'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F52. "거부사유
        <LS_FCAT>-JUST = GC_C.
      WHEN 'MENGE01'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F53. "납품잔량
        <LS_FCAT>-JUST = GC_R.
*        <LS_FCAT>-NO_ZERO = ABAP_TRUE.
      WHEN 'VRKME'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = TEXT-F54. "판매단위
        <LS_FCAT>-JUST = GC_C.
      WHEN OTHERS.
        <LS_FCAT>-NO_OUT = GC_X.
    ENDCASE.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM EXCLUDE_OF_TOOLBAR_GRID_0100
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
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
*& FORM ADD_EXCLUDE_TOOLBAR_BUTTON
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*&      --> GT_EXCLUDE_0100
*&      --> CL_GUI_ALV_GRID=>MC_FC_LOC_UND
*&---------------------------------------------------------------------*
FORM ADD_EXCLUDE_TOOLBAR_BUTTON  TABLES   P_TABLE
                                 USING    P_VALUE.
  DATA: L_EXCLUDE TYPE UI_FUNC.
  L_EXCLUDE = P_VALUE.
  APPEND L_EXCLUDE TO P_TABLE.

ENDFORM.
*&---------------------------------------------------------------------*
*& FORM CALL_GRID_0100_DISPLAY
*&---------------------------------------------------------------------*
*& TEXT
*&---------------------------------------------------------------------*
*& -->  P1        TEXT
*& <--  P2        TEXT
*&---------------------------------------------------------------------*
FORM CALL_GRID_0100_DISPLAY .
  CALL METHOD GO_GRID_0100->SET_TABLE_FOR_FIRST_DISPLAY
    EXPORTING
      IS_LAYOUT            = GS_LAYOUT_0100
      IT_TOOLBAR_EXCLUDING = GT_EXCLUDE_0100
      IS_VARIANT           = GS_VARIANT_0100
      I_SAVE               = GC_X
    CHANGING
      IT_OUTTAB            = GT_DISP
      IT_FIELDCATALOG      = GT_FIELDCAT_0100.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_TRANS_B
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_TRANS_B .
  DATA: LT_ROW_NO TYPE LVC_T_ROID WITH HEADER LINE,
        L_ANSWER  TYPE CHAR01.

  FIELD-SYMBOLS: <FS_S> LIKE GS_DISP.

  CLEAR: L_ANSWER.

  PERFORM SEL_ROW_RTN TABLES LT_ROW_NO
                      USING  GO_GRID_0100.

  IF LT_ROW_NO[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'W'
       WITH TEXT-M01. "재고 비활성화 처리할 레코드를 선택하세요.
    EXIT.
  ENDIF.

  IF LINES( LT_ROW_NO ) > 1.
    MESSAGE S003 DISPLAY LIKE GC_W
       WITH TEXT-M02. "한 건의 레코드씩 처리 가능합니다.
    EXIT.
  ENDIF.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = TEXT-T01 "재고 비활성
      TEXT_QUESTION         = TEXT-T02 "재고 비활성을 진행하시겠습니까?
      DISPLAY_CANCEL_BUTTON = SPACE
    IMPORTING
      ANSWER                = L_ANSWER.

  IF L_ANSWER = '1'.
    LOOP AT LT_ROW_NO.
      READ TABLE GT_DISP ASSIGNING <FS_S> INDEX LT_ROW_NO-ROW_ID.

      IF <FS_S>-VBELN IS NOT INITIAL.
        MESSAGE S000 DISPLAY LIKE 'E' WITH TEXT-M03. "판매오더 재고는 비활성 처리 불가합니다.
        EXIT.
      ENDIF.

      IF <FS_S>-KALAB EQ 0.
        MESSAGE S000 DISPLAY LIKE 'E' WITH TEXT-M04. "비활성할 재고가 없습니다.
        EXIT.
      ENDIF.

      CLEAR: GV_MENGE, GV_CHK.
      CALL SCREEN '0200' STARTING AT 20 10 ENDING AT 50 10.

      CHECK GV_CHK EQ 'X'.
      IF GV_MENGE > <FS_S>-KALAB.
        MESSAGE S000 DISPLAY LIKE 'E' WITH TEXT-M06. "재고가 부족합니다.
        EXIT.
      ENDIF.

      PERFORM EXEC_STOCK_MOVE USING <FS_S>.
    ENDLOOP.

    " REFRESH DISPLAY
    PERFORM REF_ALV_RTN USING GO_GRID_0100.

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form SEL_ROW_RTN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_ROW_NO
*&      --> GO_GRID_0100
*&---------------------------------------------------------------------*
FORM SEL_ROW_RTN  TABLES PT_ROW_NO TYPE LVC_T_ROID
                  USING  PR_ALV TYPE REF TO CL_GUI_ALV_GRID.

  DATA: LT_INDEX_ROWS TYPE LVC_T_ROW,
        LT_ROW_NO     TYPE LVC_T_ROID.

*--------------------------------------------------------------------*

  CLEAR: LT_INDEX_ROWS, LT_INDEX_ROWS[],
         LT_ROW_NO, LT_ROW_NO[].

  PR_ALV->GET_SELECTED_ROWS(
    IMPORTING
      ET_INDEX_ROWS = LT_INDEX_ROWS
      ET_ROW_NO     = LT_ROW_NO ).

  PT_ROW_NO[] = LT_ROW_NO[].

ENDFORM.
*&---------------------------------------------------------------------*
*& Form REF_ALV_RTN
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID_0100
*&---------------------------------------------------------------------*
FORM REF_ALV_RTN  USING    PO_GRID TYPE REF TO CL_GUI_ALV_GRID.

  DATA LS_STABLE TYPE LVC_S_STBL.

  LS_STABLE-ROW = 'X'.
  LS_STABLE-COL = 'X'.

*  CASE PO_GRID.
*    WHEN GO_GRID_0100.
*      CALL METHOD PO_GRID->SET_FRONTEND_LAYOUT
*        EXPORTING
*          IS_LAYOUT = GS_LAYOUT_0100.
*
*  ENDCASE.

  CALL METHOD PO_GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
      IS_STABLE = LS_STABLE
    EXCEPTIONS
      FINISHED  = 1
      OTHERS    = 2.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXEC_STOCK_MOVE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_S>
*&---------------------------------------------------------------------*
FORM EXEC_STOCK_MOVE  USING    P_LINE LIKE GS_DISP.

  DATA: LS_HEADER    TYPE BAPI2017_GM_HEAD_01,
        LT_ITEM      TYPE TABLE OF BAPI2017_GM_ITEM_CREATE,
        LV_CODE      TYPE BAPI2017_GM_CODE VALUE '04',
        LV_DOCUMENT  TYPE BAPI2017_GM_HEAD_RET-MAT_DOC,
        LV_YEAR      TYPE BAPI2017_GM_HEAD_RET-DOC_YEAR,
        LS_GMHEADRET LIKE BAPI2017_GM_HEAD_RET,
        LT_RETURN    TYPE TABLE OF BAPIRET2.

  DATA: LV_BWART TYPE BWART.

  CLEAR: LS_HEADER, LT_ITEM.

  LS_HEADER = VALUE #( PSTNG_DATE = SY-DATUM
                       DOC_DATE   = SY-DATUM
                       HEADER_TXT = '재고 비활성화(ZGTPPR3190)' ).

  CLEAR: LV_BWART.
  CASE GV_OK_CODE.
    WHEN 'TRS_B'.
      LV_BWART = '344'.
    WHEN 'TRS_BC'.
      LV_BWART = '343'.
  ENDCASE.

  LT_ITEM = VALUE #( ( MATERIAL       = P_LINE-MATNR
                       PLANT          = P_LINE-WERKS
                       STGE_LOC       = P_LINE-LGORT
                       BATCH          = P_LINE-CHARG
                       MOVE_TYPE      = LV_BWART
                       MOVE_PLANT     = P_LINE-WERKS
                       MOVE_STLOC     = P_LINE-LGORT
                       MOVE_BATCH     = P_LINE-CHARG
                       STCK_TYPE      = SPACE
                       ENTRY_UOM      = P_LINE-MEINS
                       ENTRY_QNT      = GV_MENGE ) ).

  CLEAR: LV_DOCUMENT, LV_YEAR, LS_GMHEADRET, LT_RETURN.
  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
    EXPORTING
      GOODSMVT_HEADER  = LS_HEADER
      GOODSMVT_CODE    = LV_CODE
    IMPORTING
      GOODSMVT_HEADRET = LS_GMHEADRET
      MATERIALDOCUMENT = LV_DOCUMENT
      MATDOCUMENTYEAR  = LV_YEAR
    TABLES
      GOODSMVT_ITEM    = LT_ITEM
      RETURN           = LT_RETURN.

  IF LS_GMHEADRET IS INITIAL.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    READ TABLE LT_RETURN INTO DATA(LS_RETURN) WITH KEY TYPE = GC_E.
    IF LS_RETURN-MESSAGE IS INITIAL.
      CASE GV_OK_CODE.
        WHEN 'TRS_B'.
          LS_RETURN-MESSAGE = TEXT-M08. "재고 비활성 처리에 실패 하였습니다.
        WHEN 'TRS_BC'.
          LS_RETURN-MESSAGE = TEXT-M10. "재고 비활성 취소 처리에 실패 하였습니다.
      ENDCASE.
    ENDIF.

    MESSAGE S000 DISPLAY LIKE 'E'
       WITH LS_RETURN-MESSAGE. "재고 비활성 처리에 실패 하였습니다.

    CLEAR: LS_RETURN.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = GC_X.

    CASE GV_OK_CODE.
      WHEN 'TRS_B'.
        MESSAGE S000 WITH TEXT-M07. "재고 비활성 처리에 성공 하였습니다.

        P_LINE-KALAB = P_LINE-KALAB - GV_MENGE.
        P_LINE-KASPE = P_LINE-KASPE + GV_MENGE.

      WHEN 'TRS_BC'.
        MESSAGE S000 WITH TEXT-M09. "재고 비활성 취소 처리에 성공 하였습니다.

        P_LINE-KALAB = P_LINE-KALAB + GV_MENGE.
        P_LINE-KASPE = P_LINE-KASPE - GV_MENGE.

    ENDCASE.

    WAIT UP TO '0.5' SECONDS.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROCESS_TRANS_BC
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROCESS_TRANS_BC .
  DATA: LT_ROW_NO TYPE LVC_T_ROID WITH HEADER LINE,
        L_ANSWER  TYPE CHAR01.

  FIELD-SYMBOLS: <FS_S> LIKE GS_DISP.

  CLEAR: L_ANSWER.

  PERFORM SEL_ROW_RTN TABLES LT_ROW_NO
                      USING  GO_GRID_0100.

  IF LT_ROW_NO[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'W'
       WITH TEXT-M01. "재고 비활성화 처리할 레코드를 선택하세요.
    EXIT.
  ENDIF.

  IF LINES( LT_ROW_NO ) > 1.
    MESSAGE S003 DISPLAY LIKE GC_W
       WITH TEXT-M02. "한 건의 레코드씩 처리 가능합니다.
    EXIT.
  ENDIF.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = TEXT-T03 "재고 비활성 취소
      TEXT_QUESTION         = TEXT-T04 "재고 비활성 취소를 진행하시겠습니까?
      DISPLAY_CANCEL_BUTTON = SPACE
    IMPORTING
      ANSWER                = L_ANSWER.

  IF L_ANSWER = '1'.
    LOOP AT LT_ROW_NO.
      READ TABLE GT_DISP ASSIGNING <FS_S> INDEX LT_ROW_NO-ROW_ID.

      IF <FS_S>-KASPE EQ 0.
        MESSAGE S000 DISPLAY LIKE 'E' WITH TEXT-M05. "취소할 비활성 재고가 없습니다.
        EXIT.
      ENDIF.

      CLEAR: GV_MENGE.
      CALL SCREEN '0200' STARTING AT 20 10 ENDING AT 50 10.

      IF GV_MENGE > <FS_S>-KASPE.
        MESSAGE S000 DISPLAY LIKE 'E' WITH TEXT-M06. "재고가 부족합니다.
        EXIT.
      ENDIF.

      PERFORM EXEC_STOCK_MOVE USING <FS_S>.
    ENDLOOP.

    " REFRESH DISPLAY
    PERFORM REF_ALV_RTN USING GO_GRID_0100.

  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_REFRESH
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_REFRESH .

  REFRESH GT_DISP.
  PERFORM GET_DATA.
  PERFORM MODIFY_DATA.

  " REFRESH DISPLAY
  PERFORM REF_ALV_RTN USING GO_GRID_0100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_CONV_STOCK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_CONV_STOCK .

  DATA: LT_ROWS TYPE LVC_T_ROW.
  DATA : LT_INPUT TYPE TABLE OF ZGTPPSIF0061.
  DATA : LT_RESULT TYPE TABLE OF ZGTPPSIF0062.
  DATA : LV_SYSTEM_ID TYPE CHAR4.

  GO_GRID_0100->GET_SELECTED_ROWS(
    IMPORTING
      ET_INDEX_ROWS = LT_ROWS ).

  DELETE LT_ROWS WHERE INDEX = 0.

  IF LT_ROWS[] IS INITIAL.
    RETURN.
  ENDIF.

  REFRESH GT_RESULT_0400.

  LOOP AT LT_ROWS INTO DATA(LS_ROWS).
    READ TABLE GT_DISP INTO DATA(LS_MAIN) INDEX LS_ROWS-INDEX.
    IF LS_MAIN-KAINS = 0.
      MESSAGE S000 DISPLAY LIKE 'E' WITH TEXT-M11. "품질검사재고에 대해서만 가용 처리 가능합니다.
      RETURN.
    ENDIF.

    CASE LS_MAIN-MTBEZ.
      WHEN 'Cable 제품' OR 'Cable 반제품' OR '완제품' OR '반제품'.
      WHEN OTHERS.
        MESSAGE S000 DISPLAY LIKE 'E' WITH TEXT-M12. " 반제품/제품의 품질재고에 대해서만 가용 처리 가능합니다.
        RETURN.
    ENDCASE.

    CLEAR GS_RESULT_0400.
    MOVE-CORRESPONDING LS_MAIN TO GS_RESULT_0400.
    APPEND GS_RESULT_0400 TO GT_RESULT_0400.

  ENDLOOP.

  IF GT_RESULT_0400 IS NOT INITIAL.
    CLEAR GS_HERDER_0300.
    GS_HERDER_0300-BUDAT = SY-DATUM.
    GS_HERDER_0300-LGORT = '3410'.

    CLEAR GV_CHK_SAVE_0300.
    CALL SCREEN '0300' STARTING AT 5 5 ENDING AT 60 8.

    IF GV_CHK_SAVE_0300 = ABAP_TRUE.
      LOOP AT GT_RESULT_0400 ASSIGNING FIELD-SYMBOL(<LS_RESULT>).
        REFRESH : LT_INPUT, LT_RESULT.
        APPEND INITIAL LINE TO LT_INPUT ASSIGNING FIELD-SYMBOL(<LS_INPUT>).
        <LS_INPUT>-ZSERNO = |{ SY-DATUM }9999|.
        <LS_INPUT>-WERKS = <LS_RESULT>-WERKS.
        <LS_INPUT>-SPGCD = <LS_RESULT>-DISPO+0(2).
        <LS_INPUT>-MATNR = <LS_RESULT>-MATNR.
        <LS_INPUT>-BUDAT = GS_HERDER_0300-BUDAT.
        <LS_INPUT>-LGORT = <LS_RESULT>-LGORT.
        <LS_INPUT>-CHARG = <LS_RESULT>-CHARG.
        <LS_INPUT>-DECISION = 'OK'.
        <LS_INPUT>-LGORT_F = GS_HERDER_0300-LGORT.
        <LS_INPUT>-MENGE = <LS_RESULT>-KAINS.
        <LS_INPUT>-MEINS = <LS_RESULT>-MEINS.
        <LS_INPUT>-DECISION = 'OK'.
        <LS_INPUT>-PERNR = SY-UNAME.
        <LS_INPUT>-NAME = ''.
        <LS_INPUT>-C_MJAHR = ''.
        <LS_INPUT>-C_MBLNR = ''.
        IF <LS_RESULT>-VBELN IS NOT INITIAL.
          <LS_INPUT>-VBELN = <LS_RESULT>-VBELN.
          <LS_INPUT>-POSNR = <LS_RESULT>-POSNR.
        ENDIF.

        CLEAR LV_SYSTEM_ID.
        LV_SYSTEM_ID = '3190'.
*        CASE <LS_RESULT>-WERKS.
*          WHEN '6500'.
*            LV_SYSTEM_ID = 'KGPM'.
*          WHEN '6600'.
*            LV_SYSTEM_ID = 'KGOM'.
*        ENDCASE.

        CALL FUNCTION 'ZGTPP_IF_I_QC_USAGE_DECSION'
          EXPORTING
            I_MODE      = 'P'
            I_SYSTEM_ID = LV_SYSTEM_ID
          IMPORTING
            ZO_RESULT   = <LS_RESULT>-RESULT
            ZO_MESSAGE  = <LS_RESULT>-MESSAGE
          TABLES
            IT_ITEM     = LT_INPUT
            OT_RESULT   = LT_RESULT.

        READ TABLE LT_RESULT INTO DATA(LS_RESULT) WITH KEY ZERP_STAT = 'E'.
        IF SY-SUBRC EQ 0.
          <LS_RESULT>-STATUS = ICON_LED_RED.
          <LS_RESULT>-MESSAGE = LS_RESULT-ZERP_MESSAGE.
        ELSE.
          CLEAR LS_RESULT.
          READ TABLE LT_RESULT INTO LS_RESULT WITH KEY ZERP_STAT = 'S'.
          <LS_RESULT>-STATUS = ICON_LED_GREEN.
          <LS_RESULT>-MESSAGE = LS_RESULT-ZERP_MESSAGE.
        ENDIF.
      ENDLOOP.

      CALL SCREEN '0400' STARTING AT 5 5 ENDING AT 120 10.

      PERFORM PROC_REFRESH.

    ENDIF.


  ENDIF.


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

  CREATE OBJECT GO_CONTAIN_0400
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


  CREATE OBJECT GO_GRID_0400
    EXPORTING
      I_PARENT      = GO_CONTAIN_0400
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
  GS_LAYOUT_0400-NO_ROWINS = ABAP_TRUE.
  GS_LAYOUT_0400-NO_ROWMARK   = ABAP_TRUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_FIELDCAT_GRID_0400
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_FIELDCAT_GRID_0400 .

  DATA : LT_FCAT_SLIS TYPE SLIS_T_FIELDCAT_ALV.
  CALL FUNCTION 'REUSE_ALV_FIELDCATALOG_MERGE'
    EXPORTING
      I_PROGRAM_NAME         = SY-REPID
      I_INCLNAME             = 'ZGTPPR3190TOP'
      I_INTERNAL_TABNAME     = 'GS_RESULT_0400'
      I_BYPASSING_BUFFER     = ABAP_TRUE
    CHANGING
      CT_FIELDCAT            = LT_FCAT_SLIS
    EXCEPTIONS
      INCONSISTENT_INTERFACE = 1
      PROGRAM_ERROR          = 2
      OTHERS                 = 3.

  REFRESH GT_FIELDCAT_0400.

*-- lt_fieldcat의 구조체를 pt_fcat의 구조체로 변경
  CALL FUNCTION 'LVC_TRANSFER_FROM_SLIS'
    EXPORTING
      IT_FIELDCAT_ALV = LT_FCAT_SLIS
    IMPORTING
      ET_FIELDCAT_LVC = GT_FIELDCAT_0400[]
    TABLES
      IT_DATA         = GT_RESULT_0400
    EXCEPTIONS
      OTHERS          = 1.

  READ TABLE GT_FIELDCAT_0400 ASSIGNING FIELD-SYMBOL(<LS_FCAT>) WITH KEY FIELDNAME = 'RESULT'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0400 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'RESULT'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = <LS_FCAT>-FIELDNAME.
    <LS_FCAT>-COL_POS = 1.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '2'.
    <LS_FCAT>-NO_OUT = ABAP_TRUE.
  ENDIF.

  READ TABLE GT_FIELDCAT_0400 ASSIGNING <LS_FCAT> WITH KEY FIELDNAME = 'MESSAGE'.
  IF SY-SUBRC NE 0.
    APPEND INITIAL LINE TO GT_FIELDCAT_0400 ASSIGNING <LS_FCAT>.
    <LS_FCAT>-FIELDNAME = 'MESSAGE'.
    <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '메시지'(F50).
    <LS_FCAT>-COL_POS = 3.
    <LS_FCAT>-DATATYPE = 'CHAR'.
    <LS_FCAT>-DD_OUTLEN = '100'.
    <LS_FCAT>-JUST = 'L'.
  ENDIF.

  LOOP AT GT_FIELDCAT_0400 ASSIGNING <LS_FCAT>.
    CLEAR <LS_FCAT>-KEY.
    CASE   <LS_FCAT>-FIELDNAME.
      WHEN 'STATUS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '상태'(f51).
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
        <LS_FCAT>-JUST = 'C'.
      WHEN 'MESSAGE'.
        <LS_FCAT>-KEY = ABAP_TRUE.
        <LS_FCAT>-FIX_COLUMN = ABAP_TRUE.
      WHEN 'WERKS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '플랜트'(f01).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'DISPO'.
        <LS_FCAT>-NO_OUT = ABAP_TRUE.
      WHEN 'MATNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '자재코드'(f03).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'MAKTX'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '자재내역'(f04).
        <LS_FCAT>-JUST = 'L'.
      WHEN 'LGORT'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '저장위치'(f06).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'CHARG'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '배치번호'(f07).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'TAGNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '꼬리표 번호'(f08).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'VBELN'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '판매오더'(f09).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'POSNR'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '판매오더 품목'(f10).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'KALAB'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '재고수량(가용)'(f13).
        <LS_FCAT>-JUST = 'R'.
      WHEN 'MEINS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '재고단위'(f14).
        <LS_FCAT>-JUST = 'C'.
      WHEN 'KAINS'.
        <LS_FCAT>-REPTEXT = <LS_FCAT>-COLTEXT = <LS_FCAT>-TOOLTIP = '재고수량(품질)'(f17).
        <LS_FCAT>-JUST = 'R'.
    ENDCASE.

  ENDLOOP.

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

  REFRESH GT_EXCLUDE_0400.

  PERFORM ADD_EXCLUDE_TOOLBAR_BUTTON TABLES GT_EXCLUDE_0400
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
      IT_OUTTAB            = GT_RESULT_0400
      IT_FIELDCATALOG      = GT_FIELDCAT_0400.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALL_1320_PROGRAM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CALL_1320_PROGRAM TABLES PT_LIST STRUCTURE ZGTSDS1110.

  RANGES : LR_VBELN FOR VBAK-VBELN.
  RANGES : LR_EDATU FOR VBEP-EDATU.

  CLEAR LR_EDATU.
  LR_EDATU-SIGN = 'I'.
  LR_EDATU-OPTION = 'BT'.

  CALL FUNCTION '/BEV4/PLPS__ADD_MONTH_TO_DATE'
    EXPORTING
      MONTHS  = '-6'
      OLDDATE = SY-DATUM
    IMPORTING
      NEWDATE = LR_EDATU-LOW.

  CALL FUNCTION '/BEV4/PLPS__ADD_MONTH_TO_DATE'
    EXPORTING
      MONTHS  = '6'
      OLDDATE = SY-DATUM
    IMPORTING
      NEWDATE = LR_EDATU-HIGH.

  APPEND LR_EDATU.


  LOOP AT GT_DATA INTO DATA(LS_DATA).
    IF LS_DATA-VBELN IS NOT INITIAL.
      CLEAR LR_VBELN.
      LR_VBELN-SIGN = 'I'.
      LR_VBELN-OPTION = 'EQ'.
      LR_VBELN-LOW = LS_DATA-VBELN.
      COLLECT LR_VBELN.
    ENDIF.
  ENDLOOP.

  SORT LR_VBELN BY LOW.

  SUBMIT ZGTSDR1320 WITH RA1 = 'X'
                                WITH SO_EDATU IN LR_EDATU
                                WITH SO_VBELN IN LR_VBELN
                               WITH P_CALL = 'X'      AND RETURN.

  IMPORT PT_LIST FROM MEMORY ID 'GO_1320_LIST'.  "변수이름이 동일해야 함.
  FREE MEMORY ID 'GO_1320_LIST'.

ENDFORM.
