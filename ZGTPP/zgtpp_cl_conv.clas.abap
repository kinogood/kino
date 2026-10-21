CLASS zgtpp_cl_conv DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    TYPES:
      BEGIN OF ty_s_merge,
        name TYPE char30,
        text TYPE string,
      END OF ty_s_merge .
    TYPES:
      ty_t_merge TYPE TABLE OF ty_s_merge WITH DEFAULT KEY .

    DATA ms_usr01 TYPE usr01 .
    DATA mt_tcurx TYPE tt_tcurx .

    METHODS constructor .
    METHODS convert_string_to_qty
      IMPORTING
        !iv_input  TYPE string
      EXPORTING
        !ev_output TYPE any
      EXCEPTIONS
        convert_error .
    METHODS convert_string_to_amt
      IMPORTING
        !iv_input  TYPE string
        !iv_waers  TYPE waers
      EXPORTING
        !ev_output TYPE any
      EXCEPTIONS
        convert_error .
    METHODS convert_amt_to_string
      IMPORTING
        !iv_input  TYPE any
        !iv_waers  TYPE waers
      EXPORTING
        !ev_output TYPE any
      EXCEPTIONS
        convert_error .
    METHODS html_merge
      IMPORTING
        !iv_objid      TYPE w3objid
        !it_merge      TYPE ty_t_merge OPTIONAL
      RETURNING
        VALUE(rv_html) TYPE string
      EXCEPTIONS
        template_not_found .
    METHODS set_parameter_zbukrs
      IMPORTING
        !iv_bukrs TYPE bukrs .
    METHODS numeric_check
      IMPORTING
        !iv_input        TYPE string
      RETURNING
        VALUE(rv_output) TYPE string .
  PROTECTED SECTION.
  PRIVATE SECTION.

    METHODS clean_string
      IMPORTING
        !iv_input        TYPE string
      EXPORTING
        VALUE(ev_output) TYPE string .
    METHODS currency_converting_factor
      IMPORTING
        !iv_waers  TYPE waers
      EXPORTING
        !ev_factor TYPE isoc_factor
      EXCEPTIONS
        too_many_decimals .
ENDCLASS.



