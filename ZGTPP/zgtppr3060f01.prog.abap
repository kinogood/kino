*&---------------------------------------------------------------------*
*& Include          ZGTPPR3060F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form get_data
*&---------------------------------------------------------------------*
FORM GET_DATA .

  IF S_LIFNR[] IS INITIAL. "공급업체코드"를 입력한 안한경우
    "---판매오더 재고 추출
    SELECT A~MATNR, A~MTART, A~MATKL, A~MEINS,
           B~WERKS, B~LGORT, B~CHARG, B~SOBKZ, B~VBELN,
           B~POSNR, B~KALAB, B~KAINS, B~KASPE,
           C~ZPJNO, C~BSTNK
      FROM MARA AS A INNER JOIN MSKA AS B
                           ON A~MATNR = B~MATNR
                     INNER JOIN VBAK AS C
                           ON B~VBELN = C~VBELN
      WHERE B~WERKS = @P_WERKS "플랜트
       AND B~MATNR IN @S_MATNR"자재코드
       AND A~MTART IN @S_MTART"자재유형
       AND A~MATKL IN @S_MATKL"자재그룹
       AND B~LGORT IN @S_LGORT "저장위치
       AND B~CHARG IN @S_CHARG"배치번호
       AND C~ZPJNO IN @S_PRJNO "프로젝트번호
       AND C~BSTNK IN @S_PRDNO "제조지시번호
       AND B~VBELN IN @S_VBELN "판매오더
       AND B~POSNR IN @S_POSNR"판매오더 아이템
       AND ( B~KALAB > 0 OR B~KAINS > 0 OR B~KASPE > 0 )
      INTO CORRESPONDING FIELDS OF TABLE @GT_DATA1.
    SORT GT_DATA1 BY WERKS MATNR.
  ENDIF.

  " ---공급업체 재고 추출
  " 저장위치","판매오더" 혹은 "판매오더 아이템" 를
  " 입력이 안된 경우에만 수행
  " 프로젝트 번호 제조지시 번호 입력 안된경우도  추가
  IF S_LGORT[] IS INITIAL
     AND S_VBELN[] IS INITIAL
     AND S_POSNR[] IS INITIAL
     AND S_PRJNO[] IS INITIAL
     AND S_PRDNO[] IS INITIAL
    .
    SELECT A~MATNR, A~MTART, A~MATKL, A~MEINS,
           B~WERKS, B~CHARG, B~SOBKZ, B~LIFNR,
           B~LBLAB AS KALAB,
           B~LBINS AS KAINS
      FROM MARA AS A INNER JOIN MSLB AS B
                           ON A~MATNR = B~MATNR
      WHERE B~WERKS = @P_WERKS "플랜트
       AND B~MATNR IN @S_MATNR"자재코드
       AND A~MTART IN @S_MTART"자재유형
       AND A~MATKL IN @S_MATKL"자재그룹
       AND B~CHARG IN @S_CHARG"배치번호
*       and  @s_prjno 프로젝트번호 조건 추가 예정(TBD)
*       and  @s_prdno 제조지시번호 조건 추가 예정(TBD)
       AND B~LIFNR IN @S_LIFNR"공급업체코드
      INTO CORRESPONDING FIELDS OF TABLE @GT_DATA2.
    SORT GT_DATA BY WERKS MATNR.
  ENDIF.

  "---배치 재고 추출
  "공급업체코드 "판매오더" 혹은 "판매오더 아이템" 를
  " 입력이 안된 경우에만 수행
  " 프로젝트 번호 제조지시 번호 입력 안된경우도  추가
  IF S_LIFNR[] IS INITIAL
     AND S_VBELN[] IS INITIAL
     AND S_POSNR[] IS INITIAL
     AND S_PRJNO[] IS INITIAL
     AND S_PRDNO[] IS INITIAL
    .
    SELECT A~MATNR, A~MTART, A~MATKL, A~MEINS,
           B~WERKS, B~LGORT, B~CHARG,
           B~CLABS AS KALAB,
           B~CINSM AS KAINS,
           B~CSPEM AS KASPE
      FROM MARA AS A INNER JOIN MCHB AS B
                           ON A~MATNR = B~MATNR
      WHERE B~WERKS = @P_WERKS "플랜트
       AND B~MATNR IN @S_MATNR"자재코드
       AND A~MTART IN @S_MTART"자재유형
       AND A~MATKL IN @S_MATKL"자재그룹
       AND B~LGORT IN @S_LGORT"저장위치
       AND B~CHARG IN @S_CHARG"배치번호
