FUNCTION z_ti_for_append_gr_document.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     REFERENCE(XZTITRQK) LIKE  ZTITRQK STRUCTURE  ZTITRQK OPTIONAL
*"     REFERENCE(XZTITRQS) LIKE  ZTITRQS STRUCTURE  ZTITRQS OPTIONAL
*"  EXPORTING
*"     REFERENCE(R_UCOMM) LIKE  SYST-UCOMM
*"  TABLES
*"      IT_TAB STRUCTURE  ZTISRQIT
*"      RKWA_KEY STRUCTURE  RKWA_KEY
*"----------------------------------------------------------------------

  it_rkwa_key[] = rkwa_key[].
  it_reqit[]    = it_tab[].
  ztitrqk       = xztitrqk.
  ztitrqs       = xztitrqs.

  CALL SCREEN 0210 STARTING AT 01 01
                    ENDING  AT 20 15 .

  IF ok_code EQ 'FCOPY'.
    it_tab[]    = it_reqit[].
  ENDIF.

  r_ucomm = ok_code.

ENDFUNCTION.
