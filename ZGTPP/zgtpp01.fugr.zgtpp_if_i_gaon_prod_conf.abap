FUNCTION ZGTPP_IF_I_GAON_PROD_CONF.
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
*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPP_IF_I_GAON_PROD_CONF
*& 프로그램 명 : [GT] [가온전선 MES] 생산오더 실적처리
*& 개요   : 생산오더의 실적 처리(Confirmation) 정보를 수신 받아,
*&     실적 처리(양품/불량/액티비티)와 Backflush 자재 투입 처리를 진행함
*&     처리 이후, 성공/오류 여부를 MES로 Sync방식 Return함
*& 생성일 : 2026.02.26
*& 생성자 : ZGODEV06
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : 가온전선 MES
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
* No      DATE      AUTHORS              DESCRIPTION                   *
* ---  ----------  ---------  -----------------------------------------*
*      2026.02.26  ZGODEV06   함수 ZGTPP_IF_I_CABLE_PROD_CONF 복사 생성
* GO01 2026.08.29  ZGODEV03   WIP 상태 오더의 validation 추가
* GO02 2026.09.10  ZGODEV03   전기일 설정 추가
*&---------------------------------------------------------------------*
  DATA : LT_CON TYPE TABLE OF ZGTPPSIF0020.
  DATA : LV_ERROR.
  DATA : LV_MESSAGE(220).
  DATA : LV_BUDAT        TYPE ZGTPPSIF0020-BUDAT,
         LV_FIN_CONF     LIKE AFRU-AUERU,
         LV_ISM06        LIKE AFRU-ISM06,
         LV_CLEAR_RES(1),
         LV_EXTID(32),
         LV_CHK_FLAG(1),
         LV_BAPI_FLAG(1).
  DATA : LV_IDX          TYPE NUMC2.

  DATA : LT_GOODSMOVEMENTS LIKE TABLE OF BAPI2017_GM_ITEM_CREATE.

  DATA : LT_RETURN           LIKE TABLE OF BAPIRET1,
         LV_RUECK            TYPE BAPI_PP_CONF_KEY-CONF_NO,
         LV_RMZHL            TYPE BAPI_PP_CONF_KEY-CONF_CNT,
         LV_CANCEL_MSG       TYPE BAPIRET1-MESSAGE,
         LV_LOCK_CHK_FLAG(1),
         LV_CANCEL_FLAG(1).
  DATA : LV_TIMESTAMP TYPE TIMESTAMPL.

  CLEAR : LT_CON, GS_CON, GT_CON,  LV_ERROR,
          GT_GR_RESULT, OT_RESULT, OT_RESULT[],
          GT_GR_RESULT_C,  GT_GR_RESULT_C[],
          GS_ZGTPPT3080, GT_ZGTPPT3080[],GT_ZGTPPT3080.

  CLEAR : LV_BAPI_FLAG,LV_EXTID.

  LT_CON[] = IT_CON[].
  GT_CON = CORRESPONDING #( LT_CON ).
  LV_BAPI_FLAG = 'X'.

*// Modified by ZGODEV06 on 2026-03-23 {
  PERFORM IS_SYSTEM_ID_GAON USING I_SYSTEM_ID GV_GAON.
*// }

*- 실적 처리
  IF I_MODE = 'P'.

    LOOP AT GT_CON INTO GS_CON.
      CLEAR : LV_ERROR, LV_TIMESTAMP,LV_BAPI_FLAG,LV_EXTID, LV_BUDAT.

      GET TIME STAMP FIELD LV_TIMESTAMP.

*- Conversion_Input
      PERFORM CONVERSION_INPUT_CON.

*- 확정 외부 ID KEY 생성
      PERFORM CREATE_IDKEY USING LV_EXTID.

*- 수신데이터 정합성 체크
*- 공통 체크 항목
      PERFORM CHECK_COMMON_CON  USING LV_ERROR.
