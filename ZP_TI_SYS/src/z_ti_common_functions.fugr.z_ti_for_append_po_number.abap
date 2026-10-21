FUNCTION z_ti_for_append_po_number.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     REFERENCE(XZTITRQK) LIKE  ZTITRQK STRUCTURE  ZTITRQK OPTIONAL
*"     REFERENCE(XZTITRQS) LIKE  ZTITRQS STRUCTURE  ZTITRQS OPTIONAL
*"  EXPORTING
*"     REFERENCE(R_UCOMM) LIKE  SYST-UCOMM
*"  TABLES
*"      ZTISPOKEY STRUCTURE  ZTISPOKEY
*"      IT_TAB STRUCTURE  ZTISRQIT
*"----------------------------------------------------------------------

  it_pokey[] = ztispokey[].
  it_reqit[] = it_tab[].
  ztitrqk    = xztitrqk.
  ztitrqs    = xztitrqs.

  CALL SCREEN 0200 STARTING AT 01 01
                    ENDING  AT 20 15 .

  IF ok_code EQ 'FCOPY'.
    it_tab[]    = it_reqit[].
  ENDIF.

  r_ucomm = ok_code.

ENDFUNCTION.
