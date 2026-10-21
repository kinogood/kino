FUNCTION ZGTPP_F4_EXIT.
*"--------------------------------------------------------------------
*"*"로컬인터페이스:
*"  IMPORTING
*"     VALUE(PARAMETER_OPTIMIZE) TYPE  C OPTIONAL
*"  TABLES
*"      SHLP_TAB TYPE  SHLP_DESCR_TAB_T
*"      RECORD_TAB STRUCTURE  SEAHLPRES
*"  CHANGING
*"     REFERENCE(SHLP) TYPE  SHLP_DESCR_T
*"     REFERENCE(CALLCONTROL) TYPE  DDSHF4CTRL
*"--------------------------------------------------------------------

  IF callcontrol-step = 'RETURN'.
    CALL FUNCTION 'SAPGUI_SET_FUNCTIONCODE'
      EXPORTING
        functioncode           = '=ENTR'
      EXCEPTIONS
        function_not_supported = 1
        OTHERS                 = 2.

    EXIT.
  ENDIF.

ENDFUNCTION.
