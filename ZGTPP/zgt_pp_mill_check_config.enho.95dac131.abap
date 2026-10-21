"Name: \TY:CL_COOCC_MILL_VP\IN:IF_EX_COOCC_MILL_VP\ME:MILL_CHECK_CONFIG_MTS\SE:END\EI
ENHANCEMENT 0 ZGT_PP_MILL_CHECK_CONFIG.
*
  "Production Order configuration Setting check
  data: lv_mtart type mtart.
  IF ls_caufvd-matnr IS NOT INITIAL.
    SELECT single mtart
      FROM mara
      INTO lv_mtart
     WHERE matnr = ls_caufvd-matnr.
  ENDIF.

  IF ls_caufvd-werks IS NOT INITIAL AND
     ( lv_mtart = 'MCFE' OR lv_mtart = 'MCHF' ).
    SELECT COUNT(*)
      FROM zgtppt1010
     WHERE module_kind = 'PP'
       AND codegrp = '2000'
       AND fld_01 = ls_caufvd-werks
       AND fld_02 = ls_caufvd-auart
       AND fld_03 = iv_dismm.
      IF sy-subrc = 0.
        cv_apokz = '3'.
      ENDIF.
    ENDIF.
ENDENHANCEMENT.