*         and  @s_prjno 프로젝트번호 조건 추가 예정(TBD)
*         and  @s_prdno 제조지시번호 조건 추가 예정(TBD)
       AND ( B~CLABS > 0 OR B~CINSM > 0 OR B~CSPEM > 0 )
      INTO CORRESPONDING FIELDS OF TABLE @GT_DATA3.
    SORT GT_DATA3 BY WERKS MATNR.
  ENDIF.

  "---플랜트 재고 추출
  " 배치번호 "판매오더" 혹은 "판매오더 아이템" 를
  " 입력이 안된 경우에만 수행
  " 프로젝트 번호 제조지시 번호 입력 안된경우도  추가
  IF S_CHARG[] IS INITIAL
     AND S_VBELN[] IS INITIAL
     AND S_POSNR[] IS INITIAL
     AND S_PRJNO[] IS INITIAL
     AND S_PRDNO[] IS INITIAL
    .
    SELECT A~MATNR, A~MTART, A~MATKL, A~MEINS,
           B~WERKS, B~LGORT,
           B~LABST AS KALAB,
           B~INSME AS KAINS,
           B~SPEME AS KASPE
      FROM MARA AS A INNER JOIN MARD AS B
                           ON A~MATNR = B~MATNR
      WHERE B~WERKS = @P_WERKS "플랜트
       AND B~MATNR IN @S_MATNR"자재코드
       AND A~MTART IN @S_MTART"자재유형
       AND A~MATKL IN @S_MATKL"자재그룹
       AND B~LGORT IN @S_LGORT"저장위치
       AND A~XCHPF <> 'X'  "배치재고는 제외 2025.07.31 PYS
       AND ( B~LABST > 0 OR B~INSME > 0 OR B~SPEME > 0 )
      INTO CORRESPONDING FIELDS OF TABLE @GT_DATA4.
    SORT GT_DATA4 BY WERKS MATNR.
  ENDIF.

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

