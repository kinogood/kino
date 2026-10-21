FUNCTION ZGTMM_IF_I_DRUM_RESULT_RCV.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_SYSTEM_ID) TYPE  ZGTE_IF_TARGET
*"     VALUE(I_BUKRS) TYPE  BUKRS
*"     VALUE(I_EKORG) TYPE  EKORG
*"     VALUE(I_WERKS) TYPE  WERKS_D
*"     VALUE(I_LIFNR) TYPE  LIFNR
*"     VALUE(I_DATE) TYPE  SY-DATUM
*"     VALUE(I_EMP_TIME) TYPE  ZGTE_EMP_TIME OPTIONAL
*"     VALUE(I_DLAB_TIME) TYPE  ZGTE_DLAB_TIME OPTIONAL
*"     VALUE(I_OVER_TIME) TYPE  ZGTE_OVER_TIME OPTIONAL
*"  EXPORTING
*"     VALUE(ZO_RESULT) TYPE  ZO_RESULT
*"     VALUE(ZO_MESSAGE) TYPE  ZO_MESSAGE
*"  TABLES
*"      IT_RESULT STRUCTURE  ZGTMMS9002
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈          : MM
*& 프로그램 ID : ZGTMM_IF_I_DRUM_RESULT_RCV
*& 프로그램 명 : 목드럼 작업 실적 수신(G-SRM->SAP)
*& 개요   : G-SRM에 생성/수정된 일일 목드럼 실적을 수신하는 FUNCTION
*& 생성일 : 2026.02.13
*& 생성자 : ZGODEV04
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  :
*& 수정자  :
*& 수정개요:
*&---------------------------------------------------------------------*

  DATA : LT_RESULT TYPE TABLE OF ZGTMMS9002,
         LS_RESULT TYPE ZGTMMS9002.

  DATA : LT_4272 LIKE TABLE OF ZGTMMT4272.


*--전송 데이터 누락여부 확인
  IF I_SYSTEM_ID IS INITIAL OR I_BUKRS IS INITIAL OR I_EKORG IS INITIAL OR
      I_WERKS IS INITIAL OR I_LIFNR IS INITIAL OR I_DATE IS INITIAL.

    ZO_RESULT    = GC_02.
    ZO_MESSAGE = '필수 값이 누락 되었습니다.'(E01).
    RETURN.
  ENDIF.

*--필수 값 정합성 체크
*회사코드
  SELECT FROM ZGTMMT1042
    FIELDS *
    WHERE BUKRS = @I_BUKRS
         AND ZYEAR = @I_DATE+0(4)
    INTO TABLE @GT_1042.

  IF GT_1042[] IS INITIAL.
    ZO_RESULT    = GC_02.
    ZO_MESSAGE = '유효하지 않은 회사코드입니다.'(E14).
    RETURN.

  ELSE.
    SORT GT_1042 BY BUKRS EKORG.
*구매조직
    READ TABLE GT_1042 TRANSPORTING NO FIELDS
    WITH KEY BUKRS = I_BUKRS
                   EKORG = I_EKORG BINARY SEARCH.
    IF SY-SUBRC NE 0.
      ZO_RESULT    = GC_02.
      ZO_MESSAGE = '유효하지 않은 구매조직입니다.'(E15).
      RETURN.
    ENDIF.
*플랜트
    SORT GT_1042 BY BUKRS WERKS.
    READ TABLE GT_1042  TRANSPORTING NO FIELDS
    WITH KEY BUKRS = I_BUKRS
                   WERKS = I_WERKS BINARY SEARCH.
    IF SY-SUBRC NE 0.
      ZO_RESULT    = GC_02.
      ZO_MESSAGE = '유효하지 않은 플랜트입니다.'(E16).
      RETURN.
    ENDIF.
*공급업체코드
    SORT GT_1042 BY BUKRS LIFNR.
    DATA(LV_LIFNR) = |{ I_LIFNR ALPHA = IN }|.
    READ TABLE GT_1042 TRANSPORTING NO FIELDS
    WITH KEY BUKRS = I_BUKRS
                   LIFNR = LV_LIFNR BINARY SEARCH.
    IF SY-SUBRC NE 0.
      ZO_RESULT    = GC_02.
      ZO_MESSAGE = '유효하지 않은 공급업체 코드입니다.'(E17).
      RETURN.
    ENDIF.
  ENDIF.