CLASS ZGTPP_CL_CONV IMPLEMENTATION.


  METHOD clean_string.

    DATA(lv_string) = iv_input.

    CASE ms_usr01-dcpfm.
      WHEN 'X'.
        TRANSLATE lv_string USING ', '.

      WHEN 'Y'.
        TRANSLATE lv_string USING ',.'.

      WHEN space.
        TRANSLATE lv_string USING '. '.
        TRANSLATE lv_string USING ',.'.
    ENDCASE.

    CONDENSE lv_string NO-GAPS.
    ev_output = lv_string.

  ENDMETHOD.


  METHOD constructor.

    CALL FUNCTION 'CETA_USR01_READ'
      EXPORTING
        bname     = sy-uname
      IMPORTING
        usr01_exp = ms_usr01.

    SELECT currkey, currdec
      INTO TABLE @mt_tcurx
      FROM tcurx
     ORDER BY currkey, currdec.

  ENDMETHOD.


  METHOD convert_amt_to_string.
    DATA lv_amount TYPE char20.

    CHECK iv_input IS NOT INITIAL AND iv_waers IS NOT INITIAL.

    WRITE iv_input CURRENCY iv_waers TO lv_amount LEFT-JUSTIFIED.

    clean_string( EXPORTING  iv_input  = CONV #( lv_amount )
                  IMPORTING  ev_output = DATA(lv_string) ).

    CATCH SYSTEM-EXCEPTIONS arithmetic_errors = 1
                            conversion_errors = 2.
      ev_output = lv_string.
    ENDCATCH.

    IF sy-subrc IS NOT INITIAL.
      CLEAR ev_output.
      RAISE convert_error.
    ENDIF.

  ENDMETHOD.


  METHOD convert_string_to_amt.

    clean_string( EXPORTING iv_input  = iv_input
                  IMPORTING ev_output = DATA(lv_amount) ).

    CATCH SYSTEM-EXCEPTIONS arithmetic_errors = 1
                            conversion_errors = 2.
      ev_output = lv_amount.

      IF ev_output IS INITIAL AND iv_waers IS INITIAL.
        RETURN.
      ENDIF.
    ENDCATCH.

    IF sy-subrc IS NOT INITIAL.
      CLEAR ev_output.
      RAISE convert_error.
    ENDIF.

    IF iv_waers IS NOT INITIAL.
      currency_converting_factor( EXPORTING  iv_waers          = iv_waers
                                  IMPORTING  ev_factor         = DATA(lv_factor)
                                  EXCEPTIONS too_many_decimals = 1
                                             OTHERS            = 2 ).
      IF sy-subrc IS INITIAL AND lv_factor IS NOT INITIAL.
        ev_output = lv_amount / lv_factor.
      ELSE.
        CLEAR ev_output.
        RAISE convert_error.
      ENDIF.
    ELSE.
      CLEAR ev_output.
      RAISE convert_error.
    ENDIF.

  ENDMETHOD.


  METHOD convert_string_to_qty.

    clean_string( EXPORTING iv_input  = iv_input
                  IMPORTING ev_output = DATA(lv_quantity) ).

    CATCH SYSTEM-EXCEPTIONS arithmetic_errors = 1
                            conversion_errors = 2.
      ev_output = lv_quantity.
    ENDCATCH.

    IF sy-subrc IS NOT INITIAL.
      CLEAR ev_output.
      RAISE convert_error.
    ENDIF.

  ENDMETHOD.


  METHOD currency_converting_factor.
    DATA lv_cur_factor TYPE isoc_factor.

    READ TABLE mt_tcurx INTO DATA(ls_tcurx) WITH KEY currkey = iv_waers BINARY SEARCH.

    IF sy-subrc NE 0.
      ls_tcurx-currdec = 2.
    ENDIF.

    IF ls_tcurx-currdec GT 5.
      RAISE too_many_decimals.
    ENDIF.

    lv_cur_factor = 100.

    IF ls_tcurx-currdec NE 0.
      DO ls_tcurx-currdec TIMES.
        lv_cur_factor = lv_cur_factor / 10.
      ENDDO.
    ENDIF.

    IF lv_cur_factor = 0.
      RAISE too_many_decimals.
    ENDIF.

    ev_factor = lv_cur_factor.

  ENDMETHOD.


  METHOD html_merge.
    DATA lt_html TYPE TABLE OF w3html.

    DATA(ls_key) = VALUE wwwdataid( objid = iv_objid ).
    IMPORT html TO lt_html FROM DATABASE wwwdata(ht) ID ls_key.

    IF sy-subrc IS NOT INITIAL.
      RAISE template_not_found.
    ENDIF.

    rv_html = REDUCE #( INIT lv_html = concat_lines_of( table = lt_html )
                        FOR  ls_merge IN it_merge
                        NEXT lv_html = replace( val  = lv_html
                                                sub  = ls_merge-name
                                                with = ls_merge-text
                                                occ  = 0 ) ) .

  ENDMETHOD.


  METHOD numeric_check.
    DATA lv_htype TYPE dd01v-datatype.

    CALL FUNCTION 'NUMERIC_CHECK'
      EXPORTING
        string_in  = iv_input
      IMPORTING
        string_out = rv_output
        htype      = lv_htype.

    CHECK lv_htype NE 'NUMC'.

    CLEAR rv_output.

  ENDMETHOD.


  METHOD set_parameter_zbukrs.
*    CONSTANTS lc_zbukrs TYPE dd04d-memoryid VALUE 'ZBUKRS'.
*
*    SELECT SINGLE zbukrs
*      INTO @DATA(lv_zbukrs)
*      FROM zcat45000
*     WHERE bukrs EQ @iv_bukrs.
*
*    CHECK sy-subrc IS INITIAL.
*
*    SET PARAMETER ID lc_zbukrs FIELD lv_zbukrs.

  ENDMETHOD.
ENDCLASS.