*  완제품 외주 품목의 공급업체코드 추출
  DATA : BEGIN OF LS_CHK_BSTNK,
           BSTNK TYPE VBAK-BSTNK,
         END OF LS_CHK_BSTNK.
  DATA : LT_CHK_BSTNK LIKE TABLE OF LS_CHK_BSTNK.

  LT_CHK_BSTNK = VALUE #( FOR LW_DATA IN GT_DATA WHERE ( MTART = 'FERT'
                                                                               AND   BSTNK IS NOT INITIAL )
                                     ( BSTNK = LW_DATA-BSTNK ) ).
  SORT LT_CHK_BSTNK BY BSTNK.
  DELETE ADJACENT DUPLICATES FROM LT_CHK_BSTNK COMPARING BSTNK.
  IF LT_CHK_BSTNK IS NOT INITIAL.
    SELECT DISTINCT
               B~JOB_NO AS BSTNK,
               D~LIFNR AS LIFNR_PROJ,
               F~NAME1 AS NAME1_PROJ,
               B~LINE_NO,                         "SRM2512-00220
               B~SERIAL_INFO                    "SRM2512-00220
      FROM @LT_CHK_BSTNK AS A
      INNER JOIN ZGTMM_CV_BD_JOBLS_PRPO AS B
                                    ON B~JOB_NO = A~BSTNK
      INNER JOIN EKPO AS C
                                    ON C~EBELN = B~EBELN
                                   AND C~EBELP = B~EBELP
      INNER JOIN EKKO AS D ON D~EBELN = C~EBELN
      INNER JOIN MARA AS E ON E~MATNR = C~MATNR
                                    AND E~MTART = 'FERT'
      INNER JOIN LFA1 AS F ON F~LIFNR = D~LIFNR
      ORDER BY B~JOB_NO
      INTO CORRESPONDING FIELDS OF TABLE @GT_BSTNK_INFOR.
  ENDIF.


  " 플랜트 내역 gt_t001w
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE GT_T001W
    FROM T001W
    FOR ALL ENTRIES IN GT_DATA
   WHERE WERKS = GT_DATA-WERKS.
  SORT GT_T001W BY WERKS..

  "자재내역 발췌
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE GT_MAKT
    FROM MAKT
    FOR ALL ENTRIES IN GT_DATA
   WHERE MATNR = GT_DATA-MATNR
     AND SPRAS = SY-LANGU.
  SORT GT_MAKT BY MATNR .

  " 자재 유형 내역 gs_t134t
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE GT_T134T
    FROM T134T
    FOR ALL ENTRIES IN GT_DATA
   WHERE MTART = GT_DATA-MTART
     AND SPRAS = SY-LANGU.
  SORT GT_T134T BY MTART .

  " 자재 그룹 내역 gt_t023t
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE GT_T023T
    FROM T023T
    FOR ALL ENTRIES IN GT_DATA
   WHERE MATKL = GT_DATA-MATKL
     AND SPRAS = SY-LANGU.
  SORT GT_T023T BY MATKL .

  " 저장 위치 내역 추출

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE GT_T001L
    FROM T001L
    FOR ALL ENTRIES IN GT_DATA
   WHERE WERKS = GT_DATA-WERKS
     AND LGORT = GT_DATA-LGORT.
  SORT GT_T001L BY WERKS .


  " 업체명 추출

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


  "제조지시 내역 추출
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE GT_ZGTEDT2121
    FROM ZGTEDT2121
    FOR ALL ENTRIES IN GT_DATA
   WHERE ZSYSTEM_ID = 'KBDM'
     AND ZWERKS = GT_DATA-WERKS
     AND ZJOB_NO = GT_DATA-BSTNK.
  SORT GT_ZGTEDT2121 BY ZJOB_NO .

  "배치속성추출
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE GT_MCH1
    FROM MCH1
    FOR ALL ENTRIES IN GT_DATA
   WHERE MATNR = GT_DATA-MATNR
*     AND werks = gt_data-werks
     AND CHARG = GT_DATA-CHARG.
  SORT GT_MCH1 BY MATNR CHARG.

  " 특성 필드 add data 추출
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE GT_T1010
    FROM ZGTPPT1010
   WHERE MODULE_KIND = 'PP'
     AND CODEGRP     = '4020'.

  "VBAP
  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE GT_VBAP
    FROM VBAP
    FOR ALL ENTRIES IN GT_DATA
   WHERE VBELN = GT_DATA-VBELN
     AND POSNR = GT_DATA-POSNR.
  SORT GT_VBAP BY VBELN POSNR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_screen_attribute
*&---------------------------------------------------------------------*
FORM SET_SCREEN_ATTRIBUTE .

ENDFORM.

*&---------------------------------------------------------------------*
*& Form exit_program
*&---------------------------------------------------------------------*
FORM EXIT_PROGRAM .

  CALL METHOD GO_DOCKING_CONTAINER->FREE.
  CLEAR : GO_DOCKING_CONTAINER, GO_GRID_0100.
  CALL METHOD CL_GUI_CFW=>FLUSH.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form send_data
*&---------------------------------------------------------------------*
FORM SEND_DATA .

