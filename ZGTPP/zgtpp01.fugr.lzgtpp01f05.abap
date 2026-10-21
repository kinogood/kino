*----------------------------------------------------------------------*
***INCLUDE LZGTPP01F05.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form CHECK_ORDER_BOM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_ERROR
*&---------------------------------------------------------------------*
FORM check_order_bom  USING  pv_error.


*- 플랜트 존재여부 체크
  SELECT SINGLE mandt
   FROM t001w
   WHERE werks = @gs_order_bom-werks
   INTO @sy-mandt.
  IF sy-subrc <> 0.

    PERFORM return_message_order_bom  USING 'E'
                                      TEXT-m06 "존재하지 않는 플랜트 입니다.
                                      .
    pv_error = 'X'.
    EXIT.
  ENDIF.

*- 플랜트 누락 체크
  IF gs_order_bom-werks IS INITIAL  .

    PERFORM return_message_order_bom  USING 'E'
                                      TEXT-m08 "필수값 '플랜트' 누락되었습니다.
                                      .
    pv_error = 'X'.
    EXIT.

  ENDIF.


*- 일련번호 누락 체크
  IF gs_order_bom-zserno IS INITIAL  .

    PERFORM return_message_order_bom  USING 'E'
                                      TEXT-m09 "필수값 '일련번호' 누락되었습니다.
                                      .
    pv_error = 'X'.
    EXIT.

  ENDIF.


*- 생산오더 번호
  SELECT SINGLE mandt
    FROM aufk
    WHERE aufnr = @gs_order_bom-aufnr
    INTO @sy-mandt.
  IF sy-subrc <> 0.

    PERFORM return_message_order_bom USING 'E'
                                     TEXT-m13. "'존재하지 않는 생산오더 입니다.'
    .
    pv_error = 'X'.
    EXIT.
  ENDIF.

*- 생산오더 누락 체크
  IF gs_order_bom-aufnr IS INITIAL  .

    PERFORM return_message_order_bom  USING 'E'
                                      TEXT-m10 "필수값 '오더번호' 누락되었습니다.
                                      .
    pv_error = 'X'.
    EXIT.

  ENDIF.

*- 예약번호 누락 체크
  IF gs_order_bom-rsnum IS INITIAL  .

    PERFORM return_message_order_bom  USING 'E'
                                      TEXT-m11 "필수값 '예약번호' 누락되었습니다.
                                      .
    pv_error = 'X'.
    EXIT.

  ENDIF.

*- 예약번호 누락 체크
  IF gs_order_bom-rspos IS INITIAL  .

    PERFORM return_message_order_bom  USING 'E'
                                      TEXT-m12 "필수값 '예약품목번호' 누락되었습니다.
                                      .
    pv_error = 'X'.
    EXIT.

  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form return_message_ORDER_BOM
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM return_message_order_bom  USING   pv_flag
                                       pv_message.

  CLEAR :  gs_result.

  gs_result = VALUE #(
                            werks         = gs_order_bom-werks
                            zserno        = gs_order_bom-zserno
                            aufnr         = gs_order_bom-aufnr
                            rsnum         = gs_order_bom-rsnum
                            rspos         = gs_order_bom-rspos
                            zerp_stat     = pv_flag
                            zerp_message  = pv_message
                         ).
  APPEND gs_result to gt_result.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form SAVE_LOG_ORDER_BOM
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
FORM save_log_order_bom  USING pv_flag
                               pv_message
                               pv_timestamp
                               pv_system_id
                               .

*  DATA : lt_zgtppt2140 TYPE TABLE OF zgtppt2140.
*  DATA  : lv_timestamp TYPE timestampl.
  CLEAR : gs_zgtppt2140.


*  GET TIME STAMP FIELD lv_timestamp.

