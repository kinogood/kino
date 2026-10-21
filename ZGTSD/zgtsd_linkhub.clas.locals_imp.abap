*"* use this source file for the definition and implementation of
*"* local helper classes, interface definitions and type
*"* declarations

*----------------------------------------------------------------------*
*       CLASS /UI2/CL_JSON DEFINITION
*----------------------------------------------------------------------*
CLASS cl_json DEFINITION.
  PUBLIC SECTION.
    TYPE-POOLS abap .
    CLASS cx_sy_conversion_error DEFINITION LOAD .
    TYPES json TYPE string .
    TYPES bool TYPE char1 .
    TYPES tribool TYPE char1 .
    TYPES pretty_name_mode TYPE char1 .
    CONSTANTS:
      BEGIN OF pretty_mode,
        none          TYPE char1  VALUE ``,
        low_case      TYPE char1  VALUE `L`,
        camel_case    TYPE char1  VALUE `X`,
        extended      TYPE char1  VALUE `Y`,
      END OF pretty_mode,
      BEGIN OF c_bool,
        true       TYPE bool  VALUE `X`,
        false      TYPE bool  VALUE ``,
      END OF  c_bool,
      BEGIN OF c_tribool,
        true       TYPE tribool  VALUE c_bool-true,
        false      TYPE tribool  VALUE `-`,
        undefined  TYPE tribool  VALUE ``,
      END OF  c_tribool .
    CONSTANTS mc_key_separator TYPE string VALUE `-`.       "#EC NOTEXT
    CONSTANTS version TYPE i VALUE 2.                       "#EC NOTEXT
    CLASS-DATA sv_white_space TYPE string READ-ONLY .
    CLASS-DATA mc_bool_types TYPE string READ-ONLY VALUE `\TYPE-POOL=ABAP\TYPE=ABAP_BOOL\TYPE=BOOLEAN\TYPE=BOOLE_D\TYPE=XFELD`. "#EC NOTEXT
    CLASS-DATA mc_bool_3state TYPE string READ-ONLY VALUE `\TYPE=BOOLEAN`. "#EC NOTEXT
    CLASS-DATA mc_json_type TYPE string READ-ONLY .
    CLASS-METHODS class_constructor .
    CLASS-METHODS deserialize IMPORTING json TYPE json
                                        pretty_name TYPE pretty_name_mode DEFAULT pretty_mode-none
                                        assoc_arrays TYPE bool DEFAULT c_bool-false
                                        assoc_arrays_opt TYPE bool DEFAULT c_bool-false
                               CHANGING data TYPE data .
    CLASS-METHODS serialize IMPORTING data TYPE data
                                      compress TYPE bool DEFAULT c_bool-false
                                      name TYPE string OPTIONAL
                                      pretty_name TYPE pretty_name_mode DEFAULT pretty_mode-none
                                      type_descr TYPE REF TO cl_abap_typedescr OPTIONAL
                                      assoc_arrays TYPE bool DEFAULT c_bool-false
                                      ts_as_iso8601 TYPE bool DEFAULT c_bool-false
                                      expand_includes TYPE bool DEFAULT c_bool-true
                                      assoc_arrays_opt TYPE bool DEFAULT c_bool-false
                            RETURNING value(r_json) TYPE json .
    METHODS constructor IMPORTING compress TYPE bool DEFAULT c_bool-false
                                  pretty_name TYPE pretty_name_mode DEFAULT pretty_mode-none
                                  assoc_arrays TYPE bool DEFAULT c_bool-false
                                  ts_as_iso8601 TYPE bool DEFAULT c_bool-false
                                  expand_includes TYPE bool DEFAULT c_bool-true
                                  assoc_arrays_opt TYPE bool DEFAULT c_bool-false .
    METHODS deserialize_int IMPORTING json TYPE json CHANGING data TYPE data .
    METHODS serialize_int IMPORTING data TYPE data name TYPE string OPTIONAL type_descr TYPE REF TO cl_abap_typedescr OPTIONAL
      RETURNING value(r_json) TYPE json .
    CLASS-METHODS bool_to_tribool IMPORTING iv_bool TYPE bool RETURNING value(rv_tribool) TYPE tribool .
    CLASS-METHODS tribool_to_bool IMPORTING iv_tribool TYPE tribool RETURNING value(rv_bool) TYPE bool .
    CLASS-METHODS string_to_xstring IMPORTING in TYPE string CHANGING value(out) TYPE any .
    CLASS-METHODS xstring_to_string IMPORTING in TYPE any RETURNING value(out) TYPE string .
  PROTECTED SECTION.
    TYPES:
      BEGIN OF pretty_name_pair,
        in  TYPE string,
        out TYPE string,
      END OF pretty_name_pair,
      BEGIN OF t_s_symbol,
        header TYPE string,
        name            TYPE string,
        type   TYPE REF TO cl_abap_datadescr,
        value           TYPE REF TO data,
        compressable    TYPE abap_bool,
      END OF t_s_symbol,
      BEGIN OF t_s_field_cache,
        name  TYPE string,
        type  TYPE REF TO cl_abap_datadescr,
        value TYPE REF TO data,
      END OF t_s_field_cache .
    TYPES:
      t_t_symbol TYPE STANDARD TABLE OF t_s_symbol WITH DEFAULT KEY,
      t_t_field_cache TYPE HASHED TABLE OF t_s_field_cache WITH UNIQUE KEY name .
    DATA mv_compress TYPE bool .
    DATA mv_pretty_name TYPE pretty_name_mode .
    DATA mv_assoc_arrays TYPE bool .
    DATA mv_ts_as_iso8601 TYPE bool .
    DATA mt_cache_pretty TYPE HASHED TABLE OF pretty_name_pair WITH UNIQUE KEY in .
    DATA mv_expand_includes TYPE bool .
    DATA mv_assoc_arrays_opt TYPE bool .
    METHODS dump_symbols FINAL IMPORTING it_symbols TYPE t_t_symbol RETURNING value(r_json) TYPE json .
    METHODS get_symbols FINAL IMPORTING type_descr TYPE REF TO cl_abap_typedescr
                                        data TYPE REF TO data OPTIONAL
                                        object TYPE REF TO object OPTIONAL
                                        include_aliases TYPE abap_bool DEFAULT abap_false
                              RETURNING value(result) TYPE t_t_symbol .
    METHODS get_fields FINAL IMPORTING type_descr TYPE REF TO cl_abap_typedescr
                              data TYPE REF TO data OPTIONAL
                              object TYPE REF TO object OPTIONAL
                            RETURNING value(rt_fields) TYPE t_t_field_cache .
   METHODS dump_int FINAL IMPORTING data TYPE data
                              type_descr TYPE REF TO cl_abap_typedescr OPTIONAL
                            RETURNING value(r_json) TYPE json .
    METHODS is_compressable IMPORTING type_descr TYPE REF TO cl_abap_typedescr
                                            name TYPE csequence
                            RETURNING value(rv_compress) TYPE abap_bool .
    METHODS restore FINAL IMPORTING json TYPE json
                                    length TYPE i
                                    value(type_descr) TYPE REF TO cl_abap_typedescr OPTIONAL
                                    field_cache TYPE t_t_field_cache OPTIONAL
                          CHANGING  data TYPE data OPTIONAL
                                    offset TYPE i DEFAULT 0
                          RAISING cx_sy_move_cast_error .
    METHODS restore_type FINAL IMPORTING json TYPE json
                                         length TYPE i
                                         value(type_descr) TYPE REF TO cl_abap_typedescr OPTIONAL
                                         field_cache TYPE t_t_field_cache OPTIONAL
                                CHANGING data TYPE data OPTIONAL
                                         offset TYPE i DEFAULT 0 .
    METHODS pretty_name_ex IMPORTING in TYPE csequence RETURNING value(out) TYPE string .
    METHODS pretty_name IMPORTING in TYPE csequence RETURNING value(out) TYPE string .
