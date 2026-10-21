*&---------------------------------------------------------------------*
*& Include          ZGTPPI1030F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form get_data
*&---------------------------------------------------------------------*
FORM GET_DATA .

  DATA : LV_STAT      LIKE  BSVX-STTXT.
  DATA : LV_MENGE_SUM LIKE  MSEG-MENGE.
  DATA : LV_WEMNG_SUM LIKE  AFPO-WEMNG.
  DATA : LV_BDMNG_SUM LIKE  RESB-BDMNG.
  DATA : LT_BKTXT TYPE RANGE OF MKPF-BKTXT.

  "생산오더 정보 발췌  ( 생산오더와 모코드 발췌)
  SELECT  A~WERKS,
          A~AUFNR,
          A~AUART,
          A~OBJNR,
          B~GAMNG,
          B~GMEIN,
          C~MATNR,
          C~WEMNG,
          C~AMEIN,
          C~KDAUF,
          C~KDPOS,
          D~ZPJNO,
          D~BSTNK,
          E~DISPO,
          F~MATKL
    FROM AUFK AS A INNER JOIN AFKO AS B
                   ON A~AUFNR = B~AUFNR
                   INNER JOIN AFPO  AS C
                   ON B~AUFNR = C~AUFNR
                   LEFT OUTER JOIN VBAK  AS D
                   ON C~KDAUF = D~VBELN
                   LEFT OUTER JOIN MARC AS E
                   ON C~MATNR = E~MATNR
                   AND A~WERKS = E~WERKS
                   LEFT OUTER JOIN MARA AS F
                   ON E~MATNR = F~MATNR
    WHERE  A~WERKS IN @S_WERKS
      AND  A~AUART IN @S_AUART
      AND  A~AUFNR IN @S_AUFNR
      AND  C~MATNR IN @S_MAT
      AND  C~KDAUF IN @S_KDAUF
      AND  C~KDPOS IN @S_KDPOS
      AND  B~GSTRP IN @S_GSTRP
      AND  D~ZPJNO IN @S_ZPJNO
      AND  D~BSTNK IN @S_BSTNK
      AND  E~DISPO IN @S_DISPO
      AND  F~MATKL IN @S_MATKL
    INTO CORRESPONDING FIELDS OF TABLE @GT_DATA.

  SORT GT_DATA BY AUFNR AUART OBJNR GAMNG MATNR WEMNG.

  "Payoff와 실적일자 확인하는 부분을 조회조건 "작업시작일자"에 값을 넣고 실행했을때만 체크
  IF S_ISDD[] IS NOT INITIAL.
    PERFORM CHECK_ISDD1.
  ENDIF.

  " 한 생산오더 품목의 입고 수량이 여러개인 경우 생산입고수량을 SUM
  LOOP AT GT_DATA.
    GT_DATA_WEMNG-WERKS = GT_DATA-WERKS.    "플랜트
    GT_DATA_WEMNG-AUFNR = GT_DATA-AUFNR.    "생산오더
    GT_DATA_WEMNG-AUART = GT_DATA-AUART.    "생산상태
    GT_DATA_WEMNG-OBJNR = GT_DATA-OBJNR.    "오브젝트 번호
    GT_DATA_WEMNG-MATNR = GT_DATA-MATNR.    "모품목코드
    GT_DATA_WEMNG-GAMNG = GT_DATA-GAMNG.    "생산오더수량
    GT_DATA_WEMNG-GMEIN = GT_DATA-GMEIN.    "생산오더단위
    GT_DATA_WEMNG-AMEIN = GT_DATA-AMEIN.    "생산입고단위
    GT_DATA_WEMNG-CMATN = GT_RESB-MATNR.    "자품목코드
    GT_DATA_WEMNG-BDMNG = GT_RESB-BDMNG.    "소요량(생산오더수량 기준)
    GT_DATA_WEMNG-CMEIN = GT_RESB-MEINS.    "출고단위
    GT_DATA_WEMNG-ZPJNO = GT_DATA-ZPJNO.
    GT_DATA_WEMNG-BSTNK = GT_DATA-BSTNK.
    GT_DATA_WEMNG-DISPO = GT_DATA-DISPO.
    GT_DATA_WEMNG-MATKL = GT_DATA-MATKL.
    LV_WEMNG_SUM = LV_WEMNG_SUM + GT_DATA-WEMNG.
    AT END OF AUFNR.
      GT_DATA_WEMNG-WEMNG = LV_WEMNG_SUM.
      APPEND GT_DATA_WEMNG.
      CLEAR : LV_WEMNG_SUM.
      CLEAR : GT_DATA_WEMNG.
    ENDAT.
  ENDLOOP.

***  DELETE ADJACENT DUPLICATES FROM gt_data
***         COMPARING  aufnr auart objnr gamng matnr wemng.

  CLEAR : GT_DATA[], GT_DATA.

  GT_DATA[] = GT_DATA_WEMNG[].


  SORT GT_DATA BY AUFNR MATNR.

  "소요량 및 투입량 정보 발췌( 오더별 자코드 발췌)
  IF GT_DATA[] IS  NOT INITIAL.

    SELECT  A~MATNR AS MATNR,
          A~BDMNG AS BDMNG,
          A~MEINS AS MEINS,
          A~AUFNR AS AUFNR,
          A~OBJNR AS OBJNR,
          A~ERFME AS ERFME,
          C~MTART AS MTART
    FROM RESB AS A INNER JOIN MARC AS B
                   ON A~MATNR = B~MATNR
                   INNER JOIN MARA AS C
                   ON B~MATNR = C~MATNR
    FOR ALL ENTRIES IN @GT_DATA
    WHERE  "a~matnr IN @s_matnr (박요신위원 요청으로 주석 처리 2025.04.28)
           A~AUFNR =  @GT_DATA-AUFNR
      AND  A~KZKUP = ''
      AND  ( A~XLOEK = '' OR ( A~XLOEK NE @SPACE AND A~ENMNG NE @SPACE ) )
      AND A~DUMPS NE 'X'          "가상품목 제외
    INTO CORRESPONDING FIELDS OF TABLE @GT_RESB.
    SORT GT_RESB BY AUFNR MATNR.


***    LOOP AT gt_resb.
***      CLEAR : lv_stat.
***      CALL FUNCTION 'STATUS_TEXT_EDIT'
***        EXPORTING
***          objnr            = gt_resb-objnr
***          only_active      = 'X'
***          spras            = 'E'
***        IMPORTING
***          line             = lv_stat
***        EXCEPTIONS
***          object_not_found = 1
***          OTHERS           = 2.
***      IF lv_stat = 'DLT'.
***        gt_resb-dflag = 'X'.
***      ENDIF.
***      MODIFY gt_resb.
***
***    ENDLOOP.
***
***    DELETE gt_resb WHERE dflag = 'X'.
    SORT GT_RESB BY AUFNR MATNR.

    LOOP AT GT_RESB.
      GT_RESB_SUM-AUFNR = GT_RESB-AUFNR.
      GT_RESB_SUM-MATNR = GT_RESB-MATNR.
      GT_RESB_SUM-MEINS = GT_RESB-MEINS.
      GT_RESB_SUM-OBJNR = GT_RESB-OBJNR.
      GT_RESB_SUM-ERFME = GT_RESB-ERFME.
      GT_RESB_SUM-MTART = GT_RESB-MTART.
*      LOOP AT gt_resb_sum WHERE aufnr = gt_resb-aufnr
*                           AND  matnr = gt_resb-matnr.
      LV_BDMNG_SUM = LV_BDMNG_SUM + GT_RESB-BDMNG.
      AT END OF MATNR.
        GT_RESB_SUM-BDMNG = LV_BDMNG_SUM.
        APPEND GT_RESB_SUM.
        CLEAR : LV_BDMNG_SUM.
        CLEAR : GT_RESB_SUM.
      ENDAT.
*      ENDLOOP.
    ENDLOOP.

    SORT GT_RESB_SUM BY AUFNR  MATNR BDMNG.

    DELETE ADJACENT DUPLICATES FROM GT_RESB_SUM
           COMPARING  AUFNR  MATNR BDMNG.

  ENDIF.

  " 생산 오더에 대한 자자재 소요량 투입량 정보 append
  SORT GT_RESB_SUM BY AUFNR .
  LOOP AT GT_RESB_SUM.

    READ TABLE GT_DATA WITH KEY AUFNR = GT_RESB_SUM-AUFNR
                       BINARY SEARCH.
    IF SY-SUBRC = 0.
      GT_DATA_TMP-WERKS = GT_DATA-WERKS.    "플랜트
      GT_DATA_TMP-AUFNR = GT_DATA-AUFNR.    "생산오더
      GT_DATA_TMP-AUART = GT_DATA-AUART.    "생산상태
      GT_DATA_TMP-OBJNR = GT_DATA-OBJNR.    "오브젝트 번호
      GT_DATA_TMP-MATNR = GT_DATA-MATNR.    "모품목코드
      GT_DATA_TMP-GAMNG = GT_DATA-GAMNG.    "생산오더수량
      GT_DATA_TMP-WEMNG = GT_DATA-WEMNG.    "생산입고수량
      GT_DATA_TMP-GMEIN = GT_DATA-GMEIN.    "생산오더단위
      GT_DATA_TMP-AMEIN = GT_DATA-AMEIN.    "생산입고단위
      GT_DATA_TMP-CMATN = GT_RESB_SUM-MATNR.    "자품목코드
      GT_DATA_TMP-BDMNG = GT_RESB_SUM-BDMNG.    "소요량(생산오더수량 기준)
      GT_DATA_TMP-CMEIN = GT_RESB_SUM-MEINS.    "출고단위
      GT_DATA_TMP-MTART = GT_RESB_SUM-MTART.
      GT_DATA_TMP-ZPJNO = GT_DATA-ZPJNO.
      GT_DATA_TMP-BSTNK = GT_DATA-BSTNK.
      GT_DATA_TMP-DISPO = GT_DATA-DISPO.
      GT_DATA_TMP-MATKL = GT_DATA-MATKL.
      APPEND GT_DATA_TMP.
    ENDIF.
  ENDLOOP.

  CLEAR : GT_DATA[] , GT_DATA.

  GT_DATA[] = GT_DATA_TMP[].  " 자자재코드를 add

  "자재 출고 정보 추출
  SORT GT_RESB BY AUFNR MATNR .
  IF GT_RESB[] IS NOT  INITIAL.

    REFRESH GT_MSEG.