ENDFORM.
*&---------------------------------------------------------------------*
*& Form data_conversion
*&---------------------------------------------------------------------*
FORM DATA_CONVERSION TABLES PT_OT_TAB STRUCTURE ZGTPPSIF0015.

  LOOP AT PT_OT_TAB ASSIGNING FIELD-SYMBOL(<LS_ITAB>).
    "자재번호
    CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
      EXPORTING
        INPUT  = <LS_ITAB>-MATNR
      IMPORTING
        OUTPUT = <LS_ITAB>-MATNR.

  ENDLOOP.

ENDFORM.

*&---------------------------------------------------------------------*
*& Form select_alv_variant
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      <-- P_LAYO
*&---------------------------------------------------------------------*
FORM SELECT_ALV_VARIANT   CHANGING PV_LAYO TYPE DISVARIANT-VARIANT.

  DATA:
    LS_VARIANT TYPE DISVARIANT.

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
*& Form modify_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MODIFY_DATA .
  DATA : LV_TAGNR(17).
  DATA : LV_IDX          TYPE NUMC2.
  DATA : LV_CHARACT(9),
         LV_STR(19).
  DATA : LV_OBJECT    TYPE VBAP-MATNR.

  DATA : LV_KALAB_SUM TYPE  MSKA-KALAB,  "재고수량(가용)
         LV_KAINS_SUM TYPE  MSKA-KAINS,  "재고수량(품질)
         LV_KASPE_SUM TYPE  MSKA-KASPE.  "재고수량(보류)

  FIELD-SYMBOLS : <FS_TABLE> TYPE ANY TABLE,
                  <FS_FIELD> TYPE ANY.

  SORT GT_BSTNK_INFOR BY BSTNK LINE_NO SERIAL_INFO.  "SRM2512-00220

  LOOP AT GT_DATA INTO GS_DATA.

    GS_DISP-WERKS = GS_DATA-WERKS. "플랜트
    " 플랜트명
    CLEAR GT_T001W.
    READ TABLE GT_T001W WITH KEY WERKS = GS_DATA-WERKS.
    IF SY-SUBRC = 0.
      GS_DISP-NAME1 = GT_T001W-NAME1.
    ENDIF.

    "자재코드 내역
    CLEAR GT_MAKT.
    READ TABLE GT_MAKT WITH KEY MATNR = GS_DATA-MATNR.
    IF SY-SUBRC = 0.
      GS_DISP-MAKTX = GT_MAKT-MAKTX.
    ENDIF.

    "배치 속성 내역
    CLEAR GT_MCH1.
    READ TABLE GT_MCH1 WITH KEY  MATNR = GS_DATA-MATNR
*                                 werks = gs_data-werks
                                 CHARG = GS_DATA-CHARG.
    IF SY-SUBRC = 0.
      GS_DISP-ZZLINE_NO = GT_MCH1-ZZLINE_NO.
      GS_DISP-ZZSERIAL_INFO = GT_MCH1-ZZSERIAL_INFO.
    ENDIF.

    CLEAR : GT_CHAR[], GT_CHAR2[].

    IF GS_DATA-CHARG IS NOT INITIAL AND P_R1 = 'X'..
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
    ELSE.
      IF GS_DATA-VBELN IS NOT INITIAL
         AND GS_DATA-CHARG IS INITIAL
         AND P_R1 = 'X'.
        READ TABLE GT_VBAP INTO GS_VBAP WITH KEY VBELN = GS_DATA-VBELN
                                                 POSNR = GS_DATA-POSNR
                                                 BINARY SEARCH.
        IF SY-SUBRC = 0.
          LV_OBJECT = GS_VBAP-MATNR.
        ENDIF.

        CALL FUNCTION 'Z_LE_GET_CHARACTERISTIC'
          EXPORTING
            I_VBELN                      = GS_DATA-VBELN
            I_POSNR                      = GS_DATA-POSNR
            I_OBJECT                     = LV_OBJECT
            I_WERKS                      = GS_DATA-WERKS
