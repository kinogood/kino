FUNCTION z_ti_lvc_table_create.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  IMPORTING
*"     VALUE(IT_FIELDCAT) TYPE  LVC_T_FCAT
*"     VALUE(I_CALLBACK_PROGRAM) TYPE  SY-REPID OPTIONAL
*"     VALUE(I_FORMNAME) TYPE  CHAR30 OPTIONAL
*"     REFERENCE(I_STYLE_TABLE) OPTIONAL
*"     REFERENCE(I_OO_CLASS_REFERENCE) OPTIONAL
*"     REFERENCE(I_OO_CLASS_NAME) OPTIONAL
*"     REFERENCE(I_OO_METHOD) OPTIONAL
*"  EXCEPTIONS
*"      GENERATE_SUBPOOL_DIR_FULL
*"----------------------------------------------------------------------

  DATA: lt_fieldcat TYPE kkblo_t_fieldcat.

  CALL FUNCTION 'LVC_TRANSFER_TO_KKBLO'
    EXPORTING
      it_fieldcat_lvc   = it_fieldcat
    IMPORTING
      et_fieldcat_kkblo = lt_fieldcat.

  CALL FUNCTION 'Z_TI_ALV_TABLE_CREATE'
    EXPORTING
      it_fieldcat               = lt_fieldcat
      i_callback_program        = i_callback_program
      i_formname                = i_formname
      i_style_table             = i_style_table
      i_oo_class_reference      = i_oo_class_reference
      i_oo_class_name           = i_oo_class_name
      i_oo_method               = i_oo_method
      i_tabname                 = '1'
    EXCEPTIONS
      generate_subpool_dir_full = 1
      OTHERS                    = 2.
  CASE sy-subrc.
    WHEN 0.
    WHEN 1.
      RAISE generate_subpool_dir_full.
    WHEN OTHERS.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
              WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ENDCASE.

ENDFUNCTION.
