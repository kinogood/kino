FUNCTION zgtpp_input_alter_f4.
*"----------------------------------------------------------------------
*"*"Local Interface:
*"  IMPORTING
*"     VALUE(I_MATKL) TYPE  MATKL OPTIONAL
*"     VALUE(I_WERKS) TYPE  WERKS_D OPTIONAL
*"  TABLES
*"      IT_MATNR STRUCTURE  ZGTPPS0002 OPTIONAL
*"----------------------------------------------------------------------
  DATA : BEGIN OF lt_matnr OCCURS 0,
           matnr LIKE marc-matnr,
           maktx LIKE makt-maktx,
         END OF lt_matnr.

  DATA : lv_tabix     LIKE sy-tabix.

  DATA : lt_field        LIKE help_value OCCURS 0 WITH HEADER LINE,
         ls_selectfield  LIKE help_info-fieldname,
         ls_select_value LIKE help_info-fldvalue.

  CLEAR : lt_field, lt_field[], ls_selectfield, ls_select_value, lt_matnr, lt_matnr[].
  lt_field-tabname  = 'MARA'.
  lt_field-fieldname = 'MATNR'. "자재 코드
  lt_field-selectflag = 'X'.
  APPEND lt_field. CLEAR lt_field.
*& 아래 부분이 F4를 눌렀을 때, Hit List를 보여준다.
  lt_field-tabname     = 'MAKT'.
  lt_field-fieldname   = 'MAKTX'. "자재 코드 내역
  lt_field-selectflag  = ' '.
  APPEND lt_field. CLEAR lt_field.

  SELECT a~matnr, b~maktx
      INTO CORRESPONDING FIELDS OF TABLE @lt_matnr
      FROM mara AS a INNER JOIN makt AS b
          ON   a~matnr = b~matnr
          INNER JOIN marc AS c
          ON   a~matnr = c~matnr
          WHERE a~matkl EQ @i_matkl
               AND b~spras EQ @sy-langu
               AND c~werks EQ @i_werks.

  CALL FUNCTION 'HELP_VALUES_GET_NO_DD_NAME'
    EXPORTING
      titel                        = TEXT-t01
      selectfield                  = ls_selectfield
    IMPORTING
      ind                          = lv_tabix
      select_value                 = ls_select_value
    TABLES
      fields                       = lt_field
      full_table                   = lt_matnr
    EXCEPTIONS
      full_table_empty             = 1
      no_tablestructure_given      = 2
      no_tablefields_in_dictionary = 3
      more_then_one_selectfield    = 4
      no_selectfield               = 5
      OTHERS                       = 6.

  CHECK NOT lv_tabix IS INITIAL.

  CLEAR lt_matnr.
  READ TABLE lt_matnr INDEX lv_tabix.
  IF sy-subrc = 0.
    it_matnr-matnr  = lt_matnr-matnr.
    it_matnr-maktx = lt_matnr-maktx.
    APPEND it_matnr.
  ENDIF.

ENDFUNCTION.