*       IMPORTING
*           ET_RETURN                    =
          TABLES
            GT_LIST                      = GT_CHAR2
          EXCEPTIONS
            INSTANCE_NOT_FOUND           = 1
            INSTANCE_IS_A_CLASSIFICATION = 2
            INVALID_DATA                 = 3
            OTHERS                       = 4.
      ELSEIF   P_R2 = 'X' OR P_R3 = 'X'.
        READ TABLE GT_VBAP INTO GS_VBAP WITH KEY VBELN = GS_DATA-VBELN
                                                 POSNR = GS_DATA-POSNR
                                                 BINARY SEARCH.
        IF SY-SUBRC = 0.
          LV_OBJECT = GS_VBAP-MATNR.
        ENDIF.

        CALL FUNCTION 'Z_LE_GET_CHARACTERISTIC'
          EXPORTING
            I_VBELN                      = GS_DATA-VBELN
            I_POSNR                      = GS_DATA-POSNR
            I_OBJECT                     = LV_OBJECT
            I_WERKS                      = GS_DATA-WERKS
*       IMPORTING
*           ET_RETURN                    =
          TABLES
            GT_LIST                      = GT_CHAR2
          EXCEPTIONS
            INSTANCE_NOT_FOUND           = 1
            INSTANCE_IS_A_CLASSIFICATION = 2
            INVALID_DATA                 = 3
            OTHERS                       = 4.
      ENDIF.
    ENDIF.

    "자재코드
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = GS_DATA-MATNR
      IMPORTING
        OUTPUT = GS_DATA-MATNR.
    GS_DISP-MATNR  = GS_DATA-MATNR.

    GS_DISP-MTART = GS_DATA-MTART. "자재유형
    "자재유형내역
    CLEAR GT_T134T.
    READ TABLE GT_T134T WITH KEY MTART = GS_DATA-MTART.
    IF SY-SUBRC = 0.
      GS_DISP-MTBEZ = GT_T134T-MTBEZ.
    ENDIF.

    GS_DISP-MATKL = GS_DATA-MATKL.  "자재그룹
    "자재그룹내역
    CLEAR GT_T023T.
    READ TABLE GT_T023T WITH KEY MATKL = GS_DATA-MATKL.
    IF SY-SUBRC = 0.
      GS_DISP-WGBEZ = GT_T023T-WGBEZ.
    ENDIF.

    GS_DISP-LGORT = GS_DATA-LGORT.  "저장위치
    "저장위치 내역
    CLEAR GT_T001L.
    READ TABLE GT_T001L WITH KEY WERKS = GS_DATA-WERKS
                                 LGORT = GS_DATA-LGORT.
    IF SY-SUBRC = 0.
      GS_DISP-LGOBE = GT_T001L-LGOBE.
    ENDIF.

    GS_DISP-CHARG = GS_DATA-CHARG.   "배치번호
    GS_DISP-SOBKZ = GS_DATA-SOBKZ.   "특별 재고 지시자
    GS_DISP-LIFNR = GS_DATA-LIFNR.  "공급업체 번호
    "공급업체명
    CLEAR GT_LFA1.
    READ TABLE GT_LFA1 WITH KEY LIFNR = GS_DATA-LIFNR.
    IF SY-SUBRC = 0.
      GS_DISP-NAME2 = GT_LFA1-NAME1.
    ENDIF.

    "프로젝트 내역
    CLEAR GT_ZSD0106T.
    READ TABLE GT_ZSD0106T WITH KEY ZPJNO = GS_DATA-ZPJNO.
    IF SY-SUBRC = 0.
      GS_DISP-PRJNM = GT_ZSD0106T-ZPTXT.
    ENDIF.

    "제조 지시 내역
    CLEAR GT_ZGTEDT2121.
    READ TABLE GT_ZGTEDT2121 WITH KEY  ZWERKS = GS_DATA-WERKS
                                      ZJOB_NO = GS_DATA-BSTNK.
    IF SY-SUBRC = 0.
      GS_DISP-PRDNM = GT_ZGTEDT2121-ZJOB_NAME.
    ENDIF.

    GS_DISP-VBELN = GS_DATA-VBELN.  " 판매오더
    GS_DISP-POSNR = GS_DATA-POSNR.  "판매오더 품목
    GS_DISP-ZPJNO = GS_DATA-ZPJNO. "프로젝트번호