*INPUT TABLE CHECK
  LT_RESULT[] = VALUE #( BASE LT_RESULT FOR LS IN IT_RESULT
                                         ( VALUE #( BASE CORRESPONDING #( LS )
                                            LIFNR = |{ LS-LIFNR ALPHA = IN }|
                                            MATNR = CONV MATNR18( |{ LS-MATNR ALPHA = IN }| )
                                            EBELN = |{ LS-EBELN ALPHA = IN }| ) ) ).

  SELECT FROM MARA AS M
    INNER JOIN ZGTMMT1042 AS A
    ON A~MATNR = M~MATNR
    FIELDS A~MATNR,
               M~LVORM
    FOR ALL ENTRIES IN @LT_RESULT
    WHERE A~BUKRS = @I_BUKRS
         AND A~WERKS = @I_WERKS
         AND A~LIFNR   = @LT_RESULT-LIFNR
         AND A~ZYEAR = @I_DATE+0(4)
         AND A~MATNR = @LT_RESULT-MATNR
         INTO TABLE @DATA(LT_CHECK).

  IF LINE_EXISTS( LT_CHECK[ LVORM = GC_X ] ).
    ZO_RESULT    = GC_02.
    ZO_MESSAGE = '삭제된 자재코드를 포함 합니다.'(E18).
    RETURN.
  ENDIF.

*  DATA(LV_LINE_IN) = LINES( LT_RESULT[] ).
*  DATA(LV_LINE_S) = LINES( LT_CHECK[] ).
*"단가 미등록 체크
*(주석처리)"                    FM LINE 121~126   "주석 처리
*-->  단가 등록여부 체크는 입고 프로그램에서 되므로 FM에서는 제외"       MATNR에 중복 없는 경우에만 사용가능한 로직이라 주석처리 필요
*입력 테이블 데이터 수 보다 셀렉트 데이터 수 적으면, 에러.
*  IF LV_LINE_IN > LV_LINE_S.
*     ZO_RESULT    = GC_02.
*     ZO_MESSAGE = '단가 미등록 자재코드를 포함 합니다.'(E19).
*     RETURN.
*  ENDIF.

*"PO 정합성 체크
*(신규)"                    "FM LINE 129
*(자재코드 체크 로직 하단)"   "LT_RESULT의 LIFNR - MATNR - EBELN 조합으로
*해당 PO가 유효한지 체크
*(EBELN 없는 경우는 체크하지 않음)
*
*SELECT
*FROM EKKO AS EK
*JOIN EKPO AS EP
*ON EK~EBELN = EP~EBELN
*WHERE EK~LIFNR, EK~EBELN, EP~MATNR,
*EKPO-LOEKZ='', ELIKZ = SPACE"        "한 건이라도 오류시,
*메시지 리턴 후 종료
*ZO_RESULT = '02'
*ZO_MESSGAE =
*""유효하지 않은 발주번호(LT_RESULT-EBELN)"""
##ITAB_KEY_IN_SELECT
  SELECT
    EK~EBELN,
    EK~LIFNR,
    EP~MATNR
    FROM EKKO AS EK
              INNER JOIN
            EKPO AS EP ON EK~EBELN EQ EP~EBELN
    WHERE EP~LOEKZ EQ @SPACE
    AND EP~ELIKZ EQ @SPACE
    AND EXISTS (
      SELECT @ABAP_TRUE
      FROM @LT_RESULT AS ZZ
      WHERE ZZ~EBELN EQ EK~EBELN
         AND ZZ~LIFNR EQ EK~LIFNR
         AND ZZ~MATNR EQ EP~MATNR
    )
    ORDER BY EK~EBELN, EK~LIFNR, EP~MATNR
    INTO TABLE @DATA(LT_PO).

  LOOP AT LT_RESULT ASSIGNING FIELD-SYMBOL(<LS_RESULT>).
    CHECK <LS_RESULT>-EBELN IS NOT INITIAL. "(EBELN 없는 경우는 체크하지 않음)
    READ TABLE LT_PO WITH KEY EBELN = <LS_RESULT>-EBELN LIFNR = <LS_RESULT>-LIFNR MATNR = <LS_RESULT>-MATNR BINARY SEARCH TRANSPORTING NO FIELDS.
    CHECK SY-SUBRC NE 0.
*ZO_RESULT = '02'
*ZO_MESSGAE =
*""유효하지 않은 발주번호(LT_RESULT-EBELN)"""
    ZO_RESULT = GC_02.
    ZO_MESSAGE = |{ TEXT-E20 }( { <LS_RESULT>-EBELN ALPHA = OUT } )|.
    RETURN.
  ENDLOOP.