***      " 공통적인 사항으로 이전부터 오더에 최종 확정 상태가 지정되어 있는지 확인
***      PERFORM check_common_order_state USING lv_fin_conf
***                                             lv_clear_res
***                                             'A'.

      IF LV_ERROR = 'X'.
        LV_MESSAGE = VALUE #( GT_GR_RESULT[ ZSERNO = GS_CON-ZSERNO ]-ZERP_MESSAGE OPTIONAL ).
        PERFORM SAVE_LOG_CON  USING 'E'
                                    LV_MESSAGE
                                    ''
                                    ''
                                    LV_EXTID
                                    LV_TIMESTAMP
                                    I_SYSTEM_ID
                                    I_MODE.
        CLEAR GS_CON.
        CONTINUE.
      ENDIF.

      CHECK LV_ERROR <> 'X'.

*- GO02 Start GAON 전기일 설정
* 양품 실적 처리시에만 적용
      IF GV_GAON EQ ABAP_TRUE.
        PERFORM SET_BUDAT USING GS_CON-AUFNR GS_CON-BUDAT.
        LV_BUDAT = GV_BUDAT.
      ELSE.
        LV_BUDAT = GS_CON-BUDAT. "실적 처리 후 오류시 롤백용
      ENDIF.
*- GO02 End GAON 전기일 설정

*- start 2025.01.13
      DATA : LV_AUART TYPE AUFK-AUART.

      SELECT SINGLE AUART
        INTO LV_AUART
        FROM AUFK
       WHERE AUFNR = GS_CON-AUFNR.
