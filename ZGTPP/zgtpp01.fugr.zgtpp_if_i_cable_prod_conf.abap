FUNCTION zgtpp_if_i_cable_prod_conf.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_MODE) TYPE  CHAR2
*"     VALUE(I_SYSTEM_ID) TYPE  CHAR4
*"  EXPORTING
*"     VALUE(ZO_RESULT) TYPE  ZO_RESULT
*"     VALUE(ZO_MESSAGE) TYPE  ZO_MESSAGE
*"  TABLES
*"      IT_CON STRUCTURE  ZGTPPSIF0020 OPTIONAL
*"      OT_RESULT STRUCTURE  ZGTPPSIF0021 OPTIONAL
*"----------------------------------------------------------------------
*&----------------------------------------------------------------------
*&*"Local Interface:
*&  IMPORTING
*&     VALUE(I_MODE) TYPE  CHAR2
*&     VALUE(I_SYSTEM_ID) TYPE  CHAR4
*&  EXPORTING
*&     VALUE(ZO_RESULT) TYPE  ZO_RESULT
*&     VALUE(ZO_MESSAGE) TYPE  ZO_MESSAGE
*&  TABLES
*&      IT_CON STRUCTURE  ZGTPPSIF0020 OPTIONAL
*&      OT_TAB STRUCTURE  ZGTPPSIF0021 OPTIONAL
*&----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPP_IF_I_CABLE_PROD_CONF
*& 프로그램 명 : [GT] 생산오더 실적처리 수신
*& 개요   :
*& 생성일 : 2024.11.28
*& 생성자 : ZGSIDEV04
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : 생산오더의 실적 처리(Confirmation) 정보를 수신 받아,
*&                   실적 처리(양품/불량/액티비티)와 Backflush 자재 투입 처리를 진행함
*&                   처리 이후, 성공/오류 여부를 MES로 Sync방식 Return함
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  :
*& 수정자  :
*& 수정개요 :
*&---------------------------------------------------------------------*
  DATA : lt_con TYPE TABLE OF zgtppsif0020.
  DATA : lv_error.
  DATA : lv_message(220).
  DATA : lv_budat      TYPE zgtppsif0020-budat,
         lv_fin_conf     LIKE afru-aueru,
         lv_ism06        LIKE afru-ism06,
         lv_clear_res(1),
         lv_extid(32),
         lv_chk_flag(1),
         lv_bapi_flag(1).
  DATA : lv_idx          TYPE numc2.

  DATA : lt_goodsmovements LIKE TABLE OF bapi2017_gm_item_create.

  DATA : lt_return           LIKE TABLE OF bapiret1,
         lv_rueck            TYPE bapi_pp_conf_key-conf_no,
         lv_rmzhl            TYPE bapi_pp_conf_key-conf_cnt,
         lv_cancel_msg       TYPE bapiret1-message,
         lv_lock_chk_flag(1),
         lv_cancel_flag(1).
  DATA : lv_timestamp TYPE timestampl.

  DATA: lv_dup_flag TYPE char1.                            "SRM2603-13959

  CLEAR : lt_con, gs_con, gt_con,  lv_error,
          gt_gr_result, ot_result, ot_result[],
          gt_gr_result_c,  gt_gr_result_c[],
          gs_zgtppt3080, gt_zgtppt3080[],gt_zgtppt3080.

  CLEAR : lv_bapi_flag,lv_extid.


  lt_con[] = it_con[].
  gt_con = CORRESPONDING #( lt_con ).
  lv_bapi_flag = 'X'.

*- 실적 처리
  IF i_mode = 'P'.

    LOOP AT gt_con INTO gs_con.
      CLEAR : lv_error, lv_timestamp,lv_bapi_flag,lv_extid, lv_budat.

      lv_budat = gs_con-budat.

      GET TIME STAMP FIELD lv_timestamp.

*- Conversion_Input
      PERFORM conversion_input_con.

*- 확정 외부 ID KEY 생성
      PERFORM create_idkey USING lv_extid.

*SRM2603-13959 소재 MOM 중복 체크 추가
      PERFORM check_dup_conf_1 USING i_system_id
                                                            i_mode
                                                            gs_con-zserno
                                                            gs_con-werks
                                                            gs_con-aufnr
                                                            gs_con-budat
                                                            gs_con-menge
                                                            gs_con-tagnr
                                                            lv_timestamp
                                                            lv_dup_flag.
      IF lv_dup_flag EQ 'X'.
        CONTINUE.
      ENDIF.
*SRM2603-13959