*  gt_zgtppt2140 = VALUE #( ( VALUE #( BASE CORRESPONDING #( gs_order_bom )
*                           zifkey       = pv_timestamp
*                           zsystem_id   = pv_system_id
*                           zerp_stat    = pv_flag
*                           zerp_message = pv_message
*                           ifnam        = sy-uname
*                           ifdat        = sy-datum
*                           iftim        = sy-uzeit
*                       ) ) ).

  GS_ZGTPPT2140 = VALUE #( BASE CORRESPONDING #( gs_order_bom )
                           zifkey       = pv_timestamp
                           zsystem_id   = pv_system_id
                           zerp_stat    = pv_flag
                           zerp_message = pv_message
                           ifnam        = sy-uname
                           ifdat        = sy-datum
                           iftim        = sy-uzeit
                            ).

  APPEND gs_zgtppt2140 to gt_zgtppt2140.


***  MODIFY zgtppt3080 FROM TABLE lt_zgtppt3080.
***  IF sy-subrc = 0.
***    COMMIT WORK.
***  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form conversion_output_gt_result
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM conversion_output_gt_result .

  LOOP AT gt_gr_result INTO DATA(ls_result).

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_OUTPUT'
      EXPORTING
        input  = ls_result-aufnr
      IMPORTING
        output = ls_result-aufnr.

    MODIFY gt_result FROM ls_result.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form result_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> ZO_RESULT
*&      --> ZO_MESSAGE
*&      --> LV_BAPI_FLAG
*&---------------------------------------------------------------------*
FORM result_data  USING  po_result
                             po_message
                             pv_bom_flag.

  DATA : lv_message(80),
         lv_result(2).
  CLEAR : lv_message, lv_result.

  IF gt_result IS NOT INITIAL
     AND pv_bom_flag <> 'N'.

*- 전체 건수
    DATA(lv_cnt_t) = REDUCE i(
                     INIT sum = 0 FOR ls_cnt_t IN gt_result
*                     WHERE ( zerp_stat = 'S' )
                     NEXT sum = sum + 1 ).

*- 성공 건수
    DATA(lv_cnt_s) = REDUCE i(
                     INIT sum = 0 FOR ls_cnt_s IN gt_result
                     WHERE ( zerp_stat = 'S' )
                     NEXT sum = sum + 1 ).

*- 실패 건수
    DATA(lv_cnt_e) = REDUCE i(
                     INIT sum = 0 FOR ls_cnt_e IN gt_result
                     WHERE ( zerp_stat = 'E' )
                     NEXT sum = sum + 1 ).

    "전체 성공
    IF lv_cnt_s IS NOT INITIAL AND
       lv_cnt_e IS INITIAL.

      lv_result = '00'.
      lv_message = |전체{ lv_cnt_t }건 중 { lv_cnt_s }건 처리 성공|.

      "전체 실패
    ELSEIF lv_cnt_s IS INITIAL AND
           lv_cnt_e IS NOT INITIAL.

      lv_result = '01'.
      lv_message = |전체{ lv_cnt_t }건 중 { lv_cnt_e }건 처리 실패|.

      "부분 성공
    ELSE.

      lv_result = '01'.
      lv_message = |전체{ lv_cnt_t }건 중 { lv_cnt_s }건 처리 성공, { lv_cnt_e }건 처리 실패|.

    ENDIF.

*- 처리 결과
    po_result  = lv_result.
    po_message = lv_message.

  ELSE.

    lv_result = '01'.
    lv_message = '실적 처리할 데이터가 없습니다'.

*- 처리 결과
    po_result  = lv_result.
    po_message = lv_message.

  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form RESERVATION_ITEM_CHECK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_ERROR
