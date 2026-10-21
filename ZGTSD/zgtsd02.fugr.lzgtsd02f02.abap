*----------------------------------------------------------------------*
***INCLUDE LZGTSD02F02.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form crte_job_for_quotation
*&---------------------------------------------------------------------*
*& 시작업 생산요청 : Pgm. : ZGTSDR0060 수행 Batch Job 구성
*&---------------------------------------------------------------------*
*&      --> PV_ZPJNO    : 프로젝트 번호
*&      --> PV_VKORG    : 영업조직
*&      --> PV_CNT      : Count 정보
*&---------------------------------------------------------------------*
FORM CRTE_JOB_FOR_QUOTATION USING PV_ZPJNO  TYPE ZPJNO
                                  PV_VKORG  TYPE VKORG
                                  PV_CNT    TYPE I.

  DATA : LV_JOBNAME  LIKE TBTCJOB-JOBNAME,
         LV_JOBCOUNT LIKE TBTCJOB-JOBCOUNT,

         LR_ERDAT    TYPE RANGE OF ERDAT,
         LV_CNT_C    TYPE CHAR10.

  CLEAR : LV_JOBNAME, LV_JOBCOUNT,
          LR_ERDAT.

*-- Batch Job 명 구성
  WRITE PV_CNT TO LV_CNT_C.

  CONDENSE LV_CNT_C NO-GAPS.

*  lv_jobname = |ZGTSDR0060_I_KO_| && lv_cnt_c.

  CONCATENATE '[SD]C_BD_ZIRP생성_' PV_ZPJNO INTO LV_JOBNAME.

*-- 당일 기준 생성일 Range 조건 구성
  APPEND VALUE #(
                  SIGN   = 'I'
                  OPTION = 'EQ'
                  LOW    = SY-DATUM
                ) TO LR_ERDAT.


  CALL FUNCTION 'JOB_OPEN'
    EXPORTING
      JOBNAME          = LV_JOBNAME
    IMPORTING
      JOBCOUNT         = LV_JOBCOUNT
    EXCEPTIONS
      CANT_CREATE_JOB  = 1
      INVALID_JOB_DATA = 2
      JOBNAME_MISSING  = 3
      OTHERS           = 4.

  SUBMIT ZGTSDR0060 VIA JOB    LV_JOBNAME
                        NUMBER LV_JOBCOUNT
                    WITH P_VKORG EQ PV_VKORG
                    WITH P_ZPJNO EQ PV_ZPJNO
                    WITH S_ERDT1 IN LR_ERDAT
                    WITH P_CRTE  EQ ABAP_TRUE
                    WITH P_BATCH EQ ABAP_TRUE

                    AND RETURN.

  CALL FUNCTION 'JOB_CLOSE'
    EXPORTING
      JOBCOUNT             = LV_JOBCOUNT
      JOBNAME              = LV_JOBNAME
      STRTIMMED            = 'X'
    EXCEPTIONS
      CANT_START_IMMEDIATE = 1
      INVALID_STARTDATE    = 2
      JOBNAME_MISSING      = 3
      JOB_CLOSE_FAILED     = 4
      JOB_NOSTEPS          = 5
      JOB_NOTEX            = 6
      LOCK_FAILED          = 7
      OTHERS               = 8.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form chk_save_data_len_qty
