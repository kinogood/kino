FUNCTION z_ti_others_text_import.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     REFERENCE(LCITY) TYPE  ZTILCITY
*"     REFERENCE(MODE)
*"  TABLES
*"      IT_TAB STRUCTURE  ZTISLC02
*"----------------------------------------------------------------------
  DATA: l_count  TYPE i.

*> Delete
  DELETE it_tab WHERE lcity EQ lcity.

*>
  CLEAR: l_count.
  LOOP AT g_tc_0300_itab  INTO g_tc_0300_wa.
*                         where lcity eq lcity.
    ADD 1 TO l_count.
    MOVE-CORRESPONDING g_tc_0300_wa  TO it_tab.
    MOVE: lcity                      TO it_tab-lcity,
          l_count                    TO it_tab-qitno.
    APPEND it_tab.
  ENDLOOP.

  REFRESH g_tc_0300_itab.

ENDFUNCTION.
