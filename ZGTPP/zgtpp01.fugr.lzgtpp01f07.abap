*----------------------------------------------------------------------*
***INCLUDE LZGTPP01F07.
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form conversion_exit_input
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM conversion_exit_input  USING  pv_routine pv_value.
  DATA lv_fname TYPE string.

  CHECK pv_value IS NOT INITIAL.

  lv_fname = |CONVERSION_EXIT_{ pv_routine }_INPUT|.

  CALL FUNCTION lv_fname
    EXPORTING
      input  = pv_value
    IMPORTING
      output = pv_value.

ENDFORM.
