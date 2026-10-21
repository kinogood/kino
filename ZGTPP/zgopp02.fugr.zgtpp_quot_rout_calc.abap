FUNCTION zgtpp_quot_rout_calc.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     REFERENCE(I_ROUTING) TYPE  CHAR01
*"     REFERENCE(I_WERKS) TYPE  WERKS_D OPTIONAL
*"     REFERENCE(I_SPART) TYPE  SPART OPTIONAL
*"     REFERENCE(I_GONG_CD) TYPE  ZEGONG_CD OPTIONAL
*"  TABLES
*"      T_CHAR_DATA STRUCTURE  ZGTPPS1007 OPTIONAL
*"      T_WORK_DATA STRUCTURE  ZGTPPS1008 OPTIONAL
*"      T_ZPPT0030 STRUCTURE  ZGTPPS1009 OPTIONAL
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPP_QUOT_ROUT_CALC
*& 프로그램 명 : [GT] 견적원가용 라우팅 작업시간 계산
*& 개요   : 견적 진행 중인 특성 값을 사용하여 유사한 양산 자재를 찾아
*           라우팅 엑티비티를 리턴하는 Function.
*           리턴된 라우팅 엑티비티를 사용하여 후속 프로세스로
*           견적 가공비를 원가에서 계산함
*& 생성일 : 2026.02.05
*& 생성자 : ZGODEV06
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : N/A
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  :
*& 수정자  :
*& 수정개요 :
*&---------------------------------------------------------------------*

  IF i_routing IS INITIAL.
    PERFORM get_std_time_char_of_manuf_std USING i_werks i_spart i_gong_cd
                                                 t_zppt0030[].
  ELSE.
    PERFORM calc_quot_routing USING t_char_data[] t_work_data[].
  ENDIF.

ENDFUNCTION.
