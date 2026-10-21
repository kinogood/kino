FUNCTION Z_TI_INT_NUMBER_PER_MILLION.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     REFERENCE(W_WAERS) TYPE  WAERS OPTIONAL
*"     REFERENCE(W_OPAMT) TYPE  ZTIOPAMT OPTIONAL
*"  EXPORTING
*"     REFERENCE(W_INT) TYPE  I
*"----------------------------------------------------------------------

*    TABLES : bapicurx.

    CLEAR bapicurx.

    CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_EXTERN_9'
      EXPORTING
        currency        = W_WAERS
        amount_internal = W_opamt
      IMPORTING
        amount_external = bapicurx-bapicurx.

       bapicurx-bapicurx = ( bapicurx-bapicurx / 1000000 ).

       W_INT = bapicurx-bapicurx.


*    CALL FUNCTION 'BAPI_CURRENCY_CONV_TO_INTERN_9'
*      EXPORTING
*        currency             = 'KRW'
*        amount_external      = bapicurx-bapicurx
*        max_number_of_digits = 18
*      IMPORTING
*        amount_internal      = zmitrqst-usamt.

ENDFUNCTION.
