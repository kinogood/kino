*----------------------------------------------------------------------*
***INCLUDE LZGTPP01F04.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form conversion_input_oper
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_OPER
*&---------------------------------------------------------------------*
FORM CONVERSION_INPUT_OPER  USING    PS_OPER TYPE ZGTPPT3120.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = PS_OPER-QRCOD
    IMPORTING
      OUTPUT = PS_OPER-QRCOD.

  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = PS_OPER-BRKNR
    IMPORTING
      OUTPUT = PS_OPER-BRKNR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_common_oper
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> I_MODE
*&      --> LV_ERROR
*&---------------------------------------------------------------------*
FORM CHECK_COMMON_OPER  USING    PV_MODE
                                 PV_ERROR.
*- Start 2025.02.06
*- 비가동 처리
  IF PV_MODE = 'P'.
    IF GS_OPER-ZSERNO IS INITIAL.
      PERFORM RETURN_MESSAGE_OPER USING GC_E
                                        TEXT-E78. "Serial No.가 누락되었습니다.
      PV_ERROR = GC_X.

    ELSEIF GS_OPER-WERKS IS INITIAL.
      PERFORM RETURN_MESSAGE_OPER USING GC_E
                                        TEXT-E79. "플랜트가 누락되었습니다.
      PV_ERROR = GC_X.

    ELSEIF GS_OPER-ARBPL IS INITIAL.
      PERFORM RETURN_MESSAGE_OPER USING GC_E
                                        TEXT-E80. "작업장이 누락되었습니다.
      PV_ERROR = GC_X.

    ELSEIF GS_OPER-QRCOD IS INITIAL.
      PERFORM RETURN_MESSAGE_OPER USING GC_E
                                        TEXT-E81. "비가동 코드가 누락되었습니다.
      PV_ERROR = GC_X.

    ELSEIF GS_OPER-BRKDT IS INITIAL.
      PERFORM RETURN_MESSAGE_OPER USING GC_E
                                        TEXT-E82. "시작일이 누락되었습니다.
      PV_ERROR = GC_X.

    ELSEIF GS_OPER-OPRDT IS INITIAL.
      PERFORM RETURN_MESSAGE_OPER USING GC_E
                                        TEXT-E83. "종료일이 누락되었습니다.
      PV_ERROR = GC_X.

    ELSEIF GS_OPER-CRNAM IS INITIAL.
      PERFORM RETURN_MESSAGE_OPER USING GC_E
                                        TEXT-E84. "비가동 입력자(사번)가 누락되었습니다.
*                                        TEXT-e24. "비가동 실적 처리 정보가 없습니다.
      PV_ERROR = GC_X.

    ENDIF.
*- End 2025.02.06
*- 비가동 취소
  ELSEIF PV_MODE = 'C'.
    IF GS_OPER-WERKS IS INITIAL OR
       GS_OPER-BRKNR IS INITIAL.
      PERFORM RETURN_MESSAGE_OPER USING GC_E
                                        TEXT-E25. "비가동 실적 취소 정보가 없습니다.
      PV_ERROR = GC_X.
    ELSE.
      SELECT SINGLE SPGCD, ARBPL, QRCOD, QRTXT, BRKDT, BRKTM, OPRDT, OPRTM, CRNAM
        INTO CORRESPONDING FIELDS OF @GS_OPER
        FROM ZPPT0026
        WHERE WERKS = @GS_OPER-WERKS
          AND BRKNR = @GS_OPER-BRKNR
          AND LOEKZ <> @GC_X.
      IF SY-SUBRC <> 0.
        PERFORM RETURN_MESSAGE_OPER USING GC_E
                                          TEXT-E26. "비가동 취소 대상이 없습니다.
        PV_ERROR = GC_X.
      ENDIF.
    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RETURN_MESSAGE_OPER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM RETURN_MESSAGE_OPER  USING   PV_STAT
                                  PV_MESSAGE.

  GT_OPER_RESULT = VALUE #( BASE GT_OPER_RESULT
                              ( WERKS        = GS_OPER-WERKS
                                ZSERNO       = GS_OPER-ZSERNO
                                BRKNR        = GS_OPER-BRKNR
                                ZERP_STAT    = PV_STAT
                                ZERP_MESSAGE = PV_MESSAGE ) ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_log_zgtppt3120
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> LV_MESSAGE
*&---------------------------------------------------------------------*
FORM SAVE_LOG_ZGTPPT3120  USING    PV_STAT
                                   PV_MESSAGE.

  DATA: LT_ZGTPPT3120 TYPE TABLE OF ZGTPPT3120.
  DATA: LV_TIMESTAMP TYPE TIMESTAMPL.
  DATA: LS_ZGTPPT3120 TYPE ZGTPPT3120.

  CLEAR: LT_ZGTPPT3120, LV_TIMESTAMP.

  GET TIME STAMP FIELD LV_TIMESTAMP.

*- 비가동 취소 시 BRKNR Clear(BRKNR->ZC_BRKNR)
  IF GS_OPER-I_MODE = 'C' AND GS_OPER-ZC_BRKNR IS NOT INITIAL.
    CLEAR: GS_OPER-BRKNR.
  ENDIF.

  LT_ZGTPPT3120 = VALUE #( ( VALUE #( BASE CORRESPONDING #( GS_OPER )
                                        ZIFKEY       = LV_TIMESTAMP
                                        ZERP_STAT    = PV_STAT
                                        ZERP_MESSAGE = PV_MESSAGE
                                        IFNAM        = SY-UNAME
                                        IFDAT        = SY-DATUM
                                        IFTIM        = SY-UZEIT ) ) ).

  MODIFY ZGTPPT3120 FROM TABLE LT_ZGTPPT3120.
  IF SY-SUBRC = 0.
    COMMIT WORK.
  ENDIF.

* ZO_RESULT, ZO_MESSAGE 업데이트를 위한 키필드 반영
  CLEAR: GS_OPER_KEYS, LS_ZGTPPT3120.
  LOOP AT LT_ZGTPPT3120 INTO LS_ZGTPPT3120.
    MOVE-CORRESPONDING LS_ZGTPPT3120 TO GS_OPER_KEYS.
    APPEND GS_OPER_KEYS TO GT_OPER_KEYS.
    CLEAR: LS_ZGTPPT3120.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_qrcod
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_ERROR
*&---------------------------------------------------------------------*
FORM CHECK_QRCOD  USING    PV_ERROR.

  CLEAR: GS_QRCOD.
  READ TABLE GT_QRCOD INTO GS_QRCOD WITH KEY QRCOD = GS_OPER-QRCOD.

*- 비가동 코드 테이블에
  IF GS_QRCOD IS INITIAL.
*- 미사용 코드
    CASE GS_OPER-QRCOD.
      WHEN '41'.
        PERFORM RETURN_MESSAGE_OPER USING GC_E
                                          TEXT-E27. "인원부족 사유는 사용할 수 없습니다.
        PV_ERROR = GC_X.
      WHEN '03' OR '11'.
        PERFORM RETURN_MESSAGE_OPER USING GC_E
                                          TEXT-E28. "치공구 및 보빈대기는 보빈공구 대기 항목으로 입력하세요.
        PV_ERROR = GC_X.
      WHEN '21'.
        PERFORM RETURN_MESSAGE_OPER USING GC_E
                                          TEXT-E29. "설비고장 대신 설비공장 항목으로 입력하세요.
        PV_ERROR = GC_X.
      WHEN '43'.
        PERFORM RETURN_MESSAGE_OPER USING GC_E
                                          TEXT-E30. "외출 항목으로는 입력할 수 없습니다.
        PV_ERROR = GC_X.
      WHEN '63'.
        PERFORM RETURN_MESSAGE_OPER USING GC_E
                                          TEXT-E31. "다른 기타 항목으로 입력하세요.
        PV_ERROR = GC_X.
      WHEN OTHERS.
        PERFORM RETURN_MESSAGE_OPER USING GC_E
                                          TEXT-E32. "해당 비가동 사유는 존재하지 않습니다.
        PV_ERROR = GC_X.
    ENDCASE.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_qrcod
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM GET_QRCOD .

  CLEAR: GT_QRCOD.
  SELECT QRCOD USELS
    INTO CORRESPONDING FIELDS OF TABLE GT_QRCOD
    FROM ZPPT0104
   WHERE USELS = GC_X.

  SORT GT_QRCOD BY QRCOD.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form mes_non_opert
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> I_MODE
*&---------------------------------------------------------------------*
FORM MES_NON_OPERT  USING  PV_MODE.


  IF PV_MODE = 'P'.

    PERFORM CHECK_BREAK_TIME. "시간점검

    PERFORM NUMBER_GET_NEXT. "비가동 번호 채번

    PERFORM NON_OPER_P. "비가동 처리

    IF GS_OPER-WERKS EQ '1305'.
      PERFORM SAVE_ZQMT0734. "2026.02.09.zlsgpp5.CHM2602-00176.
    ENDIF.

  ELSEIF PV_MODE = 'C'.

    PERFORM NON_OPER_C. "비가동 취소

    IF GS_OPER-WERKS EQ '1305'.
      PERFORM DELETE_ZQMT0734. "2026.02.09.zlsgpp5.CHM2602-00176.
    ENDIF.

  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_break_time
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CHECK_BREAK_TIME .

  DATA: LV_DAY  TYPE P,
        LV_TIME TYPE P.

  CLEAR: LV_DAY, LV_TIME.

*& 계산값을 일자에서 분으로 환산...
  LV_DAY  = ( GS_OPER-OPRDT - GS_OPER-BRKDT ) * 24 * 60.
  IF LV_DAY < 0.
    PERFORM RETURN_MESSAGE_OPER USING GC_E
                                      TEXT-E34. "비가동 시작일이 종료일보다 미래입니다.!!!
    PERFORM SAVE_LOG_ZGTPPT3120 USING GC_E
                                      TEXT-E34. "비가동 시작일이 종료일보다 미래입니다.!!!
  ENDIF.

*& 계산값을 초에서   분으로 환산...
  LV_TIME = ( GS_OPER-OPRTM - GS_OPER-BRKTM ) / 60.
  IF LV_DAY = 0 AND LV_TIME < 0.
    PERFORM RETURN_MESSAGE_OPER USING GC_E
                                      TEXT-E35. "비가동 시작시간이 종료시간보다 미래입니다.!!!
    PERFORM SAVE_LOG_ZGTPPT3120 USING GC_E
                                      TEXT-E35. "비가동 시작시간이 종료시간보다 미래입니다.!!!
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form number_get_next
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM NUMBER_GET_NEXT .

  IF GS_OPER-BRKNR IS INITIAL.

    CLEAR GS_OPER-BRKNR.

    CALL FUNCTION 'NUMBER_GET_NEXT'
      EXPORTING
        NR_RANGE_NR             = '00'
        OBJECT                  = 'ZPP_BRKNR'
      IMPORTING
        NUMBER                  = GS_OPER-BRKNR
*       RETURNCODE              =
      EXCEPTIONS
        INTERVAL_NOT_FOUND      = 1
        NUMBER_RANGE_NOT_INTERN = 2
        OBJECT_NOT_FOUND        = 3
        QUANTITY_IS_0           = 4
        QUANTITY_IS_NOT_1       = 5
        INTERVAL_OVERFLOW       = 6
        BUFFER_OVERFLOW         = 7
        OTHERS                  = 8.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_brknr
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_ERROR
*&---------------------------------------------------------------------*
FORM CHECK_BRKNR  USING    PV_ERROR.

  IF GS_OPER-BRKNR IS NOT INITIAL.
    PERFORM RETURN_MESSAGE_OPER USING GC_E
                                      TEXT-E33. "비가동 번호는 ERP에서 채번하여 생성해야 합니다.
    PV_ERROR = GC_X.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form non_oper_p
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM NON_OPER_P .

  DATA: LT_ZPPT0141 LIKE ZPPT0141 OCCURS 0 WITH HEADER LINE.

  MOVE-CORRESPONDING GS_OPER TO ZPPT0026.
  ZPPT0026-CRDAT = SY-DATUM.
  ZPPT0026-CRTIM = SY-UZEIT.
  INSERT ZPPT0026.

*-비가동 상세 내역 추가
  IF SY-SUBRC = 0.
    CLEAR: LT_ZPPT0141. REFRESH: LT_ZPPT0141.
    PERFORM MODIFY_ZPPT0141 TABLES LT_ZPPT0141 USING 'I'.

    INSERT ZPPT0141 FROM TABLE LT_ZPPT0141.
    IF SY-SUBRC = 0.
      COMMIT WORK.

      PERFORM RETURN_MESSAGE_OPER USING GC_S
                                        TEXT-S05. "비가동 입력 성공
      PERFORM SAVE_LOG_ZGTPPT3120 USING GC_S
                                        TEXT-S05. "비가동 입력 성공
    ENDIF.
  ELSE.
    ROLLBACK WORK.

    PERFORM RETURN_MESSAGE_OPER USING GC_E
                                      TEXT-E36. "비가동 입력 실패
    PERFORM SAVE_LOG_ZGTPPT3120 USING GC_E
                                      TEXT-E36. "비가동 입력 실패
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form modify_zppt0141
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LT_ZPPT0141
*&      --> P_
*&---------------------------------------------------------------------*
FORM MODIFY_ZPPT0141  TABLES   PT_ZPPT0141 STRUCTURE ZPPT0141
                                        USING    PV_VALUE.

  DATA : BEGIN OF LT_DATE OCCURS 0,
           BRKDT LIKE ZPPT0026-BRKDT,
           BRKTM LIKE ZPPT0026-BRKTM,
           OPRDT LIKE ZPPT0026-OPRDT,
           OPRTM LIKE ZPPT0026-OPRTM,
         END OF LT_DATE.

  DATA : LV_CNT    TYPE I.

  CLEAR : LT_DATE.
  REFRESH LT_DATE.

  LV_CNT = 1.

  CALL FUNCTION 'Z_PP_DIVIDE_DATE'
    EXPORTING
      I_BRKDT = GS_OPER-BRKDT
      I_BRKTM = GS_OPER-BRKTM
      I_OPRDT = GS_OPER-OPRDT
      I_OPRTM = GS_OPER-OPRTM
    TABLES
      T_DATE  = LT_DATE.

  CASE PV_VALUE.

    WHEN 'I'.     "입력
      LOOP AT LT_DATE.
        MOVE-CORRESPONDING LT_DATE TO PT_ZPPT0141.
        PT_ZPPT0141-SEQNO = LV_CNT.
        APPEND PT_ZPPT0141.
        LV_CNT = LV_CNT + 1.
      ENDLOOP.

      LOOP AT PT_ZPPT0141.
        MOVE GS_OPER-WERKS TO PT_ZPPT0141-WERKS.
        MOVE GS_OPER-ARBPL TO PT_ZPPT0141-ARBPL.
        MOVE GS_OPER-BRKNR TO PT_ZPPT0141-BRKNR.
        MOVE GS_OPER-SPGCD TO PT_ZPPT0141-SPGCD.
        MOVE GS_OPER-QRCOD TO PT_ZPPT0141-QRCOD.
        MOVE GS_OPER-CRNAM TO PT_ZPPT0141-CRNAM.
        PT_ZPPT0141-GSBER = '0'.
        " 사업 영역별 구분 - 전선
        PT_ZPPT0141-CRDAT = SY-DATUM.
        " X 생성일
        PT_ZPPT0141-CRTIM = SY-UZEIT.
        " X 입력 시간
        MODIFY PT_ZPPT0141.
      ENDLOOP.

    WHEN 'U'.     "Update

      DELETE FROM ZPPT0141 WHERE BRKNR = GS_OPER-BRKNR.

      LOOP AT LT_DATE.
        MOVE-CORRESPONDING LT_DATE TO PT_ZPPT0141.
        PT_ZPPT0141-SEQNO = LV_CNT.
        APPEND PT_ZPPT0141.
        LV_CNT = LV_CNT + 1.
      ENDLOOP.

      LOOP AT PT_ZPPT0141.
        MOVE GS_OPER-WERKS TO PT_ZPPT0141-WERKS.
        MOVE GS_OPER-ARBPL TO PT_ZPPT0141-ARBPL.
        MOVE GS_OPER-BRKNR TO PT_ZPPT0141-BRKNR.
        MOVE GS_OPER-SPGCD TO PT_ZPPT0141-SPGCD.
        MOVE GS_OPER-QRCOD TO PT_ZPPT0141-QRCOD.
        MOVE GS_OPER-CRNAM TO PT_ZPPT0141-CRNAM.
        PT_ZPPT0141-LOEKZ = 'X'.
        PT_ZPPT0141-GSBER = '0'.
        " 사업 영역별 구분 - 전선
        PT_ZPPT0141-CRDAT = SY-DATUM.
        " X 생성일
        PT_ZPPT0141-CRTIM = SY-UZEIT.
        " X 입력 시간
        MODIFY PT_ZPPT0141.
      ENDLOOP.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form non_oper_c
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM NON_OPER_C .

  DATA: LS_ZPPT0026 TYPE ZPPT0026,
        LT_ZPPT0026 TYPE TABLE OF ZPPT0026,
        LT_ZPPT0141 LIKE ZPPT0141 OCCURS 0 WITH HEADER LINE.

