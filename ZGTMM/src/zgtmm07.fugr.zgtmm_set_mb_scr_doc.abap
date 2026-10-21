FUNCTION ZGTMM_SET_MB_SCR_DOC.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  TABLES
*"      IT_MSEG TYPE  TY_T_MSEG OPTIONAL
*"      IT_CODE STRUCTURE  ZGTPPT1010 OPTIONAL
*"----------------------------------------------------------------------

  DATA:
    LT_MSEG      TYPE TY_T_MSEG,
    LT_CODE      TYPE STANDARD TABLE OF ZGTPPT1010,

    LS_ZPPT_FROM TYPE ZPPT0001,
    LS_ZPPT_TO   TYPE ZPPT0001
    .

  IF IT_MSEG[] IS INITIAL OR IT_CODE[] IS INITIAL.
    EXIT.
  ENDIF.

  MOVE-CORRESPONDING IT_MSEG[] TO LT_MSEG.
  MOVE-CORRESPONDING IT_CODE[] TO LT_CODE.

  LOOP AT LT_MSEG ASSIGNING FIELD-SYMBOL(<LS_MSEG>).
    CLEAR: LS_ZPPT_FROM, LS_ZPPT_TO.

* 1) 코드마스터 완전 일치 여부 확인
    READ TABLE LT_CODE TRANSPORTING NO FIELDS WITH KEY FLD_01 = <LS_MSEG>-BWART
                                                                                               FLD_02 = <LS_MSEG>-WERKS
                                                                                               FLD_03 = <LS_MSEG>-UMWRK
                                                                                               FLD_04 = <LS_MSEG>-MATNR.
    CHECK SY-SUBRC EQ 0.  "

* 2) 배치 관리 여부 확인
    SELECT SINGLE XCHPF
      FROM MARC
      WHERE MATNR EQ @<LS_MSEG>-MATNR
      AND WERKS EQ @<LS_MSEG>-WERKS
      INTO @DATA(LV_XCHPF).

    CHECK LV_XCHPF EQ GC_X.

* 3) 기존 꼬리표 테이블 정보 조회
    SELECT SINGLE *
      FROM ZPPT0001
      WHERE WERKS EQ @<LS_MSEG>-WERKS
      AND TAGNR EQ @<LS_MSEG>-CHARG
      INTO @LS_ZPPT_FROM.

    CHECK SY-SUBRC EQ 0.  "

* 도착지 꼬리표 테이블 DATA 생성
    LS_ZPPT_TO = CORRESPONDING #( LS_ZPPT_FROM
                                        MAPPING AUFNR   = AUFNR
                                                      TAGNR   = TAGNR
                                                      CHARG   = CHARG
                                                      MATNR   = MATNR
                                                      SPGCD   = SPGCD
                                                      MGVRG   = MGVRG
                                                      FOSTCNT = FOSTCNT
                                                      REMAIN  = REMAIN
                                                      MEINS   = MEINS
                                                      OUTFLG  = OUTFLG
                                                      GIFLG   = GIFLG
                                                      GRFLG   = GRFLG
                                                      INSPFLG = INSPFLG ).

    LS_ZPPT_TO = VALUE #( BASE LS_ZPPT_TO
                                          WERKS = <LS_MSEG>-UMWRK         "도착지 플랜트
                                          MBLNR = <LS_MSEG>-MBLNR           "이전전기 자재문서
                                          LGORT = <LS_MSEG>-UMLGO           "도착 저장위치
                                          GRINDAT = SY-DATUM
                                          GRINTIM = SY-UZEIT
                                          GRINNAM = SY-UNAME ).

* 도착지 꼬리표 테이블 MODIFY
    MODIFY ZPPT0001 FROM LS_ZPPT_TO.

    IF SY-SUBRC EQ 0.

*   출발지 꼬리표 테이블 DATA 수정 - REMAIN(잔량)

      IF <LS_MSEG>-BWART EQ GC_301. "   1) 301(이전)인 경우 0
        LS_ZPPT_FROM-REMAIN = 0.

      ELSEIF <LS_MSEG>-BWART EQ GC_302. "   2) 302(이전 취소)인 경우, 총량으로 복구
        LS_ZPPT_FROM-REMAIN = LS_ZPPT_FROM-MGVRG.

      ENDIF.

      MODIFY ZPPT0001 FROM LS_ZPPT_FROM.

      IF SY-SUBRC EQ 0.
        COMMIT WORK.
      ENDIF.
    ENDIF.
  ENDLOOP.
ENDFUNCTION.