*--전송 정보 저장(1차 Log 등록)
  CLEAR: GS_MSG, GV_SYSTEM_ID.", GS_9300, GT_9301.
*ZGTMMT9000
  GV_SYSTEM_ID = I_SYSTEM_ID.
  PERFORM SET_COM_LOG  USING 'S' 'MM00042' '' '' CHANGING GS_9000.
*ZGTMMT9300
  APPEND  VALUE #(  ZIFKEY        =	GS_9000-ZIFKEY
                                 SYSTEM_ID = GV_SYSTEM_ID
                                 BUKRS = I_BUKRS
                                 EKORG = I_EKORG
                                 WERKS = I_WERKS
                                 LIFNR = I_LIFNR
                                 ZDATE = I_DATE
                                 EMP_TIME = I_EMP_TIME
                                 DLAB_TIME = I_DLAB_TIME
                                 OVER_TIME = I_OVER_TIME ) TO GT_9300.
  MODIFY ZGTMMT9300 FROM TABLE GT_9300.
*ZGTMMT9301
  GT_9301[] = VALUE #( BASE GT_9301 FOR LS IN LT_RESULT
                                   ( VALUE #( BASE CORRESPONDING #( LS )
                                     ZIFKEY       = GS_9000-ZIFKEY
                                     SYSTEM_ID = I_SYSTEM_ID ) ) ).
  MODIFY ZGTMMT9301 FROM TABLE GT_9301.

*--실적 반영 케이스 별 분기 설정
*1.실적반영 불가_전기기간 마감.
  SELECT SINGLE FROM MARV
    FIELDS * WHERE BUKRS = @I_BUKRS INTO @DATA(LS_MARV).

  IF I_DATE(6) < |{ LS_MARV-LFGJA }{ LS_MARV-LFMON }|.
    DATA(LV_CASE) = GC_X. "반영 불가
  ELSE.
*2.해당월 비용전표 생성된 경우.
    SELECT SINGLE @ABAP_TRUE
      FROM ZGTMMT4270 WHERE SPMON = @I_DATE(6)
                                         AND BELNR IS NOT INITIAL
      INTO @DATA(LV_BELNR).

    IF SY-SUBRC = 0.
      LV_CASE = GC_A. "일부 반영 가능_비용전표 존재
    ELSE.
*3.실적헤더에 자재문서 있는 경우
      SELECT SINGLE @ABAP_TRUE
        FROM ZGTMMT4271 WHERE ZDATE = @I_DATE
                                           AND ( MBLNR IS NOT INITIAL
                                                    OR MBLNR_G IS NOT INITIAL ) "MBLNR, MBLNR_G 中 하나라도 존재하는 경우 체크
        INTO @DATA(LV_MBLNR).

      IF SY-SUBRC = 0.
        LV_CASE = GC_B. "일부 반영 가능_일 별 입고 완료된 경우.
      ELSE.
*4.위 조건 모두 아닐 시_전체 반영 가능
        CLEAR LV_CASE.
      ENDIF.
    ENDIF.
  ENDIF.

