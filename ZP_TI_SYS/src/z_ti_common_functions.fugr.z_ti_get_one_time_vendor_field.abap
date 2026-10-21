FUNCTION z_ti_get_one_time_vendor_field.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     VALUE(XZTITCSK) TYPE  ZTITCSK OPTIONAL
*"     VALUE(XLFA1) TYPE  LFA1 OPTIONAL
*"     VALUE(XMODE) TYPE  C OPTIONAL
*"  CHANGING
*"     VALUE(XZTITCSO) TYPE  ZTITCSO OPTIONAL
*"     VALUE(XOK_CODE) LIKE  SY-UCOMM OPTIONAL
*"----------------------------------------------------------------------

  CLEAR: ok-code, xok_code.

  MOVE xmode                   TO g_mode.

  MOVE-CORRESPONDING xztitcso TO g_ztitcso.
  IF xztitcso-country IS INITIAL.
    xztitcso-country = xlfa1-land1.
  ENDIF.

  ztitcso = xztitcso.

  CALL SCREEN 8000 STARTING AT 1   1.

  IF ok-code EQ 'ZTIOKAY'.
    ztitcso-acc_1_time = xztitcsk-xcpdk.
    MOVE-CORRESPONDING   ztitcso TO xztitcso.
  ELSE.
    MOVE-CORRESPONDING g_ztitcso TO xztitcso.
  ENDIF.

  xok_code = ok-code.

ENDFUNCTION.