*- end 2025.01.13

      LV_IDX = 1.
      DO 5 TIMES.

        CASE LV_IDX.

          WHEN '1'.  " - 양품 실적 처리
            " CASE 1 양품 실적 처리 대상이 있는경우
            IF GS_CON-LMNGA IS NOT INITIAL
               OR GS_CON-ISM01 IS NOT INITIAL
               OR GS_CON-ISM02 IS NOT INITIAL.

              PERFORM CALL_BAPI_CASE_A_GAON TABLES LT_GOODSMOVEMENTS
                                              LT_RETURN
                                        USING LV_MESSAGE
                                              LV_ERROR
                                              LV_EXTID
                                              'A'
                                              LV_TIMESTAMP
                                              I_SYSTEM_ID
                                              I_MODE
                                              LV_AUART
                                        CHANGING LV_BAPI_FLAG.
              IF LV_BAPI_FLAG = 'X'.
                CLEAR GS_CON.
                EXIT..
              ENDIF.
              .
            ELSE.
              LV_BAPI_FLAG = 'N'.
            ENDIF.

          WHEN '2'.  " 수리 실적 처리

            IF LV_BAPI_FLAG = 'A' OR " A  CASE BAPI가 성공이면 수행
               LV_BAPI_FLAG = 'N'.   "양품 실적 처리 대상이 없는 경우

              IF GS_CON-XMNGA IS NOT INITIAL  " 수리 실적 대상이 있는경우
                OR GS_CON-ISM08 IS NOT INITIAL.

                CLEAR : LV_LOCK_CHK_FLAG.
                PERFORM CHECK_PRODORDCONF_CREATE_LOCK
                  USING GS_CON-AUFNR
                        LV_LOCK_CHK_FLAG
                        LV_TIMESTAMP
                        I_SYSTEM_ID
                        I_MODE
                        .
                IF LV_LOCK_CHK_FLAG = 'S'.
                  PERFORM CALL_BAPI_CASE_B TABLES LT_GOODSMOVEMENTS
                                            USING LV_MESSAGE
                                                  LV_ERROR
                                                  LV_EXTID
                                                  'B'
                                                  LV_TIMESTAMP
                                                  I_SYSTEM_ID
                                                  I_MODE
                                                  LV_AUART
                                            CHANGING LV_BAPI_FLAG.
                  IF LV_BAPI_FLAG = 'X'.
                    CLEAR GS_CON.
                    EXIT.
                  ENDIF.
                ELSE.
                  LV_BAPI_FLAG = 'X'.
                  CLEAR GS_CON.
                  EXIT.
                ENDIF.
              ELSE. " 수리 실적 대상이 없는경우
                IF LV_BAPI_FLAG = 'A'
                   OR LV_BAPI_FLAG = 'B'
                   OR LV_BAPI_FLAG = 'C'
                   OR LV_BAPI_FLAG = 'D'
                   OR LV_BAPI_FLAG = 'E'
                   .
                ELSE.
                  LV_BAPI_FLAG = 'N'.
                ENDIF.
              ENDIF.

            ENDIF.

          WHEN '3'.  "준비교체(예압) 실적 처리

            IF LV_BAPI_FLAG = 'A' OR " A  양품 실적 처리가 성공이면 수행
               LV_BAPI_FLAG = 'B' OR " B  수리 실적 처리가 성공이면 수행
               LV_BAPI_FLAG = 'N'.   " 양품/수리 실적 처리 대상이 없는 경우

              IF GS_CON-ISM07 IS NOT INITIAL . " 준비교체(예압) 실적 대상이 있는경우
                CLEAR : LV_LOCK_CHK_FLAG.
                PERFORM CHECK_PRODORDCONF_CREATE_LOCK
                  USING GS_CON-AUFNR
                        LV_LOCK_CHK_FLAG
                        LV_TIMESTAMP
                        I_SYSTEM_ID
                        I_MODE
                        .
                IF LV_LOCK_CHK_FLAG = 'S'.
                  PERFORM CALL_BAPI_CASE_C TABLES LT_GOODSMOVEMENTS
                                            USING LV_MESSAGE
                                                  LV_ERROR
                                                  LV_EXTID
                                                  'C'
                                                  LV_TIMESTAMP
                                                  I_SYSTEM_ID
                                                  I_MODE
                                                  LV_AUART
                                            CHANGING LV_BAPI_FLAG.

                  IF LV_BAPI_FLAG = 'X'.
                    CLEAR GS_CON.
                    EXIT.
                  ENDIF.
                ELSE.
                  LV_BAPI_FLAG = 'X'.
                  CLEAR GS_CON.
                  EXIT.
                ENDIF.
              ELSE. " 준비교체(예압) 실적  대상이 없는경우
                IF LV_BAPI_FLAG = 'A'
                   OR LV_BAPI_FLAG = 'B'
                   OR LV_BAPI_FLAG = 'C'
                   OR LV_BAPI_FLAG = 'D'
                   OR LV_BAPI_FLAG = 'E'
                   .
                ELSE.
                  LV_BAPI_FLAG = 'N'.
                ENDIF.             .
              ENDIF.

            ENDIF.

          WHEN '4'. "Start 여장 작업 실적 처리

            IF LV_BAPI_FLAG = 'A' OR " A  양품 실적 처리가 성공이면 수행
               LV_BAPI_FLAG = 'B' OR " B  수리 실적 처리가 성공이면 수행
               LV_BAPI_FLAG = 'C' OR " C  준비교체(예압) 실적가 성공이면 수행
               LV_BAPI_FLAG = 'N'.   " 양품/수리/준비교체(예압) 실적 처리 대상이 없는 경우

              IF GS_CON-SMNGA IS NOT INITIAL OR  " Start 여장 작업 실적 처리대상이 있는경우
                 GS_CON-ISM09 IS NOT INITIAL.
                CLEAR : LV_LOCK_CHK_FLAG.
                PERFORM CHECK_PRODORDCONF_CREATE_LOCK
                  USING GS_CON-AUFNR
                        LV_LOCK_CHK_FLAG
                        LV_TIMESTAMP
                        I_SYSTEM_ID
                        I_MODE
                        .
                IF LV_LOCK_CHK_FLAG = 'S'.
                  PERFORM CALL_BAPI_CASE_D TABLES LT_GOODSMOVEMENTS
                                            USING LV_MESSAGE
                                                  LV_ERROR
                                                  LV_EXTID
                                                  'D'
                                                  LV_TIMESTAMP
                                                  I_SYSTEM_ID
                                                  I_MODE
                                                  LV_AUART
                                            CHANGING LV_BAPI_FLAG.

                  IF LV_BAPI_FLAG = 'X'.
                    CLEAR GS_CON.
                    EXIT.
                  ENDIF.
                ELSE.
                  LV_BAPI_FLAG = 'X'.
                  CLEAR GS_CON.
                  EXIT.
                ENDIF.
              ELSE. " Start 여장 작업 실적  대상이 없는경우
                IF LV_BAPI_FLAG = 'A'
                   OR LV_BAPI_FLAG = 'B'
                   OR LV_BAPI_FLAG = 'C'
                   OR LV_BAPI_FLAG = 'D'
                   OR LV_BAPI_FLAG = 'E'
                   .
                ELSE.
                  LV_BAPI_FLAG = 'N'.
                ENDIF.                 .
              ENDIF.

            ENDIF.

          WHEN '5'. "End 여장 작업 실적 처리

            IF LV_BAPI_FLAG = 'A' OR " A  양품 실적 처리가 성공이면 수행
               LV_BAPI_FLAG = 'B' OR " B  수리 실적 처리가 성공이면 수행
               LV_BAPI_FLAG = 'C' OR " C  준비교체(예압) 실적가 성공이면 수행
               LV_BAPI_FLAG = 'D' OR " D  Start 여장 작업 실적 처리가 성공이면 수행
               LV_BAPI_FLAG = 'N'.   " 양품/수리/준비교체(예압) /Start 여장 작업실적
              " 실적 처리 대상이 없는 경우

              IF GS_CON-EMNGA IS NOT INITIAL OR  " End 여장 작업  실적 처리대상이 있는경우
                 GS_CON-ISM10 IS NOT INITIAL.
                CLEAR : LV_LOCK_CHK_FLAG.
                PERFORM CHECK_PRODORDCONF_CREATE_LOCK
                  USING GS_CON-AUFNR
                        LV_LOCK_CHK_FLAG
                        LV_TIMESTAMP
                        I_SYSTEM_ID
                        I_MODE
                        .
                IF LV_LOCK_CHK_FLAG = 'S'.
                  PERFORM CALL_BAPI_CASE_E TABLES LT_GOODSMOVEMENTS
                                            USING LV_MESSAGE
                                                  LV_ERROR
                                                  LV_EXTID
                                                  'E'
                                                  LV_TIMESTAMP
                                                  I_SYSTEM_ID
                                                  I_MODE
                                                  LV_AUART
                                            CHANGING LV_BAPI_FLAG.

                  IF LV_BAPI_FLAG = 'X'.
                    CLEAR GS_CON.
                    EXIT.
                  ENDIF.
                ELSE.
                  LV_BAPI_FLAG = 'X'.
                  CLEAR GS_CON.
                  EXIT.
                ENDIF.
              ELSE. " End 여장 작업 실적  대상이 없는경우
                IF LV_BAPI_FLAG = 'A'
                   OR LV_BAPI_FLAG = 'B'
                   OR LV_BAPI_FLAG = 'C'
                   OR LV_BAPI_FLAG = 'D'
                   OR LV_BAPI_FLAG = 'E'
                   .
                ELSE.
                  LV_BAPI_FLAG = 'N'.
                ENDIF.             .
              ENDIF.

            ENDIF.

        ENDCASE.

        LV_IDX = LV_IDX + 1.

      ENDDO.

      IF LV_BAPI_FLAG = 'A' OR " A  양품 실적 처리가 성공이면 수행
         LV_BAPI_FLAG = 'B' OR " B  수리 실적 처리가 성공이면 수행
         LV_BAPI_FLAG = 'C' OR " C  준비교체(예압) 실적가 성공이면 수행
         LV_BAPI_FLAG = 'D' OR " D  Start 여장 작업 실적 처리가 성공이면 수행
         LV_BAPI_FLAG = 'E'. " E  End 여장 작업 실적 처리
        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
          EXPORTING
            WAIT = 'X'.
