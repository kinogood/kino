*----------------------------------------------------------------------*
***INCLUDE LZ_TI_COMMON_FUNCTIONSF05 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  fb_table_create_string_grid
*&---------------------------------------------------------------------*
FORM fb_table_create_string_grid
                     USING  rt_fieldcat TYPE slis_t_fieldcat_alv
                            r_form
                            r_program LIKE sy-repid
                            r_oo_class
                            r_oo_class_name
                            r_oo_method TYPE c
                            r_style_table TYPE c
                            r_tabname TYPE kkblo_tabname.

  DATA: ls_fieldcat TYPE slis_fieldcat_alv.
  DATA: l_string(60) TYPE c.
  DATA: l_name LIKE sy-repid.
  DATA: l_message(240) TYPE c,
        l_line TYPE i,
        l_word(72) TYPE c.

  DATA: ls_source TYPE string.
  DATA: lt_source LIKE STANDARD TABLE OF ls_source WITH HEADER LINE.

  DATA: l_form(30) TYPE c VALUE 'TABLE_CREATE'.
  DATA: l_length TYPE lvc_outlen.                           "Y9CK020977

  CONSTANTS:
    con_type(60) TYPE c VALUE
                 'TYPE-POOLS SLIS.',
    con_report(60) TYPE c VALUE
                 'REPORT GENENERATED_SUBROUTINE_POOL.',
    con_form(60) TYPE c VALUE
                 'FORM  TABLE_CREATE.',
    con_form2(60) TYPE c VALUE
                 'FORM  TABLE_CREATE USING R_OO_CLASS',
    con_begin(60) TYPE c VALUE
                 'DATA: BEGIN OF LT_GENTAB OCCURS 0.',
    con_style(60) TYPE c VALUE 'DATA: XYZSTYLEZYX TYPE LVC_T_STYL.',
    con_end(60) TYPE c VALUE
                 'DATA: END OF LT_GENTAB.',
    con_endform(60) TYPE c VALUE
                 'ENDFORM.',
    con_reference(60) TYPE c VALUE
                 'DATA: POINTER TYPE REF TO DATA.',
    con_create(60) TYPE c VALUE
                 'CREATE DATA POINTER LIKE STANDARD TABLE OF LT_GENTAB.'
.

*  call function 'K_KKB_FIELDCAT_COMPLETE'
*    exporting
*      i_tabname   = r_tabname
*    changing
*      ct_fieldcat = rt_fieldcat[]
*    exceptions
*      others      = 1.
*  if sy-subrc ne 0.
*    message id sy-msgid type sy-msgty number sy-msgno
*            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
*  endif.

  lt_source = con_report.
  APPEND lt_source.

  IF r_oo_class IS INITIAL.
    lt_source = con_form.
  ELSE.

    lt_source = con_form2.
    CONCATENATE lt_source 'TYPE REF TO' r_oo_class_name '.'
                   INTO lt_source SEPARATED BY space.
  ENDIF.
  APPEND lt_source.

  lt_source = con_type.
  APPEND lt_source.

  lt_source = con_begin.
  APPEND lt_source.

  SORT rt_fieldcat BY col_pos ASCENDING.

  LOOP AT rt_fieldcat INTO ls_fieldcat.

    CLEAR lt_source.
    IF NOT ls_fieldcat-ref_fieldname IS INITIAL.
      CONCATENATE 'DATA:'
                   ls_fieldcat-fieldname
                   'TYPE'
                   ls_fieldcat-ref_tabname
                  INTO lt_source SEPARATED BY space.
      IF ls_fieldcat-ref_fieldname IS INITIAL.
        CONCATENATE lt_source '.' INTO lt_source.
      ELSE.
        CONCATENATE lt_source '-' ls_fieldcat-ref_fieldname '.' INTO
                    lt_source.
      ENDIF.
    ELSEIF NOT ls_fieldcat-ref_tabname IS INITIAL.
      CONCATENATE 'DATA:'
                   ls_fieldcat-fieldname
                   'TYPE'
                   ls_fieldcat-ref_tabname
                  INTO lt_source SEPARATED BY space.
      IF ls_fieldcat-ref_fieldname IS INITIAL.
        CONCATENATE lt_source '.' INTO lt_source.
      ELSE.
        CONCATENATE lt_source '-' ls_fieldcat-ref_fieldname '.' INTO
                    lt_source.
      ENDIF.
    ELSE.
      IF ls_fieldcat-datatype = 'CHAR'.

        IF ls_fieldcat-ddic_outputlen > 0.  ">>B20K8A0Q9G
          IF ls_fieldcat-outputlen > ls_fieldcat-ddic_outputlen.
            l_length = ls_fieldcat-outputlen.
          ELSE.
            l_length = ls_fieldcat-ddic_outputlen.
          ENDIF.
        ENDIF.

        IF ls_fieldcat-intlen > 0.
          IF ls_fieldcat-outputlen > ls_fieldcat-intlen.
            l_length = ls_fieldcat-outputlen.
          ELSE.
            l_length = ls_fieldcat-intlen.
          ENDIF.
        ENDIF.

        IF l_length = 0.
          l_length = ls_fieldcat-outputlen.
        ENDIF.  "<<B20K8A0Q9G

        CONCATENATE 'DATA:'
                    ls_fieldcat-fieldname
                    INTO lt_source SEPARATED BY space.
        CONCATENATE lt_source '(' l_length ').'             "B20K8A0Q9G
                    INTO lt_source.

      ELSEIF ls_fieldcat-datatype = 'CURR'.
        CONCATENATE 'DATA:'
                    ls_fieldcat-fieldname
                    'TYPE'
                    ls_fieldcat-inttype
                    'DECIMALS 2.'
                    INTO lt_source SEPARATED BY space.
