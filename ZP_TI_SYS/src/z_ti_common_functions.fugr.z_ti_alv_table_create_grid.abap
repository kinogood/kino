FUNCTION Z_TI_ALV_TABLE_CREATE_GRID.
*"--------------------------------------------------------------------
*"*"로컬인터페이스:
*"       IMPORTING
*"             VALUE(IT_FIELDCAT) TYPE  SLIS_T_FIELDCAT_ALV
*"             VALUE(I_CALLBACK_PROGRAM) TYPE  SY-REPID OPTIONAL
*"             VALUE(I_FORMNAME) TYPE  CHAR30 OPTIONAL
*"             VALUE(I_TABNAME) TYPE  KKBLO_TABNAME DEFAULT '1'
*"             REFERENCE(I_STYLE_TABLE) OPTIONAL
*"             REFERENCE(I_OO_CLASS_REFERENCE) OPTIONAL
*"             REFERENCE(I_OO_CLASS_NAME) OPTIONAL
*"             REFERENCE(I_OO_METHOD) TYPE  C OPTIONAL
*"       EXCEPTIONS
*"              GENERATE_SUBPOOL_DIR_FULL
*"--------------------------------------------------------------------

  perform fb_table_create_string_grid using it_fieldcat[]
                                            i_formname
                                            i_callback_program
                                            i_oo_class_reference
                                            i_oo_class_name
                                            i_oo_method
                                            i_style_table        "#EC *
                                            i_tabname.

*  perform fb_table_create using it_fieldcat[]
*                                i_formname
*                                i_callback_program
*                                i_oo_class_reference
*                                i_oo_class_name
*                                i_oo_method
*                                i_style_table               "#EC *
*                                i_tabname.
*
endfunction.
