FUNCTION zgtpp_if_i_cable_prod_bom_ch.
*"--------------------------------------------------------------------
*"*"로컬인터페이스:
*"  IMPORTING
*"     VALUE(SYSTEM_ID) TYPE  CHAR4
*"  EXPORTING
*"     VALUE(ZO_RESULT) TYPE  ZO_RESULT
*"     VALUE(ZO_MESSAGE) TYPE  ZO_MESSAGE
*"  TABLES
*"      IT_ORDER_BOM STRUCTURE  ZGTPPSIF0033 OPTIONAL
*"      OT_RESULT STRUCTURE  ZGTPPSIF0034 OPTIONAL
*"--------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPP_IF_I_PROD_BOM_CH
*& 프로그램 명 : [GT] 생산오더 대체자재변경 수신
*& 개요   :
*& 생성일 : 2025.04.23
*& 생성자 : ZGSIDEV04
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : MOM에서 생산오더 작업일정 수립,
*&                            릴리즈 시점에 대체자재 변경할때 수행한다.
*&                           대체자재 변경은 MOM에서 I/F 받은
*&                           기준으로 BDC 처리한다
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  :
*& 수정자  :
*& 수정개요 :
*&---------------------------------------------------------------------*
  DATA : lt_order_bom   TYPE TABLE OF zgtppsif0033.
  DATA : ls_order_bom_i TYPE zgtppsif0033,
         lt_order_bom_i TYPE TABLE OF zgtppsif0033,
         ls_order_bom_s TYPE zgtppsif0033,
         lt_order_bom_s TYPE TABLE OF zgtppsif0033.
  DATA : lv_error.
  DATA : lv_zerp_stat(1).
  DATA : lv_message(220).
  DATA : lv_message_resb(220).
  DATA : lv_bom_flag(1).
  DATA : lv_timestamp TYPE timestampl.
  DATA : lv_line TYPE i VALUE 0.

  CLEAR : lt_order_bom, gs_order_bom, gt_order_bom[],
          lv_error,
          gt_result, gt_result[],
          ot_result, ot_result[],
          gs_zgtppt2140, gt_zgtppt2140[].

  CLEAR : lv_bom_flag.

*- SYSTEM_ID 누락 체크
  IF system_id IS INITIAL  .

    PERFORM return_message_order_bom  USING 'E'
                                      TEXT-m07 "필수값 '송신 시스템' 누락되었습니다.
                                      .
    lv_error = 'X'.
    GET TIME STAMP FIELD lv_timestamp.
    lv_message = TEXT-m07.
    PERFORM save_log_order_bom  USING 'E'
                                lv_message
                                lv_timestamp
                                system_id.    .
*    EXIT.
  ENDIF.

  IF  lv_error <> 'X'.

    lt_order_bom[] = it_order_bom[].
    gt_order_bom   = CORRESPONDING #( lt_order_bom ).
    lt_order_bom_i = CORRESPONDING #( lt_order_bom ).

    CLEAR : gt_order_bom_s[],
            gs_order_bom_s.
    LOOP AT gt_order_bom INTO gs_order_bom.

      READ TABLE gt_order_bom_s INTO gs_order_bom_s
                                WITH KEY werks  = gs_order_bom-werks
                                         zserno = gs_order_bom-zserno
                                         aufnr  = gs_order_bom-aufnr
                                         rsnum  = gs_order_bom-rsnum.
      IF sy-subrc <> 0.

        CLEAR : lv_error.

        GET TIME STAMP FIELD lv_timestamp.

        PERFORM conversion_input_gt_result.

        " 1) 필수 입력값 점검
        PERFORM check_order_bom  USING lv_error.  " CHECK ERROR 시 결과 값에 APPEND

        IF lv_error = 'X'.
          CLEAR : lv_message.
          lv_message =
          VALUE #( gt_result[ zserno = gs_order_bom-zserno ]-zerp_message
                   OPTIONAL ).
          PERFORM save_log_order_bom  USING 'E'   " LOG TABLE 에 APPEND
                                      lv_message
                                      lv_timestamp
                                      system_id
                                      .

          CLEAR gs_order_bom.
          CONTINUE.
        ENDIF.

        " 2) 예약 품목 정합성 점검 : 오더의 해당 예약정보가 일치하는지 확인
        PERFORM reservation_item_check USING lv_error.

        IF lv_error = 'X'.
          CLEAR : lv_message.
          lv_message =
          VALUE #( gt_result[ zserno = gs_order_bom-zserno ]-zerp_message
                   OPTIONAL ).