*&---------------------------------------------------------------------*
*& 해당 저장정보기준 길이 / 수량 정합성 확인 수행
*&---------------------------------------------------------------------*
*&      --> PT_0065      : Table ZGTSDT0065 저장 정보
*&      --> PT_0066      : Table ZGTSDT0066 저장 정보
*&      --> PT_0067      : Table ZGTSDT0067 저장 정보
*&      <-- PV_RESULT    : 오류 발생시 '01' 리턴
*&      <-- PV_MESSAGE   : 오류 발생시 메세지 리턴
*&---------------------------------------------------------------------*
FORM CHK_SAVE_DATA_LEN_QTY  TABLES   PT_0065     STRUCTURE ZGTSDT0065
                                     PT_0066     STRUCTURE ZGTSDT0066
                                     PT_0067     STRUCTURE ZGTSDT0067
                            CHANGING PV_RESULT   TYPE ZO_RESULT
                                     PV_MESSAGE  TYPE ZO_MESSAGE.

  CONSTANTS LC_M TYPE MEINS VALUE 'M'.

  DATA : LT_0065   TYPE TABLE OF ZGTSDT0065 WITH EMPTY KEY,
         LT_0066   TYPE TABLE OF ZGTSDT0066 WITH EMPTY KEY,

         LV_LEN_66 TYPE ZGTE_BD_ORDLEN,
         LV_LEN_67 TYPE ZGTE_BD_ORDLEN,
         LV_QTY_67 TYPE ZGTE_BD_QQTY.

  LT_0065[] = CORRESPONDING #( PT_0065[] ).
  LT_0066[] = CORRESPONDING #( PT_0066[] ).

*-- 동일 Key 정보 기준 길이 정보 일치 여부 확인
  WITH +SUM_65 AS ( SELECT A~ZSYSTEM_ID, A~JOB_NO, A~POSNR, A~ITEM_KEY,
                           SUM( A~ORD_LEN ) AS ORD_LEN
                      FROM @LT_0065 AS A
                     GROUP BY A~ZSYSTEM_ID, A~JOB_NO, A~POSNR, A~ITEM_KEY )

    SELECT A~ZSYSTEM_ID,  A~JOB_NO,  A~POSNR,  A~ITEM_KEY,  A~ORD_LEN
      FROM +SUM_65 AS A

      INTO TABLE @DATA(LT_LEN_65).

*-- ZGTSDT0065 저장 정보 기준 길이 정보 일치성 확인
  LOOP AT LT_LEN_65 INTO DATA(LS_LEN_65) .
    CLEAR : LV_LEN_66, LV_LEN_67.

    LV_LEN_66 = REDUCE #( INIT LEN TYPE ZGTE_BD_ORDLEN
                          FOR SUM_66 IN PT_0066
                        WHERE ( ZSYSTEM_ID EQ LS_LEN_65-ZSYSTEM_ID AND
                                JOB_NO     EQ LS_LEN_65-JOB_NO     AND
                                POSNR      EQ LS_LEN_65-POSNR      AND
                                ITEM_KEY   EQ LS_LEN_65-ITEM_KEY   AND
                                QUNIT      EQ LC_M )
                        NEXT LEN = LEN + SUM_66-QQTY ).

    LV_LEN_67 = REDUCE #( INIT LEN TYPE ZGTE_BD_ORDLEN
                          FOR SUM_67 IN PT_0067
                        WHERE ( ZSYSTEM_ID EQ LS_LEN_65-ZSYSTEM_ID AND
                                JOB_NO     EQ LS_LEN_65-JOB_NO     AND
                                POSNR      EQ LS_LEN_65-POSNR      AND
                                ITEM_KEY   EQ LS_LEN_65-ITEM_KEY   AND
                                QUNIT      EQ LC_M )
                        NEXT LEN = LEN + SUM_67-QQTY ).

    PV_RESULT = COND #( WHEN LS_LEN_65-ORD_LEN NE LV_LEN_66 OR
                             LS_LEN_65-ORD_LEN NE LV_LEN_67 THEN |01|
                        ELSE PV_RESULT ).

    IF PV_RESULT EQ |01|.
      PV_MESSAGE = '데이터가 일치하지 않습니다.'(E05).
      EXIT.
    ENDIF.
  ENDLOOP.

  CHECK PV_RESULT NE |01|.