* 스크랩출고내역 제외 추가로 로직변경
    REFRESH LT_BKTXT.
    IF P_C7 = ABAP_TRUE.
      APPEND INITIAL LINE TO LT_BKTXT ASSIGNING FIELD-SYMBOL(<LS_BKTXT>).
      <LS_BKTXT>-SIGN = 'E'.
      <LS_BKTXT>-OPTION = 'EQ'.
      <LS_BKTXT>-LOW = 'MES 스크랩 출고 I/F'.
    ENDIF.

    SELECT  *
      FROM MSEG AS A
      INNER JOIN MARA AS B ON A~MATNR = B~MATNR
      INNER JOIN MKPF AS C ON C~MBLNR = A~MBLNR
                          AND C~MJAHR = A~MJAHR
      INTO CORRESPONDING FIELDS OF TABLE @GT_MSEG
      FOR ALL ENTRIES IN @GT_RESB
      WHERE  A~AUFNR =  @GT_RESB-AUFNR
*        AND  a~matnr =  @gt_resb-matnr (박요신위원 요청으로 주석 처리 2025.04.28)
        AND  A~BWART IN ('261','262', 'Z61', 'Z62')
        AND  C~BKTXT IN @LT_BKTXT.


*    SELECT    *
*      FROM MSEG AS A INNER JOIN MARA AS B
*                     ON A~MATNR = B~MATNR
*      INTO CORRESPONDING FIELDS OF TABLE @GT_MSEG
*      FOR ALL ENTRIES IN @GT_RESB
*      WHERE  A~AUFNR =  @GT_RESB-AUFNR
**        AND  a~matnr =  @gt_resb-matnr (박요신위원 요청으로 주석 처리 2025.04.28)
*        AND  A~BWART IN ('261','262', 'Z61', 'Z62').

    SORT GT_MSEG BY AUFNR MATNR.

    GT_MSEG_TMP[] = GT_MSEG[].
*- Start 2025.06.27
    SORT GT_MSEG BY AUFNR MATNR.
    DELETE ADJACENT DUPLICATES FROM GT_MSEG COMPARING AUFNR MATNR.
    SORT GT_MSEG_TMP BY AUFNR MATNR.

    LOOP AT GT_MSEG.

      GT_MSEG_SUM-AUFNR = GT_MSEG-AUFNR.
      GT_MSEG_SUM-MATNR = GT_MSEG-MATNR.
      GT_MSEG_SUM-MEINS = GT_MSEG-MEINS.
      GT_MSEG_SUM-MTART = GT_MSEG-MTART.

      CLEAR LV_MENGE_SUM.
      READ TABLE GT_MSEG_TMP TRANSPORTING NO FIELDS
                             WITH KEY AUFNR = GT_MSEG-AUFNR
                                      MATNR = GT_MSEG-MATNR.

      IF SY-SUBRC EQ 0.

        LOOP AT GT_MSEG_TMP FROM SY-TABIX.

          IF GT_MSEG_TMP-AUFNR NE GT_MSEG-AUFNR OR
            GT_MSEG_TMP-MATNR NE GT_MSEG-MATNR.
            EXIT.
          ENDIF.

          IF GT_MSEG_TMP-SHKZG = 'H'.
            LV_MENGE_SUM = LV_MENGE_SUM + GT_MSEG_TMP-MENGE.
          ELSE.
            LV_MENGE_SUM = LV_MENGE_SUM - GT_MSEG_TMP-MENGE.
          ENDIF.

        ENDLOOP.

      ENDIF.

      GT_MSEG_SUM-MENGE = LV_MENGE_SUM.
      APPEND GT_MSEG_SUM.
      CLEAR GT_MSEG_SUM.

    ENDLOOP.

*    CLEAR lv_menge_sum.
*    SORT gt_mseg_tmp BY aufnr matnr.
*    LOOP AT  gt_mseg.
*      gt_mseg_sum-aufnr = gt_mseg-aufnr.
*      gt_mseg_sum-matnr = gt_mseg-matnr.
*      gt_mseg_sum-meins = gt_mseg-meins.
*      gt_mseg_sum-mtart = gt_mseg-mtart.
*      LOOP AT gt_mseg_tmp WHERE aufnr = gt_mseg-aufnr
*                           AND  matnr = gt_mseg-matnr.
*        IF gt_mseg_tmp-shkzg = 'H'.
*          lv_menge_sum = lv_menge_sum + gt_mseg_tmp-menge.
*        ELSE.
*          lv_menge_sum = lv_menge_sum - gt_mseg_tmp-menge.
*        ENDIF.
*        AT END OF matnr.
*          gt_mseg_sum-menge = lv_menge_sum.
*          APPEND gt_mseg_sum.
*          CLEAR : lv_menge_sum.
*          CLEAR : gt_mseg_sum.
*        ENDAT.
*
*      ENDLOOP.
*
*    ENDLOOP.
*- End 2025.06.27
    SORT GT_MSEG_SUM BY AUFNR  MATNR MENGE.
    DELETE ADJACENT DUPLICATES FROM GT_MSEG_SUM
           COMPARING  AUFNR  MATNR MENGE.

    " 소요량(resb)에는 없으나 생산투입(mseg)정보가 있는 항목 생성

    CLEAR : GT_DATA_TMP[].
    SORT GT_DATA BY AUFNR CMATN.
    LOOP AT GT_MSEG_SUM.
      READ TABLE GT_DATA WITH KEY AUFNR = GT_MSEG_SUM-AUFNR
                                  CMATN = GT_MSEG_SUM-MATNR.
*                         BINARY SEARCH..
      IF SY-SUBRC <> 0.
        CLEAR GT_DATA.
        READ TABLE GT_DATA WITH KEY AUFNR = GT_MSEG_SUM-AUFNR.
*                           BINARY SEARCH.
        IF SY-SUBRC = 0.
          GT_DATA_TMP-WERKS     = GT_DATA-WERKS.    "플랜트
          GT_DATA_TMP-AUFNR     = GT_DATA-AUFNR.    "생산오더
          GT_DATA_TMP-AUART     = GT_DATA-AUART.    "생산상태
          GT_DATA_TMP-OBJNR     = GT_DATA-OBJNR.    "오브젝트 번호
          GT_DATA_TMP-MATNR     = GT_DATA-MATNR.    "모품목코드
          GT_DATA_TMP-GAMNG     = GT_DATA-GAMNG.    "생산오더수량
          GT_DATA_TMP-WEMNG     = GT_DATA-WEMNG.    "생산입고수량
          GT_DATA_TMP-GMEIN     = GT_DATA-GMEIN.    "생산오더단위
          GT_DATA_TMP-AMEIN     = GT_DATA-AMEIN.    "생산입고단위
          GT_DATA_TMP-CMATN     = GT_MSEG_SUM-MATNR.    "자품목코드
          GT_DATA_TMP-CMEIN     = GT_MSEG_SUM-MEINS.    "출고단위
          GT_DATA_TMP-MTART     = GT_MSEG_SUM-MTART.
          APPEND GT_DATA_TMP TO GT_DATA.
        ENDIF.
      ENDIF.
    ENDLOOP.

  ENDIF.


  IF GT_DATA[] IS NOT INITIAL.
    " 자재코드내역을 가져온다
    SELECT *
      INTO CORRESPONDING FIELDS OF TABLE GT_MAKT
      FROM MAKT
      FOR ALL ENTRIES IN GT_DATA
     WHERE MATNR = GT_DATA-MATNR
       AND SPRAS = SY-LANGU.
    SORT GT_MAKT BY MATNR .

    SELECT *
      FROM MAKT
      FOR ALL ENTRIES IN @GT_RESB
     WHERE MATNR = @GT_RESB-MATNR
       AND SPRAS = @SY-LANGU
      APPENDING CORRESPONDING FIELDS OF TABLE @GT_MAKT.
    SORT GT_MAKT BY MATNR .

    SELECT *
      FROM MAKT
      FOR ALL ENTRIES IN @GT_MSEG
     WHERE MATNR = @GT_MSEG-MATNR
       AND SPRAS = @SY-LANGU
      APPENDING CORRESPONDING FIELDS OF TABLE @GT_MAKT.
    SORT GT_MAKT BY MATNR .


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

    "백로그 존재여부
    SELECT *
      FROM AFFW
      FOR ALL ENTRIES IN @GT_DATA
     WHERE MATNR = @GT_DATA-CMATN
       AND AUFNR = @GT_DATA-AUFNR
      APPENDING CORRESPONDING FIELDS OF TABLE @GT_AFFW.
    SORT GT_AFFW BY MATNR AUFNR .

    " 통화키 추출
    SELECT *
      INTO CORRESPONDING FIELDS OF TABLE GT_T001
      FROM T001 AS A INNER JOIN T001K AS B
                     ON A~BUKRS = B~BUKRS
      FOR ALL ENTRIES IN GT_DATA
      WHERE B~BWKEY  = GT_DATA-WERKS.
    SORT GT_T001 BY BWKEY.

    "표준원가 및 가격단위 추출
*    IF s_gstrp-low IS INITIAL.
*      s_gstrp-low = sy-datum.
*    ENDIF.

    IF S_GSTRP-LOW(6) <> SY-DATUM(6).

      SELECT *
        INTO CORRESPONDING FIELDS OF TABLE GT_MBEWH
        FROM MBEWH
        FOR ALL ENTRIES IN GT_DATA
        WHERE MATNR  = GT_DATA-CMATN
          AND BWKEY  = GT_DATA-WERKS
          AND LFGJA  = S_GSTRP-LOW+(4)
          AND LFMON  = S_GSTRP-LOW+4(2).

      SORT GT_MBEWH BY MATNR BWKEY LFGJA LFMON.

    ELSEIF S_GSTRP-LOW(6) = SY-DATUM(6) OR S_GSTRP-LOW IS INITIAL..

      SELECT *
        INTO CORRESPONDING FIELDS OF TABLE GT_MBEWH
        FROM MBEW
        FOR ALL ENTRIES IN GT_DATA
        WHERE MATNR  = GT_DATA-CMATN
          AND BWKEY  = GT_DATA-WERKS.

      SORT GT_MBEWH BY MATNR BWKEY .

    ENDIF.

  ENDIF.