*&---------------------------------------------------------------------*
FORM reservation_item_check  USING  pv_error.

  DATA : LV_MESSAGE_MARD(220).

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE GT_RESB
    FROM RESB
   WHERE AUFNR = GS_ORDER_BOM-AUFNR
     AND WERKS = GS_ORDER_BOM-WERKS
     AND RSNUM = GS_ORDER_BOM-RSNUM
     AND RSPOS = GS_ORDER_BOM-RSPOS.
  .

  IF SY-SUBRC = 0.
    READ TABLE GT_RESB INTO GS_RESB
                       WITH KEY MATNR = GS_ORDER_BOM-MATNR_FROM.
    IF SY-SUBRC <> 0.
      PERFORM RETURN_MESSAGE_ORDER_BOM  USING 'E'
                                        TEXT-M14 "오더의 품목에 투입처리된 내역이 있어 대체자재 변경할 수 없습니다
                                        .
      PV_ERROR = 'X'.
      EXIT.
    ENDIF.

  ENDIF.



  SELECT  A~MATNR,
          A~WERKS,
          A~LVORM,
          B~LVORM AS LVORM_MARA,
          A~MMSTA
    INTO CORRESPONDING FIELDS OF TABLE @GT_MARC
    FROM MARC AS A INNER JOIN MARA AS B
                   ON A~MATNR = B~MATNR
   WHERE A~MATNR = @GS_ORDER_BOM-MATNR_TO
     AND A~WERKS = @GS_ORDER_BOM-WERKS.

  IF SY-SUBRC = 0.
    READ TABLE GT_MARC INTO GS_MARC
                       WITH KEY MATNR = GS_ORDER_BOM-MATNR_TO.
    IF SY-SUBRC = 0.
      IF GS_MARC-LVORM = 'X' OR GS_MARC-LVORM_MARA = 'X'.
        PERFORM RETURN_MESSAGE_ORDER_BOM  USING 'E'
                                          TEXT-M28 "변경하고자 하는 자재가 삭제 상태입니다.
                                          .
        PV_ERROR = 'X'.
        EXIT.
      ENDIF.
    ENDIF.
  ENDIF.

*--RESB에서 추출한 저장위치 & MATNR_TO & 플랜트를 조건으로 MARD의 값이 존재하는지 점검.
*--MARD 값이 없을 경우 오류

  READ TABLE GT_RESB INTO GS_RESB
                     WITH KEY MATNR = GS_ORDER_BOM-MATNR_TO
                              WERKS = GS_ORDER_BOM-WERKS.

  IF SY-SUBRC = 0 .

    SELECT *
      INTO CORRESPONDING FIELDS OF TABLE GT_MARD
      FROM MARD
     WHERE MATNR = GS_RESB-MATNR
       AND WERKS = GS_RESB-WERKS
       AND LGORT = GS_RESB-LGORT.
                       .
    IF SY-SUBRC <> 0.
      CLEAR : LV_MESSAGE_MARD.
      CONCATENATE TEXT-M32
                  GS_ORDER_BOM-MATNR_TO
                  TEXT-M33
                  GS_RESB-LGORT
                  TEXT-M34
             INTO LV_MESSAGE_MARD. "대체자재 {MATNR_TO}의 오더 BOM 저장위치 {RESB-LGORT}가 없습니다."
      PERFORM RETURN_MESSAGE_ORDER_BOM  USING 'E'
                                        LV_MESSAGE_MARD .                                        .
      PV_ERROR = 'X'.
      EXIT.
    ENDIF.

  ENDIF.

  READ TABLE GT_MARC INTO GS_MARC
                     WITH KEY MATNR = GS_ORDER_BOM-MATNR_TO
                              WERKS = GS_ORDER_BOM-WERKS.
  IF SY-SUBRC = 0.
    IF GS_MARC-MMSTA IS NOT INITIAL.
      PERFORM RETURN_MESSAGE_ORDER_BOM  USING 'E'
                                        TEXT-M35 "대체자재의 자재상태가 설계상태가 양산 가능 상태가 아닙니다
                                        .
      PV_ERROR = 'X'.
      EXIT.
    ENDIF.
  ENDIF.