*      - 처리 결과
          zo_result  = '01'.
          zo_message = lv_message. " '오더의 품목에 투입처리된 내역이 있어 대체자재 변경할 수 없습니다.
          PERFORM save_log_order_bom  USING 'E'   " LOG TABLE 에 APPEND
                                      lv_message
                                      lv_timestamp
                                      system_id.
          CONTINUE.
        ENDIF.

        " 3) 오더 상태 점검 : 생성/REL상태 일때만 가능
        CLEAR : lv_message.
        PERFORM order_status_check USING lv_error
                                         lv_message.

        IF lv_error = 'X'.
          zo_result  = '01'.
          zo_message = lv_message.
          PERFORM save_log_order_bom  USING 'E'   " LOG TABLE 에 APPEND
                                      lv_message
                                      lv_timestamp
                                      system_id.
        ENDIF.

        " 4) 기존 투입 수량 존재하는지 점검
        PERFORM qty_check USING lv_error
                                lv_message.

        IF lv_error = 'X'.
          zo_result  = '01'.
          zo_message = lv_message.
          PERFORM save_log_order_bom  USING 'E'   " LOG TABLE 에 APPEND
                                      lv_message
                                      lv_timestamp
                                      system_id.
        ENDIF.

        "VALIDATION 오류 없을시, 대체자재 변경 BDC 수행
        IF lv_error <> 'X'.

          SELECT aufnr, posnr, rspos
            INTO TABLE @DATA(lt_resb)
            FROM resb
           WHERE aufnr = @gs_order_bom-aufnr
             AND werks = @gs_order_bom-werks
             AND rsnum = @gs_order_bom-rsnum