*-- 동일 Key 정보 기준 ZGTSDT0066, ZGTSDT0067 저장 정보 수량 정보 일치 여부 확인
  WITH +SUM_66 AS ( SELECT A~ZSYSTEM_ID, A~JOB_NO, A~POSNR, A~ITEM_KEY, A~QUNIT,
                           SUM( A~QQTY ) AS QQTY
                      FROM @LT_0066 AS A
                     GROUP BY A~ZSYSTEM_ID, A~JOB_NO, A~POSNR, A~ITEM_KEY, A~QUNIT )

    SELECT A~ZSYSTEM_ID,  A~JOB_NO,  A~POSNR,  A~ITEM_KEY,  A~QUNIT,  A~QQTY
      FROM +SUM_66 AS A

     INTO TABLE @DATA(LT_QTY_66).

  LOOP AT LT_QTY_66 INTO DATA(LS_QTY_66).
    CLEAR LV_QTY_67.

    LV_QTY_67 = REDUCE #( INIT QTY TYPE ZGTE_BD_QQTY
                          FOR SUM_67 IN PT_0067
                        WHERE ( ZSYSTEM_ID EQ LS_QTY_66-ZSYSTEM_ID AND
                                JOB_NO     EQ LS_QTY_66-JOB_NO     AND
                                POSNR      EQ LS_QTY_66-POSNR      AND
                                ITEM_KEY   EQ LS_QTY_66-ITEM_KEY   AND
                                QUNIT      EQ LS_QTY_66-QUNIT )
                         NEXT QTY = QTY + SUM_67-QQTY ).

    PV_RESULT = COND #( WHEN LS_QTY_66-QQTY NE LV_QTY_67 THEN |01|
                        ELSE PV_RESULT ).

    IF PV_RESULT EQ |01|.
      PV_MESSAGE = '데이터가 일치하지 않습니다.'(E05).
      EXIT.
    ENDIF.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BD_SD_WORK_0077_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> I_ZWERKS
*&      --> I_SYSTEM_ID
*&      --> I_ZTABLE
*&      --> I_ZKEY1
*&      <-- ZO_RESULT
*&      <-- ZO_MESSAGE
*&---------------------------------------------------------------------*
FORM BD_SD_WORK_0077_DATA  USING    PV_ZWERKS
                                    PV_SYSTEM_ID
                                    PV_ZTABLE
                                    PV_ZKEY1
                           CHANGING PV_RESULT
                                    PV_MESSAGE.


  DATA : LT_0077 TYPE TABLE OF ZGTSDT0077 WITH HEADER LINE,
         LT_T77  TYPE TABLE OF ZGTSDT0077 WITH EMPTY KEY,
         LT_D_77 TYPE TABLE OF ZGTSDT0077 WITH EMPTY KEY,
         LV_AMT  TYPE BAPICURR-BAPICURR,
         LS_2132 TYPE ZGTEDT2132,
         LT_2132 TYPE TABLE OF ZGTEDT2132 WITH NON-UNIQUE SORTED KEY K_KEY COMPONENTS ZTABLE.

  CONSTANTS : LC_KRW TYPE TCURC-WAERS VALUE 'KRW'.

  DEFINE __CONV_AMT.
    CONDENSE &1. LV_AMT = &1.
    CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_INTERNAL'
      EXPORTING
        CURRENCY             = LC_KRW
        AMOUNT_EXTERNAL      = LV_AMT
        MAX_NUMBER_OF_DIGITS = 18
      IMPORTING
        AMOUNT_INTERNAL      = &2.
  END-OF-DEFINITION.

  SELECT ZGTEDT2132~* INTO CORRESPONDING FIELDS OF TABLE @LT_2132
    FROM ZGTEDT2132
   WHERE ZSYSTEM_ID = @PV_SYSTEM_ID
     AND ZTABLE     = @PV_ZTABLE
     AND ZWERKS     = @PV_ZWERKS
     AND ZKEY1      = @PV_ZKEY1.
  IF SY-SUBRC NE 0.
    PV_RESULT = |01|.
    PV_MESSAGE = TEXT-E01.EXIT.
  ENDIF.

  SORT LT_2132 BY ZTABLE ZVALUE04.
  LOOP AT LT_2132 INTO LS_2132.

    LT_0077-ZSYSTEM     = LS_2132-ZSYSTEM_ID.
    LT_0077-JOB_NO      = LS_2132-ZKEY1.
    LT_0077-ZPJNO       = LS_2132-ZVALUE01.

    __CONV_AMT LS_2132-ZVALUE02 LT_0077-ROHCOST.     "제조원가-원재료비
    __CONV_AMT LS_2132-ZVALUE03 LT_0077-SUBCONCOST.  "제조원가-외주가공비
    __CONV_AMT LS_2132-ZVALUE04 LT_0077-INSULCOST.   "제조원가-절연비용
    __CONV_AMT LS_2132-ZVALUE05 LT_0077-CONDPRDCOST. "제조원가-도체가공비
    __CONV_AMT LS_2132-ZVALUE06 LT_0077-ASSYCOST.    "제조원가-조립가공비
    __CONV_AMT LS_2132-ZVALUE07 LT_0077-COGM.        "제조원가 총금액