*    gs_disp-prjnm = gs_data-prjnm.  "프로젝트 내역



    GS_DISP-BSTNK = GS_DATA-BSTNK."제조지시번호
*    gs_disp-prdnm = gs_data-prdnm. .   "제조지시 내역
    GS_DISP-KALAB = GS_DATA-KALAB.   "재고수량(가용)
    GS_DISP-KAINS = GS_DATA-KAINS.   "재고수량(품질)
    GS_DISP-KASPE = GS_DATA-KASPE.   "재고수량(보류)
    GS_DISP-MEINS = GS_DATA-MEINS.   " 단위

*  완제품 외주 품목의 공급업체코드 추출(20250731)
    IF GS_DATA-MTART = 'FERT' AND GS_DATA-BSTNK IS NOT INITIAL.
      CLEAR GS_BSTNK_INFOR.
      READ TABLE GT_BSTNK_INFOR INTO GS_BSTNK_INFOR
                                            WITH KEY BSTNK = GS_DATA-BSTNK
                                                           LINE_NO = GS_DISP-ZZLINE_NO
                                                           SERIAL_INFO = GS_DISP-ZZSERIAL_INFO
                                            BINARY SEARCH.
      IF SY-SUBRC EQ 0.
        GS_DISP-LIFNR_PROJ = GS_BSTNK_INFOR-LIFNR_PROJ.
        GS_DISP-NAME1_PROJ = GS_BSTNK_INFOR-NAME1_PROJ.
      ENDIF.
    ENDIF.

    LV_IDX = '01'.
    IF GS_DATA-CHARG IS NOT INITIAL AND P_R1 = 'X'..
      DO 30 TIMES.
        CONCATENATE 'CHARACT' LV_IDX INTO LV_CHARACT.

        " CHARACT01~ 30
        READ TABLE GT_T1010 INTO GS_T1010 WITH KEY FLD_01 = LV_CHARACT.
        IF SY-SUBRC = 0.
          READ TABLE GT_CHAR WITH KEY ATNAM = GS_T1010-FLD_02.
          IF SY-SUBRC = 0.
            CONCATENATE 'GS_DISP-CHARACT' LV_IDX INTO LV_STR.
            ASSIGN  (LV_STR) TO  <FS_FIELD>.
            <FS_FIELD> = GT_CHAR-ATWTB.
            UNASSIGN <FS_FIELD>.
          ENDIF.
        ENDIF.

        LV_IDX = LV_IDX + 1.
      ENDDO.
    ELSE.
      IF GS_DATA-VBELN IS NOT INITIAL
         AND GS_DATA-CHARG IS INITIAL
         AND P_R1 = 'X'.
        DO 30 TIMES.
          CONCATENATE 'CHARACT' LV_IDX INTO LV_CHARACT.

          " CHARACT01~ 30
          READ TABLE GT_T1010 INTO GS_T1010
                              WITH KEY FLD_01 = LV_CHARACT.
          IF SY-SUBRC = 0.
            READ TABLE GT_CHAR2 WITH KEY ATNAM = GS_T1010-FLD_02.
            IF SY-SUBRC = 0.
              CONCATENATE 'GS_DISP-CHARACT' LV_IDX INTO LV_STR.
              ASSIGN  (LV_STR) TO  <FS_FIELD>.
              IF GT_CHAR2-ATWTB IS INITIAL.
                <FS_FIELD> = GT_CHAR2-ATWRT.
              ELSE.
                <FS_FIELD> = GT_CHAR2-ATWTB.
              ENDIF.
              UNASSIGN <FS_FIELD>.
            ENDIF.
          ENDIF.

          LV_IDX = LV_IDX + 1.
        ENDDO.
      ELSEIF  P_R2 = 'X' OR P_R3 = 'X'.
        DO 30 TIMES.
          CONCATENATE 'CHARACT' LV_IDX INTO LV_CHARACT.

          " CHARACT01~ 30
          READ TABLE GT_T1010 INTO GS_T1010
                              WITH KEY FLD_01 = LV_CHARACT.
          IF SY-SUBRC = 0.
            READ TABLE GT_CHAR2 WITH KEY ATNAM = GS_T1010-FLD_02.
            IF SY-SUBRC = 0.
              CONCATENATE 'GS_DISP-CHARACT' LV_IDX INTO LV_STR.
              ASSIGN  (LV_STR) TO  <FS_FIELD>.
              IF GT_CHAR2-ATWTB IS INITIAL.
                <FS_FIELD> = GT_CHAR2-ATWRT.
              ELSE.
                <FS_FIELD> = GT_CHAR2-ATWTB.
              ENDIF.
              UNASSIGN <FS_FIELD>.
            ENDIF.
          ENDIF.

          LV_IDX = LV_IDX + 1.
        ENDDO.
      ENDIF.
    ENDIF.

    APPEND GS_DISP TO GT_DISP.
    CLEAR : GS_DISP, GS_DATA, GT_LFA1.

  ENDLOOP.


  IF  P_R1 = 'X'.

  ELSEIF  P_R2 = 'X'.
    CLEAR : GT_DISP_R2[], GT_DISP_R2.