ENDFORM.
*&---------------------------------------------------------------------*
*& Form ORDER_STATUS_CHECK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_ERROR
*&---------------------------------------------------------------------*
FORM ORDER_STATUS_CHECK  USING    PV_ERROR
                                  PV_MESSAGE.

  SELECT AUFNR, CRTD, REL,  DEL,  DLFL,
         LKD,   TECO, CLSD, PCNF, CNF,
         PDLV,  DLV,  PAYO, GISTART
    INTO TABLE @DATA(LT_STAT)
    FROM ZGTPP_CV_ORD_STAT
   WHERE AUFNR = @GS_ORDER_BOM-AUFNR
     AND WERKS = @GS_ORDER_BOM-WERKS.
   SORT LT_STAT BY AUFNR .

   IF SY-SUBRC = 0.
     READ TABLE LT_STAT INTO DATA(LS_STAT)
                        WITH KEY AUFNR = GS_ORDER_BOM-AUFNR
                        BINARY SEARCH.
     IF SY-SUBRC = 0.

        IF ( LS_STAT-DEL = 'X' OR LS_STAT-DLFL = 'X').
          PERFORM RETURN_MESSAGE_ORDER_BOM  USING 'E'
                                            TEXT-M15. "생산오더가 'DEL, DLFL' 상태이므로 처리할 수 없습니다
          PV_ERROR = 'X'.
          PV_MESSAGE = TEXT-M15.
          EXIT.
        ELSEIF  LS_STAT-LKD  = 'X'.
          PERFORM RETURN_MESSAGE_ORDER_BOM  USING 'E'
                                            TEXT-M16. "생산오더가 'LKD' 상태이므로 처리할 수 없습니다
          PV_ERROR = 'X'.
          PV_MESSAGE = TEXT-M16.
          EXIT.
        ELSEIF  LS_STAT-TECO  = 'X'.
          PERFORM RETURN_MESSAGE_ORDER_BOM  USING 'E'
                                            TEXT-M17. "생산오더가 'TECO' 상태이므로 처리할 수 없습니다
          PV_ERROR = 'X'.
          PV_MESSAGE = TEXT-M17.
          EXIT.
        ELSEIF  LS_STAT-CLSD  = 'X'.
          PERFORM RETURN_MESSAGE_ORDER_BOM  USING 'E'
                                            TEXT-M18. "생산오더가 'CLSD' 상태이므로 처리할 수 없습니다
          PV_ERROR = 'X'.
          PV_MESSAGE = TEXT-M18.
          EXIT.
        ELSEIF  LS_STAT-PCNF  = 'X'.
          PERFORM RETURN_MESSAGE_ORDER_BOM  USING 'E'
                                            TEXT-M19. "생산오더가 'PCNF' 상태이므로 처리할 수 없습니다
          PV_ERROR = 'X'.
          PV_MESSAGE = TEXT-M19.
          EXIT.
        ELSEIF  LS_STAT-CNF  = 'X'.
          PERFORM RETURN_MESSAGE_ORDER_BOM  USING 'E'
                                            TEXT-M20. "생산오더가 'CNF' 상태이므로 처리할 수 없습니다
          PV_ERROR = 'X'.
          PV_MESSAGE = TEXT-M20.
          EXIT.
        ELSEIF  LS_STAT-PDLV  = 'X'.
          PERFORM RETURN_MESSAGE_ORDER_BOM  USING 'E'
                                            TEXT-M21. "생산오더가 'PDLV' 상태이므로 처리할 수 없습니다
          PV_ERROR = 'X'.
          PV_MESSAGE = TEXT-M21.
          EXIT.
        ELSEIF  LS_STAT-DLV  = 'X'.
          PERFORM RETURN_MESSAGE_ORDER_BOM  USING 'E'
                                            TEXT-M22. "생산오더가 'DLV' 상태이므로 처리할 수 없습니다
          PV_ERROR = 'X'.
          PV_MESSAGE = TEXT-M22.
          EXIT.
        ENDIF.

     ENDIF.
   ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form QTY_CHECK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LV_ERROR