*- 수신 받은 비가동 번호가 기존에 있는지 점검
  CLEAR: LS_ZPPT0026.
  SELECT SINGLE BRKNR
    INTO LS_ZPPT0026-BRKNR
    FROM ZPPT0026
   WHERE BRKNR = GS_OPER-BRKNR.

  IF SY-SUBRC = 0.
    UPDATE ZPPT0026 SET: CRDAT = SY-DATUM
                         CRTIM = SY-UZEIT
                         LOEKZ = GC_X
                  WHERE WERKS = GS_OPER-WERKS
                    AND ARBPL = GS_OPER-ARBPL
                    AND BRKNR = GS_OPER-BRKNR.

    IF SY-SUBRC = 0.
      CLEAR: LT_ZPPT0141. REFRESH: LT_ZPPT0141.
      PERFORM MODIFY_ZPPT0141 TABLES LT_ZPPT0141 USING 'U'.

      INSERT ZPPT0141 FROM TABLE LT_ZPPT0141.
      IF SY-SUBRC = 0.
        COMMIT WORK.

        PERFORM RETURN_MESSAGE_OPER USING GC_S
                                          TEXT-S06. "비가동 취소 처리 성공
        PERFORM SAVE_LOG_ZGTPPT3120 USING GC_S
                                          TEXT-S06. "비가동 취소 처리 성공
      ENDIF.

    ELSE.
      ROLLBACK WORK.

      PERFORM RETURN_MESSAGE_OPER USING GC_E
                                        TEXT-E37. "비가동 취소 처리 실패
      PERFORM SAVE_LOG_ZGTPPT3120 USING GC_E
                                        TEXT-E37. "비가동 취소 처리 실패
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form conversion_output_oper
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CONVERSION_OUTPUT_OPER .
  LOOP AT GT_OPER_RESULT INTO DATA(LS_RESULT).
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = LS_RESULT-BRKNR
      IMPORTING
        OUTPUT = LS_RESULT-BRKNR.

    MODIFY GT_OPER_RESULT FROM LS_RESULT.

  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form result_oper_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> ZO_RESULT
*&      --> ZO_MESSAGE
*&---------------------------------------------------------------------*
FORM RESULT_OPER_DATA  USING    PO_RESULT
                                PO_MESSAGE.

  DATA: LV_MESSAGE(100),
        LV_RESULT(2).
  CLEAR: LV_MESSAGE, LV_RESULT.

  IF GT_OPER_RESULT IS NOT INITIAL.
*- 전체 건수
    DATA(LV_CNT_T) = REDUCE I(
                     INIT SUM = 0 FOR LS_CNT_T IN GT_OPER_RESULT
                     NEXT SUM = SUM + 1 ).

*- 성공 건수
    DATA(LV_CNT_S) = REDUCE I(
                     INIT SUM = 0 FOR LS_CNT_S IN GT_OPER_RESULT
                     WHERE ( ZERP_STAT = 'S' )
                     NEXT SUM = SUM + 1 ).

*- 실패 건수
    DATA(LV_CNT_E) = REDUCE I(
                     INIT SUM = 0 FOR LS_CNT_E IN GT_OPER_RESULT
                     WHERE ( ZERP_STAT = 'E' )
                     NEXT SUM = SUM + 1 ).

    "전체 성공
    IF LV_CNT_S IS NOT INITIAL AND
       LV_CNT_E IS INITIAL.
      LV_RESULT = '00'.
      "LV_MESSAGE = |전체{ LV_CNT_T }건 중 { LV_CNT_S }건 처리 성공, { LV_CNT_E }건 처리 실패|.
      MESSAGE S009(ZGTPP00) WITH LV_CNT_T LV_CNT_S LV_CNT_E INTO LV_MESSAGE.

      "전체 실패
    ELSEIF LV_CNT_S IS INITIAL AND
           LV_CNT_E IS NOT INITIAL.
      LV_RESULT = '01'.
      MESSAGE S009(ZGTPP00) WITH LV_CNT_T LV_CNT_S LV_CNT_E INTO LV_MESSAGE.

      "부분 성공
    ELSE.
      LV_RESULT = '01'.
      MESSAGE S009(ZGTPP00) WITH LV_CNT_T LV_CNT_S LV_CNT_E INTO LV_MESSAGE.

    ENDIF.

*- 처리 결과
    PO_RESULT  = LV_RESULT.
    PO_MESSAGE = LV_MESSAGE.

  ELSE.

    LV_RESULT = '01'.
    LV_MESSAGE = TEXT-E38. "전송실패

*- 처리 결과
    PO_RESULT  = LV_RESULT.
    PO_MESSAGE = LV_MESSAGE.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_RECEPTION_TIME
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_ERROR
*&---------------------------------------------------------------------*
FORM CHECK_RECEPTION_TIME  USING    PV_ERROR.

  DATA: LV_WERKS TYPE WERKS_D,
        LV_MATNR TYPE MATNR.

*- 플랜트 필수 및 유효성 점검
  IF GS_TIME-WERKS IS INITIAL.
    PERFORM RETURN_MESSAGE_TIME USING GC_E
                                      TEXT-E15. "플랜트는 필수 입력 값입니다.
    PV_ERROR = GC_X.
    EXIT.
  ELSE.
    CLEAR: LV_WERKS.
    SELECT SINGLE WERKS
      INTO LV_WERKS
      FROM T001W
     WHERE WERKS = GS_TIME-WERKS.

    IF LV_WERKS IS INITIAL.
      PERFORM RETURN_MESSAGE_TIME USING GC_E
                                        TEXT-E02. "존재하지 않는 플랜트 입니다.
      PV_ERROR = GC_X.
      EXIT.
    ENDIF.
  ENDIF.

*- 일련번호 필수 점검
  IF GS_TIME-ZSERNO IS INITIAL.
    PERFORM RETURN_MESSAGE_TIME USING GC_E
                                      TEXT-E16. "일련번호는 필수 입력 값입니다.
    PV_ERROR = GC_X.
    EXIT.
  ENDIF.

*- 품목코드 필수 및 유효성 점검
  IF GS_TIME-MATNR IS INITIAL.
    PERFORM RETURN_MESSAGE_TIME USING GC_E
                                      TEXT-E17. "품목코드는 필수 입력 값입니다.
    PV_ERROR = GC_X.
    EXIT.
  ELSE.
    CLEAR: LV_MATNR.
    SELECT SINGLE MATNR
      INTO LV_MATNR
      FROM MARC
     WHERE MATNR = GS_TIME-MATNR
       AND WERKS = GS_TIME-WERKS
       AND LVORM = SPACE.

    IF LV_MATNR IS INITIAL.
      PERFORM RETURN_MESSAGE_TIME USING GC_E
                                        TEXT-E18. "존재하지 않는 자재코드입니다.
      PV_ERROR = GC_X.
      EXIT.
    ENDIF.
  ENDIF.

*- 기준일자 필수 점검
  IF GS_TIME-STDDT IS INITIAL.
    PERFORM RETURN_MESSAGE_TIME USING GC_E
                                      TEXT-E19. "기준일자는 필수 입력 값입니다.
    PV_ERROR = GC_X.
    EXIT.
  ENDIF.

*- 작업유형 필수 점검
  IF GS_TIME-WC_TYPE IS INITIAL.
    PERFORM RETURN_MESSAGE_TIME USING GC_E
                                      TEXT-E20. "작업유형은 필수 입력 값입니다.
    PV_ERROR = GC_X.
    EXIT.
  ENDIF.

*- 표준 작업시간 필수 점검
  IF GS_TIME-ZTIME IS INITIAL.
    PERFORM RETURN_MESSAGE_TIME USING GC_E
                                      TEXT-E21. "표준 작업시간은 필수 입력 값입니다.
    PV_ERROR = GC_X.
    EXIT.
  ENDIF.

*- 시간단위 필수 점검
  IF GS_TIME-ZUNIT IS INITIAL.
    PERFORM RETURN_MESSAGE_TIME USING GC_E
                                      TEXT-E22. "시간단위는 필수 입력 값입니다.
    PV_ERROR = GC_X.
    EXIT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RETURN_MESSAGE_TIME
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GC_E
*&      --> P_
*&---------------------------------------------------------------------*
FORM RETURN_MESSAGE_TIME  USING   PV_STAT
                                  PV_MESSAGE.

  GT_TIME_RESULT = VALUE #( BASE GT_TIME_RESULT
                              ( WERKS        = GS_TIME-WERKS
                                ZSERNO       = GS_TIME-ZSERNO
                                MATNR        = GS_TIME-MATNR
                                STDDT        = GS_TIME-STDDT
                                WC_TYPE      = GS_TIME-WC_TYPE
                                ZERP_STAT    = PV_STAT
                                ZERP_MESSAGE = PV_MESSAGE ) ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_LOG_ZGTPPT1060
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GC_E
*&      --> LV_MESSAGE
*&---------------------------------------------------------------------*
FORM SAVE_LOG_ZGTPPT1060  USING    PV_STAT
                                   PV_MESSAGE.

  DATA: LT_ZGTPPT1060 TYPE TABLE OF ZGTPPT1060.
  DATA: LV_TIMESTAMP TYPE TIMESTAMPL.

  CLEAR: LT_ZGTPPT1060, LV_TIMESTAMP.

  GET TIME STAMP FIELD LV_TIMESTAMP.

  LT_ZGTPPT1060 = VALUE #( ( VALUE #( BASE CORRESPONDING #( GS_TIME )
                                        ZIFKEY       = LV_TIMESTAMP
                                        ZERP_STAT    = PV_STAT
                                        ZERP_MESSAGE = PV_MESSAGE
                                        IFDAT        = SY-DATUM
                                        IFTIM        = SY-UZEIT
                                        IFNAM        = SY-UNAME ) ) ).

  IF PV_STAT EQ GC_S.
    MODIFY ZGTPPT1060 FROM TABLE LT_ZGTPPT1060.
    IF SY-SUBRC = 0.
      COMMIT WORK.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RESULT_TIME_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> ZO_RESULT
*&      --> ZO_MESSAGE
*&---------------------------------------------------------------------*
FORM RESULT_TIME_DATA  USING    PO_RESULT
                                PO_MESSAGE.

  DATA: LV_MESSAGE(100),
        LV_RESULT(2).
  CLEAR: LV_MESSAGE, LV_RESULT.

  IF GT_TIME_RESULT IS NOT INITIAL.
*- 성공 건수
    DATA(LV_CNT_S) = REDUCE I(
                     INIT SUM = 0 FOR LS_CNT_S IN GT_TIME_RESULT
                     WHERE ( ZERP_STAT = 'S' )
                     NEXT SUM = SUM + 1 ).

*- 실패 건수
    DATA(LV_CNT_E) = REDUCE I(
                     INIT SUM = 0 FOR LS_CNT_E IN GT_TIME_RESULT
                     WHERE ( ZERP_STAT = 'E' )
                     NEXT SUM = SUM + 1 ).

    "전체 성공
    IF LV_CNT_S IS NOT INITIAL AND
       LV_CNT_E IS INITIAL.
      LV_RESULT = '00'.
      LV_MESSAGE = TEXT-S04. "데이터 수신에 성공하였습니다.

      "부분 성공
    ELSE.
      LV_RESULT = '01'.
      LV_MESSAGE = TEXT-E23. "데이터 수신 도중 오류가 발생하였습니다.

    ENDIF.

*- 처리 결과
    PO_RESULT  = LV_RESULT.
    PO_MESSAGE = LV_MESSAGE.

  ELSE.

    LV_RESULT = '01'.
    LV_MESSAGE = TEXT-E23. "데이터 수신 도중 오류가 발생하였습니다.

*- 처리 결과
    PO_RESULT  = LV_RESULT.
    PO_MESSAGE = LV_MESSAGE.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONVERSION_INPUT_TIME
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_TIME
*&---------------------------------------------------------------------*
FORM CONVERSION_INPUT_TIME  USING    PS_TIME TYPE ZGTPPT1060.

  CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
    EXPORTING
      INPUT  = PS_TIME-MATNR
    IMPORTING
      OUTPUT = PS_TIME-MATNR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONVERSION_OUTPUT_TIME
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CONVERSION_OUTPUT_TIME .
  LOOP AT GT_TIME_RESULT INTO DATA(LS_RESULT).
    CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
      EXPORTING
        INPUT  = LS_RESULT-MATNR
      IMPORTING
        OUTPUT = LS_RESULT-MATNR.

    MODIFY GT_TIME_RESULT FROM LS_RESULT.
  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONVERSION_INPUT_CLSD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GS_CLSD_AUFNR
*&---------------------------------------------------------------------*
FORM CONVERSION_INPUT_CLSD  USING    PV_VALUE.
  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
    EXPORTING
      INPUT  = PV_VALUE
    IMPORTING
      OUTPUT = PV_VALUE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PRO_ORD_CHG_STAT
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_ERROR
*&      --> LV_RUECK
*&      --> LV_RMZHL
*&      --> GS_CLSD_I_MODE
*&---------------------------------------------------------------------*
FORM PRO_ORD_CHG_STAT  USING    PV_ERROR
                                PV_RUECK
                                PV_RMZHL
                                PV_MODE.

  DATA: LS_OBJECT TYPE BAPI_PP_ORDER_OBJECTS,
        LS_RETURN TYPE BAPIRET2.

  CLEAR: LS_RETURN, GS_HEADER1, GT_HEADER1, GT_OP1, GS_OP1,
         GT_POSITION1, GS_POSITION1, GV_STATUS.

  LS_OBJECT = VALUE #( HEADER = 'X'
                       POSITIONS = 'X'
                       OPERATIONS = 'X' ).

*- 생산오더 디테일 펑션 호출
  CALL FUNCTION 'BAPI_PRODORD_GET_DETAIL'
    EXPORTING
      NUMBER        = GS_CLSD-AUFNR
      ORDER_OBJECTS = LS_OBJECT
    IMPORTING
      RETURN        = LS_RETURN
    TABLES
      HEADER        = GT_HEADER1
      POSITION      = GT_POSITION1
      OPERATION     = GT_OP1.

*- 생산오더 상태 펑션
  CALL FUNCTION 'Z_PP_ORDER_STATUS'
    EXPORTING
      I_AUFNR  = GS_CLSD-AUFNR
    IMPORTING
      E_STATUS = GV_STATUS.

  IF LS_RETURN-TYPE = GC_E.
    PERFORM RETURN_MESSAGE_CLSD USING GC_E
                                      TEXT-E39. "생산오더가 존재하지 않습니다.
    PV_ERROR = GC_X.
    EXIT.

  ELSE.
    LOOP AT GT_HEADER1 INTO DATA(LS_HEADER).
      IF LS_HEADER IS INITIAL.
        DELETE GT_HEADER1 FROM LS_HEADER.
      ENDIF.
    ENDLOOP.

    GS_HEADER1 = VALUE #( GT_HEADER1[ 1 ] OPTIONAL ).
    GS_POSITION1 = VALUE #( GT_POSITION1[ 1 ] OPTIONAL ).

*- 수신데이터 정합성 체크
*- 공통체크 항목
    IF GS_HEADER1-PRODUCTION_PLANT <> GS_CLSD-WERKS.
      PERFORM RETURN_MESSAGE_CLSD USING GC_E
                                        TEXT-E40. "생산오더가 해당플랜트에 존재하지 않습니다.
      PV_ERROR = 'X'.
      EXIT.
    ENDIF.

    DELETE GT_OP1 WHERE SEQUENCE_NO <> 0.

