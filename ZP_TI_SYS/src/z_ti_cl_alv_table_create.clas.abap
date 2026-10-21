class Z_TI_CL_ALV_TABLE_CREATE definition
  public
  create public .

*"* public components of class Z_TI_CL_ALV_TABLE_CREATE
*"* do not include other source files here!!!
public section.

  class-methods TABLE_COPY
    importing
      !IT_OUTTAB type STANDARD TABLE
      !IT_FIELDCATALOG type LVC_T_FCAT
    exporting
      !EP_TABLE type ref to DATA .
  class-methods INTERNAL_RECEIVER
    importing
      !IP_TABLE type ref to DATA .
  class-methods CREATE_DYNAMIC_TABLE
    importing
      value(I_STYLE_TABLE) type CHAR01 optional
      !IT_FIELDCATALOG type LVC_T_FCAT
    exporting
      !EP_TABLE type ref to DATA
      !E_STYLE_FNAME type LVC_FNAME
    exceptions
      GENERATE_SUBPOOL_DIR_FULL .
  type-pools SLIS .
  class-methods CREATE_DYNAMIC_TABLE_GRID
    importing
      value(I_STYLE_TABLE) type CHAR01 optional
      !IT_FIELDCATALOG type SLIS_T_FIELDCAT_ALV
    exporting
      !EP_TABLE type DATA
    exceptions
      GENERATE_SUBPOOL_DIR_FULL .
PROTECTED SECTION.
*" protected components of class CL_ALV_TABLE_CREATE
*" do not include other source files here!!!

PRIVATE SECTION.
*" private components of class CL_ALV_TABLE_CREATE
*" do not include other source files here!!!


*" class attributes
CLASS-DATA:
  MP_TABLE TYPE REF TO DATA .
ENDCLASS.



CLASS Z_TI_CL_ALV_TABLE_CREATE IMPLEMENTATION.


method CREATE_DYNAMIC_TABLE .

*>>ML14.11
  data: l_oo_method(80) type c.
  l_oo_method = 'INTERNAL_RECEIVER'.
*<<ML14.11

  call function 'Z_TI_LVC_TABLE_CREATE'
       exporting
            it_fieldcat               = it_fieldcatalog
*           I_CALLBACK_PROGRAM        =
*           I_FORMNAME                =
*           I_OO_CLASS_REFERENCE      =
            i_style_table             = i_style_table
            i_oo_class_name           = 'Z_TI_CL_ALV_TABLE_CREATE'
            i_oo_method               = l_oo_method
       exceptions
            generate_subpool_dir_full = 1
            others                    = 2.
  case sy-subrc.
    when 0.
      ep_table = mp_table.
    when 1.
      raise generate_subpool_dir_full.
    when others.
      message id sy-msgid type sy-msgty number sy-msgno
              with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endcase.

  if not i_style_table is initial.
    e_style_fname = 'XYZSTYLEZYX'.
  endif.

endmethod.


method CREATE_DYNAMIC_TABLE_GRID .


*>>ML14.11
  data: l_oo_method(80) type c,
        L_CALLBACK      LIKE SY-REPID,
        L_FORMNAME      TYPE CHAR30.

  l_oo_method = 'INTERNAL_RECEIVER'.
*<<ML14.11

  call function 'Z_TI_ALV_TABLE_CREATE_GRID'
       exporting
            it_fieldcat               = it_fieldcatalog
            i_callback_program        = L_CALLBACK
            i_formname                = L_FORMNAME
*            i_style_table             = i_style_table
*            i_oo_class_reference      = i_oo_class_reference
            i_oo_class_name           = 'Z_TI_CL_ALV_TABLE_CREATE'
            i_oo_method               = L_oo_method
            i_tabname                 = '1'
       exceptions
            generate_subpool_dir_full = 1
            others                    = 2.
  case sy-subrc.
    when 0.
      ep_table = mp_table.
    when 1.
      raise generate_subpool_dir_full.
    when others.
      message id sy-msgid type sy-msgty number sy-msgno
              with sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  endcase.


endmethod.


METHOD INTERNAL_RECEIVER .

* ...
  mp_table = ip_table.

ENDMETHOD.


method TABLE_COPY .
* ...
  field-symbols: <lt_destination> type standard table,
                 <ls_fieldcat> type lvc_s_fcat,
                 <ls_wa_from> type any,
                 <ls_wa_to> type any,
                 <l_from> type any,
                 <l_to> type any.

  data: lps_destination type ref to data.

  call method cl_alv_table_create=>CREATE_DYNAMIC_TABLE
                  exporting it_fieldcatalog = it_fieldcatalog
                  importing ep_table        = ep_table.

  assign ep_table->* to <lt_destination>.
  create data lps_destination like line of <lt_destination>.
  assign lps_destination->* to <ls_wa_to>.

  loop at it_outtab assigning <ls_wa_from>.
    loop at it_fieldcatalog assigning <ls_fieldcat>.
      assign component <ls_fieldcat>-fieldname
              of structure <ls_wa_from> to <l_from>.
      assign component <ls_fieldcat>-fieldname
              of structure <ls_wa_to> to <l_to>.
      <l_to> = <l_from>.
    endloop.
    append <ls_wa_to> to <lt_destination>.
  endloop.
endmethod.
ENDCLASS.
