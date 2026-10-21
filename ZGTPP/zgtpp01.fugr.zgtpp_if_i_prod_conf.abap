FUNCTION zgtpp_if_i_prod_conf.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_MODE) TYPE  CHAR02
*"     VALUE(I_SYSTEM_ID) TYPE  CHAR04
*"  EXPORTING
*"     VALUE(ZO_RESULT) TYPE  ZO_RESULT
*"     VALUE(ZO_MESSAGE) TYPE  ZO_MESSAGE
*"  TABLES
*"      IT_CON STRUCTURE  ZGTPPSIF0020
*"      OT_RESULT STRUCTURE  ZGTPPSIF0021
*"----------------------------------------------------------------------
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

  DATA : lv_tagnr_chk(1).
  lv_tagnr_chk = 'N'.

* SYSTEM ID에 따라 처리 함수를 달리 호출
  IF i_system_id = 'KPCM' OR i_system_id = 'KSMM' OR "지중 MES
     i_system_id = 'KSCM' OR                   "소재 MOM SRM2510-04825
     i_system_id = 'KFCM'.                     "한미소 MOM 260902

    CALL FUNCTION 'ZGTPP_IF_I_CABLE_PROD_CONF'
      EXPORTING
        i_mode      = i_mode
        i_system_id = i_system_id
      IMPORTING
        zo_result   = zo_result
        zo_message  = zo_message
      TABLES
        it_con      = it_con
        ot_result   = ot_result.

  ELSEIF i_system_id = 'KBDM'. "부스닥트 MES
    LOOP AT it_con.
      IF it_con-tagnr IS INITIAL.
        lv_tagnr_chk  = 'Y'.
      ENDIF.
    ENDLOOP.

    IF i_mode = 'P' AND lv_tagnr_chk  = 'Y'.
      zo_result   = 'E'.
      zo_message  = TEXT-m26."라인번호 및 시리얼 번호는 필수 입력값입니다.
    ELSE.
      CALL FUNCTION 'ZGTPP_IF_I_BD_PROD_CONF'
        EXPORTING
          i_mode      = i_mode
          i_system_id = i_system_id
        IMPORTING
          zo_result   = zo_result
          zo_message  = zo_message
        TABLES
          it_con      = it_con
          ot_result   = ot_result.
    ENDIF.

  ELSEIF i_system_id = 'KGPM' OR   "// 가온전선 MES.
         i_system_id = 'KGOM'.

    CALL FUNCTION 'ZGTPP_IF_I_GAON_PROD_CONF'
      EXPORTING
        i_mode      = i_mode
        i_system_id = i_system_id
      IMPORTING
        zo_result   = zo_result
        zo_message  = zo_message
      TABLES
        it_con      = it_con
        ot_result   = ot_result.
  ENDIF.

ENDFUNCTION.