ENDFORM.

*&---------------------------------------------------------------------*
*& Form set_screen_attribute
*&---------------------------------------------------------------------*
FORM SET_SCREEN_ATTRIBUTE .

  LOOP AT SCREEN.
    IF SCREEN-GROUP1 = 'R1'.
      IF P_R1 = ABAP_TRUE.
        SCREEN-ACTIVE = 1.
        MODIFY SCREEN.
      ELSE.
        SCREEN-ACTIVE = 0.
        MODIFY SCREEN.
      ENDIF.
    ENDIF.
  ENDLOOP.

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
*& Form data_conversion
*&---------------------------------------------------------------------*
FORM DATA_CONVERSION TABLES PT_OT_TAB STRUCTURE ZGTPPSIF0002.

  LOOP AT PT_OT_TAB ASSIGNING FIELD-SYMBOL(<LS_ITAB>).
    "자재번호
    CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
      EXPORTING
        INPUT  = <LS_ITAB>-MATNR
      IMPORTING
        OUTPUT = <LS_ITAB>-MATNR.
    "그룹카운터
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = <LS_ITAB>-ALNAL
      IMPORTING
        OUTPUT = <LS_ITAB>-ALNAL.
    "대체 BOM No.
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = <LS_ITAB>-STLAL
      IMPORTING
        OUTPUT = <LS_ITAB>-STLAL.

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
*& Form MODIFY_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MODIFY_DATA .

  DATA: LV_STAT LIKE  BSVX-STTXT.
  DATA: LT_NFM TYPE TABLE OF /NFM/TKGW,
        LS_NFM TYPE /NFM/TKGW.

  SORT GT_MAKT BY MATNR.
  SORT GT_RESB_SUM BY AUFNR MATNR.
  SORT GT_MAKT BY MATNR.
  SORT GT_MSEG_SUM BY AUFNR MATNR.
  SORT GT_RESB BY MATNR.
  SORT GT_ZSD0106T BY ZPJNO.
  SORT GT_ZGTEDT2121 BY  ZWERKS  ZJOB_NO .
  SORT GT_AFFW BY AUFNR  MATNR .

  LOOP AT GT_DATA .
    "플랜트
    GS_DISP-WERKS    =  GT_DATA-WERKS.

    "생산오더
    GS_DISP-AUFNR    =  GT_DATA-AUFNR.

    "오더상태
    CLEAR : LV_STAT.
    CALL FUNCTION 'STATUS_TEXT_EDIT'
      EXPORTING
        OBJNR            = GT_DATA-OBJNR
        ONLY_ACTIVE      = 'X'
        SPRAS            = 'E'
      IMPORTING
        LINE             = LV_STAT
      EXCEPTIONS
        OBJECT_NOT_FOUND = 1
        OTHERS           = 2.
    GS_DISP-ZORDSTAT =  LV_STAT.

    "모품목코드
    GS_DISP-PMATN    = GT_DATA-MATNR.

    "모품목내역
    CLEAR GT_MAKT.

    READ TABLE GT_MAKT WITH KEY MATNR = GT_DATA-MATNR
                       BINARY SEARCH.
    IF SY-SUBRC = 0.
      GS_DISP-PMAKTX = GT_MAKT-MAKTX.
    ENDIF.

    "생산오더수량
    GS_DISP-GAMNG  = GT_DATA-GAMNG.

    "생산입고수량
    GS_DISP-WEMNG  = GT_DATA-WEMNG.

    "생산오더단위
    GS_DISP-GMEIN  = GT_DATA-GMEIN.

    "생산입고단위
    GS_DISP-AMEIN  = GT_DATA-AMEIN.

    "자품목코드
    CLEAR : GT_RESB_SUM.

    READ TABLE GT_RESB_SUM WITH KEY AUFNR  = GT_DATA-AUFNR
                                MATNR  = GT_DATA-CMATN
                           BINARY SEARCH.
    IF SY-SUBRC = 0.
      GS_DISP-CMATN = GT_RESB_SUM-MATNR.
      "자품목내역
      CLEAR GT_MAKT.

      READ TABLE GT_MAKT WITH KEY MATNR = GT_RESB_SUM-MATNR
                         BINARY SEARCH.
      IF SY-SUBRC = 0.
        GS_DISP-CMAKTX = GT_MAKT-MAKTX.
      ENDIF.

    ELSE.
      CLEAR GT_MSEG_SUM.

      READ TABLE GT_MSEG_SUM WITH KEY AUFNR  = GT_DATA-AUFNR
                                      MATNR  = GT_DATA-CMATN
                                      BINARY SEARCH.
      IF SY-SUBRC = 0.
        GS_DISP-CMATN = GT_MSEG_SUM-MATNR.
        "자품목내역
        CLEAR GT_MAKT.

        READ TABLE GT_MAKT WITH KEY MATNR = GT_MSEG_SUM-MATNR
                           BINARY SEARCH.
        IF SY-SUBRC = 0.
          GS_DISP-CMAKTX = GT_MAKT-MAKTX.
        ENDIF.
      ENDIF.
    ENDIF.

    "소요량(생산오더수량 기준)
    CLEAR : GT_RESB_SUM.
    READ TABLE GT_RESB_SUM WITH KEY AUFNR  = GT_DATA-AUFNR
                                     MATNR  = GT_DATA-CMATN.
    IF SY-SUBRC = 0.
      "소요량(생산오더수량 기준)
      GS_DISP-BDMNG =  GT_RESB_SUM-BDMNG.
      "소요량(생산입고수량 기준) = 소요량(생산오더수량 기준) * (생산입고수량) /(생산오더수량)
      GS_DISP-ZCUMNG = ( GT_RESB_SUM-BDMNG * GT_DATA-WEMNG ) / GT_DATA-GAMNG.
    ELSE.
      GS_DISP-BDMNG =  0.
      GS_DISP-ZCUMNG = 0.
    ENDIF.

    "생산투입수량 / 출고단위
    READ TABLE GT_MSEG_SUM WITH KEY AUFNR = GT_DATA-AUFNR
                                    MATNR = GS_DISP-CMATN "자품목으로 검색
                                    BINARY SEARCH.
    IF SY-SUBRC = 0.
      GS_DISP-MENGE = GT_MSEG_SUM-MENGE.
      GS_DISP-MEINS = GT_MSEG_SUM-MEINS.
    ELSE.
      GS_DISP-MENGE = 0.
      " 생산 투입 수량이 없어도 단위 data는 넣어 준다
      READ TABLE GT_RESB WITH KEY MATNR = GS_DISP-CMATN "자품목으로 검색
                         BINARY SEARCH.
      IF SY-SUBRC = 0.
        GS_DISP-MEINS = GT_RESB-MEINS.
      ENDIF.
    ENDIF.

    GS_DISP-ZPJNO   = GT_DATA-ZPJNO.
    "프로젝트 내역
    CLEAR GT_ZSD0106T.
    READ TABLE GT_ZSD0106T WITH KEY ZPJNO = GT_DATA-ZPJNO
                           BINARY SEARCH .
    IF SY-SUBRC = 0.
      GS_DISP-ZPTXT = GT_ZSD0106T-ZPTXT.
    ENDIF.

    GS_DISP-BSTNK   = GT_DATA-BSTNK.
    "제조 지시 내역
    CLEAR GT_ZGTEDT2121.
    READ TABLE GT_ZGTEDT2121 WITH KEY  ZWERKS = GT_DATA-WERKS
                                      ZJOB_NO = GT_DATA-BSTNK
                             BINARY SEARCH.
    IF SY-SUBRC = 0.
      GS_DISP-ZJOB_NAME = GT_ZGTEDT2121-ZJOB_NAME.
    ENDIF.


    " 백로그 존재 상태
    CLEAR GT_AFFW.
    READ TABLE GT_AFFW WITH KEY AUFNR  = GT_DATA-AUFNR
                                MATNR  = GT_DATA-CMATN
                       BINARY SEARCH.
    IF SY-SUBRC = 0.
      GS_DISP-ZSTAT = ICON_LED_GREEN.
    ENDIF.


    " 수기투입여부(20250729)
    SELECT SINGLE RSNUM FROM ZGTPPT3070
      WHERE AUFNR = @GT_DATA-AUFNR
        AND MATNR = @GT_DATA-CMATN
        AND ZERP_STAT = 'S'
        INTO @DATA(LV_RSNUM).

    IF SY-SUBRC = 0 AND LV_RSNUM IS NOT INITIAL.
      GS_DISP-STATS_SUGI = ICON_LED_GREEN.
    ENDIF.
    CLEAR LV_RSNUM.

    "자재 유형
    GS_DISP-MTART    =  GT_DATA-MTART.

    "MRP 관리자
    GS_DISP-DISPO    =  GT_DATA-DISPO.

    " 통화키
    CLEAR GT_T001.
    READ TABLE GT_T001 WITH KEY BWKEY  = GT_DATA-WERKS
                       BINARY SEARCH.
    IF SY-SUBRC = 0.
      GS_DISP-WAERS =  GT_T001-WAERS.
    ENDIF.

