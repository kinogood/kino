*----------------------------------------------------------------------*
***INCLUDE LZ_TI_COMMON_FUNCTIONSF03 .
*----------------------------------------------------------------------*
*----------------------------------------------------------------------*
***INCLUDE LSKBHF06 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  FB_TABLE_CREATE
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IT_FIELDCAT[]  text
*      -->P_I_FORMNAME  text
*      -->P_I_CALLBACK_PROGRAM  text
*      -->P_I_TABNAME  text
*----------------------------------------------------------------------*
form fb_table_create using  rt_fieldcat type kkblo_t_fieldcat
                            r_form
                            r_program like sy-repid
                            r_oo_class
                            r_oo_class_name
                            r_oo_method type c
                            r_style_table type c
                            r_tabname type kkblo_tabname.
  data: ls_fieldcat type kkblo_fieldcat.
  data: l_string(60) type c.
  data: l_name like sy-repid.
  data: l_message(240) type c,
        l_line type i,
        l_word(72) type c.

*  data: begin of ls_source,
*        line type string,
*        end  of ls_source.
*  data: lt_source like standard table of ls_source with header line.
*

  data: begin of lt_source occurs 0,
          line(128) type c,
        end of lt_source.
  data: l_form(30) type c value 'TABLE_CREATE'.
  data: l_length type lvc_outlen.                           "Y9CK020977

  constants:
    con_report(60) type c value
                 'REPORT GENENERATED_SUBROUTINE_POOL.',
    con_form(60) type c value
                 'FORM  TABLE_CREATE.',
    con_form2(60) type c value
                 'FORM  TABLE_CREATE USING R_OO_CLASS',
    con_begin(60) type c value
                 'DATA: BEGIN OF LT_GENTAB OCCURS 0.',
    con_style(60) type c value 'DATA: XYZSTYLEZYX TYPE LVC_T_STYL.',
    con_end(60) type c value
                 'DATA: END OF LT_GENTAB.',
    con_endform(60) type c value
                 'ENDFORM.',
    con_reference(60) type c value
                 'DATA: POINTER TYPE REF TO DATA.',
    con_create(60) type c value
                 'CREATE DATA POINTER LIKE LT_GENTAB[].'.

  call function 'K_KKB_FIELDCAT_COMPLETE'
       exporting
            i_tabname       = r_tabname
*           I_TABNAME_SLAVE =
*           I_ALWAYS        =
*           I_NO_DDIC_READ  =
       changing
            ct_fieldcat     = rt_fieldcat[]
*           CS_LAYOUT       =
       exceptions
            others          = 1.
  if sy-subrc ne 0.
    message id sy-msgid type sy-msgty number sy-msgno
            with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endif.

  lt_source-line = con_report.
  append lt_source.

  if r_oo_class is initial.
    lt_source-line = con_form.
  else.
*   if not r_oo_class is initial.
    lt_source-line = con_form2.
    concatenate lt_source-line 'TYPE REF TO' r_oo_class_name '.'
                   into lt_source-line separated by space.
*   else.
*     LT_SOURCE-LINE = CON_FORM2.
*     concatenate lt_source-line 'TYPE REF TO' r_oo_class_name '.'
*                      into lt_source-line separated by space.
*   endif.
  endif.
  append lt_source.

  lt_source-line = con_begin.
  append lt_source.

  sort rt_fieldcat by col_pos ascending.
  loop at rt_fieldcat into ls_fieldcat.
    clear lt_source-line.
    if not ls_fieldcat-ref_fieldname is initial.
      concatenate 'DATA:'
                   ls_fieldcat-fieldname
*                  'LIKE'
                   'TYPE'
