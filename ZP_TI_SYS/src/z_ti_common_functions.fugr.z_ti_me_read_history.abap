FUNCTION z_ti_me_read_history.
*"----------------------------------------------------------------------
*"*"Global interface:
*"  IMPORTING
*"     VALUE(EBELN) LIKE  EKKO-EBELN
*"     VALUE(EBELP) LIKE  EKPO-EBELP DEFAULT 00000
*"     VALUE(WEBRE) LIKE  EKPO-WEBRE
*"     VALUE(I_BYPASSING_BUFFER) TYPE  C OPTIONAL
*"     VALUE(I_REFRESH_BUFFER) TYPE  C OPTIONAL
*"  TABLES
*"      XEKBE STRUCTURE  EKBE OPTIONAL
*"      XEKBES STRUCTURE  EKBES OPTIONAL
*"      XEKBEZ STRUCTURE  EKBEZ OPTIONAL
*"      XEKBNK STRUCTURE  EKBNK OPTIONAL
*"      XEKBZ STRUCTURE  EKBZ OPTIONAL
*"      BUDAT STRUCTURE  RSRANGE OPTIONAL
*"----------------------------------------------------------------------
*PERFORM MLCUR_AUSSCHALTEN.
  CLEAR gd_mlwere-aktiv.

  ekko-ebeln = ebeln.
  REFRESH: bet, bets, betz, bzt, betb.
  CLEAR su_waers.
  REFRESH: r_budat.
  CLEAR: r_budat.
  LOOP AT budat.
    MOVE-CORRESPONDING budat TO r_budat.
    APPEND r_budat.
  ENDLOOP.
*PERFORM BET_FUELLEN.
  PERFORM bet_fuellen USING i_bypassing_buffer
                            i_refresh_buffer.
*PERFORM BETB_FUELLEN.
  PERFORM betb_fuellen
                      USING i_bypassing_buffer
                            i_refresh_buffer.
  PERFORM schnittstelle.

ENDFUNCTION.