***    " 표준가 차이금액
***    CLEAR gt_mbewh.
***    READ TABLE gt_mbewh WITH KEY matnr  = gt_data-matnr
***                                 bwkey  = gt_data-werks
***                       BINARY SEARCH.
***    IF sy-subrc = 0.
***      gs_disp-STPRS = ( gt_mbewh-stprs / gt_mbewh-peinh ).
***      gs_disp-ZAMTDIF = ( gt_mbewh-peinh *  gs_disp-zqtydif ).
***    ENDIF.

    "자재 그룹
    GS_DISP-MATKL = GT_DATA-MATKL.

    IF P_R1 EQ 'X'.
      IF GT_DATA-WERKS EQ '1306'.
        GS_DISP-ID = ICON_LED_INACTIVE.
      ENDIF.

      "작업장
      SELECT SINGLE ARBPL, OBJID
        FROM AFKO AS A
        JOIN AFVC AS B ON B~AUFPL EQ A~AUFPL
        JOIN CRHD AS C ON C~OBJID EQ B~ARBID
       WHERE A~AUFNR EQ @GT_DATA-AUFNR
         AND B~APLFL IN ('', '000000')
         AND C~OBJTY EQ 'A'
        INTO (@GS_DISP-ARBPL, @DATA(LV_OBJID)).

      "공정코드
      GS_DISP-GONG_CD = GS_DISP-ARBPL+0(3).

      "작업장내역
      SELECT SINGLE KTEXT
        FROM CRTX
       WHERE OBJID EQ @LV_OBJID
         AND SPRAS EQ @SY-LANGU
        INTO @GS_DISP-KTEXT.

      "중량정보추출(GR)
      IF GS_DISP-GONG_CD EQ 'CST' OR
         GS_DISP-GONG_CD EQ 'BWD'.
        "중량정보추출(GR)
        CLEAR: LT_NFM.
        SELECT *
          FROM /NFM/TKGW
         WHERE MATNR EQ @GS_DISP-PMATN
           AND WERKS EQ @GS_DISP-WERKS
          INTO TABLE @LT_NFM.

        CLEAR: LS_NFM.
        LOOP AT LT_NFM INTO LS_NFM.
          CASE LS_NFM-NES.
            WHEN 'CU'.
              GS_DISP-KGW_CU_GR = LS_NFM-KGW * ( GS_DISP-WEMNG / LS_NFM-KGU ).
            WHEN 'AL'.
              GS_DISP-KGW_AL_GR = LS_NFM-KGW * ( GS_DISP-WEMNG / LS_NFM-KGU ).
          ENDCASE.
          GS_DISP-BME_GR = LS_NFM-BME.
          CLEAR: LS_NFM.
        ENDLOOP.

        IF GS_DISP-GONG_CD EQ 'CST'.
          "중량정보추출(GI)
          CLEAR: LT_NFM.
          SELECT *
            FROM /NFM/TKGW
           WHERE MATNR EQ @GS_DISP-CMATN
             AND WERKS EQ @GS_DISP-WERKS
            INTO TABLE @LT_NFM.

          CLEAR: LS_NFM.
          LOOP AT LT_NFM INTO LS_NFM.
            CASE LS_NFM-NES.
              WHEN 'CU'.
                GS_DISP-KGW_CU_GI = LS_NFM-KGW * ( GS_DISP-MENGE / LS_NFM-KGU ).
              WHEN 'AL'.
                GS_DISP-KGW_AL_GI = LS_NFM-KGW * ( GS_DISP-MENGE / LS_NFM-KGU ).
            ENDCASE.
            GS_DISP-BME_GI = LS_NFM-BME.
            CLEAR: LS_NFM.
          ENDLOOP.
        ENDIF.
      ENDIF.
    ENDIF.

    CLEAR : GT_MSEG_SUM.

    APPEND GS_DISP TO GT_DISP.

    CLEAR GS_DISP.

  ENDLOOP.

  " 자코드 조회시 적용
  DELETE GT_DISP WHERE CMATN NOT IN S_MATNR.

  IF P_C5 = 'X'. " 반제품 투입내역 제외일 경우
    DELETE GT_DISP WHERE ( MTART = 'MCHF' OR MTART = 'HALB' ).
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SET_SCREEN_VALUE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM SET_SCREEN_VALUE .
* 생산시작일자 셋팅
  IF S_GSTRP[] IS INITIAL.

    S_GSTRP-SIGN   = 'I'.
    S_GSTRP-OPTION = 'EQ'.
* 시작: 이번달 1일
    CONCATENATE SY-DATUM+0(6) '01'  INTO S_GSTRP-LOW .
* 종료: 이번달 말일
* 입력일자가 속한 월의 마지막 일자를 RETURN해 줍니다.
    CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
      EXPORTING
        DAY_IN            = SY-DATUM
      IMPORTING
        LAST_DAY_OF_MONTH = S_GSTRP-HIGH
      EXCEPTIONS
        DAY_IN_NO_DATE    = 1
        OTHERS            = 2.

    APPEND S_GSTRP.
  ENDIF.

  IF S_NUMC[] IS INITIAL.
    S_NUMC-SIGN   = 'I'.
    S_NUMC-OPTION = 'BT'.
    S_NUMC-LOW    = '100'.
    S_NUMC-HIGH   = '100'.
    APPEND S_NUMC.
  ENDIF.

  S_AUART-SIGN   = 'I'.
  S_AUART-OPTION = 'EQ'.
  S_AUART-LOW    = 'PP01'.
  APPEND S_AUART.

  S_AUART-SIGN   = 'I'.
  S_AUART-OPTION = 'EQ'.
  S_AUART-LOW    = 'PP04'.
  APPEND S_AUART.

  S_AUART-SIGN   = 'I'.
  S_AUART-OPTION = 'EQ'.
  S_AUART-LOW    = 'PP05'.
  APPEND S_AUART.

* 2026.09.04 오더타입 추가(RW01, RP01)
  S_AUART-SIGN   = 'I'.
  S_AUART-OPTION = 'EQ'.
  S_AUART-LOW    = 'RW01'.
  APPEND S_AUART.

  S_AUART-SIGN   = 'I'.
  S_AUART-OPTION = 'EQ'.
  S_AUART-LOW    = 'RP01'.
  APPEND S_AUART.
* 2026.09.04 오더타입 추가(RW01, RP01)


ENDFORM.
*&---------------------------------------------------------------------*
*& Form modify_data_sum
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM MODIFY_DATA_SUM .
  DATA : LV_STAT         LIKE  BSVX-STTXT.
  DATA : LV_GAMNG_SUM   LIKE  AFKO-GAMNG, "생산오더수량
         LV_WEMNG_SUM   LIKE  AFPO-WEMNG, "생산입고수량
         LV_BDMNG_SUM   LIKE  RESB-BDMNG, "소요량(생산오더수량 기준)종속
         LV_MENGE_SUM   LIKE  MSEG-MENGE, "생산투입수량
         LV_ZCUMNG_SUM  LIKE  RESB-BDMNG, "소요량(생산입고수량 기준)
         LV_ZQTYDIF_SUM LIKE  RESB-BDMNG. "차이수량
  DATA : LS_DISP1 LIKE  GS_DISP,
         LS_DISP2 LIKE  GS_DISP,
         LS_DISP3 LIKE  GS_DISP.

  CLEAR : GT_DISP_TMP[], GT_DISP_TMP.

  IF S_GONGCD[] IS NOT INITIAL.
    DELETE GT_DISP WHERE GONG_CD NOT IN S_GONGCD.
  ENDIF.

  GT_DISP_TMP[] = GT_DISP[].

  IF P_R1 = 'X'. "생산오더별----------------------------------------------

    SORT GT_DISP BY AUFNR PMATN CMATN.

    LOOP AT GT_DISP INTO GS_DISP.

      LS_DISP1-WERKS    = GS_DISP-WERKS.    "플랜트
      LS_DISP1-AUFNR    = GS_DISP-AUFNR.    "생산오더
      LS_DISP1-ZORDSTAT = GS_DISP-ZORDSTAT. "오더상태
      LS_DISP1-PMATN    = GS_DISP-PMATN.    "모품목코드
      LS_DISP1-PMAKTX   = GS_DISP-PMAKTX.   "모품목내역
      LS_DISP1-GMEIN    = GS_DISP-GMEIN.    "생산단위
      LS_DISP1-AMEIN    = GS_DISP-AMEIN.    "생산단위
      LS_DISP1-CMATN    = GS_DISP-CMATN.    "자품목코드
      LS_DISP1-CMAKTX   = GS_DISP-CMAKTX.   "자품목내역
      LS_DISP1-MEINS    = GS_DISP-MEINS.    "출고단위
      LS_DISP1-DISPO    = GS_DISP-DISPO.    "MRP관리자
      LS_DISP1-MTART    = GS_DISP-MTART.
      LS_DISP1-MATKL    = GS_DISP-MATKL.

      LS_DISP1-ZPJNO     = GS_DISP-ZPJNO.
      LS_DISP1-BSTNK     = GS_DISP-BSTNK.
      LS_DISP1-ZPTXT     = GS_DISP-ZPTXT.
      LS_DISP1-ZJOB_NAME = GS_DISP-ZJOB_NAME.

      LS_DISP1-GAMNG     = GS_DISP-GAMNG. "생산오더수량
      LS_DISP1-WEMNG     = GS_DISP-WEMNG. "생산입고수량
      LS_DISP1-BDMNG     = GS_DISP-BDMNG. "소요량(생산오더수량 기준)
      LS_DISP1-MENGE     = GS_DISP-MENGE. "생산투입수량
      LS_DISP1-ZSTAT     = GS_DISP-ZSTAT.  " 백로그 유무
      LS_DISP1-STATS_SUGI    = GS_DISP-STATS_SUGI.  " 수기투입여부
      LS_DISP1-ZCUMNG    = GS_DISP-ZCUMNG.
      LS_DISP1-ZQTYDIF   = GS_DISP-ZQTYDIF.
      LS_DISP1-WAERS     = GS_DISP-WAERS.
      LS_DISP1-GONG_CD   = GS_DISP-GONG_CD.
      LS_DISP1-ARBPL     = GS_DISP-ARBPL.
      LS_DISP1-KTEXT     = GS_DISP-KTEXT.
      LS_DISP1-KGW_CU_GR = GS_DISP-KGW_CU_GR.
      LS_DISP1-KGW_AL_GR = GS_DISP-KGW_AL_GR.
      LS_DISP1-BME_GR    = GS_DISP-BME_GR.
      LS_DISP1-KGW_CU_GI = GS_DISP-KGW_CU_GI.
      LS_DISP1-KGW_AL_GI = GS_DISP-KGW_AL_GI.
      LS_DISP1-BME_GI    = GS_DISP-BME_GI.

      LS_DISP1-ID       = GS_DISP-ID.

      APPEND LS_DISP1 TO GT_DISP1.
    ENDLOOP.



    "투입율(%) / 투입상태 셋팅
    PERFORM SET_RATE_CLASS TABLES GT_DISP1.
    " 상태 선택 체크
    DELETE GT_DISP1 WHERE ZDELFLAG = 'X'.

    LOOP AT GT_DISP1 INTO GS_DISP.
      " 표준가 차이금액
      CLEAR GT_MBEWH.
      READ TABLE GT_MBEWH WITH KEY MATNR  = GS_DISP-CMATN
                                   BWKEY  = GS_DISP-WERKS
                         BINARY SEARCH.
      IF SY-SUBRC = 0.
        GS_DISP-STPRS = ( GT_MBEWH-STPRS / GT_MBEWH-PEINH ).
