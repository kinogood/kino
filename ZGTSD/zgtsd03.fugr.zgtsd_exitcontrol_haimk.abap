FUNCTION ZGTSD_EXITCONTROL_HAIMK.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_VKORG) TYPE  VKORG OPTIONAL
*"     VALUE(I_WERKS) TYPE  WERKS_D OPTIONAL
*"  EXPORTING
*"     VALUE(E_EXCETP) TYPE  CHAR01
*"----------------------------------------------------------------------
*&---------------------------------------------------------------------*
*& 모듈        : SD
*& 프로그램 ID : ZGTSD_EXITCONTROL_HAIMK
*& 프로그램 명 : [SD_GT] HAIMK 대상 User Exit 적용 여부 확인
*& 개요   :
*& 생성일 : 2025.02.24
*& 생성자 : ZGSIDEV05
*&---------------------------------------------------------------------*
*& 외부 호출 프로그램 개요   : N/A
*& 타 시스템 인터페이스 개요 : SAP
*&---------------------------------------------------------------------*
*& 프로그램 수정이력
*&---------------------------------------------------------------------*
*& 수정일  :
*& 수정자  :
*& 수정개요 :
*&---------------------------------------------------------------------*
*-----------------------------------------------------------------------
*-- 1. 로컬 변수 선언
*-----------------------------------------------------------------------
  CONSTANTS : lc_sd   TYPE zgtemodule_kind VALUE 'SD',
              lc_9999 TYPE zgtecodegrp     VALUE '9999',
              lc_1    TYPE zgte_fldval     VALUE '1'.

  CLEAR : e_excetp.
*-----------------------------------------------------------------------
*-- 2. User Exit 수행 여부 공통 코드 정보 기준 확인
*-----------------------------------------------------------------------

*-- 공통 코드 정보 기준 User Exit 수행 여부 정보 Select
  SELECT SINGLE @abap_true
    FROM zgtppt1010 AS a

   WHERE a~module_kind EQ @lc_sd
     AND a~codegrp     EQ @lc_9999
     AND a~fld_05      EQ @lc_1

     AND ( a~fld_01 EQ @i_vkorg OR
           a~fld_03 EQ @i_werks )

    INTO @DATA(lv_flag).

*-- User Exit 수행여부 정보 Export
  e_excetp = COND #( WHEN sy-subrc EQ 0 THEN |Y|
                     ELSE |N|
                   ).
ENDFUNCTION.