*    LOOP AT GT_DISP INTO GS_DISP.
*      MOVE-CORRESPONDING GS_DISP TO GS_DISP_R2.
*      APPEND GS_DISP_R2 TO GT_DISP_R2.
*    ENDLOOP.
**    SORT gt_disp_r2 BY  werks
**                        name1
**                        matnr
**                        maktx
**                        mtart
**                        mtbez
**                        matkl
**                        wgbez
**                        lgort
**                        lgobe
**                        sobkz
**                        vbeln
**                        posnr
**                        zpjno
**                        prjnm
**                        bstnk
**                        prdnm.
**    DELETE ADJACENT DUPLICATES FROM gt_disp
**                               COMPARING werks
**                                        name1
**                                        matnr
**                                        maktx
**                                        mtart
**                                        mtbez
**                                        matkl
**                                        wgbez
**                                        lgort
**                                        lgobe
**                                        sobkz
**                                        vbeln
**                                        posnr
**                                        zpjno
**                                        prjnm
**                                        bstnk
**                                        prdnm.

    DATA(LT_CHK_DATA) = GT_DISP[].

    SORT LT_CHK_DATA BY  WERKS
                        MATNR
                        MTART
                        MATKL
                        LGORT
                        SOBKZ
                        VBELN
                        POSNR.

    SORT GT_DISP BY  WERKS
                        MATNR
                        MTART
                        MATKL
                        LGORT
                        SOBKZ
                        VBELN
                        POSNR.

    DELETE ADJACENT DUPLICATES FROM GT_DISP
                               COMPARING WERKS
                                        MATNR
                                        MTART
                                        MATKL
                                        LGORT
                                        SOBKZ
                                        VBELN
                                        POSNR.
    .