* like is not allowed for deep structures.
                   ls_fieldcat-ref_tabname
                  into lt_source-line separated by space.
      concatenate lt_source-line '-' ls_fieldcat-ref_fieldname '.' into
                  lt_source-line.
    else.
      if ls_fieldcat-datatype = 'CHAR'.
        if ls_fieldcat-ddic_outputlen > 0.  ">>B20K8A0Q9G
          if ls_fieldcat-outputlen > ls_fieldcat-ddic_outputlen.
            l_length = ls_fieldcat-outputlen.
          else.
            l_length = ls_fieldcat-ddic_outputlen.
          endif.
        endif.
        if ls_fieldcat-intlen > 0.
          if ls_fieldcat-outputlen > ls_fieldcat-intlen.
            l_length = ls_fieldcat-outputlen.
          else.
            l_length = ls_fieldcat-intlen.
          endif.
        endif.
        if l_length = 0.
          l_length = ls_fieldcat-outputlen.
        endif.  "<<B20K8A0Q9G
        concatenate 'DATA:'
                    ls_fieldcat-fieldname
                    into lt_source-line separated by space.
        concatenate lt_source-line '(' l_length ').'        "B20K8A0Q9G
                    into lt_source-line.
      elseif ls_fieldcat-datatype = 'CURR'.
        concatenate 'DATA:'
                    ls_fieldcat-fieldname
                    'TYPE'
                    ls_fieldcat-inttype
                    'DECIMALS 2.'
                    into lt_source-line separated by space.
      else.
        if not ls_fieldcat-intlen is initial and ls_fieldcat-inttype ne
'g'.                                                        "B20K8A0MOD
          concatenate ls_fieldcat-fieldname '(' ls_fieldcat-intlen ')'
                      into l_string.
        else.
          l_string = ls_fieldcat-fieldname.
        endif.

        if ls_fieldcat-inttype eq 'g'.                      "B20K8A0MOD

          concatenate 'DATA:'
                      l_string
                      'TYPE'
                      'String'                              "#EC NOTEXT
                      '.'
                    into lt_source-line separated by space. "B20K8A0MOD
        else.
          concatenate 'DATA:'
                      l_string
                      'TYPE'
                      ls_fieldcat-inttype '.'
                      into lt_source-line separated by space.
        endif.

        if ls_fieldcat-inttype = 'P' and not ls_fieldcat-decimals is
           initial.
          replace '.' with 'DECIMALS' into lt_source-line.
          concatenate lt_source-line ls_fieldcat-decimals '.' into
                      lt_source-line separated by space.
        endif.
      endif.
    endif.
    append lt_source.

  endloop.
*******
  if r_style_table = 'X'.
    lt_source-line = con_style.
    append lt_source.
  endif.

  lt_source-line = con_end.
  append lt_source.

  clear lt_source-line.
  if r_oo_class_name is initial.
    concatenate 'PERFORM' r_form into lt_source-line
                separated by space.
    concatenate lt_source-line '(' r_program ')' into lt_source-line.
    concatenate lt_source-line 'TABLES LT_GENTAB.' into lt_source-line
                separated by space.
  else.
    lt_source-line = con_reference.
    append lt_source.
    lt_source-line = con_create.
    append lt_source.
    if not r_oo_class is initial.
      concatenate 'CALL METHOD R_OO_CLASS->' r_oo_method
                                                  into lt_source-line.
      concatenate lt_source-line 'EXPORTING IP_TABLE = POINTER.'
                  into lt_source-line
                  separated by space.
    else.
      concatenate 'CALL METHOD CL_ALV_TABLE_CREATE=>' r_oo_method
                                                  into lt_source-line.
      concatenate lt_source-line 'EXPORTING IP_TABLE = POINTER.'
                  into lt_source-line
                  separated by space.
    endif.
  endif.
  append lt_source.

  lt_source-line = con_endform.
  append lt_source.
  if g_subname is initial.
    l_name = sy-repid.
  else.
    l_name = g_subname.
  endif.
  catch system-exceptions generate_subpool_dir_full = 9.
    generate subroutine pool lt_source[] name l_name
             message l_message line l_line word l_word.
  endcatch.
  case sy-subrc.
    when 0.
    when 9.
      raise generate_subpool_dir_full.
    when others.
      message x000(0k) with l_message l_line l_word.
  endcase.

  if r_oo_class is initial.
    perform (l_form) in program (l_name).
  else.
    perform (l_form) in program (l_name) using r_oo_class.
  endif.