*             AND RSPOS = @GS_ORDER_BOM-RSPOS
             .
          SORT lt_resb BY aufnr posnr.

          IF sy-subrc = 0.

            READ TABLE lt_resb INTO DATA(ls_resb)
                                WITH KEY aufnr = gs_order_bom-aufnr

                                BINARY SEARCH.
            IF sy-subrc = 0.

              REFRESH: gt_bdcdata, gt_msgcoll.
              CLEAR  : gt_bdcdata, gt_msgcoll, gv_yes, gv_no.

              PERFORM dynpro USING:
                'X'  'SAPLCOKO1'            '0110',
                ' '  'BDC_OKCODE'           '=KPU2',
                ' '  'CAUFVD-AUFNR'          gs_order_bom-aufnr,
                ' ' 'R62CLORD-FLG_OVIEW'     gc_x.

              LOOP AT lt_order_bom_i INTO ls_order_bom_i
                                     WHERE  werks  = gs_order_bom-werks
                                       AND  zserno = gs_order_bom-zserno
                                       AND  aufnr  = gs_order_bom-aufnr
                                       AND  rsnum  = gs_order_bom-rsnum.

                READ TABLE lt_resb INTO DATA(ls_resb2)
                                WITH KEY aufnr = ls_order_bom_i-aufnr
                                         rspos = ls_order_bom_i-rspos.
                PERFORM dynpro USING:
                  'X'  'SAPLCOMK'             '0120',
                  '  '  'BDC_OKCODE'          '=AUFS',
                  '  '  'FILTER_BOX'          'NO_FIL',
                  '  '  'SORT_BOX'            'ST_STA'.

                PERFORM dynpro USING:
                  'X'  'SAPLCO05'             '0110',
                  '  '  'BDC_OKCODE'          '=MORE',
                  '  '  'RCOSU-POSNR'         ls_resb2-posnr.

                PERFORM dynpro USING:
                  'X'  'SAPLCOMK'             '0120',
                  '  '  'BDC_OKCODE'          '/00',
                  '  '  'RESBD-MATNR(01)'      ls_order_bom_i-matnr_to.


              ENDLOOP.




              PERFORM dynpro USING:
                 'X'  'SAPLCOMK'            '0120',
                 '  '  'FILTER_BOX'         'NO_FIL',
                 '  '  'SORT_BOX'           'ST_STA',
                 '  '  'BDC_OKCODE'         '=BU'.





              gs_bdcparams-nobinpt = 'X'.   " BI 세션
              gs_bdcparams-dismode = 'N'.
              gs_bdcparams-updmode = 'S'.
              CALL TRANSACTION 'CO02'          "TRANSACTION CALL.
                                   USING gt_bdcdata
                                   OPTIONS FROM gs_bdcparams
                                   MESSAGES INTO gt_msgcoll.
              CLEAR : lv_message,lv_line.
              DESCRIBE TABLE gt_msgcoll LINES lv_line.
              READ TABLE gt_msgcoll INDEX lv_line.
              PERFORM message_function USING gt_msgcoll lv_message.
              "간혹, 일부 자재 교체 중 세부 사항이 뜨는 경우가 있어
              "처리가 안됐을 경우 한번 더 BDC 태울 것
              CLEAR : gt_msgcoll.
              READ TABLE gt_msgcoll WITH KEY msgtyp = 'S'
                                             msgid = 'CO'
                                             msgnr = '100'.
              IF sy-subrc <> 0.

                REFRESH: gt_bdcdata, gt_msgcoll.
                CLEAR  : gt_bdcdata, gt_msgcoll.

                PERFORM dynpro USING:
                  'X'  'SAPLCOKO1'         '0110',
                  ' '  'BDC_OKCODE'        '=KPU2',
                  ' '  'CAUFVD-AUFNR'      gs_order_bom-aufnr,
                  ' ' 'R62CLORD-FLG_OVIEW' gc_x.

                LOOP AT lt_order_bom_i INTO ls_order_bom_i
                                       WHERE  werks  = gs_order_bom-werks
                                         AND  zserno = gs_order_bom-zserno
                                         AND  aufnr  = gs_order_bom-aufnr
                                         AND  rsnum  = gs_order_bom-rsnum.

                  READ TABLE lt_resb INTO DATA(ls_resb3)
                                  WITH KEY aufnr = ls_order_bom_i-aufnr
                                           rspos = ls_order_bom_i-rspos.
                  PERFORM dynpro USING:
                    'X'  'SAPLCOMK'             '0120',
                    '  '  'BDC_OKCODE'          '=AUFS',
                    '  '  'FILTER_BOX'          'NO_FIL',
                    '  '  'SORT_BOX'            'ST_STA'.

                  PERFORM dynpro USING:
                    'X'  'SAPLCO05'             '0110',
                    '  '  'BDC_OKCODE'          '=MORE',
                    '  '  'RCOSU-POSNR'         ls_resb3-posnr.

                  PERFORM dynpro USING:
                    'X'  'SAPLCOMK'             '0120',
                    '  '  'BDC_OKCODE'          '/00',
                    '  '  'RESBD-MATNR(01)'      ls_order_bom_i-matnr_to.


                ENDLOOP.

                PERFORM dynpro USING:
                  'X'  'SAPLCOMD'           '0110',
                  '  '  'BDC_OKCODE'         '/00'.

                PERFORM dynpro USING:
                   'X'  'SAPLCOMK'           '0120',
                   '  '  'FILTER_BOX'        'NO_FIL',
                   '  '  'SORT_BOX'          'ST_STA',
                   '  '  'BDC_OKCODE'        '=BU'.

                gs_bdcparams-nobinpt  = 'X'.   " BI 세션
                gs_bdcparams-dismode = 'N'.
                gs_bdcparams-updmode = 'S'. "COMMIT WORK
                CALL TRANSACTION 'CO02'          "TRANSACTION CALL.
                                     USING gt_bdcdata
                                     OPTIONS FROM gs_bdcparams
                                     MESSAGES INTO gt_msgcoll.
                CLEAR : lv_message,lv_line.
                DESCRIBE TABLE gt_msgcoll LINES lv_line.
                READ TABLE gt_msgcoll INDEX lv_line.
                PERFORM message_function USING gt_msgcoll lv_message.
                CLEAR : gt_msgcoll.