*- 수신데이터 정합성 체크
*- 공통 체크 항목
      PERFORM check_common_con  USING lv_error.
***      " 공통적인 사항으로 이전부터 오더에 최종 확정 상태가 지정되어 있는지 확인
***      PERFORM check_common_order_state USING lv_fin_conf
***                                             lv_clear_res
***                                             'A'.

      IF lv_error = 'X'.
        lv_message = VALUE #( gt_gr_result[ zserno = gs_con-zserno ]-zerp_message OPTIONAL ).
        PERFORM save_log_con  USING 'E'
                                    lv_message
                                    ''
                                    ''
                                    lv_extid
                                    lv_timestamp
                                    i_system_id
                                    i_mode.
        CLEAR gs_con.
        CONTINUE.
      ENDIF.

      CHECK lv_error <> 'X'.

*- start 2025.01.13
      DATA : lv_auart TYPE aufk-auart.

      SELECT SINGLE auart
        INTO lv_auart
        FROM aufk
       WHERE aufnr = gs_con-aufnr.
*- end 2025.01.13

      lv_idx = 1.
      DO 5 TIMES.

        CASE lv_idx.

          WHEN '1'.  " - 양품 실적 처리
            " CASE 1 양품 실적 처리 대상이 있는경우
            IF gs_con-lmnga IS NOT INITIAL
               OR gs_con-ism01 IS NOT INITIAL
               OR gs_con-ism02 IS NOT INITIAL.

              PERFORM call_bapi_case_a TABLES lt_goodsmovements
                                              lt_return
                                        USING lv_message
                                              lv_error
                                              lv_extid
                                              'A'
                                              lv_timestamp
                                              i_system_id
                                              i_mode
                                              lv_auart
                                        CHANGING lv_bapi_flag.
              IF lv_bapi_flag = 'X'.
                CLEAR gs_con.
                EXIT..
              ENDIF.
              .
            ELSE.
              lv_bapi_flag = 'N'.
            ENDIF.

          WHEN '2'.  " 수리 실적 처리

            IF lv_bapi_flag = 'A' OR " A  CASE BAPI가 성공이면 수행
               lv_bapi_flag = 'N'.   "양품 실적 처리 대상이 없는 경우

              IF gs_con-xmnga IS NOT INITIAL  " 수리 실적 대상이 있는경우
                OR gs_con-ism08 IS NOT INITIAL.

                CLEAR : lv_lock_chk_flag.
                PERFORM check_prodordconf_create_lock
                  USING gs_con-aufnr
                        lv_lock_chk_flag
                        lv_timestamp
                        i_system_id
                        i_mode
                        .
                IF lv_lock_chk_flag = 'S'.
                  PERFORM call_bapi_case_b TABLES lt_goodsmovements
                                            USING lv_message
                                                  lv_error
                                                  lv_extid
                                                  'B'
                                                  lv_timestamp
                                                  i_system_id
                                                  i_mode
                                                  lv_auart
                                            CHANGING lv_bapi_flag.
                  IF lv_bapi_flag = 'X'.
                    CLEAR gs_con.
                    EXIT.
                  ENDIF.
                ELSE.
                  lv_bapi_flag = 'X'.
                  CLEAR gs_con.
                  EXIT.
                ENDIF.

              ELSE. " 수리 실적 대상이 없는경우
                IF lv_bapi_flag = 'A'
                   OR lv_bapi_flag = 'B'
                   OR lv_bapi_flag = 'C'
                   OR lv_bapi_flag = 'D'
                   OR lv_bapi_flag = 'E'
                   .
                ELSE.
                  lv_bapi_flag = 'N'.
                ENDIF.
              ENDIF.

            ENDIF.

          WHEN '3'.  "준비교체(예압) 실적 처리

            IF lv_bapi_flag = 'A' OR " A  양품 실적 처리가 성공이면 수행
               lv_bapi_flag = 'B' OR " B  수리 실적 처리가 성공이면 수행
               lv_bapi_flag = 'N'.   " 양품/수리 실적 처리 대상이 없는 경우

              IF gs_con-ism07 IS NOT INITIAL . " 준비교체(예압) 실적 대상이 있는경우
                CLEAR : lv_lock_chk_flag.
                PERFORM check_prodordconf_create_lock
                  USING gs_con-aufnr
                        lv_lock_chk_flag
                        lv_timestamp
                        i_system_id
                        i_mode
                        .
                IF lv_lock_chk_flag = 'S'.
                  PERFORM call_bapi_case_c TABLES lt_goodsmovements
                                            USING lv_message
                                                  lv_error
                                                  lv_extid
                                                  'C'
                                                  lv_timestamp
                                                  i_system_id
                                                  i_mode
                                                  lv_auart
                                            CHANGING lv_bapi_flag.

                  IF lv_bapi_flag = 'X'.
                    CLEAR gs_con.
                    EXIT.
                  ENDIF.
                ELSE.
                  lv_bapi_flag = 'X'.
                  CLEAR gs_con.
                  EXIT.
                ENDIF.
              ELSE. " 준비교체(예압) 실적  대상이 없는경우
                IF lv_bapi_flag = 'A'
                   OR lv_bapi_flag = 'B'
                   OR lv_bapi_flag = 'C'
                   OR lv_bapi_flag = 'D'
                   OR lv_bapi_flag = 'E'
                   .
                ELSE.
                  lv_bapi_flag = 'N'.
                ENDIF.             .
              ENDIF.

            ENDIF.

          WHEN '4'. "Start 여장 작업 실적 처리

            IF lv_bapi_flag = 'A' OR " A  양품 실적 처리가 성공이면 수행
               lv_bapi_flag = 'B' OR " B  수리 실적 처리가 성공이면 수행
               lv_bapi_flag = 'C' OR " C  준비교체(예압) 실적가 성공이면 수행
               lv_bapi_flag = 'N'.   " 양품/수리/준비교체(예압) 실적 처리 대상이 없는 경우

              IF gs_con-smnga IS NOT INITIAL OR  " Start 여장 작업 실적 처리대상이 있는경우
                 gs_con-ism09 IS NOT INITIAL.
                CLEAR : lv_lock_chk_flag.
                PERFORM check_prodordconf_create_lock
                  USING gs_con-aufnr
                        lv_lock_chk_flag
                        lv_timestamp
                        i_system_id
                        i_mode
                        .
                IF lv_lock_chk_flag = 'S'.
                  PERFORM call_bapi_case_d TABLES lt_goodsmovements
                                            USING lv_message
                                                  lv_error
                                                  lv_extid
                                                  'D'
                                                  lv_timestamp
                                                  i_system_id
                                                  i_mode
                                                  lv_auart
                                            CHANGING lv_bapi_flag.

                  IF lv_bapi_flag = 'X'.
                    CLEAR gs_con.
                    EXIT.
                  ENDIF.
                ELSE.
                  lv_bapi_flag = 'X'.
                  CLEAR gs_con.
                  EXIT.
                ENDIF.
              ELSE. " Start 여장 작업 실적  대상이 없는경우
                IF lv_bapi_flag = 'A'
                   OR lv_bapi_flag = 'B'
                   OR lv_bapi_flag = 'C'
                   OR lv_bapi_flag = 'D'
                   OR lv_bapi_flag = 'E'
                   .
                ELSE.
                  lv_bapi_flag = 'N'.
                ENDIF.                 .
              ENDIF.

            ENDIF.

          WHEN '5'. "End 여장 작업 실적 처리

            IF lv_bapi_flag = 'A' OR " A  양품 실적 처리가 성공이면 수행
               lv_bapi_flag = 'B' OR " B  수리 실적 처리가 성공이면 수행
               lv_bapi_flag = 'C' OR " C  준비교체(예압) 실적가 성공이면 수행
               lv_bapi_flag = 'D' OR " D  Start 여장 작업 실적 처리가 성공이면 수행
               lv_bapi_flag = 'N'.   " 양품/수리/준비교체(예압) /Start 여장 작업실적
              " 실적 처리 대상이 없는 경우

              IF gs_con-emnga IS NOT INITIAL OR  " End 여장 작업  실적 처리대상이 있는경우
                 gs_con-ism10 IS NOT INITIAL.
                CLEAR : lv_lock_chk_flag.
                PERFORM check_prodordconf_create_lock
                  USING gs_con-aufnr
                        lv_lock_chk_flag
                        lv_timestamp
                        i_system_id
                        i_mode
                        .
                IF lv_lock_chk_flag = 'S'.
                  PERFORM call_bapi_case_e TABLES lt_goodsmovements
                                            USING lv_message
                                                  lv_error
                                                  lv_extid
                                                  'E'
                                                  lv_timestamp
                                                  i_system_id
                                                  i_mode
                                                  lv_auart
                                            CHANGING lv_bapi_flag.

                  IF lv_bapi_flag = 'X'.
                    CLEAR gs_con.
                    EXIT.
                  ENDIF.
                ELSE.
                  lv_bapi_flag = 'X'.
                  CLEAR gs_con.
                  EXIT.
                ENDIF.
              ELSE. " End 여장 작업 실적  대상이 없는경우
                IF lv_bapi_flag = 'A'
                   OR lv_bapi_flag = 'B'
                   OR lv_bapi_flag = 'C'
                   OR lv_bapi_flag = 'D'
                   OR lv_bapi_flag = 'E'
                   .
                ELSE.
                  lv_bapi_flag = 'N'.
                ENDIF.             .
              ENDIF.

            ENDIF.

        ENDCASE.

        lv_idx = lv_idx + 1.

      ENDDO.

      IF lv_bapi_flag = 'A' OR " A  양품 실적 처리가 성공이면 수행
         lv_bapi_flag = 'B' OR " B  수리 실적 처리가 성공이면 수행
         lv_bapi_flag = 'C' OR " C  준비교체(예압) 실적가 성공이면 수행
         lv_bapi_flag = 'D' OR " D  Start 여장 작업 실적 처리가 성공이면 수행
         lv_bapi_flag = 'E'. " E  End 여장 작업 실적 처리
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            wait = 'X'.
**- 생산오더 전송 프로그램 호출(zgtppi2010)
*        PERFORM call_transaction_zgtppi2010 USING gs_con-werks
*                                                  gs_con-aufnr.
      ELSEIF lv_bapi_flag = 'X'.
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.


