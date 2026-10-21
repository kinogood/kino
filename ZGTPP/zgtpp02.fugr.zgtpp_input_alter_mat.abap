FUNCTION zgtpp_input_alter_mat.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_WERKS) TYPE  WERKS_D OPTIONAL
*"  TABLES
*"      IT_MATNR STRUCTURE  ZGTPPS0001 OPTIONAL
*"----------------------------------------------------------------------

  gv_werks = i_werks.
  CALL SCREEN '0222' STARTING AT 2 2 ENDING AT 47 3.
  IF gt_matnr[] IS NOT INITIAL.
    it_matnr[] = gt_matnr[].
  ENDIF.

ENDFUNCTION.
