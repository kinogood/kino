FUNCTION z_ti_get_vendor_by_send.
*"----------------------------------------------------------------------
*"*"Global interface:
*"  EXPORTING
*"     REFERENCE(ANSWER) TYPE  C
*"  TABLES
*"      XPRTCTL STRUCTURE  ZTISPRTCTL
*"----------------------------------------------------------------------

  CLEAR : answer, ok_code.

  CALL SCREEN 0100 STARTING AT 001 001.
*                   ENDING   AT 100 010.

ENDFUNCTION.