*- 확정 외부 ID KEY 생성
        CLEAR : lv_extid.
        lv_extid = gs_con-ru_extid.
        LOOP at   gt_gr_result_c INTO  gs_gr_result_c .

            PERFORM bapi_prodordconf_cancel TABLES lt_return
                                            USING gs_gr_result_c-rueck
                                                  gs_gr_result_c-rmzhl
                                                  lv_budat
                                                  lv_rueck
                                                  lv_rmzhl
                                                  lv_cancel_flag.
            IF lv_cancel_flag = 'E'.

*              CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

*              READ TABLE lt_return INTO DATA(ls_return)  WITH KEY type = 'E'.
*              IF sy-subrc = 0.
              IF lv_rueck IS INITIAL.
                PERFORM return_message_con_c  USING 'E'
*                                                  ls_return-message
                                                 TEXT-m04
                                                  '  '
                                                  '  '
                                                  lv_extid.
                PERFORM save_log_con_cancel  USING 'E'
*                                            ls_return-message
                                            TEXT-m04
                                            '  '
                                            '  '
                                            lv_extid
                                            lv_timestamp
                                            i_system_id
                                            i_mode.
              ENDIF.
              EXIT.
            ENDIF.

        ENDLOOP.

      ELSEIF lv_bapi_flag = 'N'." 양품/수리/준비교체(예압) /Start 여장 작업없음
        PERFORM return_message_con  USING 'E'
                                        '실적 처리할 데이터가 없습니다.'
                                        '  '
                                        '  '
                                        lv_extid.
        PERFORM save_log_con  USING 'E'
                           '실적 처리할 데이터가 없습니다.'
                           '  '
                           '  '
                           lv_extid
                           lv_timestamp
                           i_system_id
                           i_mode.
      ENDIF.

      CLEAR gs_con.

    ENDLOOP.