*    LOOP AT GT_DISP INTO GS_DISP.
    LOOP AT GT_DISP ASSIGNING FIELD-SYMBOL(<LS_MAIN>).
      CLEAR : LV_KALAB_SUM,   "재고수량(가용)
              LV_KAINS_SUM,   "재고수량(품질)
              LV_KASPE_SUM.   "재고수량(보류)
      LOOP AT LT_CHK_DATA INTO DATA(CHK_DATA) WHERE WERKS  = <LS_MAIN>-WERKS
                                           AND MATNR  = <LS_MAIN>-MATNR
                                           AND MTART  = <LS_MAIN>-MTART
                                           AND MATKL  = <LS_MAIN>-MATKL
                                           AND LGORT  = <LS_MAIN>-LGORT
                                           AND SOBKZ  = <LS_MAIN>-SOBKZ
                                           AND VBELN  = <LS_MAIN>-VBELN
                                           AND POSNR  = <LS_MAIN>-POSNR.

        LV_KALAB_SUM = LV_KALAB_SUM +  CHK_DATA-KALAB. "재고수량(가용)
        LV_KAINS_SUM = LV_KAINS_SUM +  CHK_DATA-KAINS. "재고수량(품질)
        LV_KASPE_SUM = LV_KASPE_SUM +  CHK_DATA-KASPE. "재고수량(보류)
      ENDLOOP.
      <LS_MAIN>-KALAB = LV_KALAB_SUM. "재고수량(가용)
      <LS_MAIN>-KAINS = LV_KAINS_SUM."재고수량(품질)DLOOP.
      <LS_MAIN>-KASPE = LV_KASPE_SUM. "재고수량(보류)
    ENDLOOP.

  ELSEIF  P_R3 = 'X'.

    CLEAR : GT_DISP_R3[], GT_DISP_R3.
    LOOP AT GT_DISP INTO GS_DISP.
      MOVE-CORRESPONDING GS_DISP TO GS_DISP_R3.
      APPEND GS_DISP_R3 TO GT_DISP_R3.
    ENDLOOP.
    SORT GT_DISP_R3 BY  WERKS
                        NAME1
                        MATNR
                        MAKTX
                        MTART
                        MTBEZ
                        MATKL
                        WGBEZ
                        LGORT
                        LGOBE
                        SOBKZ
                        ZPJNO
                        PRJNM
                        BSTNK
                        PRDNM.
    DELETE ADJACENT DUPLICATES FROM GT_DISP
                               COMPARING WERKS
                                        NAME1
                                        MATNR
                                        MAKTX
                                        MTART
                                        MTBEZ
                                        MATKL
                                        WGBEZ
                                        LGORT
                                        LGOBE
                                        SOBKZ
                                        ZPJNO
                                        PRJNM
                                        BSTNK
                                        PRDNM.
    LOOP AT GT_DISP INTO GS_DISP.
      CLEAR : LV_KALAB_SUM,   "재고수량(가용)
              LV_KAINS_SUM,   "재고수량(품질)
              LV_KASPE_SUM.   "재고수량(보류)
      LOOP AT GT_DISP_R3 INTO GS_DISP_R3 WHERE WERKS  = GS_DISP-WERKS
                                           AND NAME1  = GS_DISP-NAME1
                                           AND MATNR  = GS_DISP-MATNR
                                           AND MAKTX  = GS_DISP-MAKTX
                                           AND MTART  = GS_DISP-MTART
                                           AND MTBEZ  = GS_DISP-MTBEZ
                                           AND MATKL  = GS_DISP-MATKL
                                           AND WGBEZ  = GS_DISP-WGBEZ
                                           AND LGORT  = GS_DISP-LGORT
                                           AND LGOBE  = GS_DISP-LGOBE
                                           AND SOBKZ  = GS_DISP-SOBKZ
                                           AND ZPJNO  = GS_DISP-ZPJNO
                                           AND PRJNM  = GS_DISP-PRJNM
                                           AND BSTNK  = GS_DISP-BSTNK
                                           AND PRDNM  = GS_DISP-PRDNM.
        LV_KALAB_SUM = LV_KALAB_SUM +  GS_DISP_R3-KALAB. "재고수량(가용)
        LV_KAINS_SUM = LV_KAINS_SUM +  GS_DISP_R3-KAINS. "재고수량(품질)
        LV_KASPE_SUM = LV_KASPE_SUM +  GS_DISP_R3-KASPE. "재고수량(보류)
      ENDLOOP.
      GS_DISP-KALAB = LV_KALAB_SUM. "재고수량(가용)
      GS_DISP-KAINS = LV_KAINS_SUM."재고수량(품질)DLOOP.
      GS_DISP-KASPE = LV_KASPE_SUM. "재고수량(보류)
      MODIFY GT_DISP FROM GS_DISP.
    ENDLOOP.

  ENDIF.

ENDFORM.