*- 오더 상태 체크
    PERFORM CHECK_ORDER_STATUS USING PV_ERROR
                                     PV_MODE.
    IF PV_ERROR = 'X'.
      EXIT.
    ENDIF.

*- 생산오더 종료/취소 처리
    "(오더 최종 확정 처리 및 종료 처리)
    PERFORM FINAL_BAPI_PRODORDCONF_CREATE USING PV_MODE.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RETURN_MESSAGE_CLSD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GC_E
*&      --> TEXT_E39
*&---------------------------------------------------------------------*
FORM RETURN_MESSAGE_CLSD  USING   PV_STAT
                                  PV_MESSAGE.

  GT_CLSD_RESULT = VALUE #( BASE GT_CLSD_RESULT
                              ( WERKS        = GS_CLSD-WERKS
                                ZSERNO       = GS_CLSD-ZSERNO
                                AUFNR        = GS_CLSD-AUFNR
                                ZERP_STAT    = PV_STAT
                                ZERP_MESSAGE = PV_MESSAGE ) ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CHECK_ORDER_STATUS
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PV_ERROR
*&      --> P_MODE
*&---------------------------------------------------------------------*
FORM CHECK_ORDER_STATUS  USING    PV_ERROR
                                  PV_MODE.

  DATA : BEGIN OF LS_DATA,
           STAT TYPE CHAR100,
         END OF LS_DATA,
         LT_DATA LIKE TABLE OF LS_DATA.

  CLEAR : LS_DATA, LT_DATA, GV_CHK.
  SPLIT GV_STATUS AT ' ' INTO TABLE LT_DATA.

  IF PV_MODE = 'P'. "종료처리

    IF LINE_EXISTS( LT_DATA[ STAT = 'TECO' ] ).

      PERFORM RETURN_MESSAGE_CLSD USING GC_E
                                        '생산오더가 TECO 상태입니다.'.
      PV_ERROR = 'X'.
      EXIT.
    ENDIF.
    IF LINE_EXISTS( LT_DATA[ STAT = 'DLFL' ] ).

      PERFORM RETURN_MESSAGE_CLSD USING GC_E
                                            '생산오더가 Deletion 상태입니다.'.
      PV_ERROR = 'X'.
      EXIT.
    ENDIF.
    IF LINE_EXISTS( LT_DATA[ STAT = 'DLV' ] ) AND
       LINE_EXISTS( LT_DATA[ STAT = 'CNF' ] ).

      PERFORM RETURN_MESSAGE_CLSD USING GC_S
                                            '생산오더가 종료 상태입니다.'.
      PV_ERROR = 'X'.
      GV_CHK = 'X'.
      EXIT.
    ENDIF.
    IF LINE_EXISTS( LT_DATA[ STAT = 'PDLV' ] ) OR
       LINE_EXISTS( LT_DATA[ STAT = 'PDLV*' ] ) OR
       LINE_EXISTS( LT_DATA[ STAT = 'DLV' ] ).
    ELSE.
      PERFORM RETURN_MESSAGE_CLSD USING GC_E
                                            '생산오더 입고 수량이 없습니다.'.
      PV_ERROR = 'X'.
      EXIT.
    ENDIF.
    IF LINE_EXISTS( LT_DATA[ STAT = 'PCNF' ] ) OR
       LINE_EXISTS( LT_DATA[ STAT = 'CNF' ] ).
    ELSE.
      PERFORM RETURN_MESSAGE_CLSD USING GC_E
                                            '생산오더의 확정 데이터가 없습니다.'.
      PV_ERROR = 'X'.
      EXIT.
    ENDIF.

    LOOP AT GT_OP1 INTO GS_OP1.
      CLEAR : LT_DATA.
      SPLIT GS_OP1-SYSTEM_STATUS AT ' ' INTO TABLE LT_DATA.

      IF LINE_EXISTS( LT_DATA[ STAT = 'CNF' ] ).
        DELETE GT_OP1. CONTINUE.
      ENDIF.

      IF LINE_EXISTS( LT_DATA[ STAT = 'PCNF' ] ) OR
         LINE_EXISTS( LT_DATA[ STAT = 'CNF' ] ).
      ELSE.
        PERFORM RETURN_MESSAGE_CLSD USING GC_E
                                              '확정되지 않은 공정이 있습니다.'.
        PV_ERROR = 'X'.
        EXIT.
      ENDIF.
    ENDLOOP.

  ELSEIF PV_MODE = 'C'. "종료취소

    IF LINE_EXISTS( LT_DATA[ STAT = 'TECO' ] ).

      PERFORM RETURN_MESSAGE_CLSD USING GC_E
                                            '생산오더가 TECO 상태입니다.'.
      PV_ERROR = 'X'.
      EXIT.
    ENDIF.
    IF LINE_EXISTS( LT_DATA[ STAT = 'DLFL' ] ).

      PERFORM RETURN_MESSAGE_CLSD USING GC_E
                                            '생산오더가 Deletion 상태입니다.'.
      PV_ERROR = 'X'.
      EXIT.
    ENDIF.
*    IF NOT LINE_EXISTS( LT_DATA[ STAT = 'DLV' ] ) AND
*       NOT LINE_EXISTS( LT_DATA[ STAT = 'CNF' ] ).
*
*      PERFORM RETURN_MESSAGE_CLSD USING GC_E
*                                            '생산오더가 종료되지 않았습니다.'.
*      PV_ERROR = 'X'.
*      EXIT.
*    ENDIF.
    IF LINE_EXISTS( LT_DATA[ STAT = 'DLV' ] ) AND
       LINE_EXISTS( LT_DATA[ STAT = 'CNF' ] ).
    ELSE.
      PERFORM RETURN_MESSAGE_CLSD USING GC_S
                                            '현재 종료 상태가 아닙니다.'.
      PV_ERROR = 'X'.
      GV_CHK = 'X'.
      EXIT.
    ENDIF.

* 취소시 오더 상태의 확정 상태 확인 SKIP - 20241224
*    LOOP AT GT_OP1 INTO GS_OP1.
*      CLEAR : LT_DATA.
*      SPLIT GS_OP1-SYSTEM_STATUS AT ' ' INTO TABLE LT_DATA.
*
*      IF LINE_EXISTS( LT_DATA[ STAT = 'CNF' ] ).
*      ELSE.
*        PERFORM RETURN_MESSAGE_CLSD USING GC_E
*                                              '확정되지 않은 공정이 있습니다.'.
*        PV_ERROR = 'X'.
*        EXIT.
*      ENDIF.
*    ENDLOOP.

  ELSEIF PV_MODE = 'T'. "TECO 처리

    IF LINE_EXISTS( LT_DATA[ STAT = 'TECO' ] ).

      PERFORM RETURN_MESSAGE_CLSD USING GC_E
                                            '생산오더가 TECO 상태입니다.'.
      PV_ERROR = 'X'.
      EXIT.
    ENDIF.
    IF LINE_EXISTS( LT_DATA[ STAT = 'DLFL' ] ).

      PERFORM RETURN_MESSAGE_CLSD USING GC_E
                                            '생산오더가 Deletion 상태입니다.'.
      PV_ERROR = 'X'.
      EXIT.
    ENDIF.
    IF LINE_EXISTS( LT_DATA[ STAT = 'DLV' ] ) OR
       LINE_EXISTS( LT_DATA[ STAT = 'CNF' ] ) OR
       LINE_EXISTS( LT_DATA[ STAT = 'PDLV' ] ) OR
       LINE_EXISTS( LT_DATA[ STAT = 'PDLV*' ] ) OR
       LINE_EXISTS( LT_DATA[ STAT = 'PCNF' ] ).

      PERFORM RETURN_MESSAGE_CLSD USING GC_E
                                            '생산오더가 TECO 처리 대상이 아닙니다.'.
      PV_ERROR = 'X'.
      EXIT.
    ENDIF.

  ELSEIF PV_MODE = 'Z'. "TECO 처리 취소

    IF LINE_EXISTS( LT_DATA[ STAT = 'DLFL' ] ).

      PERFORM RETURN_MESSAGE_CLSD USING GC_E
                                            '생산오더가 Deletion 상태입니다.'.
      PV_ERROR = 'X'.
      EXIT.
    ENDIF.
    IF LINE_EXISTS( LT_DATA[ STAT = 'TECO' ] ).
    ELSE.
      PERFORM RETURN_MESSAGE_CLSD USING GC_E
                                            '생산오더가 TECO 처리 상태가 아닙니다.'.
      PV_ERROR = 'X'.
      EXIT.
    ENDIF.

  ELSEIF PV_MODE = 'R'. "릴리즈 처리

    IF NOT LINE_EXISTS( LT_DATA[ STAT = 'CRTD' ] ).

      PERFORM RETURN_MESSAGE_CLSD USING GC_E
                                            '생산오더가 릴리즈 할 수 없는 상태입니다.'.
      PV_ERROR = 'X'.
      EXIT.
    ENDIF.

  ELSEIF PV_MODE = 'B'. "릴리즈 취소 처리

    IF LINE_EXISTS( LT_DATA[ STAT = 'CRTD' ] ) OR
       LINE_EXISTS( LT_DATA[ STAT = 'CNF' ] )  OR
       LINE_EXISTS( LT_DATA[ STAT = 'PCNF' ] ) OR
       LINE_EXISTS( LT_DATA[ STAT = 'PDLV' ] ) OR
       LINE_EXISTS( LT_DATA[ STAT = 'DLV' ] )  OR
       LINE_EXISTS( LT_DATA[ STAT = 'TECO' ] ) OR
       LINE_EXISTS( LT_DATA[ STAT = 'DLFL' ] ).

      PERFORM RETURN_MESSAGE_CLSD USING GC_E
                                            '생산오더가 릴리즈를 취소할 수 없는 상태입니다.'.
      PV_ERROR = 'X'.
      EXIT.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_LOG_ZGTPPT3130
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> GC_E
*&      --> LV_MESSAGE
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM SAVE_LOG_ZGTPPT3130  USING    PV_STAT
                                   PV_MESSAGE
                                   PV_RUECK    "작업완료 확정 번호
                                   PV_RMZHL.   "확정 카운트

  DATA: LT_ZGTPPT3130 TYPE TABLE OF ZGTPPT3130.
  DATA: LV_TIMESTAMP TYPE TIMESTAMPL.
  DATA: LS_ZGTPPT3130 TYPE ZGTPPT3130.
  DATA: LV_STAT TYPE ZGTESTAT_P.

  CLEAR: LT_ZGTPPT3130, LV_TIMESTAMP.

  GET TIME STAMP FIELD LV_TIMESTAMP.

  CLEAR: LV_STAT.
  LV_STAT = PV_STAT.

  IF GV_CHK EQ 'X'.
    LV_STAT = 'S'.
  ENDIF.

  LT_ZGTPPT3130 = VALUE #( ( VALUE #( BASE CORRESPONDING #( GS_CLSD )
                                        ZIFKEY       = LV_TIMESTAMP
                                        RUECK        = PV_RUECK
                                        RMZHL        = PV_RMZHL
                                        ZERP_STAT    = LV_STAT
                                        ZERP_MESSAGE = PV_MESSAGE
                                        IFNAM        = SY-UNAME
                                        IFDAT        = SY-DATUM
                                        IFTIM        = SY-UZEIT ) ) ).

  MODIFY ZGTPPT3130 FROM TABLE LT_ZGTPPT3130.
  IF SY-SUBRC = 0.
    COMMIT WORK.
  ENDIF.

* ZO_RESULT, ZO_MESSAGE 업데이트를 위한 키필드 반영
  CLEAR: GS_CLSD_KEYS, LS_ZGTPPT3130.
  LOOP AT LT_ZGTPPT3130 INTO LS_ZGTPPT3130.
    MOVE-CORRESPONDING LS_ZGTPPT3130 TO GS_CLSD_KEYS.
    APPEND GS_CLSD_KEYS TO GT_CLSD_KEYS.
    CLEAR: LS_ZGTPPT3130.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form FINAL_BAPI_PRODORDCONF_CREATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PV_MODE
*&---------------------------------------------------------------------*
FORM FINAL_BAPI_PRODORDCONF_CREATE  USING    PV_MODE.

  DATA: BEGIN OF LS_DATA,
          STAT TYPE BAPI_ORDER_HEADER1-SYSTEM_STATUS,
        END OF LS_DATA,
        LT_DATA LIKE TABLE OF LS_DATA.

  DATA: LV_ERROR.

  CLEAR: LS_DATA, LT_DATA, LV_ERROR, GV_CONF_NO, GV_CONF_CNT.

  IF PV_MODE = 'T' OR   "생산오더 TECO 처리/취소
     PV_MODE = 'Z'.
    PERFORM BDC_TECO USING PV_MODE.

  ELSEIF PV_MODE = 'R'.  "릴리즈
    PERFORM BAPI_RELEASE.

  ELSEIF PV_MODE = 'B'.  "릴리즈 취소
    PERFORM BDC_RELEASE USING PV_MODE.

  ELSE.
*- 최종 확정 처리 할 오더의 마지막 전기일
    CLEAR: GV_BUDAT_TT.
    SELECT SINGLE MAX( BUDAT )
      INTO GV_BUDAT_TT
      FROM AFRU
     WHERE AUFNR = GS_CLSD-AUFNR
       AND STOKZ = SPACE
       AND STZHL = SPACE.

*- Operation 최종 확정 처리
    LOOP AT GT_OP1 INTO GS_OP1.
      CLEAR : LT_DATA.

      SPLIT GS_OP1-SYSTEM_STATUS AT ' ' INTO TABLE LT_DATA.

      IF PV_MODE = 'P'.
        IF LINE_EXISTS( LT_DATA[ STAT = 'CNF' ] ).
          CONTINUE.
        ENDIF.

        PERFORM BAPI_PRODORDCONF_CREATE USING LV_ERROR
                                              PV_MODE.
        IF LV_ERROR = 'X'.
          EXIT.
        ENDIF.

      ELSEIF PV_MODE = 'C'.
        IF NOT LINE_EXISTS( LT_DATA[ STAT = 'CNF' ] ).
          CONTINUE.
        ENDIF.

        PERFORM BAPI_PROD_ORD_CONF_CANCEL USING LV_ERROR
                                                PV_MODE.
        IF LV_ERROR = 'X'.
          EXIT.
        ENDIF.

      ENDIF.

      CLEAR GS_OP1.
    ENDLOOP.

*- 확정성공시 생산오더 입고 종료/취소
    IF LV_ERROR = SPACE.
      PERFORM BDC_TRANSACTION_CO02 USING PV_MODE.
    ENDIF.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BDC_TECO
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PV_MODE
*&---------------------------------------------------------------------*
FORM BDC_TECO  USING    PV_MODE.

  DATA: LV_MESSAGE(220).

  CLEAR : GT_BDCDATA, GT_BDCDATA[], GT_MESSAGE, GT_MESSAGE[], LV_MESSAGE.

  IF PV_MODE = 'T'.

    PERFORM BDC_INPUT USING :
     'SAPLCOKO1' '0110' 'X' 'CAUFVD-AUFNR' GS_CLSD-AUFNR,
     '         ' '    ' ' ' 'R62CLORD-FLG_OVIEW' 'X',
     '         ' '    ' ' ' 'BDC_OKCODE' '=ENTK'.

    PERFORM BDC_INPUT USING :
     'SAPLCOKO1' '0115' 'X' 'BDC_OKCODE' '=TABS'.

    PERFORM BDC_INPUT USING :
     'SAPLCOKO1' '0115' 'X' 'BDC_OKCODE' '=BU'.

  ELSEIF PV_MODE = 'Z'.

    PERFORM BDC_INPUT USING :
     'SAPLCOKO1' '0110' 'X' 'CAUFVD-AUFNR' GS_CLSD-AUFNR,
     '         ' '    ' ' ' 'R62CLORD-FLG_OVIEW' 'X',
     '         ' '    ' ' ' 'BDC_OKCODE' '=ENTK'.

    PERFORM BDC_INPUT USING :
     'SAPLCOKO1' '0115' 'X' 'BDC_OKCODE' '=TABR'.

    PERFORM BDC_INPUT USING :
     'SAPLCOKO1' '0115' 'X' 'BDC_OKCODE' '=BU'.

  ENDIF.

  PERFORM FILL_CTU_PARAMS USING 'N'.
  CALL TRANSACTION 'CO02' USING GT_BDCDATA
                          OPTIONS FROM GS_PARAMS
                          MESSAGES INTO GT_MESSAGE.

  PERFORM MESSAGE_FUNCTION USING GT_MESSAGE LV_MESSAGE.