*                LV_TABIX = SY-TABIX.
                READ TABLE gt_msgcoll WITH KEY msgtyp = 'S'
                                               msgid = 'CO'
                                               msgnr = '100'.
                IF sy-subrc <> 0.
                  gv_no = 1.
                  PERFORM return_message_order_bom  USING 'E'
                                                          lv_message.
                  IF lv_message IS NOT INITIAL.
                    "LV_MESSAGE = GT_MSGCOLL-MSGV1.
                  ELSE.
                    lv_message = TEXT-m24.  "대체자재 변경(BDC)을 실패했습니다.
                  ENDIF.
                  zo_result  = '01'.
                  zo_message = lv_message.
                  PERFORM save_log_order_bom  USING 'E'   " LOG TABLE 에 APPEND
                                              lv_message
                                              lv_timestamp
                                             system_id.

                ELSE.

                  "-- 첫번째 BDC 성공시 RESB CHECK
                  CLEAR : gt_resb[] , gt_resb.
                  SELECT *
                    INTO CORRESPONDING FIELDS OF TABLE gt_resb
                    FROM resb
                   WHERE aufnr = gs_order_bom-aufnr
                     AND werks = gs_order_bom-werks
                     AND rsnum = gs_order_bom-rsnum
                     AND rspos = gs_order_bom-rspos
                     AND matnr = gs_order_bom-matnr_to.

                  CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
                    EXPORTING
                      input  = gs_order_bom-matnr_to
                    IMPORTING
                      output = gs_order_bom-matnr_to.

                  IF gt_resb[] IS NOT INITIAL.
                    WAIT UP TO '0.5' SECONDS.
                    gv_yes = 1.
*                    PERFORM RETURN_MESSAGE_ORDER_BOM  USING 'S'
*                                                            LV_MESSAGE.

                    CLEAR : lv_message_resb.
                    CONCATENATE TEXT-m29
                                gs_order_bom-matnr_to
                                TEXT-m30
                           INTO lv_message_resb."대체자재 {I/F 받은 MATNR_TO} 변경 성공했습니다.
                    PERFORM return_message_order_bom  USING 'S'
                                                            lv_message_resb.
                    PERFORM save_log_order_bom  USING 'S'   " LOG TABLE 에 APPEND
                                                lv_message_resb
                                                lv_timestamp
                                               system_id.

                  ELSE.
*                    PERFORM RETURN_MESSAGE_ORDER_BOM  USING 'E'
*                                                            LV_MESSAGE.
                    CLEAR : lv_message_resb.
                    CONCATENATE TEXT-m29
                                gs_order_bom-matnr_to
                                TEXT-m31
                           INTO lv_message_resb. "대체자재 {I/F 받은 MATNR_TO} 변경 실패했습니다.
                    PERFORM return_message_order_bom  USING 'E'
                                                            lv_message_resb.
                    PERFORM save_log_order_bom  USING 'E'   " LOG TABLE 에 APPEND
                                                lv_message_resb
                                                lv_timestamp
                                               system_id.
                  ENDIF.

                ENDIF.

              ELSE.

                "-- 첫번째 BDC 성공시 RESB CHECK
                CLEAR : gt_resb[] , gt_resb.
                SELECT *
                  INTO CORRESPONDING FIELDS OF TABLE gt_resb
                  FROM resb
                 WHERE aufnr = gs_order_bom-aufnr
                   AND werks = gs_order_bom-werks
                   AND rsnum = gs_order_bom-rsnum
                   AND rspos = gs_order_bom-rspos
                   AND matnr = gs_order_bom-matnr_to.

                CALL FUNCTION 'CONVERSION_EXIT_MATN1_OUTPUT'
                  EXPORTING
                    input  = gs_order_bom-matnr_to
                  IMPORTING
                    output = gs_order_bom-matnr_to.

                IF gt_resb[] IS NOT INITIAL.
                  WAIT UP TO '0.5' SECONDS.
                  gv_yes = 1.
