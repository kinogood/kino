FUNCTION zgtpp_if_i_cable_no_oper.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_MODE) TYPE  CHAR02
*"     VALUE(I_SYSTEM_ID) TYPE  CHAR04
*"  EXPORTING
*"     VALUE(ZO_RESULT) TYPE  ZO_RESULT
*"     VALUE(ZO_MESSAGE) TYPE  ZO_MESSAGE
*"  TABLES
*"      IT_OPER STRUCTURE  ZGTPPSIF0024
*"      OT_RESULT STRUCTURE  ZGTPPSIF0025
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPP_IF_I_CABLE_NO_OPER
*& 프로그램 명 : [GT] [Cable MES] 비가동 실적처리
*& 개요   :
*& 생성일 : 2024.12.02
*& 생성자 : ZGSIDEV08
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : 지중/부스닥트 MES
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 2026.02.09.  zlsgpp5.  CHM2602-00176 SCR Crop Bar 등록.
*&---------------------------------------------------------------------*
  DATA: lt_oper TYPE TABLE OF zgtppsif0024.
  DATA: lv_error.
  DATA: lv_message(220).

  CLEAR: lt_oper, lv_error, gs_oper, gt_oper, gt_oper_result[],
         ot_result, ot_result[], gs_oper_keys, gt_oper_keys,
         gs_qrcod, gt_qrcod.

  lt_oper[] = it_oper[].
  gt_oper = CORRESPONDING #( lt_oper ).

*----------------------------------------------------------------------*
*- 비가동 처리
*----------------------------------------------------------------------*
  IF i_mode = 'P'.
*- 비가동 코드 추출
    PERFORM get_qrcod.

    LOOP AT gt_oper INTO gs_oper.
      CLEAR: lv_error.

*- Conversion input
      PERFORM conversion_input_oper USING gs_oper.

      gs_oper-i_mode = i_mode.
      gs_oper-zsystem_id = i_system_id.

*- 공통 체크 항목
      PERFORM check_common_oper USING i_mode lv_error.
      IF lv_error = gc_x.
        lv_message = VALUE #( gt_oper_result[ zserno = gs_oper-zserno ]-zerp_message OPTIONAL ).
        PERFORM save_log_zgtppt3120 USING gc_e lv_message.
        CLEAR gs_oper.
        CONTINUE.
      ENDIF.

*- 비가동 코드 체크
      PERFORM check_qrcod USING lv_error.
      IF lv_error = gc_x.
        lv_message = VALUE #( gt_oper_result[ zserno = gs_oper-zserno ]-zerp_message OPTIONAL ).
        PERFORM save_log_zgtppt3120 USING gc_e lv_message.
        CLEAR gs_oper.
        CONTINUE.
      ENDIF.

*- 비가동 번호 체크
      PERFORM check_brknr USING lv_error.
      IF lv_error = gc_x.
        lv_message = VALUE #( gt_oper_result[ zserno = gs_oper-zserno ]-zerp_message OPTIONAL ).
        PERFORM save_log_zgtppt3120 USING gc_e lv_message.
        CLEAR gs_oper.
        CONTINUE.
      ENDIF.

*- 비가동 처리
      PERFORM mes_non_opert USING i_mode.

      CLEAR: gs_oper.
    ENDLOOP.

*----------------------------------------------------------------------*
*- 비가동 취소
*----------------------------------------------------------------------*
  ELSEIF i_mode = 'C'.
    LOOP AT gt_oper INTO gs_oper.
      CLEAR: lv_error.

*- Conversion input
      PERFORM conversion_input_oper USING gs_oper.

      gs_oper-i_mode = i_mode.
      gs_oper-zsystem_id = i_system_id.
      gs_oper-zc_brknr = gs_oper-brknr.

*- 공통 체크 항목
      PERFORM check_common_oper USING i_mode lv_error.
      IF lv_error = gc_x.
        lv_message = VALUE #( gt_oper_result[ zserno = gs_oper-zserno ]-zerp_message OPTIONAL ).
        PERFORM save_log_zgtppt3120 USING gc_e lv_message.
        CLEAR gs_oper.
        CONTINUE.
      ENDIF.

*- 비가동 취소
      PERFORM mes_non_opert USING i_mode.

      CLEAR: gs_oper.
    ENDLOOP.

  ENDIF.

*----------------------------------------------------------------------*
*- RFC 펑션 결과 리턴
*----------------------------------------------------------------------*
  PERFORM conversion_output_oper.

  PERFORM result_oper_data USING zo_result
                                 zo_message.

  ot_result[] = gt_oper_result[].

*- ZO_RESULT, ZO_MESSAGE 업데이트
  IF gt_oper_keys[] IS NOT INITIAL.
    LOOP AT gt_oper_keys INTO gs_oper_keys.
      UPDATE zgtppt3120 SET zstat    = zo_result
                            zmessage = zo_message
                      WHERE zifkey     = gs_oper_keys-zifkey
                        AND zsystem_id = gs_oper_keys-zsystem_id
                        AND zserno     = gs_oper_keys-zserno
                        AND werks      = gs_oper_keys-werks
                        AND spgcd      = gs_oper_keys-spgcd
                        AND arbpl      = gs_oper_keys-arbpl.
    ENDLOOP.

    COMMIT WORK.
  ENDIF.

ENDFUNCTION.
