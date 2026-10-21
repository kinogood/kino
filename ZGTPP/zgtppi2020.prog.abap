*&---------------------------------------------------------------------*
*& Report ZGTPPI2020
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
REPORT zgtppi2020 MESSAGE-ID zgtpp00 LINE-SIZE 120.

INCLUDE zgtppi2020top.
INCLUDE zgtppi2020s01.
INCLUDE zgtppi2020c01.
INCLUDE zgtppi2020o01.
INCLUDE zgtppi2020i01.
INCLUDE zgtppi2020f01.

AT SELECTION-SCREEN OUTPUT.
  PERFORM get_parameter_description.
  PERFORM modify_first_screen.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR pa_fld01.
  PERFORM get_system_list USING 'PA_FLD01'.

AT SELECTION-SCREEN ON VALUE-REQUEST FOR pa_fld02.
  PERFORM get_system_list USING 'PA_FLD02'.

START-OF-SELECTION.
  PERFORM get_proc.

  IF pa_batch EQ abap_true AND ra_send EQ abap_true .
    CHECK gt_disp[] IS NOT INITIAL. " 전송 대상이 없으면 전송없이 종료처리 20250221
    PERFORM send_data.
  ELSE.
    CALL SCREEN 0100.
  ENDIF.
