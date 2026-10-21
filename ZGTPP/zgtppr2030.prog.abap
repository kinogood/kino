*&---------------------------------------------------------------------*
*& 모듈        : PP
*& 프로그램 ID : ZGTPPR2030
*& 프로그램 명 : [GT] 생산 오더 관리
*& 개요   : 기존 정상 생산 오더를 참고하여 재작업(탈피) 오더를 생성하고
*&            필요한 경우 관련된 재생산 오더를 생성 할 수 있는 프로그램
*& 생성일 : 2024.12.24
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
REPORT zgtppr2030 MESSAGE-ID zgtpp00.

INCLUDE zgtppr2030top.

INCLUDE zgtppr2030s01.

INCLUDE zgtppr2030c01.

INCLUDE zgtppr2030o01.

INCLUDE zgtppr2030i01.

INCLUDE zgtppr2030f01.

INITIALIZATION.

  CALL FUNCTION 'RP_LAST_DAY_OF_MONTHS'
    EXPORTING
      day_in            = sy-datum
    IMPORTING
      last_day_of_month = s_gstrp-high.
  s_gstrp-low = |{ sy-datum(6) }01 |.
  APPEND s_gstrp.

AT SELECTION-SCREEN.
  PERFORM authority_checking_proc.

AT SELECTION-SCREEN OUTPUT.

  PERFORM get_parameter_description.

  PERFORM modify_first_screen.

START-OF-SELECTION.

  PERFORM get_proc.

  IF gt_disp[] IS NOT INITIAL.

    CALL SCREEN 0100.

  ELSE.

    MESSAGE s001.

  ENDIF.