*// Modified by ZGODEV06 on 2026-06-09 {
*       gs_disp-zamtdif = ( gt_mbewh-stprs * gs_disp-zqtydif ).
        GS_DISP-ZAMTDIF = ( GS_DISP-STPRS * GS_DISP-ZQTYDIF ).
*// }
      ENDIF.
      MODIFY GT_DISP1 FROM GS_DISP.
    ENDLOOP.


    SELECT B~*
      FROM @GT_DISP1 AS A
      INNER JOIN ZGTPPT1180 AS B ON B~AUFNR = A~AUFNR
                                AND B~PMATN = A~PMATN
                                AND B~CMATN = A~CMATN
                                AND B~CHK_INSPECTION = 'Y'
      INTO TABLE @DATA(LT_1180).
    IF P_C6 = ABAP_TRUE.
      LOOP AT LT_1180 INTO DATA(LS_1180) WHERE CHK_INSPECTION = 'Y'.
        DELETE GT_DISP1 WHERE AUFNR = LS_1180-AUFNR
                          AND PMATN = LS_1180-PMATN
                          AND CMATN = LS_1180-CMATN .
      ENDLOOP.
    ELSE.
      LOOP AT LT_1180 INTO LS_1180 WHERE CHK_INSPECTION = 'Y'.
        READ TABLE GT_DISP1 ASSIGNING FIELD-SYMBOL(<LS_INSPECTION>) WITH KEY AUFNR = LS_1180-AUFNR
                                                                             PMATN = LS_1180-PMATN
                                                                             CMATN = LS_1180-CMATN .
        IF SY-SUBRC EQ 0.
          <LS_INSPECTION>-CHK_INSPECTION = 'Y'.
        ENDIF.
      ENDLOOP.
    ENDIF.

***    PERFORM check_isdd1.

  ELSEIF P_R2 = 'X'. "모품목별-------------------------------------------

    SORT GT_DISP BY AUFNR PMATN CMATN.

    LOOP AT GT_DISP INTO GS_DISP..
      GS_DISP-AUFNR    = ''.    "생산오더
*      GS_disp-zordstat = ''.    "오더상태
      MODIFY GT_DISP FROM GS_DISP.
    ENDLOOP.

    SORT GT_DISP BY  PMATN CMATN.
    LOOP AT GT_DISP INTO GS_DISP.

      LS_DISP2-WERKS    = GS_DISP-WERKS.    "플랜트
      LS_DISP2-AUFNR    = ''.    "생산오더
      LS_DISP2-ZORDSTAT = ''.    "오더상태
      LS_DISP2-PMATN    = GS_DISP-PMATN.    "모품목코드
      LS_DISP2-PMAKTX   = GS_DISP-PMAKTX.   "모품목내역
      LS_DISP2-GMEIN    = GS_DISP-GMEIN.    "생산단위
      LS_DISP2-CMATN    = GS_DISP-CMATN.    "자품목코드
      LS_DISP2-CMAKTX   = GS_DISP-CMAKTX.   "자품목내역
      LS_DISP2-MEINS    = GS_DISP-MEINS.    "출고단위
      LS_DISP2-DISPO    = GS_DISP-DISPO.    "MRP관리자
      LS_DISP2-MTART    = GS_DISP-MTART.
      LS_DISP2-MATKL    = GS_DISP-MATKL.

      LS_DISP2-ZPJNO       = GS_DISP-ZPJNO.
      LS_DISP2-BSTNK       = GS_DISP-BSTNK.
      LS_DISP2-ZPTXT       = GS_DISP-ZPTXT.
      LS_DISP2-ZJOB_NAME   = GS_DISP-ZJOB_NAME.
      LS_DISP2-ZSTAT       = GS_DISP-ZSTAT.  " 백로그 유무
      LS_DISP2-WAERS       = GS_DISP-WAERS.

      LV_GAMNG_SUM = LV_GAMNG_SUM + GS_DISP-GAMNG. "생산오더수량
      LV_WEMNG_SUM = LV_WEMNG_SUM + GS_DISP-WEMNG. "생산입고수량
      LV_BDMNG_SUM = LV_BDMNG_SUM + GS_DISP-BDMNG. "소요량(생산오더수량 기준)
      LV_MENGE_SUM = LV_MENGE_SUM + GS_DISP-MENGE. "생산투입수량
      LV_ZCUMNG_SUM  = LV_ZCUMNG_SUM + GS_DISP-ZCUMNG. "소요량(생산입고수량 기준)
      LV_ZQTYDIF_SUM = LV_ZQTYDIF_SUM + GS_DISP-ZQTYDIF. "차이수량

      AT END OF CMATN. "자품목코드
        LS_DISP2-GAMNG = LV_GAMNG_SUM.
        LS_DISP2-WEMNG = LV_WEMNG_SUM.
        LS_DISP2-BDMNG = LV_BDMNG_SUM.
        LS_DISP2-MENGE = LV_MENGE_SUM.
        LS_DISP2-ZCUMNG = LV_ZCUMNG_SUM.
        LS_DISP2-ZQTYDIF = LV_ZQTYDIF_SUM.
        APPEND LS_DISP2 TO GT_DISP2..
        CLEAR : LV_GAMNG_SUM, LV_WEMNG_SUM,
                LV_BDMNG_SUM, LV_MENGE_SUM,
                LV_ZCUMNG_SUM, LV_ZQTYDIF_SUM.
        CLEAR : LS_DISP2.
      ENDAT.

    ENDLOOP.
    "투입율(%) / 투입상태 셋팅
    PERFORM SET_RATE_CLASS TABLES GT_DISP2.
    " 상태 선택 체크
    DELETE GT_DISP2 WHERE ZDELFLAG = 'X'.


    LOOP AT GT_DISP2 INTO GS_DISP.
      " 표준가 차이금액
      CLEAR GT_MBEWH.
      READ TABLE GT_MBEWH WITH KEY MATNR  = GS_DISP-CMATN
                                   BWKEY  = GS_DISP-WERKS
                         BINARY SEARCH.
      IF SY-SUBRC = 0.
        GS_DISP-STPRS = ( GT_MBEWH-STPRS / GT_MBEWH-PEINH ).
*// Modified by ZGODEV06 on 2026-04-20 {
*       GS_DISP-ZAMTDIF = ( GT_MBEWH-STPRS *  GS_DISP-ZQTYDIF ).
        GS_DISP-ZAMTDIF = ( GS_DISP-STPRS * GS_DISP-ZQTYDIF ).
*// }

      ENDIF.
      MODIFY GT_DISP2 FROM GS_DISP.
    ENDLOOP.
***    PERFORM check_isdd2.


  ELSEIF P_R3 = 'X'. "자품목별-------------------------------------------


    SORT GT_DISP BY AUFNR PMATN CMATN.

    LOOP AT GT_DISP INTO GS_DISP.
*      GS_disp-werks    = ''.    "플랜트
      GS_DISP-AUFNR    = ''.    "생산오더
*      GS_disp-zordstat = ''.    "오더상태
      GS_DISP-PMATN    = ''.    "모품목코드
*      GS_disp-pmaktx   = ''.   "모품목내역
*      GS_disp-gmein    = ''.    "생산단위
      MODIFY GT_DISP FROM GS_DISP.
    ENDLOOP.

    SORT GT_DISP BY  CMATN.

    LOOP AT GT_DISP INTO GS_DISP.

      LS_DISP3-WERKS    = ''.    "플랜트
      LS_DISP3-AUFNR    = ''.    "생산오더
      LS_DISP3-ZORDSTAT = ''.    "오더상태
      LS_DISP3-PMATN    = ''.    "모품목코드
      LS_DISP3-PMAKTX   = ''.   "모품목내역
      LS_DISP3-GMEIN    = ''.    "생산단위
      LS_DISP3-CMATN    = GS_DISP-CMATN.    "자품목코드
      LS_DISP3-CMAKTX   = GS_DISP-CMAKTX.   "자품목내역
      LS_DISP3-MEINS    = GS_DISP-MEINS.    "출고단위
      LS_DISP3-DISPO    = GS_DISP-DISPO.    "MRP관리자
      LS_DISP3-MTART    = GS_DISP-MTART.

      LS_DISP3-ZPJNO       = GS_DISP-ZPJNO.
      LS_DISP3-BSTNK       = GS_DISP-BSTNK.
      LS_DISP3-ZPTXT       = GS_DISP-ZPTXT.
      LS_DISP3-ZJOB_NAME   = GS_DISP-ZJOB_NAME.
      LS_DISP3-ZSTAT       = GS_DISP-ZSTAT.  " 백로그 유무
      LS_DISP3-WAERS       = GS_DISP-WAERS.

      LV_GAMNG_SUM = LV_GAMNG_SUM + GS_DISP-GAMNG. "생산오더수량
      LV_WEMNG_SUM = LV_WEMNG_SUM + GS_DISP-WEMNG. "생산입고수량
      LV_BDMNG_SUM = LV_BDMNG_SUM + GS_DISP-BDMNG. "소요량(생산오더수량 기준)
      LV_MENGE_SUM = LV_MENGE_SUM + GS_DISP-MENGE. "생산투입수량
      LV_ZCUMNG_SUM  = LV_ZCUMNG_SUM + GS_DISP-ZCUMNG. "소요량(생산입고수량 기준)
      LV_ZQTYDIF_SUM = LV_ZQTYDIF_SUM + GS_DISP-ZQTYDIF. "차이수량

      AT END OF CMATN. "자품목코드
        LS_DISP3-GAMNG = LV_GAMNG_SUM.
        LS_DISP3-WEMNG = LV_WEMNG_SUM.
        LS_DISP3-BDMNG = LV_BDMNG_SUM.
        LS_DISP3-MENGE = LV_MENGE_SUM.

*        ls_disp-zcumng = ( ls_disp-bdmng * ls_disp-wemng ) / ls_disp-gamng.
        LS_DISP3-ZCUMNG = LV_ZCUMNG_SUM.
