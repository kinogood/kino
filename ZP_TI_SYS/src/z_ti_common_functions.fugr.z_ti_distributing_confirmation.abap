FUNCTION Z_TI_DISTRIBUTING_CONFIRMATION.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     REFERENCE(IM_DEFAULT) TYPE  C DEFAULT '1'
*"  EXPORTING
*"     REFERENCE(EX_ANSWER) TYPE  C
*"----------------------------------------------------------------------

  CLEAR: ex_answer, g_answer.

  IF im_default EQ '1'.
    g_radio1  =  'X'.
    CLEAR: g_radio2.
  ELSE.
    g_radio2  =  'X'.
    CLEAR: g_radio1.
  ENDIF.

  CALL SCREEN 0700 STARTING AT 01 01.

  ex_answer = g_answer.




ENDFUNCTION.