*- 실적 취소-------------------------------------------------------*
  ELSEIF i_mode = 'C'.

    CLEAR : lv_extid .

    LOOP AT gt_con INTO gs_con.
      CLEAR : lv_error, lv_timestamp..

      GET TIME STAMP FIELD lv_timestamp.


*- 확정 외부 ID KEY 생성
      CLEAR : lv_extid.
      lv_extid = gs_con-ru_extid.

*- Conversion_Input
      PERFORM conversion_input_con.

*SRM2603-13959 소재 MOM 중복 체크 추가
      PERFORM check_dup_conf_1 USING i_system_id
                                                            i_mode
                                                            gs_con-zserno
                                                            gs_con-werks
                                                            gs_con-aufnr
                                                            gs_con-budat
                                                            gs_con-menge
                                                            gs_con-tagnr
                                                            lv_timestamp
                                                            lv_dup_flag.
      IF lv_dup_flag EQ 'X'.
        CONTINUE.
      ENDIF.
*SRM2603-13959

*- 공통 체크 항목
      PERFORM check_common_con  USING lv_error.

***      " 공통적인 사항으로 이전부터 오더에 최종 확정 상태가 지정되어 있는지 확인
***      PERFORM check_common_order_state USING lv_fin_conf
***                                             lv_clear_res
***                                             'A'.

      IF lv_error = 'X'.
        lv_message = VALUE #( gt_gr_result[ zserno = gs_con-zserno ]-zerp_message OPTIONAL ).
        PERFORM save_log_con_cancel  USING 'E'
                                          lv_message
                                          ''
                                          ''
                                          lv_extid
                                          lv_timestamp
                                          i_system_id
                                          i_mode.
        CLEAR gs_con.
        CONTINUE.
      ENDIF.