**- 생산오더 전송 프로그램 호출(zgtppi2010)
*        PERFORM call_transaction_zgtppi2010 USING gs_con-werks
*                                                  gs_con-aufnr.
      ELSEIF LV_BAPI_FLAG = 'X'.
        CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

*- 확정 외부 ID KEY 생성
        CLEAR : LV_EXTID.
        LV_EXTID = GS_CON-RU_EXTID.
        LOOP AT   GT_GR_RESULT_C INTO  GS_GR_RESULT_C .

          PERFORM BAPI_PRODORDCONF_CANCEL TABLES LT_RETURN
                                          USING GS_GR_RESULT_C-RUECK
                                                GS_GR_RESULT_C-RMZHL
                                                LV_BUDAT
                                                LV_RUECK
                                                LV_RMZHL
                                                LV_CANCEL_FLAG.
          IF LV_CANCEL_FLAG = 'E'.

*              CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

*              READ TABLE lt_return INTO DATA(ls_return)  WITH KEY type = 'E'.
*              IF sy-subrc = 0.
            IF LV_RUECK IS INITIAL.
              PERFORM RETURN_MESSAGE_CON_C  USING 'E'
*                                                  ls_return-message
                                               TEXT-M04
                                                '  '
                                                '  '
                                                LV_EXTID.
              PERFORM SAVE_LOG_CON_CANCEL  USING 'E'