*        ls_disp-zqtydif = ls_disp-menge - ls_disp-zcumng.
        LS_DISP3-ZQTYDIF = LV_ZQTYDIF_SUM.
        APPEND LS_DISP3 TO GT_DISP3..
        CLEAR : LV_GAMNG_SUM, LV_WEMNG_SUM,
                LV_BDMNG_SUM, LV_MENGE_SUM,
                LV_ZCUMNG_SUM, LV_ZQTYDIF_SUM.
        CLEAR : LS_DISP3.
      ENDAT.

    ENDLOOP.
    "투입율(%) / 투입상태 셋팅
    PERFORM SET_RATE_CLASS TABLES GT_DISP3 .
    " 상태 선택 체크
    DELETE GT_DISP3 WHERE ZDELFLAG = 'X'.

    LOOP AT GT_DISP3 INTO GS_DISP.
      " 표준가 차이금액
      CLEAR GT_MBEWH.
      READ TABLE GT_MBEWH WITH KEY MATNR  = GS_DISP-CMATN
                                   BWKEY  = GS_DISP-WERKS
                         BINARY SEARCH.
      IF SY-SUBRC = 0.
        GS_DISP-STPRS = ( GT_MBEWH-STPRS / GT_MBEWH-PEINH ).
*// Modified by ZGODEV06 on 2026-06-09 {
*       gs_disp-zamtdif = ( gt_mbewh-stprs * gs_disp-zqtydif ).
        GS_DISP-ZAMTDIF = ( GS_DISP-STPRS * GS_DISP-ZQTYDIF ).
*// }
      ENDIF.
      MODIFY GT_DISP3 FROM GS_DISP.
    ENDLOOP.
***    PERFORM check_isdd3.

  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_rate_class
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GT_DISP1
*&---------------------------------------------------------------------*
FORM SET_RATE_CLASS  TABLES  PT_DISP STRUCTURE GS_DISP.

  DATA : LS_DISP LIKE  GS_DISP.
  DATA : LV_INPUT(10)  TYPE P DECIMALS 3,
         LV_OUTPUT(10) TYPE P DECIMALS 2.


  "투입율(%) / 투입상태 셋팅
  CLEAR : LS_DISP.
  LOOP AT PT_DISP INTO LS_DISP.

    "소요량(생산입고수량 기준) = 소요량(생산오더수량 기준)
    "* (생산입고수량) /(생산오더수량)
***    ls_disp-zcumng = ( ls_disp-bdmng * ls_disp-wemng ) / ls_disp-gamng.

    "차이수량 =(생산투입수량) - 소요량(생산입고수량 기준)
    LS_DISP-ZQTYDIF = LS_DISP-MENGE - LS_DISP-ZCUMNG.

    "투입율(%) / 투입상태
    "소요량(생산오더수량 기준)" (BDMNG) = 0 인 경우
    " (계획된 자재소요량이 없는 경우 (RESB에 정보 없음))
    IF LS_DISP-BDMNG = 0.
      IF LS_DISP-MENGE > 0.
        LS_DISP-ZGIRATE = '9999.999'.
      ELSEIF  LS_DISP-MENGE = 0.
        LS_DISP-ZGIRATE = '0'.
      ELSEIF LS_DISP-MENGE < 0.
        LS_DISP-ZGIRATE = '-9999.999'.
      ENDIF.
      LS_DISP-ZCLASS = '비계획투입'.
    ENDIF.

    "소요량(생산오더수량 기준)" (BDMNG) <> 0 인 경우
    IF LS_DISP-BDMNG <> 0.
      IF LS_DISP-ZCUMNG = 0. "소요량(생산입고수량 기준) = 0 일 때
***        IF ls_disp-menge > 0. " 생산 투입수량과 비교
***          ls_disp-zgirate = '9999.999'.
***        ELSEIF  gs_disp-menge = 0.
***          ls_disp-zgirate = '0'.
***        ELSEIF ls_disp-menge < 0.
***          ls_disp-zgirate = '-9999.999'.
***        ENDIF.
        LS_DISP-ZGIRATE = '0'.

        IF ( LS_DISP-ZGIRATE >= S_NUMC-LOW
            AND LS_DISP-ZGIRATE <= S_NUMC-HIGH ).
          LS_DISP-ZCLASS = '적정투입'.
        ELSEIF  S_NUMC-LOW > LS_DISP-ZGIRATE.
          IF LS_DISP-ZGIRATE = '0'.
            LS_DISP-ZCLASS = '적정투입'.
          ELSE.
            LS_DISP-ZCLASS = '과소투입'.
          ENDIF.
        ELSEIF  S_NUMC-HIGH < LS_DISP-ZGIRATE.
          IF LS_DISP-ZGIRATE = '0'.
            LS_DISP-ZCLASS = '적정투입'.
          ELSE.
            LS_DISP-ZCLASS = '과다투입'.
          ENDIF.
        ENDIF.

        " 차이수량도 무조건 0으로 한다
        LS_DISP-ZQTYDIF = 0.

      ENDIF.

      IF LS_DISP-ZCUMNG <> 0. "소요량(생산입고수량 기준) <> 0 일 때
        IF ( LS_DISP-MENGE > 0 AND LS_DISP-ZCUMNG > 0 ).
          LS_DISP-ZGIRATE = ( LS_DISP-MENGE / LS_DISP-ZCUMNG ) * 100.
        ELSE.
          LS_DISP-ZGIRATE = 0.
        ENDIF.
        IF ( LS_DISP-ZGIRATE >= S_NUMC-LOW
            AND LS_DISP-ZGIRATE <= S_NUMC-HIGH ).
          LS_DISP-ZCLASS = '적정투입'.
        ELSEIF  S_NUMC-LOW > LS_DISP-ZGIRATE.
          LS_DISP-ZCLASS = '과소투입'.
        ELSEIF  S_NUMC-HIGH < LS_DISP-ZGIRATE.
          LS_DISP-ZCLASS = '과다투입'.
        ENDIF.
      ENDIF.

    ENDIF.

    CALL FUNCTION 'FIMA_NUMERICAL_VALUE_ROUND'
      EXPORTING
        I_RTYPE     = '-'         "   ' ' : 반올림, + 올림  - 버림
        I_RUNIT     = '0.01'      "  소수점 자리수 지정
        I_VALUE     = LS_DISP-ZGIRATE "lv_input
      IMPORTING
        E_VALUE_RND = LV_OUTPUT.

    CLEAR : LS_DISP-ZGIRATE.
    LS_DISP-ZGIRATE   =  LV_OUTPUT.
    LS_DISP-ZGIRATE_D =  LV_OUTPUT.

    IF P_R1 = 'X'. "생산오더별
      MODIFY GT_DISP1 FROM LS_DISP.
    ELSEIF P_R2 = 'X'. "모품목별
      MODIFY GT_DISP2 FROM LS_DISP.
    ELSEIF P_R3 = 'X'. "자품목별
      MODIFY GT_DISP3 FROM LS_DISP.
    ENDIF.

  ENDLOOP.

  " 추후 DATA 확인 후 반영
