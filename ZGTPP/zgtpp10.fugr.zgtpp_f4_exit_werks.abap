FUNCTION zgtpp_f4_exit_werks.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(PARAMETER_OPTIMIZE) TYPE  C OPTIONAL
*"  TABLES
*"      SHLP_TAB TYPE  SHLP_DESCR_TAB_T
*"      RECORD_TAB STRUCTURE  SEAHLPRES
*"  CHANGING
*"     REFERENCE(SHLP) TYPE  SHLP_DESCR_T
*"     REFERENCE(CALLCONTROL) TYPE  DDSHF4CTRL
*"----------------------------------------------------------------------


*// F4IF_SHLP_EXIT_EXAMPLE  :
*// F4UT_OPTIMIZE_COLWIDTH :

  DATA fieldprop_wa LIKE ddshfprop.
  DATA dfies_wa LIKE dfies.
  DATA i TYPE i.
  FIELD-SYMBOLS: <col>.
  DATA: len    TYPE i, maxlen TYPE i.
  DATA: value     LIKE ddshiface-value,
        param_tab LIKE dd32p-fieldname OCCURS 0 WITH HEADER LINE.

  RANGES params FOR fieldprop_wa-fieldname.

  IF callcontrol-step = 'PRESEL1'.
    IF parameter_optimize IS INITIAL.
      CALL FUNCTION 'F4UT_PARAMETER_VALUE_GET'
        EXPORTING
          parameter   = 'PARAMETER_OPTIMIZE'
        IMPORTING
          value       = value
        TABLES
          shlp_tab    = shlp_tab
          record_tab  = record_tab
        CHANGING
          shlp        = shlp
          callcontrol = callcontrol
        EXCEPTIONS
          OTHERS      = 2.
      IF sy-subrc = 0.
        SPLIT value AT ',' INTO TABLE param_tab.
      ENDIF.
    ELSE.
      SPLIT parameter_optimize AT ',' INTO TABLE param_tab.
    ENDIF.
    params-option = 'EQ'.
    params-sign = 'I'.
    LOOP AT param_tab.
      params-low = param_tab.
      APPEND params.
    ENDLOOP.
    SORT shlp-fielddescr BY fieldname.
    LOOP AT shlp-fieldprop INTO fieldprop_wa
            WHERE fieldname IN params AND shlplispos <> 0.
      READ TABLE shlp-fielddescr
           WITH KEY fieldname = fieldprop_wa-fieldname BINARY SEARCH
           TRANSPORTING NO FIELDS.
      CHECK sy-subrc = 0.
      i = sy-tabix.
      dfies_wa-mask+7(1) = 'O'.
      MODIFY shlp-fielddescr FROM dfies_wa INDEX i TRANSPORTING mask+7(1).
    ENDLOOP.

    EXIT.
  ENDIF.

  IF callcontrol-step = 'RETURN'.
    CALL FUNCTION 'SAPGUI_SET_FUNCTIONCODE'
      EXPORTING
        functioncode           = '=ENTR'
      EXCEPTIONS
        function_not_supported = 1
        OTHERS                 = 2.
  ENDIF.

ENDFUNCTION.