ENDCLASS.                    "/ui2/cl_json DEFINITION
*----------------------------------------------------------------------*
*       CLASS /UI2/CL_JSON MACROS
*----------------------------------------------------------------------*
DEFINE escape_json_inplace.
  replace all occurrences of `\` in &1 with `\\`.
  replace all occurrences of `"` in &1 with `\"`.
END-OF-DEFINITION.
DEFINE escape_json.
  move &1 to &2.
  escape_json_inplace &2.
END-OF-DEFINITION.
DEFINE dump_type.
  case &2->type_kind.
    when cl_abap_typedescr=>typekind_float or cl_abap_typedescr=>typekind_int or cl_abap_typedescr=>typekind_int1 or
         cl_abap_typedescr=>typekind_int2 or cl_abap_typedescr=>typekind_packed or `8`. " TYPEKIND_INT8 -> '8' only from 7.40.
      if &2->type_kind eq cl_abap_typedescr=>typekind_packed and mv_ts_as_iso8601 eq c_bool-true and &2->absolute_name cp `\TYPE=TIMESTAMP*`.
        if &1 is initial.
          &3 = `""`.
        else.
          move &1 to &3.
          if &2->absolute_name eq `\TYPE=TIMESTAMP`.
            concatenate `"` &3(4) `-` &3+4(2) `-` &3+6(2) `T` &3+8(2) `:` &3+10(2) `:` &3+12(2) `.0000000Z"`  into &3.
          elseif &2->absolute_name eq `\TYPE=TIMESTAMPL`.
            concatenate `"` &3(4) `-` &3+4(2) `-` &3+6(2) `T` &3+8(2) `:` &3+10(2) `:` &3+12(2) `.` &3+15(7) `Z"`  into &3.
          endif.
        endif.
      elseif &1 is initial.
        &3 = `0`.
      else.
        move &1 to &3.
        if &1 lt 0.
          if &2->type_kind <> cl_abap_typedescr=>typekind_float. "float: sign is already at the beginning
            shift &3 right circular.
          endif.
        else.
          condense &3.
        endif.
      endif.
    when cl_abap_typedescr=>typekind_num.
      if &1 is initial.
        &3 = `0`.
      else.
        move &1 to &3.
        shift &3 left deleting leading ` 0`.
      endif.
    when cl_abap_typedescr=>typekind_string or cl_abap_typedescr=>typekind_csequence or cl_abap_typedescr=>typekind_clike.
      if &1 is initial.
        &3 = `""`.
      elseif &2->absolute_name eq mc_json_type.
        &3 = &1.
      else.
        escape_json &1 &3.
        concatenate `"` &3 `"` into &3.
      endif.
    when cl_abap_typedescr=>typekind_xstring or cl_abap_typedescr=>typekind_hex.
      if &1 is initial.
        &3 = `""`.
      else.
        &3 = xstring_to_string( &1 ).
        escape_json_inplace &3.
        concatenate `"` &3 `"` into &3.
      endif.
    when cl_abap_typedescr=>typekind_char.
      if &2->output_length eq 1 and mc_bool_types cs &2->absolute_name.
        if &1 eq c_bool-true.
          &3 = `true`.                                      "#EC NOTEXT
        elseif mc_bool_3state cs &2->absolute_name and data is initial.
          &3 = `null`.                                      "#EC NOTEXT
        else.
          &3 = `false`.                                     "#EC NOTEXT
        endif.
      else.
        escape_json &1 &3.
        concatenate `"` &3 `"` into &3.
      endif.
    when cl_abap_typedescr=>typekind_date.
      concatenate `"` &1(4) `-` &1+4(2) `-` &1+6(2) `"` into &3.
    when cl_abap_typedescr=>typekind_time.
      concatenate `"` &1(2) `:` &1+2(2) `:` &1+4(2) `"` into &3.
    when others.
      if &1 is initial.
        &3 = `null`.                                        "#EC NOTEXT
      else.
        move &1 to &3.
      endif.
  endcase.
END-OF-DEFINITION.
DEFINE format_name.
  case &2.
    when pretty_mode-camel_case.
      &3 = pretty_name( &1 ).
    when pretty_mode-extended.
      &3 = pretty_name_ex( &1 ).
    when pretty_mode-low_case.
      &3 = &1.
      translate &3 to lower case.                         "#EC SYNTCHAR
    when others.
      &3 = &1.
  endcase.
END-OF-DEFINITION.
DEFINE while_offset_cs.
  while offset < length.
    find first occurrence of json+offset(1) in &1.
    if sy-subrc is not initial.
      exit.
    endif.
    offset = offset + 1.
  endwhile.
END-OF-DEFINITION.
DEFINE eat_white.
  while_offset_cs sv_white_space.
