FUNCTION ZGTPP_IF_I_BD_PROD_GI.
*"--------------------------------------------------------------------
*"*"로컬인터페이스:
*"  IMPORTING
*"     VALUE(I_MODE) TYPE  CHAR02
*"     VALUE(I_SYSTEM_ID) TYPE  CHAR04
*"  EXPORTING
*"     VALUE(ZO_RESULT) TYPE  ZO_RESULT
*"     VALUE(ZO_MESSAGE) TYPE  ZO_MESSAGE
*"  TABLES
*"      IT_ISSUE STRUCTURE  ZGTPPSIF0017
*"      OT_RESULT STRUCTURE  ZGTPPSIF0016
*"--------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPP_IF_I_CABLE_PROD_GI
*& 프로그램 명 : [GT] [Cable MES] 생산오더 출고처리
*& 개요   :
*& 생성일 : 2024.11.26
*& 생성자 : ZGSIDEV06
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : 지중/부스닥트 MES
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  :
*& 수정자  :
*& 수정개요 :
*&---------------------------------------------------------------------*
  DATA : lt_issue TYPE TABLE OF zgtppsif0017.
  DATA : lv_error.

  CLEAR : gt_issue, lt_issue, lv_error, ot_result, ot_result[], gs_gi_keys, gt_gi_keys,
               gt_gi_result[], gs_batch, gt_batch, gv_suc.

  lt_issue[] = it_issue[].
  gt_issue = CORRESPONDING #( lt_issue ).

  IF it_issue[] IS NOT INITIAL.
*- 자재 투입 : P. 자재 투입 재처리 : R. 자재 투입 취소 : C
    IF i_mode = 'P' OR i_mode = 'R'.

      LOOP AT gt_issue INTO DATA(ls_issue).

        CLEAR lv_error.
        ls_issue-i_mode = i_mode.
*- Conversion_Input
        PERFORM conversion_input USING ls_issue i_mode.
*- 수신데이터 정합성 체크
* 공통 체크 항목
        PERFORM check_common_issue_bd USING ls_issue lv_error i_mode.
        IF lv_error = 'X'.
          IF i_mode = 'P'.
            PERFORM save_log_zgtppt3070 USING ls_issue i_system_id i_mode.
          ELSEIF i_mode = 'R'.
            PERFORM save_log_zgtppt3070 USING ls_issue i_system_id i_mode.
            PERFORM save_log_zgtppt3100 USING ls_issue i_system_id i_mode.
          ENDIF.
          CONTINUE.
        ENDIF.
* 자재 투입 체크 항목
        IF i_mode = 'P' OR i_mode = 'R'.
          PERFORM check_input_issue_bd USING ls_issue lv_error i_mode.
          IF lv_error = 'X'.
            IF i_mode = 'P'.
              PERFORM save_log_zgtppt3070 USING ls_issue i_system_id i_mode.
            ELSEIF i_mode = 'R'.
              PERFORM save_log_zgtppt3070 USING ls_issue i_system_id i_mode.
              PERFORM save_log_zgtppt3100 USING ls_issue i_system_id i_mode.
            ENDIF.
            CONTINUE.
          ENDIF.
*- 투입 처리
          PERFORM bapi_goodsmvt_create USING ls_issue i_system_id i_mode.
        ENDIF.

      ENDLOOP.
*- 자재 투입 취소 : C. 자재 투입 재처리 취소 : RC
    ELSEIF i_mode = 'C' or i_mode = 'RC'.

      LOOP AT gt_issue INTO ls_issue.

        CLEAR lv_error.
        ls_issue-i_mode = i_mode.
*- Conversion_Input
        PERFORM conversion_input USING ls_issue i_mode.
*- 수신데이터 정합성 체크
* 공통 체크 항목
        PERFORM check_common_issue  USING ls_issue lv_error i_mode.
        IF lv_error = 'X'.
          PERFORM save_log_zgtppt3070 USING ls_issue i_system_id i_mode.
          CONTINUE.
        ENDIF.
*- 투입 취소 체크 항목
        PERFORM check_cancel_issue USING ls_issue lv_error.
        IF lv_error = 'X'.
          PERFORM save_log_zgtppt3070 USING ls_issue i_system_id i_mode.
          CONTINUE.
        ENDIF.
*- 투입 취소 처리
        PERFORM bapi_goodsmvt_cancel USING ls_issue i_system_id i_mode.

      ENDLOOP.

    ENDIF.
*- RFC 펑션 결과 리턴
    PERFORM conversion_output_gt_gi_result.

    PERFORM result_gi_data USING zo_result zo_message.

    ot_result[] = gt_gi_result[].
*- ZO_RESULT, ZO_MESSAGE 업데이트
    IF gt_gi_keys[] IS NOT INITIAL.

      LOOP AT gt_gi_keys INTO gs_gi_keys.

        UPDATE zgtppt3070 SET zstat           = zo_result
                                              zmessage  = zo_message
                                  WHERE zifkey          = gs_gi_keys-zifkey
                                       AND zsystem_id = gs_gi_keys-zsystem_id
                                       AND zserno        = gs_gi_keys-zserno
                                       AND werks          = gs_gi_keys-werks
                                       AND rsnum         = gs_gi_keys-rsnum
                                       AND rspos         = gs_gi_keys-rspos.

      ENDLOOP.

      COMMIT WORK.

    ENDIF.

  ENDIF.

ENDFUNCTION.