*--케이스 별 실적 저장
*일 실적 헤더 기존 데이터 존재 체크
  SELECT SINGLE MJAHR, MBLNR, DUMMY, ERDAT, ERDAT_LOCAL,
                           ERTIM, ERTIM_LOCAL, ERNAM  FROM ZGTMMT4271
    WHERE BUKRS = @I_BUKRS
         AND EKORG = @I_EKORG
         AND WERKS = @I_WERKS
         AND LIFNR = @I_LIFNR
         AND SPMON = @I_DATE(6)
         AND ZDATE = @I_DATE INTO @DATA(LS_4271).

  CASE LV_CASE.
    WHEN GC_A OR GC_B. "일부반영_일 실적(헤더)만 저장
*일 실적_HEADER
      DATA(LS_ZGTMMT4271) = VALUE ZGTMMT4271(
                                      BUKRS = I_BUKRS
                                      EKORG = I_EKORG
                                      WERKS = I_WERKS
                                      LIFNR = LV_LIFNR
                                      SPMON = I_DATE(6)
                                      ZDATE  = I_DATE
                                      EMP_TIME = I_EMP_TIME
                                      DLAB_TIME = I_DLAB_TIME
                                      OVER_TIME = I_OVER_TIME
                                      MEINH = GC_H "'H' 고정
                                      MJAHR = COND #( WHEN LS_4271 IS INITIAL THEN '' ELSE LS_4271-MJAHR )
                                      MBLNR = COND #( WHEN LS_4271 IS INITIAL THEN '' ELSE LS_4271-MBLNR )
                                      DUMMY = COND #( WHEN LS_4271 IS INITIAL THEN '' ELSE LS_4271-DUMMY )
                                      ERDAT = COND #( WHEN LS_4271 IS INITIAL THEN SY-DATUM
                                                                  ELSE LS_4271-ERDAT )
                                      ERDAT_LOCAL = COND #( WHEN LS_4271 IS INITIAL THEN SY-DATLO
                                                                              ELSE LS_4271-ERDAT_LOCAL )
                                      ERTIM = COND #( WHEN LS_4271 IS INITIAL THEN SY-UZEIT
                                                                 ELSE LS_4271-ERTIM )
                                      ERTIM_LOCAL = COND #( WHEN LS_4271 IS INITIAL THEN SY-TIMLO
                                                                             ELSE LS_4271-ERTIM_LOCAL )
                                      ERNAM = COND #( WHEN LS_4271 IS INITIAL THEN SY-UNAME
                                                                   ELSE LS_4271-ERNAM )
                                      AEDAT = COND #( WHEN LS_4271 IS INITIAL THEN '' ELSE SY-DATUM )
                                      AEDAT_LOCAL = COND #( WHEN LS_4271 IS INITIAL THEN '' ELSE SY-DATLO )
                                      AETIM = COND #( WHEN LS_4271 IS INITIAL THEN '' ELSE SY-UZEIT )
                                      AETIM_LOCAL = COND #( WHEN LS_4271 IS INITIAL THEN '' ELSE SY-TIMLO )
                                      AENAM = COND #( WHEN LS_4271 IS INITIAL THEN '' ELSE SY-UNAME ) ).
*데이터 저장_일 실적_헤더
      MODIFY ZGTMMT4271 FROM LS_ZGTMMT4271.

    WHEN GC_X. "반영 불가_저장 없이 EXPORT만 설정.


    WHEN OTHERS. "NULL:전체 반영 가능.
*월 실적
      DATA(LT_ZGTMMT4270) = VALUE ZGTMMT4270(
                                      BUKRS = I_BUKRS
                                      EKORG = I_EKORG
                                      WERKS = I_WERKS
                                      LIFNR = LV_LIFNR
                                      SPMON = I_DATE(6)
                                      WAERS = GC_KRW "KRW고정
                                      ERDAT = SY-DATUM
                                      ERDAT_LOCAL = SY-DATLO
                                      ERTIM = SY-UZEIT
                                      ERTIM_LOCAL = SY-TIMLO
                                      ERNAM = SY-UNAME ).