endform.                               " FB_TABLE_CREATE
*&---------------------------------------------------------------------*
*&      Form  fb_table_create_string
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_IT_FIELDCAT[]  text
*      -->P_I_FORMNAME  text
*      -->P_I_CALLBACK_PROGRAM  text
*      -->P_I_OO_CLASS_REFERENCE  text
*      -->P_I_OO_CLASS_NAME  text
*      -->P_I_OO_METHOD  text
*      -->P_I_STYLE_TABLE  text
*      -->P_I_TABNAME  text
*----------------------------------------------------------------------*
form fb_table_create_string using  rt_fieldcat type kkblo_t_fieldcat
                            r_form
                            r_program like sy-repid
                            r_oo_class
                            r_oo_class_name
                            r_oo_method type c
                            r_style_table type c
                            r_tabname type kkblo_tabname.

  data: ls_fieldcat type kkblo_fieldcat.
  data: l_string(60) type c.
  data: l_name like sy-repid.
  data: l_message(240) type c,
        l_line type i,
        l_word(72) type c.

  data: ls_source type string.
  data: lt_source like standard table of ls_source with header line.

  data: l_form(30) type c value 'TABLE_CREATE'.
  data: l_length type lvc_outlen.                           "Y9CK020977

  constants:
    con_report(60) type c value
                 'REPORT GENENERATED_SUBROUTINE_POOL.',
    con_form(60) type c value
                 'FORM  TABLE_CREATE.',
    con_form2(60) type c value
                 'FORM  TABLE_CREATE USING R_OO_CLASS',
    con_begin(60) type c value
                 'DATA: BEGIN OF LT_GENTAB OCCURS 0.',
    con_style(60) type c value 'DATA: XYZSTYLEZYX TYPE LVC_T_STYL.',
    con_end(60) type c value
                 'DATA: END OF LT_GENTAB.',
    con_endform(60) type c value
                 'ENDFORM.',
    con_reference(60) type c value
                 'DATA: POINTER TYPE REF TO DATA.',
    con_create(60) type c value
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
  append lt_source.

  if r_oo_class is initial.
    lt_source = con_form.
  else.

    lt_source = con_form2.
    concatenate lt_source 'TYPE REF TO' r_oo_class_name '.'
                   into lt_source separated by space.
  endif.
  append lt_source.

  lt_source = con_begin.
  append lt_source.

  sort rt_fieldcat by col_pos ascending.

  loop at rt_fieldcat into ls_fieldcat.

    clear lt_source.
    if not ls_fieldcat-ref_fieldname is initial.
      concatenate 'DATA:'
                   ls_fieldcat-fieldname
                   'TYPE'
                   ls_fieldcat-ref_tabname
                  into lt_source separated by space.
      concatenate lt_source '-' ls_fieldcat-ref_fieldname '.' into
                  lt_source.
    else.
      if ls_fieldcat-datatype = 'CHAR'.

        if ls_fieldcat-ddic_outputlen > 0.  ">>B20K8A0Q9G
          if ls_fieldcat-outputlen > ls_fieldcat-ddic_outputlen.
            l_length = ls_fieldcat-outputlen.
          else.
            l_length = ls_fieldcat-ddic_outputlen.
          endif.
        endif.

        if ls_fieldcat-intlen > 0.
          if ls_fieldcat-outputlen > ls_fieldcat-intlen.
            l_length = ls_fieldcat-outputlen.
          else.
            l_length = ls_fieldcat-intlen.
          endif.
        endif.

        if l_length = 0.
          l_length = ls_fieldcat-outputlen.
        endif.  "<<B20K8A0Q9G

        concatenate 'DATA:'
                    ls_fieldcat-fieldname
                    into lt_source separated by space.
        concatenate lt_source '(' l_length ').'             "B20K8A0Q9G
                    into lt_source.

      elseif ls_fieldcat-datatype = 'CURR'.
        concatenate 'DATA:'
                    ls_fieldcat-fieldname
                    'TYPE'
                    ls_fieldcat-inttype
                    'DECIMALS 2.'
                    into lt_source separated by space.