*- 실적 취소 체크 항목
      CLEAR : gt_afru[] , gt_afru.
      PERFORM check_cancel_con USING lv_error
                                     lv_extid.

      IF lv_error = 'X'.
        lv_message = VALUE #( gt_gr_result[ zserno = gs_con-zserno ]-zerp_message OPTIONAL ).

        PERFORM save_log_con_cancel  USING 'E'
                                          lv_message
                                          ''
                                          ''
                                          lv_extid
                                          lv_timestamp
                                          i_system_id
                                          i_mode.
        CLEAR gs_con.
        CONTINUE.
      ENDIF.

***      CLEAR : gt_afru[] , gt_afru.
***      PERFORM get_cancel_data USING gs_con-ru_extid
***                                    gs_con-aufnr.
*- 실적 취소
      CLEAR : lv_cancel_flag, lv_lock_chk_flag.
      LOOP AT  gt_afru.
        PERFORM check_prodordconf_create_lock USING  gs_con-aufnr
                                                   lv_lock_chk_flag
                                                   lv_timestamp
                                                   i_system_id
                                                   i_mode
                                                   .
        IF lv_lock_chk_flag = 'S'.

          PERFORM bapi_prodordconf_cancel TABLES lt_return
                                          USING gt_afru-rueck
                                                gt_afru-rmzhl
                                                gt_afru-budat
                                                lv_rueck
                                                lv_rmzhl
                                                lv_cancel_flag.
          IF lv_cancel_flag = 'E'.

*            CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

*            READ TABLE lt_return INTO DATA(ls_return)  WITH KEY type = 'E'.
*            IF sy-subrc = 0.
            IF lv_rueck IS INITIAL.
              PERFORM return_message_con  USING 'E'
*                                                ls_return-message
                                               TEXT-m04
                                                '  '
                                                '  '
                                                lv_extid.
              PERFORM save_log_con_cancel  USING 'E'
*                                          ls_return-message
                                          TEXT-m04
                                          '  '
                                          '  '
                                          lv_extid
                                          lv_timestamp
                                          i_system_id
                                          i_mode.
            ENDIF.
            EXIT.
          ENDIF.

        ELSE.

          CONCATENATE '오더번호('
                      sy-msgv1
                      ')이 처리중입니다'
                 INTO lv_message .
          PERFORM save_log_con  USING 'E'
                                      lv_message
                                      ''
                                      ''
                                      lv_extid
                                      lv_timestamp
                                      i_system_id
                                      i_mode.
          lv_bapi_flag = 'X'.

        ENDIF.

      ENDLOOP.


*     *- 성공
      IF lv_cancel_flag = 'S'.
*        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*          EXPORTING
*            wait = 'X'.
        lv_cancel_msg = TEXT-m05."|성공|. "BAPI 메시지가 필요

        PERFORM return_message_con  USING 'S'
                                          lv_cancel_msg
                                          lv_rueck
                                          lv_rmzhl
                                          lv_extid.

        PERFORM save_log_con_cancel  USING 'S'
                                    lv_cancel_msg
                                    lv_rueck
                                    lv_rmzhl
                                    lv_extid
                                    lv_timestamp
                                    i_system_id
                                    i_mode.
*        LOOP AT  gt_afru.
**     - 생산오더 전송 프로그램 호출(zgtppi2010)
*          PERFORM call_transaction_zgtppi2010_C
*            USING gt_afru-werks
*                  gt_afru-aufnr.
*        ENDLOOP.

      ENDIF.

      CLEAR gs_con.

    ENDLOOP.

  ENDIF.


  MODIFY zgtppt3080 FROM TABLE gt_zgtppt3080.
  IF sy-subrc = 0.
    COMMIT WORK.
  ENDIF.

*- RFC 펑션 결과 리턴
  PERFORM conversion_output_gt_gr_result.

  PERFORM result_gr_data USING zo_result
                               zo_message
                               lv_bapi_flag.

  ot_result[] = gt_gr_result[].

ENDFUNCTION.
