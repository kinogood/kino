FUNCTION z_ti_cost_document_type_popup.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  EXPORTING
*"     VALUE(P_ANSWER) TYPE  C
*"     VALUE(P_MONSC) TYPE  ZTIMONSC
*"----------------------------------------------------------------------

  CLEAR : g_answer, ok_code.

  ztisscrcom-monsc = 'I'.

  CALL SCREEN 0500 STARTING AT 001 001.
*                   ENDING   AT 100 010.

  p_answer = g_answer.
  p_monsc  = ztisscrcom-monsc.

ENDFUNCTION.
