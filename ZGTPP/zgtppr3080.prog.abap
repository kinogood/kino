*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPPR3080
*& 프로그램 명 : [GT]I/F 공통 수신 모니터링
*& 개요   :
*& 생성일 : 2025.01.15.
*& 생성자 : 신영철
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
REPORT zgtppr3080           MESSAGE-ID zgtpp00.

*-----------------------------------------------------------------------
*-- Include
*-----------------------------------------------------------------------
INCLUDE : zgtppr3080top,              " TOP Include
          zgtppr3080s01,              " Selection-Screen Include
          zgtppr3080c01,              " Class ALV Include
          zgtppr3080o01,              " PBO Include
          zgtppr3080i01,              " PAI Include
          zgtppr3080f01.              " Form Include

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
*-- At Selection-Screen On Value-Request for Field
*-----------------------------------------------------------------------
AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_sysid.
*-- 수신 시스템 Search Help 정보 구성
  PERFORM set_f4_sysid.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR p_if_no.
*-- Process(I/F No) Search Help 정보 구성
  PERFORM set_f4_if_no.

*-----------------------------------------------------------------------
*-- At Selection-Screen
*-----------------------------------------------------------------------
AT SELECTION-SCREEN.
  CASE sscrfields-ucomm.
    WHEN 'FC01'.            " I/F List 조회 수행
      PERFORM submit_prg_if_list.

    WHEN 'ONLI'.            " 조회 수행

  ENDCASE.

*-----------------------------------------------------------------------
*-- At Selection-Screen On Field
*-----------------------------------------------------------------------
AT SELECTION-SCREEN ON p_sysid.
*-- 수신 시스템 조회 조건 필수값 확인
  PERFORM chk_req_value_for_sysid   USING    p_sysid.

AT SELECTION-SCREEN ON p_if_no.
*-- I/F No. 조회 조건 필수값 확인
  PERFORM chk_req_value_for_if_no   USING    p_if_no.

AT SELECTION-SCREEN ON s_ifdat.
*-- 수신일자 조회조건 필수값 확인
  PERFORM chk_req_value_for_ifdat   USING    s_ifdat[].

*-----------------------------------------------------------------------
*-- Start-Of-Selection
*-----------------------------------------------------------------------
START-OF-SELECTION.

  PERFORM select_main_data          CHANGING gv_eflg.

*-----------------------------------------------------------------------
*-- End-Of-Selection
*-----------------------------------------------------------------------
END-OF-SELECTION.

  CHECK gv_eflg NE abap_true.

  CALL SCREEN 0100.
