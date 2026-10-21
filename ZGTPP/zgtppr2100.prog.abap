*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPPR2100
*& 프로그램 명 : [GT] 월간계획(공정별생산계획조회)
*& 개요   : 월간 생산 계획 시뮬레이션 확정을 통해 수립된 공정별 생산
*&          계획을 조회하는 프로그램
*& 생성일 : 2025.05.15
*& 생성자 : ZGSIDEV06
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
REPORT zgtppr2100 MESSAGE-ID zgtpp00.

INCLUDE zgtppr2100top.

INCLUDE zgtppr2100s01.

INCLUDE zgtppr2100c01.

INCLUDE zgtppr2100i01.

INCLUDE zgtppr2100o01.

INCLUDE zgtppr2100f01.
*-----------------------------------------------------------------------
*-- Initialization.
*-----------------------------------------------------------------------
INITIALIZATION.

  s_spmon-low = sy-datum+0(6).
  gv_date_s = s_spmon-low && '01'.
  CALL FUNCTION 'RE_ADD_MONTH_TO_DATE'
    EXPORTING
      months  = '3'
      olddate = gv_date_s
    IMPORTING
      newdate = gv_date_e.
  s_spmon-high = gv_date_e+0(6).
  APPEND s_spmon.

*-----------------------------------------------------------------------
*-- At Selection-Screen Output
*-----------------------------------------------------------------------
AT SELECTION-SCREEN OUTPUT.

  PERFORM get_parameter_description.
  PERFORM modify_first_screen.

*-----------------------------------------------------------------------
*-- At Selection-Screen
*-----------------------------------------------------------------------
AT SELECTION-SCREEN.

*-----------------------------------------------------------------------
*-- START-OF-SELECTION
*-----------------------------------------------------------------------
START-OF-SELECTION.

  PERFORM authority_checking_proc.

  PERFORM get_data.

*-----------------------------------------------------------------------
*-- END-OF-SELECTION
*-----------------------------------------------------------------------
END-OF-SELECTION.

  CHECK gv_error IS INITIAL.

  IF <gt_main_disp_100> IS NOT INITIAL.
    CALL SCREEN 0100.
  ELSE.
    MESSAGE s001 DISPLAY LIKE 'E'.
  ENDIF.