*                  PERFORM RETURN_MESSAGE_ORDER_BOM  USING 'S'
*                                                          LV_MESSAGE.
                  CLEAR : lv_message_resb.
                  CONCATENATE TEXT-m29
                              gs_order_bom-matnr_to
                              TEXT-m30
                         INTO lv_message_resb. "대체자재 {I/F 받은 MATNR_TO} 변경 성공했습니다.
                  PERFORM return_message_order_bom  USING 'S'
                                                          lv_message_resb.
                  PERFORM save_log_order_bom  USING 'S'   " LOG TABLE 에 APPEND
                                              lv_message_resb
                                              lv_timestamp
                                             system_id.
                ELSE.
*                  PERFORM RETURN_MESSAGE_ORDER_BOM  USING 'E'
*                                                          LV_MESSAGE.
                  CLEAR : lv_message_resb.
                  CONCATENATE TEXT-m29
                              gs_order_bom-matnr_to
                              TEXT-m31
                         INTO lv_message_resb. "대체자재 {I/F 받은 MATNR_TO} 변경 실패했습니다.
                  PERFORM return_message_order_bom  USING 'E'
                                                            lv_message_resb.
                  PERFORM save_log_order_bom  USING 'E'   " LOG TABLE 에 APPEND
                                              lv_message_resb
                                              lv_timestamp
                                             system_id.
                ENDIF.

              ENDIF.

            ENDIF.

          ELSE.

            PERFORM return_message_order_bom  USING 'E'
                                                    TEXT-m25. "예약/종속 소요량 DATA 추출 실패했습니다.
            CLEAR : lv_message.
            lv_message = TEXT-m25.
            zo_result  = '01'.
            zo_message = lv_message.
            PERFORM save_log_order_bom  USING 'E'   " LOG TABLE 에 APPEND
                                       lv_message
                                       lv_timestamp
                                       system_id.
          ENDIF.

        ENDIF.

        CLEAR : lv_message, lv_zerp_stat.
        lv_zerp_stat =
        VALUE #( gt_result[ zserno = gs_order_bom-zserno ]-zerp_stat
                 OPTIONAL ).
        lv_message =
        VALUE #( gt_result[ zserno = gs_order_bom-zserno ]-zerp_message
                 OPTIONAL ).

        PERFORM append_read_data USING gs_order_bom
                                       lv_zerp_stat
                                       lv_message.

      ELSE.  " 이미 처리된 아이템인경우

        PERFORM return_message_order_bom
                          USING gs_order_bom_s-zerp_stat
                                gs_order_bom_s-zerp_message.

        " LOG TABLE 에 APPEND
        PERFORM save_log_order_bom  USING gs_order_bom_s-zerp_stat
                                   gs_order_bom_s-zerp_message
                                   lv_timestamp
                                   system_id.

      ENDIF.

    ENDLOOP.

  ENDIF.

*- RFC 펑션 결과 리턴
*  PERFORM CONVERSION_OUTPUT_GT_RESULT.

  PERFORM result_data USING zo_result
                            zo_message
                            lv_bom_flag.
  LOOP AT gt_zgtppt2140 INTO gs_zgtppt2140.
    gs_zgtppt2140-zstat     =  zo_result.
    gs_zgtppt2140-zmessage  =  zo_message.
    MODIFY gt_zgtppt2140 FROM gs_zgtppt2140.
  ENDLOOP.


  MODIFY zgtppt2140 FROM TABLE gt_zgtppt2140.
  IF sy-subrc = 0.
    COMMIT WORK.
  ENDIF.


  ot_result[] = gt_result[].


ENDFUNCTION.