*- 실패
  IF LINE_EXISTS( GT_MESSAGE[ MSGTYP = 'A' ] ) OR
     LINE_EXISTS( GT_MESSAGE[ MSGTYP = 'E' ] ) OR
     LINE_EXISTS( GT_MESSAGE[ MSGTYP = 'X' ] ).

    PERFORM RETURN_MESSAGE_CLSD USING GC_E
                                      LV_MESSAGE.
    PERFORM SAVE_LOG_ZGTPPT3130 USING GC_E
                                      LV_MESSAGE
                                      ' '
                                      ' '.

*- 성공
  ELSE.
    IF PV_MODE = 'T'.
      PERFORM RETURN_MESSAGE_CLSD USING GC_S
                                        'TECO 처리 성공'.
      PERFORM SAVE_LOG_ZGTPPT3130 USING GC_S
                                        'TECO 처리 성공'
                                        ' '
                                        ' '.

    ELSEIF PV_MODE = 'Z'.
      PERFORM RETURN_MESSAGE_CLSD USING GC_S
                                        'TECO 취소 성공'.
      PERFORM SAVE_LOG_ZGTPPT3130 USING GC_S
                                        'TECO 취소 성공'
                                        ' '
                                        ' '.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BAPI_RELEASE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM BAPI_RELEASE .

  DATA: LT_ORDERS	TYPE BAPI_ORDER_KEY OCCURS 0 WITH HEADER LINE,
        LT_RETURN	TYPE BAPIRET2 OCCURS 0 WITH HEADER LINE.
  DATA : LV_MESSAGE(220).
  CLEAR: LT_RETURN, LT_RETURN[], LT_ORDERS, LT_ORDERS[], LV_MESSAGE.

  LT_ORDERS-ORDER_NUMBER = GS_CLSD-AUFNR.
  APPEND LT_ORDERS.

  CALL FUNCTION 'BAPI_PRODORD_RELEASE'
    EXPORTING
      RELEASE_CONTROL    = '1'
      WORK_PROCESS_GROUP = 'COWORK_BAPI'
      WORK_PROCESS_MAX   = 99
    IMPORTING
      RETURN             = LT_RETURN
    TABLES
      ORDERS             = LT_ORDERS.

  READ TABLE LT_RETURN WITH KEY TYPE = GC_E.
  IF SY-SUBRC <> 0.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.
    WAIT UP TO '2' SECONDS.

    PERFORM RETURN_MESSAGE_CLSD USING GC_S
                                      '릴리즈 처리 성공'.
    PERFORM SAVE_LOG_ZGTPPT3130 USING GC_S
                                      '릴리즈 처리 성공'
                                      ' '
                                      ' '.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    READ TABLE LT_RETURN WITH KEY TYPE = GC_E.
    LV_MESSAGE = LT_RETURN-MESSAGE.

    PERFORM RETURN_MESSAGE_CLSD USING GC_E
                                      LV_MESSAGE.
    PERFORM SAVE_LOG_ZGTPPT3130 USING GC_E
                                      LV_MESSAGE
                                      ' '
                                      ' '.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BDC_RELEASE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_MODE
*&---------------------------------------------------------------------*
FORM BDC_RELEASE  USING    PV_MODE.

  DATA : LV_MESSAGE(220).

  CLEAR : GT_BDCDATA, GT_BDCDATA[], GT_MESSAGE, GT_MESSAGE[], LV_MESSAGE.

  PERFORM BDC_INPUT USING :
   'SAPLCOKO1' '0110' 'X' 'CAUFVD-AUFNR' GS_CLSD-AUFNR,
   '         ' '    ' ' ' 'R62CLORD-FLG_OVIEW' 'X',
   '         ' '    ' ' ' 'BDC_OKCODE' '=ENTK'.

  PERFORM BDC_INPUT USING :
   'SAPLCOKO1' '0115' 'X' 'BDC_OKCODE' '=STAK'.

  PERFORM BDC_INPUT USING :
   'SAPLSPO2' '0300' 'X' 'BDC_OKCODE' 'OPT2'.

  IF SY-UNAME <> 'EAI_IF'.
    PERFORM BDC_INPUT USING :
     'SAPLCOKO1' '0131' 'X' 'RC62F-VER_SEL' 'X',
     '         ' '    ' ' ' 'RC62F-PROD_VERS' GS_POSITION1-PRODUCTION_VERSION,
     '         ' '    ' ' ' 'RC62F-NEW_ROUT' 'X',
     '         ' '    ' ' ' 'RC62F-PLAUF' GS_HEADER1-START_DATE,
     '         ' '    ' ' ' 'RC62F-NEW_BOM' 'X',
     '         ' '    ' ' ' 'RC62F-AUFLD' GS_HEADER1-START_DATE,
     '         ' '    ' ' ' 'BDC_OKCODE' '=ENT1'.
  ENDIF.

  PERFORM BDC_INPUT USING :
   'SAPLCOKO1' '0115' 'X' 'BDC_OKCODE' '=BU'.

  PERFORM BDC_INPUT USING :
   'SAPLSPO1' '0300' 'X' 'BDC_OKCODE' '=YES'.

*  ENDIF.

  PERFORM FILL_CTU_PARAMS USING 'N'.
  GS_PARAMS-NOBINPT = 'X'.
  CALL TRANSACTION 'CO02' USING GT_BDCDATA
                          OPTIONS FROM GS_PARAMS
                          MESSAGES INTO GT_MESSAGE.

  PERFORM MESSAGE_FUNCTION USING GT_MESSAGE LV_MESSAGE.

*- 실패
  IF LINE_EXISTS( GT_MESSAGE[ MSGTYP = 'A' ] ) OR
     LINE_EXISTS( GT_MESSAGE[ MSGTYP = 'E' ] ) OR
     LINE_EXISTS( GT_MESSAGE[ MSGTYP = 'X' ] ) OR
     LINE_EXISTS( GT_MESSAGE[ MSGID = '00' MSGNR = '344' ] ).

    PERFORM RETURN_MESSAGE_CLSD USING GC_E
                                      LV_MESSAGE.
    PERFORM SAVE_LOG_ZGTPPT3130 USING GC_E
                                      LV_MESSAGE
                                      ' '
                                      ' '.
*- 성공
  ELSE.
    PERFORM RETURN_MESSAGE_CLSD USING GC_S
                                      '릴리즈 취소 성공'.
    PERFORM SAVE_LOG_ZGTPPT3130 USING GC_S
                                      '릴리즈 취소 성공'
                                      ' '
                                      ' '.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BAPI_PRODORDCONF_CREATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_ERROR
*&      --> PV_MODE
*&---------------------------------------------------------------------*
FORM BAPI_PRODORDCONF_CREATE  USING PV_ERROR
                                    PV_MODE.

  DATA: LT_TT      TYPE TABLE OF BAPI_PP_TIMETICKET,
        LT_GOODS   TYPE TABLE OF BAPI2017_GM_ITEM_CREATE,
        LT_DETAIL  TYPE TABLE OF BAPI_CORU_RETURN,
        LS_DETAIL  TYPE BAPI_CORU_RETURN,
        LS_RETURN  TYPE BAPIRET1,
        LV_MESSAGE TYPE BAPI_CORU_RETURN-MESSAGE.

  CLEAR : LT_TT, LT_GOODS, LT_DETAIL, LS_RETURN, LV_MESSAGE, LS_DETAIL.
  CLEAR : GV_CONF_NO, GV_CONF_CNT.

  LT_TT = VALUE #( ( CONF_NO    = GS_OP1-CONF_NO
                     ORDERID    = GS_CLSD-AUFNR
                     OPERATION  = GS_OP1-OPERATION_NUMBER
                     WORK_CNTR  = GS_OP1-WORK_CENTER
                     POSTG_DATE = GV_BUDAT_TT  "SY-DATUM "확정 이력의 마지막 전기일
                     PLANT      = GS_CLSD-WERKS
                     FIN_CONF   = 'X'
                     CLEAR_RES  = 'X'
                      ) ).

*- 생산 실적 처리 (최종 확정 처리)
  CALL FUNCTION 'BAPI_PRODORDCONF_CREATE_TT'
    IMPORTING
      RETURN         = LS_RETURN
    TABLES
      TIMETICKETS    = LT_TT
      GOODSMOVEMENTS = LT_GOODS
      DETAIL_RETURN  = LT_DETAIL.

*- 성공
  IF LS_RETURN IS INITIAL.

    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.

    LS_DETAIL = VALUE #( LT_DETAIL[ 1 ] OPTIONAL ).

*    PERFORM RETURN_MESSAGE_CLSD USING GC_S
*                                      LS_DETAIL-MESSAGE.

    GV_CONF_NO  = LS_DETAIL-CONF_NO.
    GV_CONF_CNT = LS_DETAIL-CONF_CNT.

*    PERFORM SAVE_LOG_ZGTPPT3130 USING GC_S
*                                      LS_DETAIL-MESSAGE
*                                      LS_DETAIL-CONF_NO
*                                      LS_DETAIL-CONF_CNT.


*    IF PV_SIGN = 'X'. "PCNF가 포함된 것만 종료처리
*
**- 생산오더의 생산입고 종료 처리
*      PERFORM BDC_TRANSACTION_CO02 USING P_MODE.
*    ENDIF.

*- 실패
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    PV_ERROR = 'X'.
    LOOP AT LT_DETAIL INTO LS_DETAIL WHERE TYPE = 'A'
                                       OR  TYPE = 'E'
                                       OR  TYPE = 'X'.

      PERFORM RETURN_MESSAGE_CLSD USING GC_E
                                        LS_DETAIL-MESSAGE.
      PERFORM SAVE_LOG_ZGTPPT3130 USING GC_E
                                        LS_DETAIL-MESSAGE
                                        ' '
                                        ' '.
*      CLEAR LS_DETAIL.
      EXIT.
    ENDLOOP.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BDC_TRANSACTION_CO02
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PV_MODE
*&---------------------------------------------------------------------*
FORM BDC_TRANSACTION_CO02  USING    PV_MODE.

  DATA : BEGIN OF LS_DATA,
           STAT TYPE BAPI_ORDER_HEADER1-SYSTEM_STATUS,
         END OF LS_DATA,
         LT_DATA LIKE TABLE OF LS_DATA.
  DATA : LV_MESSAGE(220),
         LV_ERROR.

  DATA : BEGIN OF LS_AFPO,
           AUFNR TYPE AFPO-AUFNR,
           POSNR TYPE AFPO-POSNR,
           ELIKZ TYPE AFPO-ELIKZ,
         END OF LS_AFPO,
         LT_AFPO LIKE TABLE OF LS_AFPO.
  DATA : LV_FLAG(1).

  DATA: LV_MBLNR TYPE MBLNR.

  CLEAR : LS_DATA, LT_DATA, LV_MESSAGE.

  IF PV_MODE = 'P'.
*- 납품완료 상태이면 종료처리 skip.
    SPLIT GV_STATUS AT ' ' INTO TABLE LT_DATA.
* DLV 상태에도 0 입고를 위해 하기 로직 SKIP - 20241220
*    IF LINE_EXISTS( LT_DATA[ STAT = 'DLV' ] ).
*
*      PERFORM RETURN_MESSAGE_CLSD USING GC_S
*                                        '생산오더 종료 성공'.
*      PERFORM SAVE_LOG_ZGTPPT3130 USING GC_S
*                                        '생산오더 종료 성공'
*                                        GV_CONF_NO
*                                        GV_CONF_CNT.
*      EXIT.
*    ENDIF.
* 생산 오더의 상태가 0 입고 자재 문서가 존재하면 생산오더 종료 처리 SKIP
    CLEAR: LV_MBLNR.
    " 기존 로직 주석처리 20250107 BY HSY START
***    SELECT SINGLE MBLNR
***      INTO LV_MBLNR
***      FROM MATDOC
***     WHERE AUFNR     EQ GS_CLSD-AUFNR
***       AND BWART     EQ '101'
***       AND WERKS     EQ GS_CLSD-WERKS
***       AND CHARG     EQ 'GR_ZERO1'
***       AND ELIKZ     EQ GC_X
***       AND CANCELLED EQ SPACE.
    " 기존 로직 주석처리 20250107 BY HSY END

    " 수정 로직 START----------------------------------------------------
    "1) 생산오더의 전체 품목 발췌
    SELECT AUFNR, POSNR, ELIKZ
      INTO CORRESPONDING FIELDS OF TABLE @LT_AFPO
      FROM AFPO
     WHERE AUFNR EQ @GS_CLSD-AUFNR
      AND PWERK  EQ @GS_CLSD-WERKS.

    IF LT_AFPO[] IS NOT INITIAL.
      CLEAR : LV_FLAG.
      LOOP AT LT_AFPO INTO LS_AFPO.
        IF LS_AFPO-ELIKZ <> 'X'.
          " 생산오더가 완료처리가 안된 품목이 있을시
          LV_FLAG = 'X'.
        ENDIF.
      ENDLOOP.
    ENDIF.
    " 수정 로직 END------------------------------------------------------
***    IF LV_MBLNR IS NOT INITIAL." 기존 로직 주석처리
    IF LV_FLAG <> 'X'." 기존 로직 주석처리
      PERFORM RETURN_MESSAGE_CLSD USING GC_S
                                        '생산오더 종료 성공'.
      PERFORM SAVE_LOG_ZGTPPT3130 USING GC_S
                                        '생산오더 종료 성공'
                                        GV_CONF_NO
                                        GV_CONF_CNT.
      EXIT.
    ENDIF.

*- 오더별 총수량이 '0'이면 종료처리 X
    SELECT CASE BWART WHEN '102' THEN ( ABS( MENGE ) * -1 )
                      ELSE MENGE
           END AS MENGE
      FROM AUFM
      INTO TABLE @DATA(LT_AUFM)
     WHERE AUFNR = @GS_CLSD-AUFNR
       AND WERKS = @GS_CLSD-WERKS
       AND ( BWART = '101' OR BWART = '102' ).

    DATA(LV_SUM) = REDUCE #( INIT SUM = CONV AUFM-MENGE( 0 )
                             FOR LS_AUFM IN LT_AUFM
                             NEXT SUM = SUM + LS_AUFM-MENGE ).

    IF LV_SUM = 0.
      PERFORM RETURN_MESSAGE_CLSD USING GC_E
                                        '생산 입고 수량이 없습니다.'.
      PERFORM SAVE_LOG_ZGTPPT3130 USING GC_E
                                        '생산 입고 수량이 없습니다.'
                                        GV_CONF_NO
                                        GV_CONF_CNT.
      EXIT.
    ENDIF.

*- 종료처리 전 자재문서 전기일 체크
    SELECT A~MBLNR, A~MJAHR, A~AUFNR, A~SJAHR, A~SMBLN, A~BWART, A~CHARG, B~BUDAT
      FROM MSEG AS A
     INNER JOIN AUFM AS B ON A~MBLNR = B~MBLNR
                         AND A~MJAHR = B~MJAHR
                         AND A~WERKS = B~WERKS
                         AND A~AUFNR = B~AUFNR
     WHERE B~AUFNR = @GS_CLSD-AUFNR
       AND ( A~BWART = '101' OR A~BWART = '102' )
       AND B~WERKS = @GS_CLSD-WERKS
      INTO TABLE @DATA(LT_MSEG).

    "이동유형(101,102) 데이터 맵핑 삭제
    LOOP AT LT_MSEG INTO DATA(LS_MSEG) WHERE BWART = '102'.
      DELETE LT_MSEG WHERE MBLNR = LS_MSEG-SMBLN
                       AND MJAHR = LS_MSEG-SJAHR.
      DELETE LT_MSEG. CONTINUE.
    ENDLOOP.

    "마지막 전기일
    CLEAR: GV_BUDAT.
    SORT LT_MSEG BY BUDAT DESCENDING.
    READ TABLE LT_MSEG INTO LS_MSEG INDEX 1.
    GV_BUDAT = LS_MSEG-BUDAT.

    "전기일이 당월이 아닌 경우 : 배치생성/ZERO입고처리(DLV 확정처리)
*    IF NOT LINE_EXISTS( LT_MSEG[ BUDAT+4(2) = SY-DATUM+4(2) ] ).
    PERFORM BAPI_BATCH_CREATE.
    EXIT.
*    ENDIF.

  ELSEIF PV_MODE = 'C'.