***  LOOP AT pt_disp INTO ls_disp.
***
***    ls_disp-zcumng = ls_disp-zcumng / ls_disp-gamng.
***
***    IF p_r1 = 'X'. "생산오더별
***      MODIFY gt_disp1 FROM ls_disp.
***    ELSEIF p_r2 = 'X'. "모품목별
***      MODIFY gt_disp2 FROM ls_disp.
***    ELSEIF p_r3 = 'X'. "자품목별
***      MODIFY gt_disp3 FROM ls_disp.
***    ENDIF.
***
***  ENDLOOP.

  "투입율(%) / 투입상태 조회 확인
  LOOP AT PT_DISP INTO LS_DISP.
    IF P_C1 <> 'X'. "적정 투입
      IF LS_DISP-ZCLASS = '적정투입'.
        LS_DISP-ZDELFLAG = 'X'.
      ENDIF.
    ENDIF.
    IF  P_C2 <> 'X'. "과소 투입
      IF LS_DISP-ZCLASS = '과소투입'.
        LS_DISP-ZDELFLAG = 'X'.
      ENDIF.
    ENDIF.
    IF  P_C3 <> 'X'. "과다 투입
      IF LS_DISP-ZCLASS = '과다투입'.
        LS_DISP-ZDELFLAG = 'X'.
      ENDIF.
    ENDIF.
    IF  P_C4 <> 'X'. "비계획 투입
      IF LS_DISP-ZCLASS = '비계획투입'.
        LS_DISP-ZDELFLAG = 'X'.
      ENDIF.
    ENDIF.

    IF P_R1 = 'X'. "생산오더별
      MODIFY GT_DISP1 FROM LS_DISP.
    ELSEIF P_R2 = 'X'. "모품목별
      MODIFY GT_DISP2 FROM LS_DISP.
    ELSEIF P_R3 = 'X'. "자품목별
      MODIFY GT_DISP3 FROM LS_DISP.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form authority_checking_proc
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM AUTHORITY_CHECKING_PROC .
*& 플랜트에 대한 권한체크
  AUTHORITY-CHECK OBJECT 'ZPP_WERKS'
  ID 'WERKS'  FIELD S_WERKS-LOW.

  IF SY-SUBRC <> 0.
    MESSAGE E006 WITH '플랜트[' S_WERKS-LOW
                      '] 작업권한을 확인하세요.'.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form input_value_check
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM INPUT_VALUE_CHECK .

  IF S_GSTRP[] IS INITIAL
    AND S_ISDD[] IS INITIAL.

    GV_CHECK_ERROR = 'N'.
    MESSAGE S013 DISPLAY LIKE 'E'..
    LEAVE LIST-PROCESSING.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_isdd
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_ISDD1 .

  SORT GT_DISP1 BY OBJNR.

  SELECT *
      INTO CORRESPONDING FIELDS OF TABLE @GT_CDSV
      FROM ISTATUSOBJSTSCHG
      FOR ALL ENTRIES IN @GT_DATA
      WHERE STATUSOBJECT EQ @GT_DATA-OBJNR
          AND STATUSCODE EQ 'E0001'
          AND STATUSISINACTIVE EQ @SPACE.
  SORT GT_CDSV BY STATUSOBJECT.
  DELETE GT_CDSV WHERE LASTCHANGEDATE NOT IN S_ISDD.

  LOOP AT GT_DATA INTO GS_DATA.
    READ TABLE GT_CDSV INTO GS_CDSV WITH KEY STATUSOBJECT = GS_DATA-OBJNR
                                    BINARY SEARCH.
    IF SY-SUBRC <> 0.
      GS_DATA-ZCDSFLAG = 'X'.
      MODIFY GT_DATA FROM GS_DATA.
    ENDIF.
  ENDLOOP.

  IF GT_DATA[] IS NOT INITIAL.
    SELECT *
        INTO CORRESPONDING FIELDS OF TABLE @GT_AFRU_MIN
        FROM AFRU
        FOR ALL ENTRIES IN @GT_DATA
        WHERE AUFNR EQ @GT_DATA-AUFNR
             AND RMZHL EQ ( SELECT MIN( RMZHL ) FROM AFRU
                                          WHERE AUFNR EQ @GT_DATA-AUFNR
                                               AND AUERU NE 'X'
                                               AND STOKZ EQ @SPACE
                                               AND STZHL EQ @SPACE ).
    SORT GT_AFRU_MIN BY AUFNR.
    DELETE GT_AFRU_MIN WHERE ISDD NOT IN S_ISDD.
  ENDIF.

  LOOP AT GT_DATA INTO GS_DATA.
    READ TABLE GT_AFRU_MIN  WITH KEY AUFNR = GS_DATA-AUFNR
                            BINARY SEARCH .
    IF SY-SUBRC <> 0.
      GS_DATA-ZAFRUFLAG = 'X'.
      MODIFY GT_DATA FROM GS_DATA.
    ENDIF.
  ENDLOOP.

  DELETE GT_DATA WHERE ZAFRUFLAG  = 'X' AND  ZCDSFLAG  = 'X'..

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_isdd2
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_ISDD2 .

  SORT GT_DISP2 BY OBJNR.

  SELECT *
      INTO CORRESPONDING FIELDS OF TABLE @GT_CDSV
      FROM ISTATUSOBJSTSCHG
      FOR ALL ENTRIES IN @GT_DISP2
      WHERE STATUSOBJECT EQ @GT_DISP2-OBJNR
          AND STATUSCODE EQ 'E0001'
          AND STATUSISINACTIVE EQ @SPACE.

  LOOP AT GT_DISP2 INTO GS_DISP.
    READ TABLE GT_CDSV INTO GS_CDSV WITH KEY STATUSOBJECT = GS_DISP-OBJNR.
    IF SY-SUBRC = 0.
      GS_DISP-ZCDSFLAG = 'X'.
      MODIFY GT_DISP2 FROM GS_DISP.
    ENDIF.
  ENDLOOP.

  DELETE GT_DISP2 WHERE ZCDSFLAG  = 'X'.

  SELECT *
      INTO CORRESPONDING FIELDS OF TABLE @GT_AFRU_MIN
      FROM AFRU
      FOR ALL ENTRIES IN @GT_DISP2
      WHERE AUFNR EQ @GT_DISP2-AUFNR
           AND RMZHL EQ ( SELECT MIN( RMZHL ) FROM AFRU
                                        WHERE AUFNR EQ @GT_DISP2-AUFNR
                                             AND AUERU NE 'X'
                                             AND STOKZ EQ @SPACE
                                             AND STZHL EQ @SPACE ).

  LOOP AT GT_DISP2 INTO GS_DISP.
    READ TABLE GT_AFRU_MIN  WITH KEY AUFNR = GS_DISP-AUFNR.
    IF SY-SUBRC = 0.
      GS_DISP-ZAFRUFLAG = 'X'.
      MODIFY GT_DISP2 FROM GS_DISP.
    ENDIF.
  ENDLOOP.

  DELETE GT_DISP2 WHERE ZAFRUFLAG  = 'X'.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_isdd3
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_ISDD3 .

  SORT GT_DISP3 BY OBJNR.

  SELECT *
      INTO CORRESPONDING FIELDS OF TABLE @GT_CDSV
      FROM ISTATUSOBJSTSCHG
      FOR ALL ENTRIES IN @GT_DISP3
      WHERE STATUSOBJECT EQ @GT_DISP3-OBJNR
          AND STATUSCODE EQ 'E0001'
          AND STATUSISINACTIVE EQ @SPACE.

  LOOP AT GT_DISP3 INTO GS_DISP.
    READ TABLE GT_CDSV INTO GS_CDSV WITH KEY STATUSOBJECT = GS_DISP-OBJNR.
    IF SY-SUBRC = 0.
      GS_DISP-ZCDSFLAG = 'X'.
      MODIFY GT_DISP3 FROM GS_DISP.
    ENDIF.
  ENDLOOP.

  DELETE GT_DISP3 WHERE ZCDSFLAG  = 'X'.

  SELECT *
      INTO CORRESPONDING FIELDS OF TABLE @GT_AFRU_MIN
      FROM AFRU
      FOR ALL ENTRIES IN @GT_DISP3
      WHERE AUFNR EQ @GT_DISP3-AUFNR
           AND RMZHL EQ ( SELECT MIN( RMZHL ) FROM AFRU
                                        WHERE AUFNR EQ @GT_DISP3-AUFNR
                                             AND AUERU NE 'X'
                                             AND STOKZ EQ @SPACE
                                             AND STZHL EQ @SPACE ).

  LOOP AT GT_DISP3 INTO GS_DISP.
    READ TABLE GT_AFRU_MIN  WITH KEY AUFNR = GS_DISP-AUFNR.
    IF SY-SUBRC = 0.
      GS_DISP-ZAFRUFLAG = 'X'.
      MODIFY GT_DISP3 FROM GS_DISP.
    ENDIF.
  ENDLOOP.

  DELETE GT_DISP3 WHERE ZAFRUFLAG  = 'X'.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_MATGIMIG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_MATGIMIG .
  DATA: LT_ROW_NO TYPE LVC_T_ROID WITH HEADER LINE,
        L_ANSWER  TYPE CHAR01.

  FIELD-SYMBOLS: <FS_S> LIKE GS_DISP.

  CLEAR: L_ANSWER.

  PERFORM SEL_ROW_RTN TABLES LT_ROW_NO
                      USING  GO_GRID_0100.

  IF LT_ROW_NO[] IS INITIAL.
    MESSAGE S003 DISPLAY LIKE 'W'
       WITH '실행 할 레코드를 선택하세요.'.
    EXIT.
  ENDIF.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = '자재 투입 조정'
      TEXT_QUESTION         = '자재 투입 조정을 수행하시겠습니까?'
      DISPLAY_CANCEL_BUTTON = SPACE
    IMPORTING
      ANSWER                = L_ANSWER.

  IF L_ANSWER = '1'.
    LOOP AT LT_ROW_NO.
      READ TABLE GT_DISP1 ASSIGNING <FS_S> INDEX LT_ROW_NO-ROW_ID.

      IF <FS_S>-ZCLASS EQ '비계획투입'.
        <FS_S>-ID = ICON_LED_RED.
        <FS_S>-RTMSG = '투입상태 과소투입/과다투입만 처리 가능합니다.'.
      ELSE.
        IF <FS_S>-MEINS NE 'SET' AND <FS_S>-MEINS NE 'EA'.
          <FS_S>-ID = ICON_LED_RED.
          <FS_S>-RTMSG = '출고 단위가 SET 또는 EA가 아닙니다.'.
        ELSE.
          IF <FS_S>-GAMNG NE <FS_S>-WEMNG.
            <FS_S>-ID = ICON_LED_RED.
            <FS_S>-RTMSG = '생산오더수량과 입고수량이 같지 않습니다.'.
          ELSE.
            IF <FS_S>-ZQTYDIF EQ 0.
              <FS_S>-ID = ICON_LED_RED.
              <FS_S>-RTMSG = '차이수량이 없어 조정할 대상이 없습니다.'.
            ELSE.
              SELECT SINGLE DEL, DLFL, LKD, TECO, CLSD
                FROM ZGTPP_CV_ORD_STAT
               WHERE AUFNR EQ @<FS_S>-AUFNR
                 AND WERKS EQ @<FS_S>-WERKS
                INTO @DATA(LS_ORDSTAT).

              IF LS_ORDSTAT-DEL EQ 'X' OR
                 LS_ORDSTAT-DLFL EQ 'X' OR
                 LS_ORDSTAT-LKD EQ 'X' OR
                 LS_ORDSTAT-TECO EQ 'X' OR
                 LS_ORDSTAT-CLSD EQ 'X'.
                <FS_S>-ID = ICON_LED_RED.
                <FS_S>-RTMSG = '생산오더 상태가 처리불가한 상태입니다.'.
              ELSE.
                "선택한 생산오더의 101 전기일자
                CLEAR: GV_BUDAT.
                SELECT MAX( BUDAT )
                  FROM MATDOC
                 WHERE AUFNR EQ @<FS_S>-AUFNR
                   AND WERKS EQ @<FS_S>-WERKS
                   AND BWART EQ '101'
                   AND CANCELLED EQ @SPACE
                  INTO @GV_BUDAT.

                IF GV_BUDAT+0(6) NE SY-DATUM+0(6).
                  <FS_S>-ID = ICON_LED_RED.
                  <FS_S>-RTMSG = '마지막 입고일자가 현재월 이전이므로 투입 취소할 수 없습니다.'.
                ELSE.
                  PERFORM EXEC_MATGIMIG USING <FS_S>.
                ENDIF.
              ENDIF.
            ENDIF.
          ENDIF.
        ENDIF.
      ENDIF.
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

  CASE PO_GRID.
    WHEN GO_GRID_0100.
      CALL METHOD PO_GRID->SET_FRONTEND_LAYOUT
        EXPORTING
          IS_LAYOUT = GS_LAYOUT_0100.
  ENDCASE.

  CALL METHOD PO_GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
      I_SOFT_REFRESH = 'X'
      IS_STABLE      = LS_STABLE
    EXCEPTIONS
      FINISHED       = 1
      OTHERS         = 2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form EXEC_MATGIMIG
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> <FS_S>
*&---------------------------------------------------------------------*
FORM EXEC_MATGIMIG  USING    P_LINE LIKE GS_DISP.

  DATA: LS_HEADER    TYPE BAPI2017_GM_HEAD_01,
        LT_ITEM      TYPE TABLE OF BAPI2017_GM_ITEM_CREATE,
        LV_CODE      TYPE BAPI2017_GM_CODE VALUE '03',
        LV_DOCUMENT  TYPE BAPI2017_GM_HEAD_RET-MAT_DOC,
        LV_YEAR      TYPE BAPI2017_GM_HEAD_RET-DOC_YEAR,
        LS_GMHEADRET LIKE BAPI2017_GM_HEAD_RET,
        LT_RETURN    TYPE TABLE OF BAPIRET2.

  DATA: LV_LGORT LIKE RESB-LGORT,
        LV_BWART LIKE MATDOC-BWART,
        LV_ERFMG LIKE MATDOC-ERFMG.