*일 실적_HEADER
      CLEAR LS_ZGTMMT4271.
      LS_ZGTMMT4271 = VALUE ZGTMMT4271(
                                      BUKRS = I_BUKRS
                                      EKORG = I_EKORG
                                      WERKS = I_WERKS
                                      LIFNR = LV_LIFNR
                                      SPMON = I_DATE(6)
                                      ZDATE  = I_DATE
                                      EMP_TIME = I_EMP_TIME
                                      DLAB_TIME = I_DLAB_TIME
                                      OVER_TIME = I_OVER_TIME
                                      MEINH = GC_H "'H' 고정
                                      ERDAT = COND #( WHEN LS_4271 IS INITIAL THEN SY-DATUM
                                                                  ELSE LS_4271-ERDAT )
                                      ERDAT_LOCAL = COND #( WHEN LS_4271 IS INITIAL THEN SY-DATLO
                                                                              ELSE LS_4271-ERDAT_LOCAL )
                                      ERTIM = COND #( WHEN LS_4271 IS INITIAL THEN SY-UZEIT
                                                                 ELSE LS_4271-ERTIM )
                                      ERTIM_LOCAL = COND #( WHEN LS_4271 IS INITIAL THEN SY-TIMLO
                                                                             ELSE LS_4271-ERTIM_LOCAL )
                                      ERNAM = COND #( WHEN LS_4271 IS INITIAL THEN SY-UNAME
                                                                   ELSE LS_4271-ERNAM )
                                      AEDAT = COND #( WHEN LS_4271 IS INITIAL THEN '' ELSE SY-DATUM )
                                      AEDAT_LOCAL = COND #( WHEN LS_4271 IS INITIAL THEN '' ELSE SY-DATLO )
                                      AETIM = COND #( WHEN LS_4271 IS INITIAL THEN '' ELSE SY-UZEIT )
                                      AETIM_LOCAL = COND #( WHEN LS_4271 IS INITIAL THEN '' ELSE SY-TIMLO )
                                      AENAM = COND #( WHEN LS_4271 IS INITIAL THEN '' ELSE SY-UNAME ) ).
*일 실적_ITEM
      SORT GT_1042 BY BUKRS EKORG WERKS LIFNR ZYEAR MATNR.
      PERFORM SET_DAILY_RESULT TABLES LT_RESULT LT_4272.


*"ZGTMMT4273
*DB 반영"                   "FM LINE 312
*(일 실적 아이템 DB 반영 하단)"   "1. LT_RESULT-EBELN 필드에 값이 하나라도 있는 경우
*1) 해당 일자 기준으로 ZGTMMT4273 DELETE
*(BUKRS, WERKS, LIFNR, ZDATE 조합)
*
*2) LT_RESULT -EBELN 존재하는 LINE을 ZGTMMT4273에 MODIFY (ZSEQ는 제외)
*
*2.  LT_RESULT-EBELN 필드에 값이 하나도 없는 경우
*ZGTMMT4273 DB반영 하지 않음
*"        "SRM에서 PO정보를 입력해도,
*다시 조회할때는 PO없이 자재별 실적이 SAP->SRM으로 넘어감
*
*이 상태로 작업자가 실수로 저장 누르는 경우 기존 PO 할당값이 엎어지게 되는 것을 방지하기 위함"
      DATA LT_4273 TYPE STANDARD TABLE OF ZGTMMT4273.
##ITAB_DB_SELECT
##ITAB_KEY_IN_SELECT
      SELECT
        ZZ~BUKRS,
        ZZ~EKORG,
        ZZ~WERKS,
        ZZ~LIFNR,
        ZZ~ZDATE,
        ZZ~MATNR,
        ZZ~EBELN,
        SUM( ZZ~DRM_COUNT ) AS DRM_COUNT,
        SUM( ZZ~BOARD_COUNT ) AS BOARD_COUNT,
        SUM( ZZ~MARK_COUNT ) AS MARK_COUNT,
        SUM( ZZ~DIS_COUNT ) AS DIS_COUNT
        FROM @LT_RESULT AS ZZ
        WHERE ZZ~EBELN IS NOT INITIAL
        GROUP BY ZZ~BUKRS, ZZ~EKORG, ZZ~WERKS, ZZ~LIFNR, ZZ~ZDATE, ZZ~MATNR, ZZ~EBELN
        INTO CORRESPONDING FIELDS OF TABLE @LT_4273.

