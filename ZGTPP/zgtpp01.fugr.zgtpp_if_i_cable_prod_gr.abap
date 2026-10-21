FUNCTION zgtpp_if_i_cable_prod_gr.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_MODE) TYPE  CHAR02
*"     VALUE(I_SYSTEM_ID) TYPE  CHAR04
*"  EXPORTING
*"     VALUE(ZO_RESULT) TYPE  ZO_RESULT
*"     VALUE(ZO_MESSAGE) TYPE  ZO_MESSAGE
*"  TABLES
*"      IT_GR STRUCTURE  ZGTPPSIF0022
*"      OT_RESULT STRUCTURE  ZGTPPSIF0023
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPP_IF_I_CABLE_PROD_GR
*& 프로그램 명 : [GT] [Cable MES] 생산오더 입고처리
*& 개요   :
*& 생성일 : 2024.11.29
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
  DATA : lt_tab TYPE TABLE OF zgtppsif0022.
  DATA : lv_error.
  DATA : lv_message(220).
  DATA: lv_dup_flag TYPE char1.                            "SRM2603-13959

  CLEAR : lt_tab, lv_error, gs_tab, gt_tab, gt_tab_result, ot_result, ot_result[].
  lt_tab[] = it_gr[].
  gt_tab = CORRESPONDING #( lt_tab ).
*- 입고
  IF i_mode = 'P'.

    LOOP AT gt_tab INTO gs_tab.

      CLEAR lv_error.
      gs_tab-i_mode = 'P'.
*- Conversion_Input
      PERFORM conversion_input_tab.

*SRM2603-13959 소재 MOM 중복 체크 추가
      PERFORM check_dup_gr_1 USING gs_tab
                                                        i_system_id
                                                        i_mode
                                                        lv_dup_flag.
      IF lv_dup_flag EQ 'X'.
        CONTINUE.
      ENDIF.
*SRM2603-13959

*- 공통 체크 항목
      PERFORM check_common_tab  USING lv_error.

      IF lv_error = 'X'.

        lv_message = VALUE #( gt_tab_result[ zserno = gs_tab-zserno ]-zerp_message OPTIONAL ).
        PERFORM save_log_zgtppt3110 USING 'E'
                                             lv_message
                                             ''
                                             ''
                                             i_system_id.
        CLEAR gs_tab.
        CONTINUE.

      ENDIF.
*- 입고처리
** 한미소 부산물 입고 로직 추가 260914
      IF gs_tab-bwart = '531'.
        PERFORM bapi_goodsmvt_create_tab_531 USING i_system_id.
      ELSE. "** 한미소 부산물 입고 로직 추가 260914
        PERFORM bapi_goodsmvt_create_tab USING i_system_id.
      ENDIF. "** 한미소 부산물 입고 로직 추가 260914

      CLEAR gs_tab.

    ENDLOOP.
*- 입고 취소
  ELSEIF i_mode = 'C'.

    LOOP AT gt_tab INTO gs_tab.

      CLEAR lv_error.
      gs_tab-i_mode = 'C'.
*- Conversion_Input
      PERFORM conversion_input_tab.

*SRM2603-13959 소재 MOM 중복 체크 추가
      PERFORM check_dup_gr_1 USING gs_tab
                                                        i_system_id
                                                        i_mode
                                                        lv_dup_flag.
      IF lv_dup_flag EQ 'X'.
        CONTINUE.
      ENDIF.
*SRM2603-13959
*- 공통 체크 항목
      PERFORM check_common_tab  USING lv_error.

      IF lv_error = 'X'.

        lv_message = VALUE #( gt_tab_result[ zserno = gs_tab-zserno ]-zerp_message OPTIONAL ).
        PERFORM save_log_zgtppt3110 USING 'E'
                                             lv_message
                                             ''
                                             ''
                                             i_system_id.
        CLEAR gs_tab.
        CONTINUE.

      ENDIF.
*- 입고 취소 처리
      PERFORM bapi_goodsmvt_cancel_tab USING i_system_id.

      CLEAR gs_tab.

    ENDLOOP.

  ENDIF.
*- RFC 펑션 결과 리턴
  PERFORM conversion_output_tab_result.

  PERFORM result_tab_data USING zo_result zo_message.

  ot_result[] = gt_tab_result[].
*- ZO_RESULT, ZO_MESSAGE 업데이트
  IF gt_gr_keys[] IS NOT INITIAL.

    LOOP AT gt_gr_keys INTO gs_gr_keys.

      UPDATE zgtppt3110 SET zstat           = zo_result
                                            zmessage  = zo_message
                                WHERE zifkey          = gs_gr_keys-zifkey
                                     AND zsystem_id = gs_gr_keys-zsystem_id
                                     AND zserno       = gs_gr_keys-zserno
                                     AND werks         = gs_gr_keys-werks
                                     AND aufnr          = gs_gr_keys-aufnr
                                     AND posnr         = gs_gr_keys-posnr.

    ENDLOOP.

    COMMIT WORK.

  ENDIF.

ENDFUNCTION.