*>>>Y6BK014682
      ELSEIF ls_fieldcat-datatype EQ 'INT1'
              OR ls_fieldcat-inttype EQ 'B'
              OR ls_fieldcat-inttype EQ 'b'.
        ls_fieldcat-inttype = 'I'.

        CONCATENATE 'DATA:'
                    ls_fieldcat-fieldname
                    'TYPE'
                    'INT1'                                  "#EC NOTEXT
                    '.'
                    INTO lt_source SEPARATED BY space.      "Y6BK029403

      ELSEIF ls_fieldcat-datatype EQ 'INT2'
        OR ls_fieldcat-inttype EQ 's'.
        ls_fieldcat-inttype = 'I'.
        CONCATENATE 'DATA:'
                    ls_fieldcat-fieldname
                    'TYPE'
                    'INT2'                                  "#EC NOTEXT
                    '.'
                    INTO lt_source SEPARATED BY space.      "Y6BK029403

*<<<Y6BK014682
      ELSE.
        IF NOT ls_fieldcat-intlen IS INITIAL AND ls_fieldcat-inttype NE
'g'.                                                        "B20K8A0MOD
*>>>Y6BK024489
          IF ls_fieldcat-inttype EQ 'P'
            AND ls_fieldcat-intlen < 16.
            DATA: l_leng TYPE lvc_outlen.
            l_leng =  16.
            CONCATENATE ls_fieldcat-fieldname '(' l_leng ')'
                          INTO l_string.
          ELSE.
           CONCATENATE ls_fieldcat-fieldname '(' ls_fieldcat-intlen ')'
                         INTO l_string.
          ENDIF.
*<<<Y6BK024489
        ELSE.
          l_string = ls_fieldcat-fieldname.
        ENDIF.

        IF ls_fieldcat-inttype EQ 'g'.                      "B20K8A0MOD

          CONCATENATE 'DATA:'
                      l_string
                      'TYPE'
                      'String'                              "#EC NOTEXT
                      '.'
                      INTO lt_source SEPARATED BY space.    "B20K8A0MOD
        ELSE.
          CONCATENATE 'DATA:'
                      l_string
                      'TYPE'
                      ls_fieldcat-inttype '.'
                      INTO lt_source SEPARATED BY space.
        ENDIF.

        IF ls_fieldcat-inttype = 'P' AND
           NOT ls_fieldcat-decimals_out IS
           INITIAL.
          REPLACE '.' WITH 'DECIMALS' INTO lt_source.
          CONCATENATE lt_source ls_fieldcat-decimals_out '.' INTO
                      lt_source SEPARATED BY space.
        ENDIF.

        IF ls_fieldcat-inttype = 'F'.

        ENDIF.

      ENDIF.
    ENDIF.
    APPEND lt_source.

  ENDLOOP.
*******
  IF r_style_table = 'X'.
    lt_source = con_style.
    APPEND lt_source.
  ENDIF.

  lt_source = con_end.
  APPEND lt_source.

  CLEAR lt_source.
  IF r_oo_class_name IS INITIAL.
    CONCATENATE 'PERFORM' r_form INTO lt_source
                SEPARATED BY space.
    CONCATENATE lt_source '(' r_program ')' INTO lt_source.
    CONCATENATE lt_source 'TABLES LT_GENTAB.' INTO lt_source
                SEPARATED BY space.
  ELSE.
    lt_source = con_reference.
    APPEND lt_source.
    lt_source = con_create.
    APPEND lt_source.
    IF NOT r_oo_class IS INITIAL.
      CONCATENATE 'CALL METHOD R_OO_CLASS->' r_oo_method
                                                   INTO lt_source.
      CONCATENATE lt_source 'EXPORTING IP_TABLE = POINTER.'
                   INTO lt_source
                   SEPARATED BY space.
    ELSE.
      CONCATENATE 'CALL METHOD Z_TI_CL_ALV_TABLE_CREATE=>' r_oo_method
                                                   INTO lt_source.
      CONCATENATE lt_source 'EXPORTING IP_TABLE = POINTER.'
                  INTO lt_source
                  SEPARATED BY space.
    ENDIF.
  ENDIF.
  APPEND lt_source.

  lt_source = con_endform.
  APPEND lt_source.
  IF g_subname IS INITIAL.
*    l_name = sy-repid.
    l_name = 'SAPLSKBH'.
  ELSE.
    l_name = g_subname.
  ENDIF.
  CATCH SYSTEM-EXCEPTIONS generate_subpool_dir_full = 9.
    GENERATE SUBROUTINE POOL lt_source NAME l_name
             MESSAGE l_message LINE l_line WORD l_word.
  ENDCATCH.
  CASE sy-subrc.
    WHEN 0.
    WHEN 9.
      RAISE generate_subpool_dir_full.
    WHEN OTHERS.
      MESSAGE x000(0k) WITH l_message l_line l_word.
  ENDCASE.

  IF NOT l_message IS INITIAL.
    MESSAGE A999 WITH l_message.
  ENDIF.

  IF r_oo_class IS INITIAL.
    PERFORM (l_form) IN PROGRAM (l_name).
  ELSE.
    PERFORM (l_form) IN PROGRAM (l_name) USING r_oo_class.
  ENDIF.
ENDFORM.                    " fb_table_create_string_grid