END-OF-DEFINITION.
DEFINE eat_string.
  if json+offset(1) eq `"`.
    mark   = offset + 1.
    offset = mark.
    unescape = abap_false.
    do.
      find first occurrence of `"` in section offset offset of json match offset pos.
      if sy-subrc is not initial.
        raise exception type cx_sy_move_cast_error.
      endif.
      offset = pos.
      pos = pos - 1.
      " if escaped search further
      while pos ge 0 and json+pos(1) eq `\`.
        pos = pos - 1.
        unescape = abap_true.
      endwhile.
      match = ( offset - pos ) mod 2.
      if match ne 0.
        exit.
      endif.
      offset = offset + 1.
    enddo.
    match = offset - mark.
    &1 = json+mark(match).
    if unescape eq abap_true.
      replace all occurrences of `\"` in &1 with `"`.
      replace all occurrences of `\\` in &1 with `\`.
    endif.
    offset = offset + 1.
  else.
    raise exception type cx_sy_move_cast_error.
  endif.
END-OF-DEFINITION.
DEFINE eat_number.
  mark   = offset.
  while_offset_cs `0123456789+-eE.`.                        "#EC NOTEXT
  match = offset - mark.
  &1 = json+mark(match).
END-OF-DEFINITION.
DEFINE eat_bool.
  mark   = offset.
  while_offset_cs `aeflnrstu`.                              "#EC NOTEXT
  match = offset - mark.
  if json+mark(match) eq `true`.                            "#EC NOTEXT
    &1 = c_bool-true.
  elseif json+mark(match) eq `false`.                       "#EC NOTEXT
    if type_descr is bound and mc_bool_3state cs type_descr->absolute_name.
      &1 = c_tribool-false.
    else.
      &1 = c_bool-false.
    endif.
  elseif json+mark(match) eq `null`.                        "#EC NOTEXT
    clear &1.
  endif.
END-OF-DEFINITION.
DEFINE eat_char.
  if offset < length and json+offset(1) eq &1.
    offset = offset + 1.
  else.
    raise exception type cx_sy_move_cast_error.
  endif.
END-OF-DEFINITION.
*----------------------------------------------------------------------*
*       CLASS /UI2/CL_JSON IMPLEMENTATION
*----------------------------------------------------------------------*
*
*----------------------------------------------------------------------*
CLASS cl_json IMPLEMENTATION.
  METHOD class_constructor.
    DATA: lo_bool_type_descr    TYPE REF TO cl_abap_typedescr,
          lo_tribool_type_descr TYPE REF TO cl_abap_typedescr,
          lo_json_type_descr    TYPE REF TO cl_abap_typedescr,
          lv_json_string        TYPE json.
    lo_bool_type_descr    = cl_abap_typedescr=>describe_by_data( c_bool-true ).
    lo_tribool_type_descr = cl_abap_typedescr=>describe_by_data( c_tribool-true ).
    lo_json_type_descr    = cl_abap_typedescr=>describe_by_data( lv_json_string ).
    CONCATENATE mc_bool_types lo_bool_type_descr->absolute_name lo_tribool_type_descr->absolute_name INTO mc_bool_types.
    CONCATENATE mc_bool_3state lo_tribool_type_descr->absolute_name INTO mc_bool_3state.
    CONCATENATE mc_json_type lo_json_type_descr->absolute_name INTO mc_json_type.
    sv_white_space = cl_abap_char_utilities=>get_simple_spaces_for_cur_cp( ).
  ENDMETHOD.                    "class_constructor
  METHOD constructor.
    mv_compress       = compress.
    mv_pretty_name    = pretty_name.
    mv_assoc_arrays   = assoc_arrays.
    mv_ts_as_iso8601  = ts_as_iso8601.
    mv_expand_includes  = expand_includes.
    mv_assoc_arrays_opt = assoc_arrays_opt.
  ENDMETHOD.                    "constructor
  METHOD serialize.
    " **********************************************************************
    "! Usage examples and documentation can be found on SCN:
    " http://wiki.scn.sap.com/wiki/display/Snippets/One+more+ABAP+to+JSON+Serializer+and+Deserializer
    " **********************************************************************  "
    DATA: lo_json  TYPE REF TO cl_json.
    CREATE OBJECT lo_json
      EXPORTING
        compress         = compress
        pretty_name      = pretty_name
        assoc_arrays     = assoc_arrays
        assoc_arrays_opt = assoc_arrays_opt
        expand_includes  = expand_includes
        ts_as_iso8601    = ts_as_iso8601.
    r_json = lo_json->serialize_int( name = name data = data type_descr = type_descr ).
  ENDMETHOD.                    "serialize
  METHOD serialize_int.
    DATA: lo_descr   TYPE REF TO cl_abap_typedescr.
    IF type_descr IS INITIAL.
      lo_descr = cl_abap_typedescr=>describe_by_data( data ).
    ELSE.
      lo_descr = type_descr.
    ENDIF.
    r_json = dump_int( data = data type_descr = lo_descr ).
    " we do not do escaping of every single string value for white space characters,
    " but we do it on top, to replace multiple calls by 3 only, while we do not serialize
    " outlined/formatted JSON this shall not produce any harm
    REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>cr_lf          IN r_json WITH `\r\n`.
    REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>newline        IN r_json WITH `\n`.
    REPLACE ALL OCCURRENCES OF cl_abap_char_utilities=>horizontal_tab IN r_json WITH `\t`.
    IF name IS NOT INITIAL AND ( mv_compress IS INITIAL OR r_json IS NOT INITIAL ).
      CONCATENATE `"` name `":` r_json INTO r_json.
    ENDIF.
  ENDMETHOD.                    "serialize
  METHOD deserialize.
    DATA: lo_json TYPE REF TO cl_json.
    " **********************************************************************
    "! Usage examples and documentation can be found on SCN:
    " http://wiki.scn.sap.com/wiki/display/Snippets/One+more+ABAP+to+JSON+Serializer+and+Deserializer
    " **********************************************************************  "
    IF json IS NOT INITIAL.
      CREATE OBJECT lo_json
        EXPORTING
          pretty_name      = pretty_name
          assoc_arrays     = assoc_arrays
          assoc_arrays_opt = assoc_arrays_opt.
      lo_json->deserialize_int( EXPORTING json = json CHANGING data = data ).
    ENDIF.
  ENDMETHOD.                    "deserialize
  METHOD deserialize_int.
    DATA: length    TYPE i,
          unescaped LIKE json.
    IF json IS NOT INITIAL.
      unescaped = json.
      " to eliminate numeric replacement calls for every single sting value, we do
      " replacement over all JSON text, while this shall not destroy JSON structure
      REPLACE ALL OCCURRENCES OF `\r\n` IN unescaped WITH cl_abap_char_utilities=>cr_lf.
      REPLACE ALL OCCURRENCES OF `\n`   IN unescaped WITH cl_abap_char_utilities=>newline.
      REPLACE ALL OCCURRENCES OF `\t`   IN unescaped WITH cl_abap_char_utilities=>horizontal_tab.
      length = numofchar( unescaped ).
      restore_type( EXPORTING json = unescaped length = length CHANGING data = data ).
    ENDIF.
  ENDMETHOD.                    "deserialize
  METHOD dump_int.
    DATA: lo_typedesc        TYPE REF TO cl_abap_typedescr,
          lo_elem_descr      TYPE REF TO cl_abap_elemdescr,
          lo_classdesc       TYPE REF TO cl_abap_classdescr,
          lo_structdesc      TYPE REF TO cl_abap_structdescr,
          lo_tabledescr      TYPE REF TO cl_abap_tabledescr,
          lt_symbols         TYPE t_t_symbol,
          lt_keys            LIKE lt_symbols,
          lt_properties      TYPE STANDARD TABLE OF string,
          lt_fields          TYPE STANDARD TABLE OF string,
          lo_obj_ref         TYPE REF TO object,
          lo_data_ref        TYPE REF TO data,
          ls_skip_key        TYPE LINE OF abap_keydescr_tab,
          lv_array_opt       TYPE abap_bool,
          lv_prop_name       TYPE string,
          lv_keyval          TYPE string,
          lv_itemval         TYPE string.
    FIELD-SYMBOLS: <line>    TYPE any,
                   <value>   TYPE any,
                   <data>    TYPE data,
                   <key>     TYPE LINE OF abap_keydescr_tab,
                   <symbol>  LIKE LINE OF lt_symbols,
                   <table>   TYPE ANY TABLE.
    CASE type_descr->kind.
      WHEN cl_abap_typedescr=>kind_ref.
        IF data IS INITIAL.
          r_json = `null`.                                  "#EC NOTEXT
        ELSEIF type_descr->type_kind EQ cl_abap_typedescr=>typekind_dref.
          lo_data_ref ?= data.
          lo_typedesc = cl_abap_typedescr=>describe_by_data_ref( lo_data_ref ).
          ASSIGN lo_data_ref->* TO <data>.
          r_json = dump_int( data = <data> type_descr = lo_typedesc ).
        ELSE.
          lo_obj_ref ?= data.
          lo_classdesc ?= cl_abap_typedescr=>describe_by_object_ref( lo_obj_ref ).
          lt_symbols = get_symbols( type_descr = lo_classdesc object = lo_obj_ref ).
          r_json = dump_symbols( lt_symbols ).
        ENDIF.
      WHEN cl_abap_typedescr=>kind_elem.
        lo_elem_descr ?= type_descr.
        dump_type data lo_elem_descr r_json.
      WHEN cl_abap_typedescr=>kind_struct.
        lo_structdesc ?= type_descr.
        GET REFERENCE OF data INTO lo_data_ref.
        lt_symbols = get_symbols( type_descr = lo_structdesc data = lo_data_ref ).
        r_json = dump_symbols( lt_symbols ).
      WHEN cl_abap_typedescr=>kind_table.
        lo_tabledescr ?= type_descr.
        lo_typedesc = lo_tabledescr->get_table_line_type( ).
        ASSIGN data TO <table>.
        " optimization for structured tables
        IF lo_typedesc->kind EQ cl_abap_typedescr=>kind_struct.
          lo_structdesc ?= lo_typedesc.
          CREATE DATA lo_data_ref TYPE (lo_structdesc->absolute_name).
          ASSIGN lo_data_ref->* TO <line>.
          lt_symbols = get_symbols( type_descr = lo_structdesc data = lo_data_ref ).
          " here we have differentiation of output of simple table to JSON array
          " and sorted or hashed table with unique key into JSON associative array
          IF lo_tabledescr->has_unique_key IS NOT INITIAL AND mv_assoc_arrays IS NOT INITIAL.
            IF lo_tabledescr->key_defkind EQ lo_tabledescr->keydefkind_user.
              LOOP AT lo_tabledescr->key ASSIGNING <key>.
                READ TABLE lt_symbols WITH KEY name = <key>-name ASSIGNING <symbol>.
                APPEND <symbol> TO lt_keys.
              ENDLOOP.
            ENDIF.
            IF lines( lo_tabledescr->key ) EQ 1.
              READ TABLE lo_tabledescr->key INDEX 1 INTO ls_skip_key.
              DELETE lt_symbols WHERE name EQ ls_skip_key-name.
              " remove object wrapping for simple name-value tables
              IF mv_assoc_arrays_opt EQ abap_true AND lines( lt_symbols ) EQ 1.
                lv_array_opt = abap_true.
              ENDIF.
            ENDIF.
            LOOP AT <table> INTO <line>.
              CLEAR: lt_fields, lv_prop_name.
              LOOP AT lt_symbols ASSIGNING <symbol>.
                ASSIGN <symbol>-value->* TO <value>.
                IF mv_compress IS INITIAL OR <value> IS NOT INITIAL OR <symbol>-compressable EQ abap_false.
                  IF <symbol>-type->kind EQ cl_abap_typedescr=>kind_elem.
                    lo_elem_descr ?= <symbol>-type.
                    dump_type <value> lo_elem_descr lv_itemval.
                  ELSE.
                    lv_itemval = dump_int( data = <value> type_descr = <symbol>-type ).
                  ENDIF.
                  IF lv_array_opt EQ abap_false.
                    CONCATENATE <symbol>-header lv_itemval INTO lv_itemval.
                  ENDIF.
                  APPEND lv_itemval TO lt_fields.
                ENDIF.
              ENDLOOP.
              IF lo_tabledescr->key_defkind EQ lo_tabledescr->keydefkind_user.
                LOOP AT lt_keys ASSIGNING <symbol>.
                  ASSIGN <symbol>-value->* TO <value>.
                  MOVE <value> TO lv_keyval.
                  CONDENSE lv_keyval.
                  IF lv_prop_name IS NOT INITIAL.
                    CONCATENATE lv_prop_name mc_key_separator lv_keyval INTO lv_prop_name.
                  ELSE.
                    lv_prop_name = lv_keyval.
                  ENDIF.
                ENDLOOP.
              ELSE.
                LOOP AT lt_symbols ASSIGNING <symbol>.
                  ASSIGN <symbol>-value->* TO <value>.
                  MOVE <value> TO lv_keyval.
                  CONDENSE lv_keyval.
                  IF lv_prop_name IS NOT INITIAL.
                    CONCATENATE lv_prop_name mc_key_separator lv_keyval INTO lv_prop_name.
                  ELSE.
                    lv_prop_name = lv_keyval.
                  ENDIF.
                ENDLOOP.
              ENDIF.
              CONCATENATE LINES OF lt_fields INTO lv_itemval SEPARATED BY `,`.
              IF lv_array_opt EQ abap_false.
                CONCATENATE `"` lv_prop_name `":{` lv_itemval `}` INTO lv_itemval.
              ELSE.
                CONCATENATE `"` lv_prop_name `":` lv_itemval `` INTO lv_itemval.
              ENDIF.
              APPEND lv_itemval TO lt_properties.
            ENDLOOP.
            CONCATENATE LINES OF lt_properties INTO r_json SEPARATED BY `,`.
            CONCATENATE `{` r_json `}` INTO r_json.
          ELSE.
            LOOP AT <table> INTO <line>.
              CLEAR lt_fields.
              LOOP AT lt_symbols ASSIGNING <symbol>.
                ASSIGN <symbol>-value->* TO <value>.
                IF mv_compress IS INITIAL OR <value> IS NOT INITIAL OR <symbol>-compressable EQ abap_false.
                  IF <symbol>-type->kind EQ cl_abap_typedescr=>kind_elem.
                    lo_elem_descr ?= <symbol>-type.
                    dump_type <value> lo_elem_descr lv_itemval.
                  ELSE.
                    lv_itemval = dump_int( data = <value> type_descr = <symbol>-type ).
                  ENDIF.
                  CONCATENATE <symbol>-header lv_itemval INTO lv_itemval.
                  APPEND lv_itemval TO lt_fields.
                ENDIF.
              ENDLOOP.
              CONCATENATE LINES OF lt_fields INTO lv_itemval SEPARATED BY `,`.
              CONCATENATE `{` lv_itemval `}` INTO lv_itemval.
              APPEND lv_itemval TO lt_properties.
            ENDLOOP.
            CONCATENATE LINES OF lt_properties INTO r_json SEPARATED BY `,`.
            CONCATENATE `[` r_json `]` INTO r_json.
          ENDIF.
        ELSE.
          LOOP AT <table> ASSIGNING <value>.
            lv_itemval = dump_int( data = <value> type_descr = lo_typedesc ).
            APPEND lv_itemval TO lt_properties.
          ENDLOOP.
          CONCATENATE LINES OF lt_properties INTO r_json SEPARATED BY `,`.
          CONCATENATE `[` r_json `]` INTO r_json.
        ENDIF.
    ENDCASE.
  ENDMETHOD.                    "dump
  METHOD dump_symbols.
    DATA: lv_properties      TYPE STANDARD TABLE OF string,
          lv_itemval         TYPE string.
    FIELD-SYMBOLS: <value>   TYPE any,
                   <symbol>  LIKE LINE OF it_symbols.
    LOOP AT it_symbols ASSIGNING <symbol>.
      ASSIGN <symbol>-value->* TO <value>.
      IF mv_compress IS INITIAL OR <value> IS NOT INITIAL OR <symbol>-compressable EQ abap_false.
        lv_itemval = dump_int( data = <value> type_descr = <symbol>-type ).
        CONCATENATE <symbol>-header lv_itemval INTO lv_itemval.
        APPEND lv_itemval TO lv_properties.
      ENDIF.
    ENDLOOP.
    CONCATENATE LINES OF lv_properties INTO r_json SEPARATED BY `,`.
    CONCATENATE `{` r_json `}` INTO r_json.
  ENDMETHOD.                    "dump_symbols
  METHOD get_fields.
    DATA: lt_symbols      TYPE t_t_symbol,
          lv_name     TYPE char128,
          ls_field    LIKE LINE OF rt_fields.
    FIELD-SYMBOLS: <sym>   LIKE LINE OF lt_symbols.
    lt_symbols = get_symbols( type_descr = type_descr data = data object = object include_aliases = abap_true ).
    LOOP AT lt_symbols ASSIGNING <sym>.
      ls_field-name  = <sym>-name.
      ls_field-type  = <sym>-type.
      ls_field-value = <sym>-value.
      " insert as UPPER CASE
      INSERT ls_field INTO TABLE rt_fields.
      " insert as lower case
      TRANSLATE ls_field-name TO LOWER CASE.
      INSERT ls_field INTO TABLE rt_fields.
      " as pretty printed
      IF mv_pretty_name NE pretty_mode-none AND mv_pretty_name NE pretty_mode-low_case.
        format_name ls_field-name mv_pretty_name ls_field-name.
        INSERT ls_field INTO TABLE rt_fields.
        " let us check for not well formed canelCase to be compatible with old logic
        lv_name = ls_field-name.
        TRANSLATE lv_name(1) TO UPPER CASE.
        ls_field-name = lv_name.
        INSERT ls_field INTO TABLE rt_fields.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.                    "get_fields
  METHOD get_symbols.
    DATA: comp_tab TYPE cl_abap_structdescr=>component_table,
          symb_tab LIKE result,
          symb     LIKE LINE OF symb_tab,
          class_descr   TYPE REF TO cl_abap_classdescr,
          struct_descr  TYPE REF TO cl_abap_structdescr.
    FIELD-SYMBOLS: <comp>  LIKE LINE OF comp_tab,
                   <attr>  LIKE LINE OF cl_abap_objectdescr=>attributes,
                   <field> TYPE any.
    IF type_descr->kind EQ cl_abap_typedescr=>kind_struct.
      struct_descr ?= type_descr.
      comp_tab = struct_descr->get_components( ).
      LOOP AT comp_tab ASSIGNING <comp>.
        IF <comp>-name IS NOT INITIAL AND
          ( <comp>-as_include EQ abap_false OR include_aliases EQ abap_true OR mv_expand_includes EQ abap_false ).
          symb-name = <comp>-name.
          symb-type = <comp>-type.
          symb-compressable = is_compressable( type_descr = symb-type name = symb-name ).
          ASSIGN data->(symb-name) TO <field>.
          GET REFERENCE OF <field> INTO symb-value.
          format_name symb-name mv_pretty_name symb-header.
          CONCATENATE `"` symb-header  `":` INTO symb-header.
          APPEND symb TO result.
        ENDIF.
        IF <comp>-as_include EQ abap_true AND mv_expand_includes EQ abap_true.
          struct_descr ?= <comp>-type.
          symb_tab = get_symbols( type_descr = struct_descr data = data include_aliases = include_aliases ).
          LOOP AT symb_tab INTO symb.
            CONCATENATE symb-name <comp>-suffix INTO symb-name.
            symb-compressable = is_compressable( type_descr = symb-type name = symb-name ).
            ASSIGN data->(symb-name) TO <field>.
            GET REFERENCE OF <field> INTO symb-value.
            format_name symb-name mv_pretty_name symb-header.
            CONCATENATE `"` symb-header  `":` INTO symb-header.
            APPEND symb TO result.
          ENDLOOP.
        ENDIF.
      ENDLOOP.
    ELSEIF type_descr->type_kind EQ cl_abap_typedescr=>typekind_class.
      class_descr ?= type_descr.
      LOOP AT class_descr->attributes ASSIGNING <attr> WHERE is_constant IS INITIAL AND alias_for IS INITIAL AND
        ( is_interface IS INITIAL OR type_kind NE cl_abap_typedescr=>typekind_oref ).
        symb-name = <attr>-name.
        symb-type = class_descr->get_attribute_type( <attr>-name ).
        symb-compressable = is_compressable( type_descr = symb-type name = symb-name ).
        ASSIGN object->(<attr>-name) TO <field>.
        GET REFERENCE OF <field> INTO symb-value.
        format_name symb-name mv_pretty_name symb-header.
        CONCATENATE `"` symb-header  `":` INTO symb-header.
        APPEND symb TO result.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.                    "GET_SYMBOLS
  METHOD is_compressable.
    rv_compress = abap_true.
  ENDMETHOD.                    "is_compressable
  METHOD pretty_name.
    DATA: tokens TYPE TABLE OF char128,
          cache  LIKE LINE OF mt_cache_pretty.
    FIELD-SYMBOLS: <token> LIKE LINE OF tokens,
                   <cache> LIKE LINE OF mt_cache_pretty.
    READ TABLE mt_cache_pretty WITH TABLE KEY in = in ASSIGNING <cache>.
    IF sy-subrc IS INITIAL.
      out = <cache>-out.
    ELSE.
      out = in.
      REPLACE ALL OCCURRENCES OF `__` IN out WITH `*`.
      TRANSLATE out TO LOWER CASE.
      TRANSLATE out USING `/_:_~_`.
      SPLIT out AT `_` INTO TABLE tokens.
      LOOP AT tokens ASSIGNING <token> FROM 2.
        TRANSLATE <token>(1) TO UPPER CASE.
      ENDLOOP.
      CONCATENATE LINES OF tokens INTO out.
      REPLACE ALL OCCURRENCES OF `*` IN out WITH `_`.
      cache-in  = in.
      cache-out = out.
      INSERT cache INTO TABLE mt_cache_pretty.
    ENDIF.
  ENDMETHOD.                    "pretty_name
  METHOD pretty_name_ex.
    DATA: tokens TYPE TABLE OF char128,
          cache  LIKE LINE OF mt_cache_pretty.
    FIELD-SYMBOLS: <token> LIKE LINE OF tokens,
                   <cache> LIKE LINE OF mt_cache_pretty.
    READ TABLE mt_cache_pretty WITH TABLE KEY in = in ASSIGNING <cache>.
    IF sy-subrc IS INITIAL.
      out = <cache>-out.
    ELSE.
      out = in.
      REPLACE ALL OCCURRENCES OF `___` IN out WITH `.`.
      REPLACE ALL OCCURRENCES OF `__` IN out WITH `*`.
      TRANSLATE out TO LOWER CASE.
      TRANSLATE out USING `/_:_~_`.
      SPLIT out AT `_` INTO TABLE tokens.
      LOOP AT tokens ASSIGNING <token> FROM 2.
        TRANSLATE <token>(1) TO UPPER CASE.
      ENDLOOP.
      CONCATENATE LINES OF tokens INTO out.
      REPLACE ALL OCCURRENCES OF `*` IN out WITH `_`.
      cache-in  = in.
      cache-out = out.
      INSERT cache INTO TABLE mt_cache_pretty.
    ENDIF.
  ENDMETHOD.                    "pretty_name_ex
  METHOD restore.
    DATA: mark        LIKE offset,
          match       LIKE offset,
          pos         LIKE offset,
          unescape    TYPE abap_bool,
          ref_descr   TYPE REF TO cl_abap_refdescr,
          data_ref    TYPE REF TO data,
          object_ref  TYPE REF TO object,
          fields      LIKE field_cache,
          name_json   TYPE string.
    FIELD-SYMBOLS: <value>       TYPE any,
                   <field_cache> LIKE LINE OF field_cache.
    fields = field_cache.
    IF type_descr IS NOT INITIAL AND type_descr->kind EQ type_descr->kind_ref.
      ref_descr ?= type_descr.
      type_descr = ref_descr->get_referenced_type( ).
      IF ref_descr->type_kind EQ ref_descr->typekind_oref.
        IF data IS INITIAL.
          CREATE OBJECT data TYPE (type_descr->absolute_name).
        ENDIF.
        object_ref ?= data.
        fields = get_fields( type_descr = type_descr object = object_ref ).
      ELSEIF ref_descr->type_kind EQ ref_descr->typekind_dref.
        IF data IS INITIAL.
          CREATE DATA data TYPE (type_descr->absolute_name).
        ENDIF.
        data_ref ?= data.
        ASSIGN data_ref->* TO <value>.
        fields = get_fields( type_descr = type_descr data = data_ref ).
        restore( EXPORTING json = json length = length type_descr = type_descr field_cache = fields
                   CHANGING data = <value> offset = offset ).
        RETURN.
      ENDIF.
    ENDIF.
    IF fields IS INITIAL AND type_descr IS NOT INITIAL AND type_descr->kind EQ type_descr->kind_struct.
      GET REFERENCE OF data INTO data_ref.
      fields = get_fields( type_descr = type_descr data = data_ref ).
    ENDIF.
    eat_white.
    eat_char `{`.
    eat_white.
    WHILE offset < length AND json+offset(1) NE `}`.
      eat_white.
      eat_string name_json.
      eat_white.
      eat_char `:`.
      eat_white.
      READ TABLE fields WITH TABLE KEY name = name_json ASSIGNING <field_cache>.
      IF sy-subrc IS NOT INITIAL.
        TRANSLATE name_json TO UPPER CASE.
        READ TABLE fields WITH TABLE KEY name = name_json ASSIGNING <field_cache>.
      ENDIF.
      IF sy-subrc IS INITIAL.
        ASSIGN <field_cache>-value->* TO <value>.
        restore_type( EXPORTING json = json length = length type_descr = <field_cache>-type CHANGING data = <value> offset = offset ).
      ELSE.
        restore_type( EXPORTING json = json length = length CHANGING offset = offset ).
      ENDIF.
      eat_white.
      IF offset < length AND json+offset(1) NE `}`.
        eat_char `,`.
      ELSE.
        EXIT.
      ENDIF.
    ENDWHILE.
    eat_char `}`.
  ENDMETHOD.                    "restore
  METHOD restore_type.
    DATA: mark        LIKE offset,
          match       LIKE offset,
          unescape    TYPE abap_bool,
          sdummy      TYPE string,                          "#EC NEEDED
          lr_idummy   TYPE REF TO i,                        "#EC NEEDED
          lr_bdummy   TYPE REF TO bool,                     "#EC NEEDED
          lr_sdummy   TYPE REF TO string,                   "#EC NEEDED
          pos         LIKE offset,
          line        TYPE REF TO data,
          key_ref     TYPE REF TO data,
          key_name    TYPE string,
          key_value   TYPE string,
          lt_fields   LIKE field_cache,
          lt_symbols  TYPE t_t_symbol,
          elem_descr  TYPE REF TO cl_abap_elemdescr,
          table_descr TYPE REF TO cl_abap_tabledescr,
          data_descr  TYPE REF TO cl_abap_datadescr.
    FIELD-SYMBOLS: <line>           TYPE any,
                   <value>          TYPE any,
                   <field>     LIKE LINE OF lt_fields,
                   <table>     TYPE ANY TABLE,
                   <value_sym> LIKE LINE OF lt_symbols.
    IF type_descr IS INITIAL AND data IS SUPPLIED.
      type_descr = cl_abap_typedescr=>describe_by_data( data ).
    ENDIF.
    eat_white.
    TRY .
        IF type_descr IS NOT INITIAL AND type_descr->absolute_name EQ mc_json_type.
          " skip deserialization
          mark = offset.
          restore_type( EXPORTING json = json length = length CHANGING offset = offset ).
          match = offset - mark.
          data = json+mark(match).
        ENDIF.
        CASE json+offset(1).
          WHEN `{`. " object
            IF type_descr IS NOT INITIAL.
              IF mv_assoc_arrays EQ c_bool-true AND type_descr->kind EQ cl_abap_typedescr=>kind_table.
                table_descr ?= type_descr.
                data_descr = table_descr->get_table_line_type( ).
                IF table_descr->has_unique_key IS NOT INITIAL.
                  eat_char `{`.
                  eat_white.
                  IF json+offset(1) NE `}`.
                    ASSIGN data TO <table>.
                    CREATE DATA line LIKE LINE OF <table>.
                    ASSIGN line->* TO <line>.
                    lt_fields = get_fields( type_descr = data_descr data = line ).
                    IF table_descr->key_defkind EQ table_descr->keydefkind_user AND lines( table_descr->key ) EQ 1.
                      READ TABLE table_descr->key INDEX 1 INTO key_name.
                      READ TABLE lt_fields WITH TABLE KEY name = key_name ASSIGNING <field>.
                      key_ref = <field>-value.
                      IF mv_assoc_arrays_opt EQ c_bool-true.
                        lt_symbols = get_symbols( type_descr = data_descr data = line ).
                        DELETE lt_symbols WHERE name EQ key_name.
                        IF lines( lt_symbols ) EQ 1.
                          READ TABLE lt_symbols INDEX 1 ASSIGNING <value_sym>.
                        ENDIF.
                      ENDIF.
                    ENDIF.
                    WHILE offset < length AND json+offset(1) NE `}`.
                      CLEAR <line>.
                      eat_white.
                      eat_string key_value.
                      eat_white.
                      eat_char `:`.
                      eat_white.
                      IF <value_sym> IS ASSIGNED.
                        ASSIGN <value_sym>-value->* TO <value>.
                        restore_type( EXPORTING json = json length = length type_descr = <value_sym>-type
                                      CHANGING data = <value> offset = offset ).
                      ELSE.
                        restore_type( EXPORTING json = json length = length type_descr = data_descr field_cache = lt_fields
                                      CHANGING data = <line> offset = offset ).
                      ENDIF.
                      IF table_descr->key_defkind EQ table_descr->keydefkind_user.
                        IF key_ref IS BOUND.
                          ASSIGN key_ref->* TO <value>.
                          IF <value> IS INITIAL.
                            MOVE key_value TO <value>.
                          ENDIF.
                        ENDIF.
                      ELSEIF <line> IS INITIAL.
                        MOVE key_value TO <line>.
                      ENDIF.
                      INSERT <line> INTO TABLE <table>.
                      eat_white.
                      IF offset < length AND json+offset(1) NE `}`.
                        eat_char `,`.
                      ELSE.
                        EXIT.
                      ENDIF.
                    ENDWHILE.
                  ENDIF.
                  eat_char `}`.
                ELSE.
                  restore( EXPORTING json = json length = length CHANGING  offset = offset ).
                ENDIF.
              ELSE.
                restore( EXPORTING json = json length = length type_descr = type_descr field_cache = field_cache
                         CHANGING data = data offset = offset ).
              ENDIF.
            ELSE.
              restore( EXPORTING json = json length = length CHANGING  offset = offset ).
            ENDIF.
          WHEN `[`. " array
            eat_char `[`.
            eat_white.
            IF json+offset(1) NE `]`.
              IF type_descr IS NOT INITIAL AND type_descr->kind EQ cl_abap_typedescr=>kind_table.
                table_descr ?= type_descr.
                data_descr = table_descr->get_table_line_type( ).
                ASSIGN data TO <table>.
                CREATE DATA line LIKE LINE OF <table>.
                ASSIGN line->* TO <line>.
                lt_fields = get_fields( type_descr = data_descr data = line ).
                WHILE offset < length AND json+offset(1) NE `]`.
                  CLEAR <line>.
                  restore_type( EXPORTING json = json length = length type_descr = data_descr field_cache = lt_fields
                                CHANGING data = <line> offset = offset ).
                  INSERT <line> INTO TABLE <table>.
                  eat_white.
                  IF offset < length AND json+offset(1) NE `]`.
                    eat_char `,`.
                  ELSE.
                    EXIT.
                  ENDIF.
                ENDWHILE.
              ELSE.
                " skip array
                WHILE offset < length AND json+offset(1) NE `}`.
                  eat_white.
                  restore_type( EXPORTING json = json length = length CHANGING offset = offset ).
                  eat_white.
                  IF offset < length AND json+offset(1) NE `]`.
                    eat_char `,`.
                  ELSE.
                    EXIT.
                  ENDIF.
                ENDWHILE.
              ENDIF.
            ENDIF.
            eat_char `]`.
          WHEN `"`. " string
            eat_string sdummy.
            IF type_descr IS NOT INITIAL.
              " unescape string
              IF sdummy IS NOT INITIAL.
                IF type_descr->kind EQ cl_abap_typedescr=>kind_elem.
                  elem_descr ?= type_descr.
                  CASE elem_descr->type_kind.
                    WHEN cl_abap_typedescr=>typekind_char.
                      IF elem_descr->output_length EQ 1 AND mc_bool_types CS elem_descr->absolute_name.
                        IF sdummy(1) CA `XxTt1`.
                          data = c_bool-true.
                        ELSE.
                          data = c_bool-false.
                        ENDIF.
                        RETURN.
                      ENDIF.
                    WHEN cl_abap_typedescr=>typekind_xstring OR cl_abap_typedescr=>typekind_hex.
                      string_to_xstring( EXPORTING in = sdummy CHANGING out = data ).
                      RETURN.
                    WHEN cl_abap_typedescr=>typekind_date.
                      REPLACE FIRST OCCURRENCE OF REGEX `(\d{4})-(\d{2})-(\d{2})` IN sdummy WITH `$1$2$3`
                      REPLACEMENT LENGTH match REPLACEMENT OFFSET pos. "#EC NOTEXT
                      IF sy-subrc EQ 0 AND pos EQ 0.
                        sdummy = sdummy(match).
                      ENDIF.
                    WHEN cl_abap_typedescr=>typekind_time.
                      REPLACE FIRST OCCURRENCE OF REGEX `(\d{2}):(\d{2}):(\d{2})` IN sdummy WITH `$1$2$3`
                      REPLACEMENT LENGTH match REPLACEMENT OFFSET pos. "#EC NOTEXT
                      IF sy-subrc EQ 0 AND pos EQ 0.
                        sdummy = sdummy(match).
                      ENDIF.
                    WHEN cl_abap_typedescr=>typekind_packed.
                      REPLACE FIRST OCCURRENCE OF REGEX `(\d{4})-?(\d{2})-?(\d{2})T(\d{2}):?(\d{2}):?(\d{2})(?:[\.,](\d{0,7}))?Z?` IN sdummy WITH `$1$2$3$4$5$6.$7`
                      REPLACEMENT LENGTH match REPLACEMENT OFFSET pos. "#EC NOTEXT
                      IF sy-subrc EQ 0 AND pos EQ 0.
                        sdummy = sdummy(match).
                      ENDIF.
                  ENDCASE.
                ELSEIF type_descr->type_kind EQ cl_abap_typedescr=>typekind_dref.
                  CREATE DATA lr_sdummy TYPE string.
                  MOVE sdummy TO lr_sdummy->*.
                  data ?= lr_sdummy.
                  RETURN.
                ENDIF.
              ENDIF.
              MOVE sdummy TO data. " to avoid crashes due to data type inconsistency
            ENDIF.
          WHEN `-`. " number
            IF type_descr IS NOT INITIAL.
              IF type_descr->kind EQ type_descr->kind_ref AND type_descr->type_kind EQ cl_abap_typedescr=>typekind_dref.
                CREATE DATA lr_idummy TYPE i.
                eat_number lr_idummy->*.                    "#EC NOTEXT
                data ?= lr_idummy.
              ELSEIF type_descr->kind EQ type_descr->kind_elem.
                eat_number data.                            "#EC NOTEXT
              ELSE.
                eat_number sdummy.                          "#EC NOTEXT
              ENDIF.
            ELSE.
              eat_number sdummy.                            "#EC NOTEXT
            ENDIF.
          WHEN OTHERS.
            FIND FIRST OCCURRENCE OF json+offset(1) IN `0123456789`.
            IF sy-subrc IS INITIAL. " number
              IF type_descr IS NOT INITIAL.
                IF type_descr->kind EQ type_descr->kind_ref AND type_descr->type_kind EQ cl_abap_typedescr=>typekind_dref.
                  CREATE DATA lr_idummy TYPE i.
                  eat_number lr_idummy->*.                  "#EC NOTEXT
                  data ?= lr_idummy.
                ELSEIF type_descr->kind EQ type_descr->kind_elem.
                  eat_number data.                          "#EC NOTEXT
                ELSE.
                  eat_number sdummy.                        "#EC NOTEXT
                ENDIF.
              ELSE.
                eat_number sdummy.                          "#EC NOTEXT
              ENDIF.
            ELSE. " true/false/null
              IF type_descr IS NOT INITIAL.
                IF type_descr->kind EQ type_descr->kind_ref AND type_descr->type_kind EQ cl_abap_typedescr=>typekind_dref.
                  CREATE DATA lr_bdummy TYPE bool.
                  eat_bool lr_bdummy->*.                    "#EC NOTEXT
                  data ?= lr_bdummy.
                ELSEIF type_descr->kind EQ type_descr->kind_elem.
                  eat_bool data.                            "#EC NOTEXT
                ELSE.
                  eat_bool sdummy.                          "#EC NOTEXT
                ENDIF.
              ELSE.
                eat_bool sdummy.                            "#EC NOTEXT
              ENDIF.
            ENDIF.
        ENDCASE.
      CATCH cx_sy_move_cast_error cx_sy_conversion_no_number cx_sy_conversion_overflow.
        CLEAR data.
    ENDTRY.
  ENDMETHOD.                    "restore_type
  METHOD string_to_xstring.
    DATA: lv_xstring TYPE xstring.
    CALL FUNCTION 'SSFC_BASE64_DECODE'
      EXPORTING
        b64data = in
      IMPORTING
        bindata = lv_xstring
      EXCEPTIONS
        OTHERS  = 1.
    IF sy-subrc IS INITIAL.
      MOVE lv_xstring TO out.
    ELSE.
      MOVE in TO out.
    ENDIF.
  ENDMETHOD.                    "string_to_xstring
  METHOD tribool_to_bool.
    IF iv_tribool EQ c_tribool-true.
      rv_bool = c_bool-true.
    ELSEIF iv_tribool EQ c_tribool-undefined.
      rv_bool = abap_undefined. " fall back to abap_undefined
    ENDIF.
  ENDMETHOD.                    "TRIBOOL_TO_BOOL
  METHOD bool_to_tribool.
    IF iv_bool EQ c_bool-true.
      rv_tribool = c_tribool-true.
    ELSEIF iv_bool EQ abap_undefined. " fall back for abap _bool
      rv_tribool = c_tribool-undefined.
    ELSE.
      rv_tribool = c_tribool-false.
    ENDIF.
  ENDMETHOD.                    "bool_to_tribool
  METHOD xstring_to_string.
    DATA: lv_xstring TYPE xstring.
    " let us fix data conversion issues here
    lv_xstring = in.
    CALL FUNCTION 'SSFC_BASE64_ENCODE'
      EXPORTING
        bindata = lv_xstring
      IMPORTING
        b64data = out
      EXCEPTIONS
        OTHERS  = 1.
    IF sy-subrc IS NOT INITIAL.
      MOVE in TO out.
    ENDIF.
  ENDMETHOD.                    "xstring_to_string
ENDCLASS.                    "/UI2/CL_JSON IMPLEMENTATION