*-선택한 자품목 출고 저장위치
  CLEAR: LV_LGORT.
  SELECT SINGLE LGORT
    FROM RESB
   WHERE AUFNR EQ @P_LINE-AUFNR
     AND WERKS EQ @P_LINE-WERKS
     AND MATNR EQ @P_LINE-CMATN
    INTO @LV_LGORT.

  CLEAR: LV_BWART.
  IF P_LINE-ZCLASS EQ '과소투입'.
    LV_BWART = '261'.
  ELSEIF P_LINE-ZCLASS EQ '과다투입'.
    LV_BWART = '262'.
  ENDIF.

  CLEAR: LV_ERFMG.
  LV_ERFMG = ABS( P_LINE-ZQTYDIF ).

  CLEAR: LS_HEADER, LT_ITEM.

  LS_HEADER = VALUE #( PSTNG_DATE = GV_BUDAT
                       DOC_DATE   = GV_BUDAT
                       PR_UNAME   = SY-UNAME
                       HEADER_TXT = 'ZGTPPR1040' ).

  LT_ITEM = VALUE #( ( MATERIAL       = P_LINE-CMATN
                       PLANT          = P_LINE-WERKS
                       STGE_LOC       = LV_LGORT
                       BATCH          = SPACE
                       MOVE_TYPE      = LV_BWART
                       STCK_TYPE      = 'F'
                       ENTRY_QNT      = LV_ERFMG
                       ENTRY_UOM      = P_LINE-MEINS
                       ORDERID        = P_LINE-AUFNR ) ).

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

    READ TABLE LT_RETURN INTO DATA(LS_RETURN) WITH KEY TYPE = 'E'.
    P_LINE-ID = ICON_LED_RED.
    P_LINE-RTMSG = LS_RETURN-MESSAGE.

    CLEAR: LS_RETURN.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.

    P_LINE-ID = ICON_LED_GREEN.
    P_LINE-RTMSG = '조정 처리에 성공하였습니다.'.
    P_LINE-ZCLASS = '적정투입'.
    P_LINE-ZQTYDIF = 0.

    REFRESH: P_LINE-CELLSCOL.
    CLEAR: P_LINE-CELLSCOL.

    WAIT UP TO '0.5' SECONDS.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHK_COCKPIT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHK_COCKPIT .
  DATA: LV_CKP(1).
  IMPORT CKP TO LV_CKP FROM MEMORY ID 'CKP'.
  FREE MEMORY ID 'CKP'.

  IF LV_CKP EQ 'X'.
    EXPORT CKP = 'S' TO MEMORY ID 'CKP'.
    CLEAR: LV_CKP.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form F4_GONG_CD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&---------------------------------------------------------------------*
FORM F4_GONG_CD  USING    PV_DYNPROFLD TYPE HELP_INFO-DYNPROFLD .

  DATA : BEGIN OF LS_GONG,
           GONG_CD TYPE ZEDT0011-GONG_CD,
           GONG_NM TYPE ZEDT0011-GONG_NM,
         END OF LS_GONG.
  DATA : LT_GONG LIKE TABLE OF LS_GONG.

  DATA : LT_RETURN_TAB TYPE TABLE OF DDSHRETVAL,
         LS_RETURN_TAB LIKE LINE OF LT_RETURN_TAB.

  DATA : LV_OFFSET(6) TYPE N.
  DATA : LO_FLIEF TYPE REF TO DATA.

  DATA : LT_FIELD_TAB TYPE TABLE OF DFIES.
  DATA : LO_STRUCTDESCR TYPE REF TO CL_ABAP_STRUCTDESCR.

  DATA : LV_LINE       LIKE SY-STEPL,
         LT_DYNPFIELDS LIKE TABLE OF DYNPREAD.

  SELECT DISTINCT B~GONG_CD, C~GONG_NM
    INTO CORRESPONDING FIELDS OF TABLE @LT_GONG
    FROM T001K AS A
    INNER JOIN ZEDT0010 AS B ON B~BUKRS = A~BUKRS
    INNER JOIN ZEDT0011 AS C ON C~GONG_CD = B~GONG_CD
    INNER JOIN ZPPT0107 AS E ON E~SPART = B~SPART
                                     AND E~WERKS = A~BWKEY
   WHERE A~BWKEY IN @S_WERKS.

  SORT LT_GONG BY GONG_CD.

* 필드 속성 정의
  FREE LO_FLIEF.
  CREATE DATA LO_FLIEF LIKE LS_GONG.

  LO_STRUCTDESCR ?= CL_ABAP_STRUCTDESCR=>DESCRIBE_BY_DATA_REF( LO_FLIEF ).
  LT_FIELD_TAB = CL_SALV_DATA_DESCR=>READ_STRUCTDESCR( LO_STRUCTDESCR ).

  CLEAR LV_OFFSET.
  LOOP AT LT_FIELD_TAB ASSIGNING FIELD-SYMBOL(<LS_FIELD_TAB>).

    CASE <LS_FIELD_TAB>-FIELDNAME.
      WHEN 'GONG_CD'.
        <LS_FIELD_TAB>-REPTEXT  = '공정'.
      WHEN 'GONG_NM'.
        <LS_FIELD_TAB>-REPTEXT  = '공정명'.
    ENDCASE.

    <LS_FIELD_TAB>-OFFSET = LV_OFFSET.
    LV_OFFSET = LV_OFFSET + <LS_FIELD_TAB>-INTLEN.
  ENDLOOP.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'  "F4 창 띄움
    EXPORTING
      RETFIELD        = 'GONG_CD'
      DYNPROFIELD     = PV_DYNPROFLD
      VALUE_ORG       = 'S'
      WINDOW_TITLE    = '공정 조회'
      DISPLAY         = 'F'
    TABLES
      FIELD_TAB       = LT_FIELD_TAB
      VALUE_TAB       = LT_GONG                  "부서코드, 부서명 가져온 인터널 테이블
      RETURN_TAB      = LT_RETURN_TAB            "F4에서 선택한 값이 들어옴
    EXCEPTIONS
      PARAMETER_ERROR = 1
      NO_VALUES_FOUND = 2
      OTHERS          = 3.

  READ TABLE LT_RETURN_TAB INTO LS_RETURN_TAB INDEX 1.
  IF SY-SUBRC EQ 0.
    READ TABLE LT_GONG INTO LS_GONG WITH KEY GONG_CD = LS_RETURN_TAB-FIELDVAL.

    REFRESH LT_DYNPFIELDS.
    PERFORM GET_STEPL USING LV_LINE.
*      공정
    APPEND INITIAL LINE TO LT_DYNPFIELDS ASSIGNING FIELD-SYMBOL(<LS_DYNPFIELDS>).
    <LS_DYNPFIELDS>-FIELDNAME = PV_DYNPROFLD.
    <LS_DYNPFIELDS>-STEPL = LV_LINE.
    <LS_DYNPFIELDS>-FIELDVALUE = LS_GONG-GONG_CD.

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
*& Form REFRESH_GRID
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GO_GRID_0100
*&---------------------------------------------------------------------*
FORM REFRESH_GRID  USING    PO_GRID TYPE REF TO CL_GUI_ALV_GRID..

  DATA: LS_SCROLL   TYPE LVC_S_STBL.

  LS_SCROLL-ROW = 'X'.
  LS_SCROLL-COL = 'X'.

  CASE PO_GRID.
    WHEN GO_GRID_0100.
      GO_GRID_0100->SET_FRONTEND_LAYOUT( IS_LAYOUT = GS_LAYOUT_0100 ).
  ENDCASE.

  CALL METHOD PO_GRID->REFRESH_TABLE_DISPLAY
    EXPORTING
*     I_SOFT_REFRESH = 'X'
      IS_STABLE = LS_SCROLL.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PROC_CONFIRM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PROC_CONFIRM .

  DATA : LT_ROWS TYPE LVC_T_ROW.
  DATA : LV_ANSWER  TYPE CHAR01.
  DATA : LT_1180 TYPE TABLE OF ZGTPPT1180.
  DATA : LS_1180 TYPE ZGTPPT1180.

  GO_GRID_0100->GET_SELECTED_ROWS(
    IMPORTING
      ET_INDEX_ROWS = LT_ROWS ).                 " Indexes of Selected Rows

  DELETE LT_ROWS WHERE INDEX = 0.

  IF LT_ROWS IS INITIAL.
    RETURN.
  ENDIF.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      TITLEBAR              = '점검 완료'
      TEXT_QUESTION         = '해당 생산오더의 자품목 점검 완료로 처리하시겠습니까?'
      DISPLAY_CANCEL_BUTTON = SPACE
    IMPORTING
      ANSWER                = LV_ANSWER.

  IF LV_ANSWER = '1'.
    LOOP AT LT_ROWS INTO DATA(LS_ROWS).
      READ TABLE GT_DISP1 ASSIGNING FIELD-SYMBOL(<LS_MAIN>) INDEX LS_ROWS-INDEX.
      <LS_MAIN>-CHK_INSPECTION = 'Y'.

      CLEAR LS_1180.
      MOVE-CORRESPONDING <LS_MAIN> TO LS_1180.
      APPEND LS_1180 TO LT_1180.

    ENDLOOP.

    IF LT_1180 IS NOT INITIAL.
      MODIFY ZGTPPT1180 FROM TABLE LT_1180.
      IF SY-SUBRC EQ 0.
        COMMIT WORK AND WAIT.
      ENDIF.

      MESSAGE S006 WITH '자품목 점검 완료로 처리되었습니다'.
      PERFORM REFRESH_GRID USING GO_GRID_0100.

    ENDIF.

  ENDIF.

ENDFORM.
