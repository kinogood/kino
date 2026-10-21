FUNCTION z_ti_others_text_export.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     REFERENCE(LCITY) TYPE  ZTILCITY
*"     REFERENCE(START) TYPE  C OPTIONAL
*"     REFERENCE(MODE) TYPE  C
*"     REFERENCE(BUTTON) TYPE  C DEFAULT 'N'
*"  TABLES
*"      IT_TAB STRUCTURE  ZTISLC02
*"----------------------------------------------------------------------
  g_mode   = mode.
  g_lcity  = lcity.
  g_button = button.

  IF start EQ 'S'.
    it_ztitlc2[] = it_tab[].
  ENDIF.

  REFRESH: g_tc_0300_itab.
  LOOP AT it_tab WHERE lcity EQ lcity.
    CLEAR: g_tc_0300_wa.
    MOVE-CORRESPONDING it_tab TO g_tc_0300_wa.
    APPEND g_tc_0300_wa TO g_tc_0300_itab.
  ENDLOOP.

ENDFUNCTION.