*- 납품완료 상태이면 종료취소처리
    SPLIT GV_STATUS AT ' ' INTO TABLE LT_DATA.

    IF NOT LINE_EXISTS( LT_DATA[ STAT = 'DLV ' ] ).
      PERFORM RETURN_MESSAGE_CLSD USING GC_S
                                        '생산오더 종료 취소 성공'.

      PERFORM SAVE_LOG_ZGTPPT3130 USING GC_S
                                        '생산오더 종료 취소 성공'
                                        GV_CONF_NO
                                        GV_CONF_CNT.
      EXIT.
    ENDIF.

*- 생산 오더 입고 취소 처리
    PERFORM BAPI_GOODSMVT_CANCEL_C.
  ENDIF.

*- 생산오더 입고 종료/취소 처리->생산 오더 입고 취소 처리 로 변경
*- BDC->BAPI로 취소 프로세스 변경
*  PERFORM BDC_TRANSACTION_BY_CO02 USING P_MODE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BAPI_BATCH_CREATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM BAPI_BATCH_CREATE .

  DATA: LV_BATCH TYPE MCHA-CHARG VALUE 'GR_ZERO1'.
  DATA: LV_CLASS TYPE KLAH-CLASS.
  DATA: LT_RETURN TYPE TABLE OF BAPIRET2,
        LS_ATTR   TYPE BAPIBATCHATT,
        LS_CTRL   TYPE BAPIBATCHCTRL.
  DATA: LV_MESSAGE TYPE BAPIRET2-MESSAGE.
  DATA: LV_MATNR   TYPE MARA-MATNR.

  CLEAR: LV_MESSAGE.
  CLEAR: LV_CLASS, LT_RETURN, LS_ATTR, LS_CTRL.

  SELECT SINGLE CHARG
    INTO @DATA(LV_CHARG)
    FROM MCHA
   WHERE MATNR = @GS_POSITION1-MATERIAL
     AND WERKS = @GS_CLSD-WERKS
     AND CHARG = @LV_BATCH.

  "배치생성
  IF SY-SUBRC <> 0.
    CLEAR LV_MATNR.
    LV_MATNR = GS_POSITION1-MATERIAL.

    CALL FUNCTION 'CLFC_BATCH_ALLOCATION_TO_CLASS'
      EXPORTING
        MATERIAL           = LV_MATNR
        PLANT              = GS_CLSD-WERKS
        CLASSTYPE          = '023'
      IMPORTING
        CLASS              = LV_CLASS
      EXCEPTIONS
        NO_CLASS_FOUND     = 1
        NO_CLASSTYPE_FOUND = 2
        OTHERS             = 3.

    LS_ATTR-STATUSKEY = '1'.
    LS_CTRL = VALUE #( CLASS_NUM = LV_CLASS
                       DOCLASSIFY = 'X' ).

    CALL FUNCTION 'BAPI_BATCH_CREATE'
      EXPORTING
        MATERIAL             = CONV MATNR18( GS_POSITION1-MATERIAL )
        BATCH                = LV_BATCH
        PLANT                = GS_CLSD-WERKS
        BATCHATTRIBUTES      = LS_ATTR
        BATCHCONTROLFIELDS   = LS_CTRL
        BATCHSTORAGELOCATION = GS_POSITION1-STORAGE_LOCATION
      TABLES
        RETURN               = LT_RETURN.

    IF LINE_EXISTS( LT_RETURN[ TYPE = 'E' ] ).
      CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
      LV_MESSAGE = VALUE #( LT_RETURN[ TYPE = 'E' ]-MESSAGE OPTIONAL ).
      PERFORM RETURN_MESSAGE_CLSD USING GC_E
                                        LV_MESSAGE.
      PERFORM SAVE_LOG_ZGTPPT3130 USING GC_E
                                        LV_MESSAGE
                                        ' '
                                        ' '.
      EXIT.
    ELSE.
      CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
        EXPORTING
          WAIT = 'X'.
    ENDIF.
  ENDIF.

  "ZERO 입고처리 및 DLV 확정처리
  PERFORM BAPI_ZERO_GOODSMVT_CREATE USING LV_BATCH.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BAPI_ZERO_GOODSMVT_CREATE
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_BATCH
*&---------------------------------------------------------------------*
FORM BAPI_ZERO_GOODSMVT_CREATE  USING    PV_BATCH.

  DATA: LS_HEADER   TYPE BAPI2017_GM_HEAD_01,
        LV_CODE     TYPE BAPI2017_GM_CODE VALUE '02',
        LV_DOCUMENT TYPE BAPI2017_GM_HEAD_RET-MAT_DOC,
        LV_YEAR     TYPE BAPI2017_GM_HEAD_RET-DOC_YEAR,
        LV_MESSAGE  TYPE BAPIRET2-MESSAGE,
        LT_ITEM     TYPE TABLE OF BAPI2017_GM_ITEM_CREATE,
        LS_ITEM     TYPE BAPI2017_GM_ITEM_CREATE,
        LT_RET      TYPE TABLE OF BAPIRET2.

  DATA : LV_ELIKZ LIKE AFPO-ELIKZ.  " ADD BY HSY 20250107

  CLEAR: LV_DOCUMENT, LV_YEAR, LT_RET, LV_MESSAGE.

  LS_HEADER = VALUE #( PSTNG_DATE = GV_BUDAT "SY-DATUM     "전표상의 전기일
                       DOC_DATE   = GV_BUDAT "SY-DATUM     "전표 증빙일
                       HEADER_TXT = PV_BATCH ).  "전표 헤더 텍스트

  LOOP AT GT_POSITION1 INTO DATA(LS_POSITION1).

    " 수정 로직 START----------------------------------------------------

    "1) 생산오더의 전체 품목 기준 납품완료 확인
    CLEAR LV_ELIKZ.
    SELECT SINGLE ELIKZ " 납품 완료 지시자
      INTO @LV_ELIKZ
      FROM AFPO
     WHERE AUFNR EQ @GS_CLSD-AUFNR
      AND PWERK  EQ @GS_CLSD-WERKS
      AND POSNR  EQ @LS_POSITION1-ORDER_ITEM_NUMBER
      AND ELIKZ  EQ 'X' .    "납품완료
    " 수정 로직 END------------------------------------------------------
    IF LV_ELIKZ <> 'X'. " 해당 생산오더의 품목이 납품 완료가 아니면 완료 진행
      APPEND VALUE #( MATERIAL   = LS_POSITION1-MATERIAL          "입고자재
                      PLANT      = GS_CLSD-WERKS                  "플랜트
                      ORDERID    = GS_CLSD-AUFNR                  "생산오더
                      ORDER_ITNO = LS_POSITION1-ORDER_ITEM_NUMBER "오더품목번호
                      MVT_IND    = 'F'                            "이동지시자
                      STCK_TYPE  = SPACE                          "재고 유형
                      NO_MORE_GR = 'X'                            "납품완료 지시자
                      MOVE_TYPE  = '101'                          "이동유형
                      STGE_LOC   = LS_POSITION1-STORAGE_LOCATION  "입고창고
                      BATCH      = PV_BATCH                       "배치번호
                      ENTRY_QNT  = '0'                            "입고수량
                      ENTRY_UOM  = LS_POSITION1-BASE_UNIT         "입고단위
                    ) TO LT_ITEM.
    ENDIF.

  ENDLOOP.

  CALL FUNCTION 'BAPI_GOODSMVT_CREATE'
    EXPORTING
      GOODSMVT_HEADER  = LS_HEADER
      GOODSMVT_CODE    = LV_CODE
    IMPORTING
      MATERIALDOCUMENT = LV_DOCUMENT
      MATDOCUMENTYEAR  = LV_YEAR
    TABLES
      GOODSMVT_ITEM    = LT_ITEM
      RETURN           = LT_RET.

  IF LINE_EXISTS( LT_RET[ TYPE = 'E' ] ).
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.
    LV_MESSAGE = VALUE #( LT_RET[ TYPE = 'E' ]-MESSAGE OPTIONAL ).
    PERFORM RETURN_MESSAGE_CLSD USING GC_E
                                      '생산오더 종료(0입고 처리) 중 실패'.
    PERFORM SAVE_LOG_ZGTPPT3130 USING GC_E
                                      '생산오더 종료(0입고 처리) 중 실패'
                                      ' '
                                      ' '.
    EXIT.
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.

    PERFORM RETURN_MESSAGE_CLSD USING GC_S
                                      '생산오더 종료 처리 성공'.
    PERFORM SAVE_LOG_ZGTPPT3130 USING GC_S
                                      '생산오더 종료 처리 성공'
                                      GV_CONF_NO
                                      GV_CONF_CNT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BAPI_PROD_ORD_CONF_CANCEL
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_ERROR
*&      --> PV_MODE
*&---------------------------------------------------------------------*
FORM BAPI_PROD_ORD_CONF_CANCEL  USING    PV_ERROR
                                         PV_MODE.
  DATA: LS_RETURN TYPE BAPIRET1,
        LV_RUECK  TYPE BAPI_PP_CONF_KEY-CONF_NO,
        LV_RMZHL  TYPE BAPI_PP_CONF_KEY-CONF_CNT.

  CLEAR: LS_RETURN, LV_RUECK, LV_RMZHL.
  CLEAR: GV_CONF_NO, GV_CONF_CNT.

  SELECT SINGLE AUFNR,
                RUECK,
                RMZHL
    INTO @DATA(LS_CANCEL)
    FROM AFRU
   WHERE AUFNR = @GS_CLSD-AUFNR
    AND  VORNR = @GS_OP1-OPERATION_NUMBER
    AND  AUERU = 'X'
    AND  STZHL = ' '
    AND  STOKZ = @SPACE.

*- 실적 취소 펑션
  CALL FUNCTION 'BAPI_PRODORDCONF_CANCEL'
    EXPORTING
      CONFIRMATION        = LS_CANCEL-RUECK "확정번호
      CONFIRMATIONCOUNTER = LS_CANCEL-RMZHL "확정카운터
*     POSTG_DATE          = '  '
    IMPORTING
      RETURN              = LS_RETURN
      CREATED_CONF_NO     = LV_RUECK
      CREATED_CONF_COUNT  = LV_RMZHL.

*- 성공
  IF LS_RETURN IS INITIAL.
    CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
      EXPORTING
        WAIT = 'X'.

*    PERFORM RETURN_MESSAGE_CLSD USING GC_S
*                                     '종료 취소 성공'.

    GV_CONF_NO  = LV_RUECK.
    GV_CONF_CNT = LV_RMZHL.

*    PERFORM SAVE_LOG_ZGTPPT3130 USING GC_S
*                                     '종료 취소 성공'
*                                     LV_RUECK
*                                     LV_RMZHL.


*    IF PV_SIGN = 'X'.
*
**- 생산오더의 생산입고 종료 취소 처리 (CNF가 포함된 것만 종료 취소 처리)
*      PERFORM BDC_TRANSACTION_CO02  USING P_MODE.
*    ENDIF.


*- 실패
  ELSE.
    CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

    PV_ERROR = 'X'.
    PERFORM RETURN_MESSAGE_CLSD USING GC_E
                                      LS_RETURN-MESSAGE.
    PERFORM SAVE_LOG_ZGTPPT3130 USING GC_E
                                      LS_RETURN-MESSAGE
                                      ' '
                                      ' '.
    EXIT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form BAPI_GOODSMVT_CANCEL_C
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM BAPI_GOODSMVT_CANCEL_C .

  DATA: LS_HEADRET LIKE BAPI2017_GM_HEAD_RET,
        LT_RETURN  TYPE TABLE OF BAPIRET2 WITH HEADER LINE,
        LT_ITEMNO  TYPE TABLE OF BAPI2017_GM_ITEM_04,
        LS_ITEMNO  TYPE BAPI2017_GM_ITEM_04.

* 취소 대상 자재문서 정보 추출
  SELECT MBLNR, MJAHR, BUDAT, ZEILE
    INTO TABLE @DATA(LT_MATDOC)
    FROM MATDOC
   WHERE AUFNR = @GS_CLSD-AUFNR
     AND CHARG = 'GR_ZERO1'
     AND BWART = '101'
     AND CANCELLED = ''.

  IF LT_MATDOC[] IS INITIAL.
    " 처리 메시지 수정 20250107 BY HSY
    PERFORM RETURN_MESSAGE_CLSD USING GC_S
           '생산오더 종료 처리 성공. CNF 취소, 0입고 취소 대상 데이터 없음.'.
    PERFORM SAVE_LOG_ZGTPPT3130 USING GC_S
           '생산오더 종료 처리 성공. CNF 취소, 0입고 취소 대상 데이터 없음.'
                                      ' '
                                      ' '.
    EXIT.
  ELSE.
    SORT LT_MATDOC BY MBLNR ZEILE.
    DATA(LT_CANCEL) = LT_MATDOC[].
    DELETE ADJACENT DUPLICATES FROM LT_MATDOC COMPARING MBLNR.

    LOOP AT LT_MATDOC INTO DATA(LS_MATDOC).
      CLEAR: LS_HEADRET, LT_RETURN, LT_RETURN[],
             LT_ITEMNO,  LT_ITEMNO[], LS_ITEMNO.
      LOOP AT LT_CANCEL INTO DATA(LS_CANCEL) WHERE MBLNR EQ LS_MATDOC-MBLNR.
        LS_ITEMNO-MATDOC_ITEM = LS_CANCEL-ZEILE.
        APPEND LS_ITEMNO TO LT_ITEMNO.
      ENDLOOP.

      CALL FUNCTION 'BAPI_GOODSMVT_CANCEL'
        EXPORTING
          MATERIALDOCUMENT    = LS_MATDOC-MBLNR
          MATDOCUMENTYEAR     = LS_MATDOC-MJAHR
          GOODSMVT_PSTNG_DATE = LS_MATDOC-BUDAT
          GOODSMVT_PR_UNAME   = SY-UNAME
          DOCUMENTHEADER_TEXT = 'MES I/F'
        IMPORTING
          GOODSMVT_HEADRET    = LS_HEADRET
        TABLES
          RETURN              = LT_RETURN
          GOODSMVT_MATDOCITEM = LT_ITEMNO.

      IF LS_HEADRET-MAT_DOC IS NOT INITIAL.
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            WAIT = 'X'.

        PERFORM RETURN_MESSAGE_CLSD USING GC_S
                                          '생산오더가 종료 취소 처리 되었습니다.'.
        PERFORM SAVE_LOG_ZGTPPT3130 USING GC_S
                                          '생산오더가 종료 취소 처리 되었습니다.'
                                          GV_CONF_NO
                                          GV_CONF_CNT.
      ELSE.
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

        PERFORM RETURN_MESSAGE_CLSD USING GC_E
                                          '생산오더 종료 취소(0 입고 취소) 처리 중 실패'.
        PERFORM SAVE_LOG_ZGTPPT3130 USING GC_E
                                          '생산오더 종료 취소(0 입고 취소) 처리 중 실패'
                                          ' '
                                          ' '.
        EXIT.
      ENDIF.
    ENDLOOP.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONVERSION_OUTPUT_CLSD
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM CONVERSION_OUTPUT_CLSD .
  LOOP AT GT_CLSD_RESULT INTO DATA(LS_RESULT).
    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        INPUT  = LS_RESULT-AUFNR
      IMPORTING
        OUTPUT = LS_RESULT-AUFNR.

    MODIFY GT_CLSD_RESULT FROM LS_RESULT.

  ENDLOOP.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form RESULT_CLSD_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> ZO_RESULT
*&      --> ZO_MESSAGE
*&---------------------------------------------------------------------*
FORM RESULT_CLSD_DATA  USING    PO_RESULT
                                PO_MESSAGE.

  DATA: LV_MESSAGE(100),
        LV_RESULT(2).
  CLEAR: LV_MESSAGE, LV_RESULT.

  IF GT_CLSD_RESULT IS NOT INITIAL.
*- 전체 건수
    DATA(LV_CNT_T) = REDUCE I(
                     INIT SUM = 0 FOR LS_CNT_T IN GT_CLSD_RESULT
                     NEXT SUM = SUM + 1 ).

*- 성공 건수
    DATA(LV_CNT_S) = REDUCE I(
                     INIT SUM = 0 FOR LS_CNT_S IN GT_CLSD_RESULT
                     WHERE ( ZERP_STAT = 'S' )
                     NEXT SUM = SUM + 1 ).