*   한계이익
    LT_0077-CMAMT = LT_0077-COGM - ( LT_0077-ROHCOST + LT_0077-SUBCONCOST ).

*   한계이익률
    IF LT_0077-COGM NE 0.
      LT_0077-CMRTE = LT_0077-CMAMT / LT_0077-COGM * 100.
    ENDIF.

    LT_0077-WAERK       = |KRW|.

    LT_0077-ERDAT       = SY-DATUM.
    LT_0077-ERZEIT      = SY-UZEIT.
    LT_0077-ERNAM       = SY-UNAME.
    LT_0077-ERDATLO     = SY-DATLO.
    LT_0077-ERTIMLO     = SY-TIMLO.
    APPEND LT_0077. CLEAR LT_0077.
  ENDLOOP.

  IF LT_0077[] IS INITIAL.
    PV_RESULT = |01|.
    PV_MESSAGE = TEXT-E01.EXIT.
  ENDIF.

  LT_T77[] = CORRESPONDING #( LT_0077[] ).

*-- 기존 정보 기준 판매오더 없는 경우 해당 이전 정보 삭제 정보 구성
  WITH +DEL_KEY AS ( SELECT A~ZSYSTEM, A~JOB_NO, ZPJNO
                       FROM @LT_T77 AS A
                      GROUP BY A~ZSYSTEM, A~JOB_NO, A~ZPJNO )

    SELECT A~ZSYSTEM,  A~JOB_NO,  A~ZPJNO
      FROM ZGTSDT0077 AS A INNER JOIN +DEL_KEY AS B
                              ON A~ZSYSTEM EQ B~ZSYSTEM
                             AND A~JOB_NO  EQ B~JOB_NO
                             AND A~ZPJNO   EQ B~ZPJNO

      INTO CORRESPONDING FIELDS OF TABLE @LT_D_77.

*-- 삭제 정보 있을경우 삭제 선수행
  IF LT_D_77[] IS NOT INITIAL.
    TRY.
        DELETE ZGTSDT0077 FROM TABLE LT_D_77.
      CATCH CX_SY_OPEN_SQL_DB INTO DATA(LO_SQL_DB).
        ROLLBACK WORK. PV_RESULT = |01|.
        PV_MESSAGE = TEXT-E02.EXIT.
    ENDTRY.
  ENDIF.

*-- 저장 수행
  IF LT_0077[] IS NOT INITIAL.
    MODIFY ZGTSDT0077 FROM TABLE LT_0077.
    IF SY-SUBRC NE 0.
      ROLLBACK WORK. PV_RESULT = |01|.
      PV_MESSAGE = TEXT-E02.EXIT.
    ENDIF.
  ENDIF.

ENDFORM.
