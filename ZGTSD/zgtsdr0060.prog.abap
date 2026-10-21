*&---------------------------------------------------------------------*
*& 모듈        : SD
*& 프로그램 ID : ZGTSDR0060
*& 프로그램 명 : 시작업생산요청 생성
*& 개요   :
*& 생성일 : 2025.03.24
*& 생성자 : ZGSISD04
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : N/A
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  :
*& 수정자  :
*& 수정개요:
*&---------------------------------------------------------------------*
REPORT zgtsdr0060           MESSAGE-ID zgtsd01.

*-----------------------------------------------------------------------
*-- Include
*-----------------------------------------------------------------------
INCLUDE : zgtsdr0060top,              " TOP Include
          zgtsdr0060s01,              " Selection-Screen Include
          zgtsdr0060c01,              " Class ALV Include
          zgtsdr0060o01,              " PBO Include
          zgtsdr0060i01,              " PAI Include
          zgtsdr0060f01.              " Form Include

*-----------------------------------------------------------------------
*-- Initialization.
*-----------------------------------------------------------------------
INITIALIZATION.
  PERFORM set_initialization.

*-----------------------------------------------------------------------
*-- At Selection-Screen Output
*-----------------------------------------------------------------------
AT SELECTION-SCREEN OUTPUT.
  PERFORM screen_output_1000.

*-----------------------------------------------------------------------
*-- At Selection-Screen On Field
*-----------------------------------------------------------------------
AT SELECTION-SCREEN ON p_vkorg.
*-- 영업조직 필수값 체크
  PERFORM chk_req_value_for_vkorg   USING    p_vkorg.

*AT SELECTION-SCREEN ON p_zpjno.
**-- 프로젝트 필수값
*  PERFORM chk_req_value_for_zpjno   USING    p_zpjno.

AT SELECTION-SCREEN ON s_erdt1.
*-- 시작업제번 생성일 필수값 체크
  PERFORM chk_req_value_for_erdt1   USING    s_erdt1[].

AT SELECTION-SCREEN ON s_erdt2.
*-- 시작업요청 생성일 필수값 체크
  PERFORM chk_req_value_for_erdt2   USING    s_erdt2[].

AT SELECTION-SCREEN.
  PERFORM chk_value_for_pjno.

*-----------------------------------------------------------------------
*-- Start-Of-Selection
*-----------------------------------------------------------------------
START-OF-SELECTION.

  PERFORM select_data.

*-----------------------------------------------------------------------
*-- End-Of-Selection
*-----------------------------------------------------------------------
END-OF-SELECTION.

  IF gt_head[] IS INITIAL.
    MESSAGE s010 DISPLAY LIKE 'E'.
    EXIT.
  ENDIF.

  IF p_crte  EQ abap_true AND
     p_batch EQ abap_true.
*-- Batch Job 수행
    PERFORM run_batch_job.

  ELSE.
    CALL SCREEN 0100.
  ENDIF.
