FUNCTION z_ti_display_amendent_fields.
*"----------------------------------------------------------------------
*"*"Local interface:
*"  TABLES
*"      IT_ZTISAMENDFID STRUCTURE  ZTISAMENDFID
*"  EXCEPTIONS
*"      NO_DATA
*"----------------------------------------------------------------------
  DATA: lt_dd03l LIKE dd03l OCCURS 0 WITH HEADER LINE,
        lt_dd04t LIKE dd04t OCCURS 0 WITH HEADER LINE,
        l_tabix  LIKE sy-tabix,
        l_count  TYPE i.

  it_amendfield[] = it_ztisamendfid[].

  IF it_amendfield[] IS INITIAL.
    MESSAGE e029 RAISING no_data.
  ENDIF.

  READ TABLE it_amendfield WITH KEY scrtext_m = space.
  IF sy-subrc EQ 0.
    SELECT *
      INTO CORRESPONDING FIELDS OF TABLE lt_dd03l
      FROM dd03l
       FOR ALL ENTRIES IN it_amendfield
     WHERE tabname    EQ  it_amendfield-tabname
       AND fieldname  EQ  it_amendfield-fieldname.

    SELECT *
      INTO CORRESPONDING FIELDS OF TABLE lt_dd04t
      FROM dd04t
       FOR ALL ENTRIES IN lt_dd03l
     WHERE rollname   EQ  lt_dd03l-rollname
       AND ddlanguage EQ  sy-langu.
    LOOP AT it_amendfield.
      l_tabix = sy-tabix.

      IF it_amendfield-scrtext_m  IS INITIAL.
        READ TABLE lt_dd03l
             WITH KEY tabname   = it_amendfield-tabname
                      fieldname = it_amendfield-fieldname.
        IF sy-subrc EQ 0.
          READ TABLE lt_dd04t WITH KEY rollname = lt_dd03l-rollname.
          IF sy-subrc EQ 0.
            it_amendfield-scrtext_m = lt_dd04t-scrtext_m.
            MODIFY it_amendfield INDEX l_tabix.
          ENDIF.
        ENDIF.
      ENDIF.
    ENDLOOP.
  ENDIF.

  CLEAR: ok-code.

  CALL SCREEN '0600' STARTING AT 1 1.

  it_ztisamendfid[] = it_amendfield[].

ENDFUNCTION.