*- 실패 건수
    DATA(LV_CNT_E) = REDUCE I(
                     INIT SUM = 0 FOR LS_CNT_E IN GT_CLSD_RESULT
                     WHERE ( ZERP_STAT = 'E' )
                     NEXT SUM = SUM + 1 ).

    "전체 성공
    IF LV_CNT_S IS NOT INITIAL AND
       LV_CNT_E IS INITIAL.
      LV_RESULT = '00'.
      "LV_MESSAGE = |전체{ LV_CNT_T }건 중 { LV_CNT_S }건 처리 성공, { LV_CNT_E }건 처리 실패|.
      MESSAGE S009(ZGTPP00) WITH LV_CNT_T LV_CNT_S LV_CNT_E INTO LV_MESSAGE.

      "전체 실패
    ELSEIF LV_CNT_S IS INITIAL AND
           LV_CNT_E IS NOT INITIAL.
      LV_RESULT = '01'.
      MESSAGE S009(ZGTPP00) WITH LV_CNT_T LV_CNT_S LV_CNT_E INTO LV_MESSAGE.

      "부분 성공
    ELSE.
      LV_RESULT = '01'.
      MESSAGE S009(ZGTPP00) WITH LV_CNT_T LV_CNT_S LV_CNT_E INTO LV_MESSAGE.

    ENDIF.

*- 처리 결과
    PO_RESULT  = LV_RESULT.
    PO_MESSAGE = LV_MESSAGE.

  ELSE.

    LV_RESULT = '01'.
    LV_MESSAGE = TEXT-E38. "전송실패

*- 처리 결과
    PO_RESULT  = LV_RESULT.
    PO_MESSAGE = LV_MESSAGE.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_ZQMT0734
*&---------------------------------------------------------------------*
*& 2026.02.09.zlsgpp5.CHM2602-00176.create.
*&---------------------------------------------------------------------*
FORM SAVE_ZQMT0734 .

  DATA: LS_ZQMT0734     TYPE ZQMT0734,
        LT_KEKO         TYPE TTY_KEKO,
        LS_KEKO         TYPE TY_KEKO,
        LV_COST_TYPE    TYPE CK_KALKA,    "원가계산 유형
        LV_MINUTE       TYPE INT4,
        LV_MESSAGE(220).


*___플랜트 체크.
  CHECK GS_OPER-WERKS EQ '1305'.

*___에러건은 처리하지 않음.
  CHECK GS_OPER-ZERP_STAT NE GC_E.

*___NAME 필드에 / 가 있으면 진행. 없으면 종료.
  CHECK GS_OPER-NAME CS '/'.

*___NAME 필드로부터 관련 데이터를 가져옴.
  "작업자 이름/비가동사유코드1/비가동사유코드2/발생량
  CLEAR: LS_ZQMT0734, LV_MESSAGE.
  PERFORM GET_FACTOR_DATA USING GS_OPER-NAME GS_OPER-BRKDT
                          CHANGING LS_ZQMT0734
                                   LV_MESSAGE.
  IF LV_MESSAGE IS NOT INITIAL.
    PERFORM APPEND_RESULT_MESSAGE USING LV_MESSAGE.
    EXIT.
  ENDIF.

*___원가 계산된 월 Select
  PERFORM GET_KEKO  USING LS_ZQMT0734
                    CHANGING LT_KEKO
                             LV_COST_TYPE
                             LV_MESSAGE.
  IF LV_MESSAGE IS NOT INITIAL.
    PERFORM APPEND_RESULT_MESSAGE USING LV_MESSAGE.
    EXIT.
  ENDIF.

  LOOP AT LT_KEKO INTO LS_KEKO.

*___CU가격 및 설비 관련비 Select
    PERFORM GET_COST_COMPONENT  USING LS_KEKO
                                      LV_COST_TYPE
                                CHANGING  LS_ZQMT0734-CU_AMT
                                          LS_ZQMT0734-EQU_AMT
                                          LS_ZQMT0734-WAERS
                                          LV_MESSAGE.
    IF LV_MESSAGE IS NOT INITIAL.
      PERFORM APPEND_RESULT_MESSAGE USING LV_MESSAGE.
      EXIT.
    ENDIF.

*___표준가/가격 단위 Select
    PERFORM GET_CKMLCR  USING LS_KEKO
                        CHANGING LS_ZQMT0734-STPRS
                                 LS_ZQMT0734-PEINH
                                 LV_MESSAGE.
    IF LV_MESSAGE IS NOT INITIAL.
      PERFORM APPEND_RESULT_MESSAGE USING LV_MESSAGE.
      EXIT.
    ENDIF.

*___품질 비용 계산
    PERFORM CALC_WOGBTR CHANGING LS_ZQMT0734.

*___비가동시간
    CLEAR: LV_MINUTE.
    CALL FUNCTION 'Z_PP_CALC_GAP_TIMES'
      EXPORTING
        IF_DATE1  = GS_OPER-BRKDT
        IF_TIME1  = GS_OPER-BRKTM
        IF_DATE2  = GS_OPER-OPRDT
        IF_TIME2  = GS_OPER-OPRTM
      IMPORTING
        IF_MINUTE = LV_MINUTE.

    LS_ZQMT0734-NWKTM = LV_MINUTE.

*___fill data.
    LS_ZQMT0734-BRKDT   = GS_OPER-BRKDT.
    LS_ZQMT0734-BRKTM   = GS_OPER-BRKTM.
    LS_ZQMT0734-OPRDT   = GS_OPER-OPRDT.
    LS_ZQMT0734-OPRTM   = GS_OPER-OPRTM.
    LS_ZQMT0734-GJAHR   = GS_OPER-BRKDT(4).
    LS_ZQMT0734-PERAB   = GS_OPER-BRKDT+4(2).
    LS_ZQMT0734-YEARMM  = GS_OPER-BRKDT(6).
    LS_ZQMT0734-RCPERNR = GS_OPER-CRNAM.
    LS_ZQMT0734-BRKNR   = GS_OPER-BRKNR.  "비가동 번호
    LS_ZQMT0734-CHUSER  = SY-UNAME.
    LS_ZQMT0734-CHDATE  = SY-DATUM.

    MODIFY ZQMT0734 FROM LS_ZQMT0734.
    IF SY-SUBRC EQ 0.
      COMMIT WORK.
      LV_MESSAGE = |Q-COST-CropBar 입력 성공.|.
      PERFORM APPEND_RESULT_MESSAGE USING LV_MESSAGE.
    ELSE.
      LV_MESSAGE = |Q-COST-CropBar 입력 실패.|.
      PERFORM APPEND_RESULT_MESSAGE USING LV_MESSAGE.
      EXIT.
    ENDIF.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_factor_data
*&---------------------------------------------------------------------*
*& 2026.02.09.zlsgpp5.CHM2602-00176.create.
*&---------------------------------------------------------------------*
FORM GET_FACTOR_DATA  USING IV_NAME IV_BRKDT
                      CHANGING OS_DATA TYPE ZQMT0734
                               OV_MESSAGE.

  CLEAR: OS_DATA.

*___NAME 필드에서 factor1,2를 추출.
  DATA: LV_MENGE TYPE STRING.
  CLEAR: LV_MENGE.
  SPLIT IV_NAME  AT '/'
        INTO OS_DATA-RCPERNRT OS_DATA-FACTOR1 OS_DATA-FACTOR2 LV_MENGE.

  IF OS_DATA-FACTOR1 IS INITIAL.
    OV_MESSAGE = '존재하지 않는 사유코드 1 입니다.!'.
    EXIT.
  ENDIF.

  IF OS_DATA-FACTOR2 IS INITIAL.
    OV_MESSAGE = '존재하지 않는 사유코드 2 입니다.!'.
    EXIT.
  ENDIF.

*___수량
  OS_DATA-MENGE = LV_MENGE.


*___비가동 사유 1 체크
  DATA: LT_DD07V  LIKE DD07V OCCURS 0 WITH HEADER LINE.
  CLEAR: LT_DD07V, LT_DD07V[].
  CALL FUNCTION 'GET_DOMAIN_VALUES'
    EXPORTING
      DOMNAME         = 'ZFACTOR1'
      TEXT            = 'X'
    TABLES
      VALUES_TAB      = LT_DD07V
    EXCEPTIONS
      NO_VALUES_FOUND = 1
      OTHERS          = 2.

  READ TABLE LT_DD07V WITH KEY DOMVALUE_L = OS_DATA-FACTOR1.
  IF SY-SUBRC NE 0.
    OV_MESSAGE = '존재하지 않는 사유코드 1 입니다.!'.
    EXIT.
  ENDIF.


*___회사코드
  SELECT SINGLE BUKRS INTO OS_DATA-BUKRS
    FROM ZQMT0799
   WHERE FACTOR1 = OS_DATA-FACTOR1.

*___관리 회계영역
  SELECT SINGLE KOKRS INTO OS_DATA-KOKRS
    FROM TKA02
   WHERE BUKRS = OS_DATA-BUKRS.

*___Q-COST 비용항목
  SELECT SINGLE A~WERKS A~MATNR A~QCODE1 A~KOSTL B~MAKTX D~MEINS
    INTO (OS_DATA-WERKS, OS_DATA-MATNR, OS_DATA-QCODE1,
          OS_DATA-KOSTL, OS_DATA-MAKTX, OS_DATA-MEINS)
    FROM ZQMT0733 AS A INNER JOIN MAKT AS B   ON A~MATNR = B~MATNR
                                              AND B~SPRAS = SY-LANGU
                       INNER JOIN MARA AS D   ON A~MATNR = D~MATNR
                       INNER JOIN T001W AS C  ON A~WERKS = C~WERKS
   WHERE A~BUKRS = OS_DATA-BUKRS
     AND A~KOKRS = OS_DATA-KOKRS
     AND A~GJAHR = IV_BRKDT(4)
     AND A~FACTOR1 = OS_DATA-FACTOR1.
  IF SY-SUBRC <> 0.
    OV_MESSAGE = 'Q-CODE 비용항목 Select중 오류발생.!'.
    EXIT.
  ENDIF.

*___손익 센터
  SELECT SINGLE A~PRCTR INTO OS_DATA-PRCTR
    FROM CSKS AS A INNER JOIN CSKT AS B ON A~KOSTL = B~KOSTL
                                       AND A~DATBI = B~DATBI
   WHERE A~KOKRS = OS_DATA-KOKRS
     AND A~KOSTL = OS_DATA-KOSTL
     AND A~DATBI >= IV_BRKDT.
  IF SY-SUBRC <> 0.
    OV_MESSAGE = 'Cost Center Select중 오류발생.!'.
    EXIT.
  ENDIF.

  SELECT SINGLE B~KTEXT INTO @DATA(LV_PRCTR_T)
    FROM CEPC AS A INNER JOIN CEPCT AS B ON B~SPRAS = @SY-LANGU
                                        AND A~PRCTR = B~PRCTR
                                        AND A~DATBI = B~DATBI
                                        AND A~KOKRS = B~KOKRS
   WHERE A~PRCTR = @OS_DATA-PRCTR
     AND A~DATBI >= @IV_BRKDT
     AND A~KOKRS = @OS_DATA-KOKRS.
  IF SY-SUBRC <> 0.
    OV_MESSAGE = 'Profit Center Select중 오류발생.!'.
    EXIT.
  ENDIF.


*___비가동 사유 2 체크
  SELECT SINGLE FTXT INTO @DATA(LV_FACTOR2_T)
    FROM ZQMT0799
   WHERE BUKRS = @OS_DATA-BUKRS
     AND FACTOR1 = @OS_DATA-FACTOR1
     AND FACTOR2 = @OS_DATA-FACTOR2.
  IF SY-SUBRC <> 0.
    OV_MESSAGE = '존재하지 않는 사유코드2 입니다.!'.
    EXIT.
  ENDIF.


*___alpha
*  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
*    EXPORTING
*      INPUT  = OS_DATA-MATNR
*    IMPORTING
*      OUTPUT = OS_DATA-MATNR.
*
*  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
*    EXPORTING
*      INPUT  = OS_DATA-KOSTL
*    IMPORTING
*      OUTPUT = OS_DATA-KOSTL.
*
*  CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
*    EXPORTING
*      INPUT  = OS_DATA-PRCTR
*    IMPORTING
*      OUTPUT = OS_DATA-PRCTR.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_COST_COMPONENT
*&---------------------------------------------------------------------*
*& 2026.02.09.zlsgpp5.CHM2602-00176.create.
*&---------------------------------------------------------------------*
FORM GET_COST_COMPONENT  USING    IS_KEKO TYPE TY_KEKO
                                  IV_COST_TYPE
                         CHANGING OV_CU_AMT OV_EQU_AMT OV_WAERS
                                  OV_MESSAGE.

  DATA: LS_COST_ESTIMATE_HEADER LIKE BAPIHEADER,
        LT_COST_COMPONENTS      LIKE BAPISPLITT OCCURS 0 WITH HEADER LINE,
        LT_COST_COMPONENTS_AS   LIKE BAPISPLITT OCCURS 0 WITH HEADER LINE.

  DATA: BEGIN OF LT_CC OCCURS 0,
          WERKS  LIKE MARC-WERKS,
          MTART  LIKE MARA-MTART,
          SPART  LIKE MARA-SPART,
          PRCTR  LIKE MARC-PRCTR,
          MATNR  LIKE MARC-MATNR,
          MAKTX  LIKE MAKT-MAKTX,
          BISMT  LIKE MARA-BISMT,
          KLVAR  LIKE KEKO-KLVAR,
          TVERS  LIKE KEKO-TVERS,
          MEINS  LIKE MARA-MEINS,
          LOSGR  LIKE MARC-LOSGR,
          BRGEW  LIKE MARA-BRGEW,
          CUWGT  LIKE CE11000-VV152,
          STATUS LIKE BAPIHEADER-CE_STATUS,
          KADKY  LIKE KEKO-KADKY,
          KADAT  LIKE KEKO-KADAT,
          FIX    LIKE BAPISPLITT-TOTAL_AMT,
          VAR    LIKE BAPISPLITT-TOTAL_AMT,
          000    LIKE BAPISPLITT-TOTAL_AMT,     "제조원가 SUM
          111    LIKE BAPISPLITT-TOTAL_AMT,        "CU
          112    LIKE BAPISPLITT-TOTAL_AMT,        "AL
          113    LIKE BAPISPLITT-TOTAL_AMT,        "Fiber
          114    LIKE BAPISPLITT-TOTAL_AMT,        "Chemical재
          115    LIKE BAPISPLITT-TOTAL_AMT,        "기타주재료
          120    LIKE BAPISPLITT-TOTAL_AMT,        "기타재료
          151    LIKE BAPISPLITT-TOTAL_AMT,        "반/제품 기타
          152    LIKE BAPISPLITT-TOTAL_AMT,        "상품
          191    LIKE BAPISPLITT-TOTAL_AMT,        "부산물
          210    LIKE BAPISPLITT-TOTAL_AMT,        "인원비용
          220    LIKE BAPISPLITT-TOTAL_AMT,        "생산지원비
          230    LIKE BAPISPLITT-TOTAL_AMT,        "설비관련비
          240    LIKE BAPISPLITT-TOTAL_AMT,        "기타직접비
          250    LIKE BAPISPLITT-TOTAL_AMT,        "배부간접비
          310    LIKE BAPISPLITT-TOTAL_AMT,        "외주가공비
        END OF LT_CC.