*                                            ls_return-message
                                          TEXT-M04
                                          '  '
                                          '  '
                                          LV_EXTID
                                          LV_TIMESTAMP
                                          I_SYSTEM_ID
                                          I_MODE.
            ENDIF.
            EXIT.
          ENDIF.

        ENDLOOP.

      ELSEIF LV_BAPI_FLAG = 'N'." 양품/수리/준비교체(예압) /Start 여장 작업없음
        PERFORM RETURN_MESSAGE_CON  USING 'E'
                                        '실적 처리할 데이터가 없습니다.'
                                        '  '
                                        '  '
                                        LV_EXTID.
        PERFORM SAVE_LOG_CON  USING 'E'
                           '실적 처리할 데이터가 없습니다.'
                           '  '
                           '  '
                           LV_EXTID
                           LV_TIMESTAMP
                           I_SYSTEM_ID
                           I_MODE.
      ENDIF.

      CLEAR GS_CON.

    ENDLOOP.

*- 실적 취소-------------------------------------------------------*
  ELSEIF I_MODE = 'C'.

    CLEAR : LV_EXTID .

    LOOP AT GT_CON INTO GS_CON.
      CLEAR : LV_ERROR, LV_TIMESTAMP.

      GET TIME STAMP FIELD LV_TIMESTAMP.


*- 확정 외부 ID KEY 생성
      CLEAR : LV_EXTID.
      LV_EXTID = GS_CON-RU_EXTID.

*- Conversion_Input
      PERFORM CONVERSION_INPUT_CON.

*- 공통 체크 항목
      PERFORM CHECK_COMMON_CON  USING LV_ERROR.

***      " 공통적인 사항으로 이전부터 오더에 최종 확정 상태가 지정되어 있는지 확인
***      PERFORM check_common_order_state USING lv_fin_conf
***                                             lv_clear_res
***                                             'A'.

      IF LV_ERROR = 'X'.
        LV_MESSAGE = VALUE #( GT_GR_RESULT[ ZSERNO = GS_CON-ZSERNO ]-ZERP_MESSAGE OPTIONAL ).
        PERFORM SAVE_LOG_CON_CANCEL  USING 'E'
                                          LV_MESSAGE
                                          ''
                                          ''
                                          LV_EXTID
                                          LV_TIMESTAMP
                                          I_SYSTEM_ID
                                          I_MODE.
        CLEAR GS_CON.
        CONTINUE.
      ENDIF.

*- 실적 취소 체크 항목
      CLEAR : GT_AFRU[] , GT_AFRU.
      PERFORM CHECK_CANCEL_CON USING LV_ERROR
                                     LV_EXTID.

      IF LV_ERROR = 'X'.
        LV_MESSAGE = VALUE #( GT_GR_RESULT[ ZSERNO = GS_CON-ZSERNO ]-ZERP_MESSAGE OPTIONAL ).

        PERFORM SAVE_LOG_CON_CANCEL  USING 'E'
                                          LV_MESSAGE
                                          ''
                                          ''
                                          LV_EXTID
                                          LV_TIMESTAMP
                                          I_SYSTEM_ID
                                          I_MODE.
        CLEAR GS_CON.
        CONTINUE.
      ENDIF.