*>>>Y6BK014682
      elseif ls_fieldcat-datatype eq 'INT1'
              or ls_fieldcat-inttype eq 'B'
              or ls_fieldcat-inttype eq 'b'.
        ls_fieldcat-inttype = 'I'.

          concatenate 'DATA:'
                      ls_fieldcat-fieldname
                      'TYPE'
                      'INT1'                              "#EC NOTEXT
                      '.'
                      into lt_source separated by space.    "Y6BK029403

      elseif ls_fieldcat-datatype eq 'INT2'
        or ls_fieldcat-inttype eq 's'.
        ls_fieldcat-inttype = 'I'.
          concatenate 'DATA:'
                      ls_fieldcat-fieldname
                      'TYPE'
                      'INT2'                              "#EC NOTEXT
                      '.'
                      into lt_source separated by space.    "Y6BK029403

*<<<Y6BK014682
      else.
        if not ls_fieldcat-intlen is initial and ls_fieldcat-inttype ne
'g'.                                                        "B20K8A0MOD
*>>>Y6BK024489
          if ls_fieldcat-inttype eq 'P'
            and ls_fieldcat-intlen < 16.
            data: l_leng type lvc_outlen.
            l_leng =  16.
            concatenate ls_fieldcat-fieldname '(' l_leng ')'
                          into l_string.
          else.
           concatenate ls_fieldcat-fieldname '(' ls_fieldcat-intlen ')'
                         into l_string.
          endif.
*<<<Y6BK024489
        else.
          l_string = ls_fieldcat-fieldname.
        endif.

        if ls_fieldcat-inttype eq 'g'.                      "B20K8A0MOD

          concatenate 'DATA:'
                      l_string
                      'TYPE'
                      'String'                              "#EC NOTEXT
                      '.'
                      into lt_source separated by space.    "B20K8A0MOD
        else.
          concatenate 'DATA:'
                      l_string
                      'TYPE'
                      ls_fieldcat-inttype '.'
                      into lt_source separated by space.
        endif.

        if ls_fieldcat-inttype = 'P' and not ls_fieldcat-decimals is
           initial.
          replace '.' with 'DECIMALS' into lt_source.
          concatenate lt_source ls_fieldcat-decimals '.' into
                      lt_source separated by space.
        endif.

        if ls_fieldcat-inttype = 'F'.

        endif.

      endif.
    endif.
    append lt_source.

  endloop.
*******
  if r_style_table = 'X'.
    lt_source = con_style.
    append lt_source.
  endif.

  lt_source = con_end.
  append lt_source.

  clear lt_source.
  if r_oo_class_name is initial.
    concatenate 'PERFORM' r_form into lt_source
                separated by space.
    concatenate lt_source '(' r_program ')' into lt_source.
    concatenate lt_source 'TABLES LT_GENTAB.' into lt_source
                separated by space.
  else.
    lt_source = con_reference.
    append lt_source.
    lt_source = con_create.
    append lt_source.
    if not r_oo_class is initial.
      concatenate 'CALL METHOD R_OO_CLASS->' r_oo_method
                                                   into lt_source.
      concatenate lt_source 'EXPORTING IP_TABLE = POINTER.'
                   into lt_source
                   separated by space.
    else.
      concatenate 'CALL METHOD Z_TI_CL_ALV_TABLE_CREATE=>' r_oo_method
                                                   into lt_source.
      concatenate lt_source 'EXPORTING IP_TABLE = POINTER.'
                  into lt_source
                  separated by space.
    endif.
  endif.
  append lt_source.

  lt_source = con_endform.
  append lt_source.
  if g_subname is initial.
*    l_name = sy-repid.
    l_name = 'SAPLSKBH'.
  else.
    l_name = g_subname.
  endif.
  catch system-exceptions generate_subpool_dir_full = 9.
    generate subroutine pool lt_source name l_name
             message l_message line l_line word l_word.
  endcatch.
  case sy-subrc.
    when 0.
    when 9.
      raise generate_subpool_dir_full.
    when others.
      message x000(0k) with l_message l_line l_word.
  endcase.

  if r_oo_class is initial.
    perform (l_form) in program (l_name).
  else.
    perform (l_form) in program (l_name) using r_oo_class.
  endif.
endform.                    " fb_table_create_string