* Sub Cost Components Strucuture
  DATA: BEGIN OF LT_SCC OCCURS 0,
          WERKS  LIKE MARC-WERKS,
          MTART  LIKE MARA-MTART,
          SPART  LIKE MARA-SPART,
          PRCTR  LIKE MARC-PRCTR,
          MATNR  LIKE MARC-MATNR,
          MAKTX  LIKE MAKT-MAKTX,
          BISMT  LIKE MARA-BISMT,
          KLVAR  LIKE KEKO-KLVAR,
          TVERS  LIKE KEKO-TVERS,
          MEINS  LIKE MARA-MEINS,
          LOSGR  LIKE MARC-LOSGR,
          BRGEW  LIKE MARA-BRGEW,
          CUWGT  LIKE CE11000-VV152,
          STATUS LIKE BAPIHEADER-CE_STATUS,
          KADKY  LIKE KEKO-KADKY,
          KADAT  LIKE KEKO-KADAT,
          FIX    LIKE BAPISPLITT-TOTAL_AMT,
          VAR    LIKE BAPISPLITT-TOTAL_AMT,
          000    LIKE BAPISPLITT-TOTAL_AMT,     "제조원가 SUM
          111    LIKE BAPISPLITT-TOTAL_AMT,        "CU
          112    LIKE BAPISPLITT-TOTAL_AMT,        "AL
          113    LIKE BAPISPLITT-TOTAL_AMT,        "Fiber
          114    LIKE BAPISPLITT-TOTAL_AMT,        "Chemical재
          115    LIKE BAPISPLITT-TOTAL_AMT,        "기타주재료
          120    LIKE BAPISPLITT-TOTAL_AMT,        "기타재료
          151    LIKE BAPISPLITT-TOTAL_AMT,        "반/제품 기타
          152    LIKE BAPISPLITT-TOTAL_AMT,        "상품
          191    LIKE BAPISPLITT-TOTAL_AMT,        "부산물
          211    LIKE BAPISPLITT-TOTAL_AMT,        "인건비
          212    LIKE BAPISPLITT-TOTAL_AMT,        "인원관련비
          213    LIKE BAPISPLITT-TOTAL_AMT,        "생산외주용역비
          221    LIKE BAPISPLITT-TOTAL_AMT,        "자재관리비
          222    LIKE BAPISPLITT-TOTAL_AMT,        "설비관리비
          223    LIKE BAPISPLITT-TOTAL_AMT,        "품질관리비
          231    LIKE BAPISPLITT-TOTAL_AMT,        "UTILITY비용
          232    LIKE BAPISPLITT-TOTAL_AMT,        "설비/시설관련비
          233    LIKE BAPISPLITT-TOTAL_AMT,        "금형비
          241    LIKE BAPISPLITT-TOTAL_AMT,        "포장비
          242    LIKE BAPISPLITT-TOTAL_AMT,        "직접비기타
          250    LIKE BAPISPLITT-TOTAL_AMT,        "배부간접비
          310    LIKE BAPISPLITT-TOTAL_AMT,        "외주가공비
        END OF LT_SCC.

  DATA: LS_RETURN	 LIKE BAPIRETURN,
        P_LOSGR    LIKE CKI64A-KOSMNG,
        LV_NAME(3).     "index가 아닌 text로 인식 위해

  FIELD-SYMBOLS : <F_CC>  TYPE ANY,
                  <F_SCC> TYPE ANY.


  P_LOSGR = 1000.


  CLEAR:  LT_COST_COMPONENTS, LT_COST_COMPONENTS[],
          LT_COST_COMPONENTS_AS, LT_COST_COMPONENTS_AS[],
          LT_CC, LT_CC[],
          LT_SCC, LT_SCC[],
          LS_COST_ESTIMATE_HEADER, LS_RETURN.

  CALL FUNCTION 'BAPI_COSTESTIMATE_GETDETAIL'
    EXPORTING
      REFERENCEOBJECT      = C_REF_OBJECT
      COSTINGNUMBER        = IS_KEKO-KALNR
      COSTINGTYPE          = IV_COST_TYPE
      COSTINGDATE          = IS_KEKO-KADKY
      COSTINGVERSION       = '02'             "c_cost_version
      VALUATIONVARIANT     = IS_KEKO-BWVAR
      ENTEREDMANUALLY      = ''               "KKZMA
      COST_COMPONENT_VIEW  = '01'             "c_cost_view
*     COST_COMPONENT_GROUP = GROUP
      CURRENCY_ORG_UNIT    = '01'
*               01  오브젝트 통화의 원가구성요소 분할
*               02  관리회계영역 통화의 원가구성요소 분할
    IMPORTING
      COST_ESTIMATE_HEADER = LS_COST_ESTIMATE_HEADER
      RETURN               = LS_RETURN
    TABLES
      COST_COMPONENTS      = LT_COST_COMPONENTS
      COST_COMPONENTS_AS   = LT_COST_COMPONENTS_AS
    EXCEPTIONS
      OTHERS               = 1.

  IF LS_RETURN-TYPE = 'E' AND LS_RETURN-CODE = 'CK807'.
    OV_MESSAGE = '[저장실패]CU 및 설비관련비 Select시 오류 발생.!'.
    EXIT.
  ENDIF.

  SORT LT_COST_COMPONENTS BY COST_COMP.
  SORT LT_COST_COMPONENTS_AS BY COST_COMP.

  CLEAR: LT_CC, LT_SCC.

  LT_CC-LOSGR = LT_SCC-LOSGR = LS_COST_ESTIMATE_HEADER-LOTSIZE.

  LOOP AT LT_COST_COMPONENTS.
    LV_NAME = LT_COST_COMPONENTS-COST_COMP.
    ASSIGN COMPONENT LV_NAME OF STRUCTURE LT_CC TO <F_CC>.
    IF SY-SUBRC = 0.
      IF LT_CC-LOSGR EQ 0.
        <F_CC> = 0.
        LT_CC-000 = LT_CC-000 + <F_CC>.
      ELSE.
        <F_CC> = LT_COST_COMPONENTS-TOTAL_AMT * P_LOSGR / LT_CC-LOSGR.
        LT_CC-000 = LT_CC-000 + <F_CC>.
      ENDIF.
    ENDIF.
  ENDLOOP.

  LOOP AT LT_COST_COMPONENTS_AS.
    LV_NAME = LT_COST_COMPONENTS_AS-COST_COMP.
    ASSIGN COMPONENT LV_NAME OF STRUCTURE LT_SCC TO <F_SCC>.
    IF SY-SUBRC = 0.
      IF LT_SCC-LOSGR EQ 0.
        <F_SCC> = 0.
        LT_SCC-000 = LT_SCC-000 + <F_SCC>.
      ELSE.
        <F_SCC> = LT_COST_COMPONENTS_AS-TOTAL_AMT * P_LOSGR / LT_SCC-LOSGR.
        LT_SCC-000 = LT_SCC-000 + <F_SCC>.
      ENDIF.
    ENDIF.
  ENDLOOP.

  APPEND : LT_CC, LT_SCC.

  OV_WAERS   = LS_COST_ESTIMATE_HEADER-CURRENCY.

  CLEAR: OV_CU_AMT, OV_EQU_AMT.
  IF OV_WAERS = 'KRW'.
    OV_CU_AMT  = LT_CC-111 . "CU가격
    OV_EQU_AMT = LT_CC-230 . "설비관련비
  ELSE.
    OV_CU_AMT  = LT_CC-111. "CU가격
    OV_EQU_AMT = LT_CC-230. "설비관련비
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_CKMLCR
*&---------------------------------------------------------------------*
*& 2026.02.09.zlsgpp5.CHM2602-00176.create.
*&---------------------------------------------------------------------*
FORM GET_CKMLCR  USING    IS_KEKO TYPE TY_KEKO
                 CHANGING OV_STPRS OV_PEINH
                          OV_MESSAGE.

  CLEAR: OV_STPRS, OV_PEINH.
  SELECT SINGLE STPRS PEINH
    INTO (OV_STPRS, OV_PEINH)
    FROM CKMLCR
   WHERE KALNR = IS_KEKO-KALNR
     AND BDATJ = IS_KEKO-KADKY(4)
     AND POPER = IS_KEKO-KADKY+4(2)
     AND CURTP = '10'.
  IF SY-SUBRC <> 0.
    OV_MESSAGE = '[저장실패]표준가 Select시 오류 발생.!'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CALC_WOGBTR
*&---------------------------------------------------------------------*
*& 2026.02.09.zlsgpp5.CHM2602-00176.create.
*&---------------------------------------------------------------------*
FORM CALC_WOGBTR  CHANGING PS_DATA TYPE ZQMT0734.

  DATA: LV_STPRS  LIKE CKMLCR-STPRS.

  CLEAR: PS_DATA-WOGBTR, LV_STPRS.

  LV_STPRS = PS_DATA-STPRS * 100.

  PS_DATA-WOGBTR =  PS_DATA-MENGE *
                    ( LV_STPRS  - PS_DATA-CU_AMT - PS_DATA-EQU_AMT ) /
                    PS_DATA-PEINH.
  PS_DATA-WOGBTR = PS_DATA-WOGBTR / 100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_KEKO
*&---------------------------------------------------------------------*
*& 2026.02.09.zlsgpp5.CHM2602-00176.create.
*&---------------------------------------------------------------------*
FORM GET_KEKO  USING LS_ZQMT0734 TYPE ZQMT0734
               CHANGING PT_KEKO TYPE TTY_KEKO
                        PV_COST_TYPE
                        PV_MESSAGE.

  DATA: LV_MAXROWS TYPE BAPIMAXROW VALUE '999999999',
        LS_KEKO    TYPE TY_KEKO.

  CLEAR: PT_KEKO.
  SELECT K~WERKS K~MATNR K~KADKY K~KALST K~KALNR K~BWVAR
    INTO TABLE PT_KEKO
    FROM KEKO AS K  JOIN MARA AS A  ON K~MATNR = A~MATNR
                    JOIN MBEW AS M  ON M~BWKEY = K~WERKS
                                    AND M~MATNR = K~MATNR
                                    AND M~KALN1 = K~KALNR
      UP TO LV_MAXROWS ROWS
   WHERE K~BZOBJ    = C_REF_OBJECT
     AND K~TVERS    = '2'               "원가계산버전
     AND K~KKZMA    = ''                "수동으로 입력된 원가
     AND K~MATNR    = LS_ZQMT0734-MATNR
     AND K~WERKS    = LS_ZQMT0734-WERKS
     AND K~KLVAR    = 'RL01'            "원가계산변형
     AND K~ERZKA    EQ 'X'
     AND K~FEH_STA  IN ('KA','VO','FR').
  IF SY-SUBRC <> 0.
    PV_MESSAGE = '원가계산된 내역이 존재하지 않습니다.!'.
    EXIT.
  ELSE.
    CLEAR: PV_COST_TYPE.
    SELECT SINGLE KALKA INTO PV_COST_TYPE
      FROM TCK03
     WHERE KLVAR = 'RL01'.
    IF SY-SUBRC <> 0.
      PV_MESSAGE = '원가계산변형이 존재하지 않습니다.!'.
      EXIT.
    ENDIF.
  ENDIF.


*___원가 계산된 월중 해당 월 계산
  DELETE PT_KEKO WHERE KADKY > GS_OPER-BRKDT.
  SORT   PT_KEKO BY WERKS MATNR ASCENDING KADKY DESCENDING
                                          KALST DESCENDING.
  LOOP AT PT_KEKO INTO LS_KEKO.
    AT NEW MATNR.
      CONTINUE.
    ENDAT.
    DELETE PT_KEKO INDEX SY-TABIX.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form DELETE_ZQMT0734
*&---------------------------------------------------------------------*
*& 2026.02.09.zlsgpp5.CHM2602-00176.create.
*&---------------------------------------------------------------------*
FORM DELETE_ZQMT0734 .

  DATA: LV_MESSAGE(220).

  CHECK GS_OPER-ZC_BRKNR IS NOT INITIAL.

*___비가동번호가 있는지 확인하고 없으면 종료.
  SELECT SINGLE BRKNR INTO @DATA(LV_BKRNR)
    FROM ZQMT0734
   WHERE BRKNR = @GS_OPER-ZC_BRKNR.
  IF LV_BKRNR IS INITIAL.
    EXIT.
  ENDIF.

*___비가동번호로 테이블 데이터 삭제.
  DELETE FROM ZQMT0734 WHERE BRKNR = GS_OPER-ZC_BRKNR.
  IF SY-SUBRC EQ 0.
    COMMIT WORK.
    LV_MESSAGE = |Q-COST-CropBar 삭제 성공.|.
    PERFORM APPEND_RESULT_MESSAGE USING LV_MESSAGE.
  ELSE.
    LV_MESSAGE = |Q-COST-CropBar 삭제 실패.|.
    PERFORM APPEND_RESULT_MESSAGE USING LV_MESSAGE.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form APPEND_RESULT_MESSAGE