***      CLEAR : gt_afru[] , gt_afru.
***      PERFORM get_cancel_data USING gs_con-ru_extid
***                                    gs_con-aufnr.
*- 실적 취소
      CLEAR : LV_CANCEL_FLAG, LV_LOCK_CHK_FLAG.
      LOOP AT  GT_AFRU.
        PERFORM CHECK_PRODORDCONF_CREATE_LOCK USING  GS_CON-AUFNR
                                                   LV_LOCK_CHK_FLAG
                                                   LV_TIMESTAMP
                                                   I_SYSTEM_ID
                                                   I_MODE
                                                   .
        IF LV_LOCK_CHK_FLAG = 'S'.

          PERFORM BAPI_PRODORDCONF_CANCEL TABLES LT_RETURN
                                          USING GT_AFRU-RUECK
                                                GT_AFRU-RMZHL
                                                GT_AFRU-BUDAT
                                                LV_RUECK
                                                LV_RMZHL
                                                LV_CANCEL_FLAG.
          IF LV_CANCEL_FLAG = 'E'.

*            CALL FUNCTION 'BAPI_TRANSACTION_ROLLBACK'.

*            READ TABLE lt_return INTO DATA(ls_return)  WITH KEY type = 'E'.
*            IF sy-subrc = 0.
            IF LV_RUECK IS INITIAL.
              PERFORM RETURN_MESSAGE_CON  USING 'E'
*                                                ls_return-message
                                               TEXT-M04
                                                '  '
                                                '  '
                                                LV_EXTID.
              PERFORM SAVE_LOG_CON_CANCEL  USING 'E'
*                                          ls_return-message
                                          TEXT-M04
                                          '  '
                                          '  '
                                          LV_EXTID
                                          LV_TIMESTAMP
                                          I_SYSTEM_ID
                                          I_MODE.
            ENDIF.
            EXIT.
          ENDIF.

        ELSE.

          CONCATENATE '오더번호('
                      SY-MSGV1
                      ')이 처리중입니다'
                 INTO LV_MESSAGE .
          PERFORM SAVE_LOG_CON  USING 'E'
                                      LV_MESSAGE
                                      ''
                                      ''
                                      LV_EXTID
                                      LV_TIMESTAMP
                                      I_SYSTEM_ID
                                      I_MODE.
          LV_BAPI_FLAG = 'X'.

        ENDIF.

      ENDLOOP.


*     *- 성공
      IF LV_CANCEL_FLAG = 'S'.
*        CALL FUNCTION 'BAPI_TRANSACTION_COMMIT'
*          EXPORTING
*            wait = 'X'.
        LV_CANCEL_MSG = TEXT-M05."|성공|. "BAPI 메시지가 필요

        PERFORM RETURN_MESSAGE_CON  USING 'S'
                                          LV_CANCEL_MSG
                                          LV_RUECK
                                          LV_RMZHL
                                          LV_EXTID.

        PERFORM SAVE_LOG_CON_CANCEL  USING 'S'
                                    LV_CANCEL_MSG
                                    LV_RUECK
                                    LV_RMZHL
                                    LV_EXTID
                                    LV_TIMESTAMP
                                    I_SYSTEM_ID
                                    I_MODE.
*        LOOP AT  gt_afru.
**     - 생산오더 전송 프로그램 호출(zgtppi2010)
*          PERFORM call_transaction_zgtppi2010_C
*            USING gt_afru-werks
*                  gt_afru-aufnr.
*        ENDLOOP.

      ENDIF.

      CLEAR GS_CON.

    ENDLOOP.

  ENDIF.

  MODIFY ZGTPPT3080 FROM TABLE GT_ZGTPPT3080.
  IF SY-SUBRC = 0.
    COMMIT WORK.
  ENDIF.

*- RFC 펑션 결과 리턴
  PERFORM CONVERSION_OUTPUT_GT_GR_RESULT.

  PERFORM RESULT_GR_DATA USING ZO_RESULT
                               ZO_MESSAGE
                               LV_BAPI_FLAG.

  OT_RESULT[] = GT_GR_RESULT[].

ENDFUNCTION.