*데이터 반영(SAVE)
*월 실적(기정보 없을 경우에만 인서트)
      SELECT SINGLE @ABAP_TRUE
        FROM ZGTMMT4270
        WHERE BUKRS = @I_BUKRS
             AND EKORG = @I_EKORG
             AND WERKS = @I_WERKS
             AND LIFNR = @LV_LIFNR
             AND SPMON = @I_DATE(6) INTO @DATA(LV_CK).

      IF SY-SUBRC NE 0.
        TRY.
            INSERT ZGTMMT4270 FROM LT_ZGTMMT4270 .

          CATCH CX_ROOT INTO DATA(LV_ERROR).
            DATA(LV_MSG) = LV_ERROR->GET_TEXT( ).
        ENDTRY.
      ENDIF.


*일 실적_헤더
      MODIFY ZGTMMT4271 FROM LS_ZGTMMT4271.

*일 실적_아이템(기존 데이터 삭제 후 신규 생성)
      DELETE FROM ZGTMMT4272 WHERE LIFNR = @LV_LIFNR
                                                      AND WERKS = @I_WERKS
                                                      AND ZDATE = @I_DATE.
      TRY.
          INSERT ZGTMMT4272 FROM TABLE LT_4272.

        CATCH CX_ROOT INTO LV_ERROR.
          LV_MSG = LV_ERROR->GET_TEXT( ).
      ENDTRY.



*목드럼 임가공 실적(Daily) ITEM - PO(G-PRO)
      MODIFY ZGTMMT4271 FROM LS_ZGTMMT4271.

*기존 데이터 삭제 후 신규 생성
      IF LT_4273[] IS NOT INITIAL.
        DELETE FROM ZGTMMT4273 WHERE BUKRS = @I_BUKRS
                                                        AND WERKS = @I_WERKS
                                                        AND LIFNR = @LV_LIFNR
                                                        AND ZDATE = @I_DATE.
        TRY.
            INSERT ZGTMMT4273 FROM TABLE LT_4273.

          CATCH CX_ROOT INTO LV_ERROR.
            LV_MSG = LV_ERROR->GET_TEXT( ).
        ENDTRY.
      ENDIF.

  ENDCASE.

**--EXPORT 구성
  IF SY-SUBRC = 0 AND LV_MSG IS INITIAL.
    COMMIT WORK AND WAIT.
    ZO_RESULT    = GC_00. "00
    ZO_MESSAGE = COND #( WHEN LV_CASE = GC_A
                                           THEN '해당 월의 비용 전표가 존재하여, 작업 시간만 저장됩니다.(수량 수정 불가)'(M19)
                                           WHEN LV_CASE = GC_B
                                           THEN '해당 일자의 입고가 완료되어 작업 시간만 저장됩니다.(수량 수정 불가)'(M20)
                                           WHEN LV_CASE IS INITIAL
                                           THEN '실적이 저장 되었습니다.'(M21) ELSE '실적이 저장 되었습니다.'(M21) ).
  ELSE.
    ROLLBACK WORK.
    ZO_RESULT    = GC_02. "02
    ZO_MESSAGE = COND #( WHEN LV_MSG IS INITIAL
                                           THEN '저장에 실패 했습니다.'(M18) ELSE LV_MSG ).
  ENDIF.

  IF LV_CASE = GC_X.
    ZO_RESULT    = GC_02. "02
    ZO_MESSAGE = '해당 월의 마감이 완료 되었습니다.(수정 불가)'(M22).
  ENDIF.

*최종 LOG 저장
  PERFORM SET_COM_LOG  USING 'E' 'MM00042' ZO_RESULT ZO_MESSAGE CHANGING GS_9000.



**금액필드_원화표기 변환
*         PERFORM CONVERT_CURRENCY  USING WA-DRM_PRICE CHANGING LS_RESULT-DRM_PRICE.

*         LS_RESULT-LIFNR   = |{ WA-LIFNR ALPHA = OUT }|.
*         LS_RESULT-MATNR = |{ WA-MATNR ALPHA = OUT }|.



ENDFUNCTION.