*&      --> LV_MESSAGE
*&---------------------------------------------------------------------*
FORM qty_check  USING    pv_error
                         pv_message.

  SELECT AUFNR, MBLNR
    INTO TABLE @DATA(LT_MATDOC)
    FROM MATDOC
   WHERE AUFNR = @GS_ORDER_BOM-AUFNR
     AND WERKS = @GS_ORDER_BOM-WERKS
     AND RSNUM = @GS_ORDER_BOM-RSNUM
     AND RSPOS = @GS_ORDER_BOM-RSPOS
     AND BWART = '261'
     AND CANCELLED = ' '.
   SORT LT_MATDOC BY AUFNR MBLNR.

   IF SY-SUBRC = 0.
     READ TABLE LT_MATDOC INTO DATA(LS_MATDOC)
                        WITH KEY AUFNR = GS_ORDER_BOM-AUFNR
                        BINARY SEARCH.
     IF LS_MATDOC-mblnr IS NOT INITIAL.
        PERFORM RETURN_MESSAGE_ORDER_BOM  USING 'E'
                                          TEXT-M23. "오더의 품목에 투입처리된 내역이 있어 대체자재 변경할 수 없습니다
        PV_ERROR = 'X'.
        PV_MESSAGE = TEXT-M23.
     ENDIF.

   ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form dynpro
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> P_
*&      --> P_
*&      --> P_
*&---------------------------------------------------------------------*
FORM dynpro  USING dynbegin name value.

  CLEAR gt_bdcdata.
  IF dynbegin = 'X'.
    MOVE: name  TO gt_bdcdata-program,
          value TO gt_bdcdata-dynpro,
          'X'   TO gt_bdcdata-dynbegin.
    APPEND gt_bdcdata.
  ELSE.
    MOVE: name  TO gt_bdcdata-fnam,
          value TO gt_bdcdata-fval.
    APPEND gt_bdcdata.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form CONVERSION_OUTPUT_GT_RESULT1
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*& -->  p1        text
*& <--  p2        text
*&---------------------------------------------------------------------*
FORM conversion_input_gt_result .


    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = GS_ORDER_BOM-AUFNR
      IMPORTING
        output = GS_ORDER_BOM-AUFNR.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = GS_ORDER_BOM-RSNUM
      IMPORTING
        output = GS_ORDER_BOM-RSNUM.

    CALL FUNCTION 'CONVERSION_EXIT_ALPHA_INPUT'
      EXPORTING
        input  = GS_ORDER_BOM-RSPOS
      IMPORTING
        output = GS_ORDER_BOM-RSPOS.

    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        input  = GS_ORDER_BOM-MATNR_FROM
      IMPORTING
        output = GS_ORDER_BOM-MATNR_FROM.

    CALL FUNCTION 'CONVERSION_EXIT_MATN1_INPUT'
      EXPORTING
        input  = GS_ORDER_BOM-MATNR_TO
      IMPORTING
        output = GS_ORDER_BOM-MATNR_TO.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form APPEND_READ_DATA
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> LS_ORDER_BOM
*&---------------------------------------------------------------------*
FORM append_read_data  USING    ps_order_bom TYPE ZGTPPSIF0033
                                PV_ZERP_STAT
                                PV_MESSAGE.

  DATA  : LS_ZGTPPSIF0033 LIKE GS_ORDER_BOM_S.
  CLEAR : LS_ZGTPPSIF0033.



  LS_ZGTPPSIF0033 = VALUE #( BASE  CORRESPONDING #( ps_order_bom )
                             ZERP_STAT    = PV_ZERP_STAT
                             ZERP_MESSAGE = PV_MESSAGE
                             ).

  APPEND LS_ZGTPPSIF0033 to GT_ORDER_BOM_S.


ENDFORM.