*&---------------------------------------------------------------------*
*& 2026.02.09.zlsgpp5.CHM2602-00176.create.
*&---------------------------------------------------------------------*
FORM APPEND_RESULT_MESSAGE  USING    PV_MESSAGE.

  DATA: LV_BRKNR TYPE ZGTPPT3120-BRKNR.

  CLEAR: LV_BRKNR.
  IF GS_OPER-I_MODE EQ 'C' AND GS_OPER-ZC_BRKNR IS NOT INITIAL.
    LV_BRKNR = GS_OPER-ZC_BRKNR. "취소시.
  ELSE.
    LV_BRKNR = GS_OPER-BRKNR.
  ENDIF.


  READ TABLE GT_OPER_RESULT ASSIGNING FIELD-SYMBOL(<RESULT>)
                            WITH KEY WERKS  = GS_OPER-WERKS
                                     ZSERNO = GS_OPER-ZSERNO
                                     BRKNR  = LV_BRKNR.
  IF SY-SUBRC EQ 0.
    <RESULT>-ZERP_MESSAGE = |{ <RESULT>-ZERP_MESSAGE } / { PV_MESSAGE }|.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PRO_ZZCUT_REQ
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PRO_ZZCUT_REQ USING    PV_ERROR.

  IF GS_CLSD-I_MODE EQ 'P'.
    PERFORM PRO_ZZCUT_REQ_P USING PV_ERROR.
  ELSEIF GS_CLSD-I_MODE EQ 'C'.
    PERFORM PRO_ZZCUT_REQ_C USING PV_ERROR.
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form PRO_ZZCUT_REQ_P
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM PRO_ZZCUT_REQ_P USING    PV_ERROR.
  DATA: LT_CONFG TYPE TY_T_CONFG.
  DATA: LV_WELENG TYPE ZGTPPT2170-WELENG.
  DATA: LV_WEMENG TYPE ZGTPPT2170-WEMENG.
  DATA: LV_ITEM TYPE ZGTEZASSIGN_ITEM.

  DATA: LS_SELTAB TYPE RSPARAMS,
        LT_SELTAB TYPE TABLE OF RSPARAMS.

  DATA : LV_JOBNAME  LIKE TBTCJOB-JOBNAME VALUE 'ZGTPPI2030',
         LV_JOBNAME2 LIKE TBTCJOB-JOBNAME,
         LV_JOBCOUNT LIKE TBTCJOB-JOBCOUNT,
         LV_RELEASED LIKE BTCH0000-CHAR1,
         LV_UZEIT    LIKE SY-UZEIT.

  DATA: LT_ZGTPPT2170 LIKE TABLE OF ZGTPPT2170,
        LT_ZGTPPT2180 LIKE TABLE OF ZGTPPT2180,
        LT_ZGTPPT2190 LIKE TABLE OF ZGTPPT2190,
        LT_ZGTPPT3131 LIKE TABLE OF ZGTPPT3131.

  "생산 입고 대상 생산오더가 특별사유 절단요청 건인지 체크
  SELECT A~ZZCUT_REQ,
         B~AUFNR, B~POSNR, B~PSMNG, B~MEINS, B~LGORT, B~KDAUF, B~KDPOS
    FROM AUFK AS A
    JOIN AFPO AS B ON B~AUFNR EQ A~AUFNR
   WHERE A~AUFNR     EQ @GS_CLSD-AUFNR
     AND A~ZZCUT_REQ NE @SPACE
    INTO TABLE @DATA(LT_ZZCUT_REQ).

  CHECK LT_ZZCUT_REQ[] IS NOT INITIAL.

  SORT LT_ZZCUT_REQ BY KDAUF KDPOS.

  "판매오더 상세정보 추출
  SELECT A~VBELN, A~KUNNR, A~VKORG, A~VTWEG, A~SPART, A~VKGRP, A~VKBUR, A~ERDAT,
         B~POSNR, B~MATNR, B~VRKME, B~CUOBJ,
         C~ETENR, C~EDATU, C~WMENG,
         E~MEINS, E~ZZSPEC_NO, E~MTART, E~MATKL
    FROM VBAK AS A
    JOIN VBAP AS B ON B~VBELN EQ A~VBELN
    JOIN VBEP AS C ON C~VBELN EQ B~VBELN
                  AND C~POSNR EQ B~POSNR
    JOIN MARC AS D ON D~MATNR EQ B~MATNR
                  AND D~WERKS EQ B~WERKS
    JOIN MARA AS E ON E~MATNR EQ B~MATNR
     FOR ALL ENTRIES IN @LT_ZZCUT_REQ
   WHERE A~VBELN EQ @LT_ZZCUT_REQ-KDAUF
     AND B~POSNR EQ @LT_ZZCUT_REQ-KDPOS
     AND C~ETENR EQ '0001'
    INTO TABLE @DATA(LT_VBAK).

  "절단 지시 정보 저장
  "주문 할당 처리
  CLEAR: LT_ZGTPPT2170, LT_ZGTPPT2180.
  LOOP AT LT_VBAK INTO DATA(LS_VBAK).

    CLEAR: LT_CONFG.
    PERFORM GET_VC_CONFIGURATION USING LS_VBAK-CUOBJ LT_CONFG.

    NEW ZGTPP_CL_CONV( )->CONVERT_STRING_TO_QTY( EXPORTING IV_INPUT  = CONV #( VALUE #( LT_CONFG[ KEY SKEY1 ATNAM = ZGTPP_IF_CONST=>GC_ATNAM-SAP_MILLCA_LENGTH ]-ATWRT OPTIONAL ) )
                                                 IMPORTING EV_OUTPUT = LV_WELENG ).

    CLEAR: LV_WEMENG.
    IF LS_VBAK-MEINS NE LS_VBAK-VRKME.
      CALL FUNCTION 'MD_CONVERT_MATERIAL_UNIT'
        EXPORTING
          I_MATNR              = LS_VBAK-MATNR
          I_IN_ME              = LS_VBAK-VRKME
          I_OUT_ME             = LS_VBAK-MEINS
          I_MENGE              = LS_VBAK-WMENG
        IMPORTING
          E_MENGE              = LV_WEMENG
        EXCEPTIONS
          ERROR_IN_APPLICATION = 1
          ERROR                = 2
          OTHERS               = 3.
    ELSE.
      LV_WEMENG = LS_VBAK-WMENG.
    ENDIF.

    DATA(LS_ZGTPPT2170) = VALUE ZGTPPT2170( ZASSIGN_TYPE = 'CT'
                                            LOEKZ        = SPACE
                                            WERKS        = GS_CLSD-WERKS
                                            VBELN        = LS_VBAK-VBELN
                                            POSNR        = LS_VBAK-POSNR
                                            ETENR        = LS_VBAK-ETENR
                                            EDATU        = LS_VBAK-EDATU
                                            WEMENG       = LV_WEMENG
                                            VRKME        = LS_VBAK-MEINS
                                            WELENG       = LV_WELENG
                                            WECNT        = VALUE #( LT_CONFG[ KEY SKEY1 ATNAM = ZGTPP_IF_CONST=>GC_ATNAM-SAP_MILLCA_FACTOR ]-ATWRT OPTIONAL )
                                            MATNR        = LS_VBAK-MATNR
                                            KUNNR        = LS_VBAK-KUNNR
                                            VKORG        = LS_VBAK-VKORG
                                            VTWEG        = LS_VBAK-VTWEG
                                            SPART        = LS_VBAK-SPART
                                            VKGRP        = LS_VBAK-VKGRP
                                            VKBUR        = LS_VBAK-VKBUR
                                            CRDAT        = SY-DATUM
                                            CRTIM        = SY-UZEIT
                                            CRNAM        = SY-UNAME ).

    PERFORM GET_NEXT_NUMBER USING 'ZPP_ASSIGN' LS_ZGTPPT2170-ZASSIGN_NO.

    APPEND LS_ZGTPPT2170 TO LT_ZGTPPT2170.

    CLEAR: LV_ITEM.
    LOOP AT LT_ZZCUT_REQ INTO DATA(LS_ZZCUT_REQ) WHERE KDAUF EQ LS_VBAK-VBELN
                                                   AND KDPOS EQ LS_VBAK-POSNR.
      LV_ITEM += 1.

      SELECT SINGLE CHARG
        FROM MATDOC
       WHERE AUFNR EQ @LS_ZZCUT_REQ-AUFNR
         AND AUFPS EQ @LS_ZZCUT_REQ-POSNR
         AND BWART EQ '101'
         AND CANCELLED EQ @SPACE
        INTO @DATA(LV_CHARG).

      DATA(LS_ZGTPPT2180) = VALUE ZGTPPT2180( ZASSIGN_NO   = LS_ZGTPPT2170-ZASSIGN_NO
                                              ZASSIGN_ITEM = LV_ITEM
                                              LGORT        = LS_ZZCUT_REQ-LGORT
                                              F_CHARG      = LV_CHARG
                                              LABST1       = LS_ZZCUT_REQ-PSMNG
                                              LABST2       = SPACE
                                              LABST3       = LS_ZZCUT_REQ-PSMNG
                                              ZCUT_YN      = 'Y'
                                              ZCUT_CNT     = '1'
                                              ZREW_YN      = 'Y'
                                              ZEXCLUDE     = SPACE
                                              MEINS        = LS_ZZCUT_REQ-MEINS
                                              ZORD_TYPE    = 'C4'
                                              CRDAT        = SY-DATUM
                                              CRTIM        = SY-UZEIT
                                              CRNAM        = SY-UNAME ).

      APPEND LS_ZGTPPT2180 TO LT_ZGTPPT2180.
      CLEAR: LS_ZGTPPT2180.
    ENDLOOP.

    CLEAR: LS_ZGTPPT2170.
  ENDLOOP.

  MODIFY ZGTPPT2170 FROM TABLE LT_ZGTPPT2170.
  MODIFY ZGTPPT2180 FROM TABLE LT_ZGTPPT2180.

  IF SY-SUBRC NE 0.
    ROLLBACK WORK.
    PERFORM RETURN_MESSAGE_CLSD USING GC_E
                                      '절단지시 생성 도중 오류가 발생하였습니다.'.
    PV_ERROR = 'X'.
    EXIT.
  ENDIF.

  SORT: LT_ZGTPPT2170 BY ZASSIGN_NO,
        LT_ZGTPPT2180 BY ZASSIGN_NO ZASSIGN_ITEM.

  "절단지시
  CLEAR: LT_ZGTPPT2190.
  LOOP AT LT_ZGTPPT2180 INTO LS_ZGTPPT2180.
    READ TABLE LT_ZGTPPT2170 INTO LS_ZGTPPT2170 WITH KEY ZASSIGN_NO = LS_ZGTPPT2180-ZASSIGN_NO.

    DATA(LS_ZGTPPT2190) = VALUE ZGTPPT2190( ZCUT_ORD_ITEM = LS_ZGTPPT2180-ZASSIGN_ITEM
                                            LOEKZ         = SPACE
                                            WERKS         = GS_CLSD-WERKS
                                            ZASSIGN_NO    = LS_ZGTPPT2180-ZASSIGN_NO
                                            ZASSIGN_ITEM  = LS_ZGTPPT2180-ZASSIGN_ITEM
                                            ZCUT_LEN      = LS_ZGTPPT2170-WELENG
                                            ZCUT_CNT      = '1'
                                            ZCUT_YN       = 'Y'
                                            ZREW_YN       = 'Y'
                                            ZEXCLUDE      = SPACE
                                            T_CHARG       = SPACE
                                            ZCUT_MBLNR    = SPACE
                                            ZCUT_MJAHR    = SPACE
                                            ZCUT_ZEILE    = SPACE
                                            ZZCUT_REQ     = 'X'
                                            SOBKZ         = 'E'
                                            CRDAT         = SY-DATUM
                                            CRTIM         = SY-UZEIT
                                            CRNAM         = SY-UNAME ).

    PERFORM GET_NEXT_NUMBER USING 'ZPP_CUTORD' LS_ZGTPPT2190-ZCUT_ORD_NO.

    APPEND LS_ZGTPPT2190 TO LT_ZGTPPT2190.
    CLEAR: LS_ZGTPPT2190, LS_ZGTPPT2170.
  ENDLOOP.

  MODIFY ZGTPPT2190 FROM TABLE LT_ZGTPPT2190.

  IF SY-SUBRC NE 0.
    ROLLBACK WORK.
    PERFORM RETURN_MESSAGE_CLSD USING GC_E
                                      '절단지시 생성 도중 오류가 발생하였습니다.'.
    PV_ERROR = 'X'.
    EXIT.
  ENDIF.

  "절단오더 정보 송신
  CLEAR: LV_JOBNAME2.
  LV_JOBNAME2 = LV_JOBNAME && |_| && SY-DATUM && |_| && SY-UZEIT.

  CLEAR: LV_JOBCOUNT.
  DO.
    CALL FUNCTION 'JOB_OPEN'
      EXPORTING
        JOBNAME          = LV_JOBNAME2
      IMPORTING
        JOBCOUNT         = LV_JOBCOUNT
      EXCEPTIONS
        CANT_CREATE_JOB  = 1
        INVALID_JOB_DATA = 2
        JOBNAME_MISSING  = 3
        OTHERS           = 4.
    IF SY-SUBRC EQ 0.
      EXIT.
    ENDIF.
  ENDDO.

  CLEAR: LT_SELTAB[].
  LT_SELTAB = VALUE #(
  ( SELNAME = 'P_SYSID' KIND = 'P' SIGN = 'I' OPTION = 'EQ' LOW = 'KGPM' )
  ( SELNAME = 'P_SEND'  KIND = 'P' SIGN = 'I' OPTION = 'EQ' LOW = 'X' )
  ( SELNAME = 'P_BATCH' KIND = 'P' SIGN = 'I' OPTION = 'EQ' LOW = 'X' ) ).

  SORT LT_ZGTPPT2190 BY ZCUT_ORD_NO ZCUT_ORD_ITEM.
  LOOP AT LT_ZGTPPT2190 INTO DATA(LV_CUT_ORD).
    APPEND VALUE #( SELNAME = 'S_ZCUTNO' KIND = 'S' SIGN = 'I' OPTION = 'EQ' LOW = LV_CUT_ORD-ZCUT_ORD_NO )
        TO LT_SELTAB.
  ENDLOOP.

  SUBMIT ZGTPPI2030 VIA JOB LV_JOBNAME2
                    NUMBER LV_JOBCOUNT
                    WITH SELECTION-TABLE LT_SELTAB
                    AND RETURN.

  CLEAR: LV_UZEIT.
  LV_UZEIT = SY-UZEIT + 10.
  CALL FUNCTION 'JOB_CLOSE'
    EXPORTING
      JOBCOUNT             = LV_JOBCOUNT
      JOBNAME              = LV_JOBNAME2
      SDLSTRTDT            = SY-DATUM
      SDLSTRTTM            = LV_UZEIT
      STRTIMMED            = 'X'  "즉시 기동
    IMPORTING
      JOB_WAS_RELEASED     = LV_RELEASED
    EXCEPTIONS
      CANT_START_IMMEDIATE = 1
      INVALID_STARTDATE    = 2
      JOBNAME_MISSING      = 3
      JOB_CLOSE_FAILED     = 4
      JOB_NOSTEPS          = 5
      JOB_NOTEX            = 6
      LOCK_FAILED          = 7
      OTHERS               = 8.

  "절단지시 생성 이력 저장
  CLEAR: LV_ITEM, LT_ZGTPPT3131.
  LOOP AT LT_ZGTPPT2190 INTO LS_ZGTPPT2190.
    LV_ITEM += 1.
    DATA(LS_ZGTPPT3131) = VALUE ZGTPPT3131( AUFNR       = GS_CLSD-AUFNR
                                            SEQNO       = LV_ITEM
                                            ZCUT_ORD_NO = LS_ZGTPPT2190-ZCUT_ORD_NO
                                            CRDAT       = SY-DATUM
                                            CRTIM       = SY-UZEIT
                                            CRNAM       = SY-UNAME ).

    APPEND LS_ZGTPPT3131 TO LT_ZGTPPT3131.
    CLEAR: LS_ZGTPPT3131.
  ENDLOOP.

  MODIFY ZGTPPT3131 FROM TABLE LT_ZGTPPT3131.

  IF SY-SUBRC EQ 0.
    COMMIT WORK AND WAIT.
  ELSE.
    ROLLBACK WORK.
    PERFORM RETURN_MESSAGE_CLSD USING GC_E
                                      '절단지시 생성 도중 오류가 발생하였습니다.'.
    PV_ERROR = 'X'.
    EXIT.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_VC_CONFIGURATION
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_SLORD_CUOBJ
*&      --> LT_CONFG
*&---------------------------------------------------------------------*
FORM GET_VC_CONFIGURATION  USING PV_CUOBJ
                                 PT_CONFG TYPE TY_T_CONFG.

  CALL FUNCTION 'VC_I_GET_CONFIGURATION'
    EXPORTING
      INSTANCE            = PV_CUOBJ
    TABLES
      CONFIGURATION       = PT_CONFG
    EXCEPTIONS
      INSTANCE_NOT_FOUND  = 1
      INTERNAL_ERROR      = 2
      NO_CLASS_ALLOCATION = 3
      INSTANCE_NOT_VALID  = 4
      OTHERS              = 5.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form GET_NEXT_NUMBER
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> LS_ZGTPPT2170_ZASSIGN_NO
*&---------------------------------------------------------------------*
FORM GET_NEXT_NUMBER  USING PV_OBJECT PV_NUMBER.

  CALL FUNCTION 'NUMBER_GET_NEXT'
    EXPORTING
      NR_RANGE_NR             = COND NRNR( WHEN PV_OBJECT EQ 'ZGTPP_GORD' THEN '03'
                                           ELSE '01'  )
      OBJECT                  = PV_OBJECT
    IMPORTING
      NUMBER                  = PV_NUMBER
    EXCEPTIONS
      INTERVAL_NOT_FOUND      = 1
      NUMBER_RANGE_NOT_INTERN = 2
      OBJECT_NOT_FOUND        = 3
      QUANTITY_IS_0           = 4
      QUANTITY_IS_NOT_1       = 5
      INTERVAL_OVERFLOW       = 6
      BUFFER_OVERFLOW         = 7
      OTHERS                  = 8.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form PRO_ZZCUT_REQ_C
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> PV_ERROR
*&---------------------------------------------------------------------*
FORM PRO_ZZCUT_REQ_C   USING    PV_ERROR.

  "생산 종료 취소 대상 생산오더가 특별사유 절단요청 건인지 체크
  SELECT A~ZZCUT_REQ,
         B~AUFNR, B~POSNR, B~PSMNG, B~MEINS, B~LGORT, B~KDAUF, B~KDPOS
    FROM AUFK AS A
    JOIN AFPO AS B ON B~AUFNR EQ A~AUFNR
   WHERE A~AUFNR     EQ @GS_CLSD-AUFNR
     AND A~ZZCUT_REQ NE @SPACE
    INTO TABLE @DATA(LT_ZZCUT_REQ).

  CHECK LT_ZZCUT_REQ[] IS NOT INITIAL.

  SORT LT_ZZCUT_REQ BY AUFNR.

  "절단지시번호 추출
  SELECT A~AUFNR, A~SEQNO, A~ZCUT_ORD_NO,
         B~ZASSIGN_NO
    FROM ZGTPPT3131 AS A
    JOIN ZGTPPT2190 AS B ON B~ZCUT_ORD_NO EQ A~ZCUT_ORD_NO
     FOR ALL ENTRIES IN @LT_ZZCUT_REQ
   WHERE A~AUFNR EQ @LT_ZZCUT_REQ-AUFNR
    INTO TABLE @DATA(LT_3131).

  CHECK LT_3131[] IS NOT INITIAL.

  SORT LT_3131 BY AUFNR SEQNO.

  "절단 지시 정보를 취소
  LOOP AT LT_3131 INTO DATA(LS_3131).
    UPDATE ZGTPPT2170
       SET LOEKZ = 'X'
     WHERE ZASSIGN_NO = LS_3131-ZASSIGN_NO.

    UPDATE ZGTPPT2190
       SET LOEKZ = 'X'
     WHERE ZCUT_ORD_NO = LS_3131-ZCUT_ORD_NO.

    UPDATE ZGTPPT3131
       SET ZCUT_ORD_NO = SPACE
     WHERE AUFNR = LS_3131-AUFNR
       AND SEQNO = LS_3131-SEQNO.
  ENDLOOP.

  IF SY-SUBRC EQ 0.
    COMMIT WORK AND WAIT.
  ELSE.
    ROLLBACK WORK.
    PERFORM RETURN_MESSAGE_CLSD USING GC_E
                                      '절단지시 취소 도중 오류가 발생하였습니다.'.
    PV_ERROR = 'X'.
    EXIT.
  ENDIF.

ENDFORM.
