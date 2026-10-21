*&---------------------------------------------------------------------*
*& Include          ZGTPPR1150F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form initialization
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM initialization.

  GET PARAMETER ID 'WRK'  FIELD p_werks.
  GET PARAMETER ID 'ZSPG' FIELD p_spgcd.

  PERFORM get_parameter_description.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form start_of_selection
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM start_of_selection.

  PERFORM get_master_data.

  CASE abap_true.
    WHEN p_t1140. "// (군포) 생산/물자 스크랩코드.
      PERFORM retrieve_data_from_zgtppt1140.

    WHEN p_t1120. "// (전주) 생산/물자 스크랩코드 .
      PERFORM retrieve_data_from_zgtppt1120.

    WHEN p_t1130. "// (군포) 탈피 후 코드 및 환산율.
      PERFORM retrieve_data_from_zgtppt1130.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form end_of_selection
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM end_of_selection .

  PERFORM call_screen_100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form user_command_exit
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM user_command_exit .

  PERFORM dequeue_table.

  IF gr_list IS BOUND.
    gr_list->free( ).
    CLEAR gr_list.
  ENDIF.

  LEAVE TO SCREEN 0.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form confirmation_popup
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM confirmation_popup USING pv_question pv_answer.

  CALL FUNCTION 'POPUP_TO_CONFIRM'
    EXPORTING
      titlebar       = TEXT-c01
      text_question  = pv_question
    IMPORTING
      answer         = pv_answer
    EXCEPTIONS
      text_not_found = 1
      OTHERS         = 2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_field_catalog
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM handle_field_catalog.

  CASE abap_true.
    WHEN p_t1140. "// (군포) 생산/물자 스크랩코드.
      PERFORM modify_fcat_in_t1140.

    WHEN p_t1120. "// (전주) 생산/물자 스크랩코드 .
      PERFORM modify_fcat_in_t1120.

    WHEN p_t1130. "// (군포) 탈피 후 코드 및 환산율.
      PERFORM modify_fcat_in_t1130.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_layout
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM handle_layout.

  TRY.
      gr_list->ms_layout = VALUE #( BASE gr_list->ms_layout  stylefname = 'STYLE' ).

    CATCH cx_root.

  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form at_selection_screen_output
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM at_selection_screen_output .

  PERFORM get_parameter_description.

  LOOP AT SCREEN INTO DATA(ls_screen).
    CASE ls_screen-group1.
      WHEN 'TXT'.
        ls_screen-intensified = 1.
        MODIFY SCREEN FROM ls_screen.
    ENDCASE.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form at_selection_screen
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM at_selection_screen .

  CASE sscrfields-ucomm.
    WHEN gc_fcode-onli. "// 실행.
      PERFORM check_sel_screen_input_value.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_sel_screen_input_value
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM check_sel_screen_input_value.

*// 플랜트.
  IF p_werks IS INITIAL.
    MESSAGE e164(m3) DISPLAY LIKE 'S'.
  ELSE.
    SELECT SINGLE name1
      INTO @p_name1
      FROM t001w
     WHERE werks EQ @p_werks.

    IF sy-subrc IS NOT INITIAL.
      MESSAGE e011(vf) WITH p_werks DISPLAY LIKE 'S'.
    ENDIF.
  ENDIF.

*// SPG코드.
  IF p_spgcd IS INITIAL.
    MESSAGE e031 WITH TEXT-002 DISPLAY LIKE 'S'.
  ELSE.
    SELECT SINGLE descr
      INTO @p_descr
      FROM zppt0107
     WHERE werks EQ @p_werks
       AND spgcd EQ @p_spgcd.

    IF sy-subrc IS NOT INITIAL.
      MESSAGE e000 WITH TEXT-e05 DISPLAY LIKE 'S'.
    ENDIF.
  ENDIF.

  PERFORM enqueue_table.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form call_screen_100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM call_screen_100 .

  gv_tpar1 = COND #( WHEN p_t1140 EQ abap_true THEN TEXT-c11
                     WHEN p_t1120 EQ abap_true THEN TEXT-c12
                     WHEN p_t1130 EQ abap_true THEN TEXT-c13 ).

  gv_tpar2 = |{ p_werks } { p_name1 } / { p_spgcd } { p_descr }|.

  gt_exclude = COND #( WHEN sy-tcode NE gc_tcode-zgtppr1150v THEN VALUE #( ( gc_fcode-save ) ) ).

  CALL SCREEN 100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_toolbar
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM handle_toolbar  USING pr_object TYPE REF TO cl_alv_event_toolbar_set.

  CHECK sy-tcode EQ gc_tcode-zgtppr1150v.

  pr_object->mt_toolbar = VALUE #( BASE pr_object->mt_toolbar
                                  ( butn_type = 3 )
                                  ( function  = gc_fcode-insert_row
                                    icon      = icon_insert_row
                                    quickinfo = TEXT-b01 )
                                  ( function  = gc_fcode-delete_row
                                    icon      = icon_delete_row
                                    quickinfo = TEXT-b02 ) ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_user_command
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM handle_user_command  USING pv_ucomm.

  CASE abap_true.
    WHEN p_t1140. "// (군포) 생산/물자 스크랩코드.
      PERFORM user_command_in_t1140 USING pv_ucomm.

    WHEN p_t1120. "// (전주) 생산/물자 스크랩코드 .
      PERFORM user_command_in_t1120 USING pv_ucomm.

    WHEN p_t1130. "// (군포) 탈피 후 코드 및 환산율.
      PERFORM user_command_in_t1130 USING pv_ucomm.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_parameter_description
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM get_parameter_description .

  CLEAR: p_name1, p_descr.

  IF p_werks IS NOT INITIAL.
    SELECT SINGLE name1
      INTO @p_name1
      FROM t001w
     WHERE werks EQ @p_werks.
  ENDIF.

  IF p_werks IS NOT INITIAL AND p_spgcd IS NOT INITIAL.
    SELECT SINGLE descr
      INTO @p_descr
      FROM zppt0107
     WHERE werks EQ @p_werks
       AND spgcd EQ @p_spgcd.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form enqueue_table
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM enqueue_table .

  CHECK sy-tcode EQ gc_tcode-zgtppr1150v.

  CALL FUNCTION 'ENQUEUE_E_TABLE'
    EXPORTING
      tabname        = COND #( WHEN p_t1120 EQ abap_true THEN gc_table-zgtppt1120
                               WHEN p_t1130 EQ abap_true THEN gc_table-zgtppt1130
                               WHEN p_t1140 EQ abap_true THEN gc_table-zgtppt1140 )
      varkey         = CONV vim_enqkey( |{ p_werks }{ p_spgcd }| )
    EXCEPTIONS
      foreign_lock   = 1
      system_failure = 2
      OTHERS         = 3.

  IF sy-subrc IS NOT INITIAL.
    MESSAGE ID sy-msgid TYPE 'E' NUMBER sy-msgno
                                 WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4 DISPLAY LIKE 'S'.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form dequeue_table
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM dequeue_table .

  CHECK sy-tcode EQ gc_tcode-zgtppr1150v.

  CALL FUNCTION 'DEQUEUE_E_TABLE'
    EXPORTING
      tabname = COND #( WHEN p_t1120 EQ abap_true THEN gc_table-zgtppt1120
                        WHEN p_t1130 EQ abap_true THEN gc_table-zgtppt1130
                        WHEN p_t1140 EQ abap_true THEN gc_table-zgtppt1140 )
      varkey  = CONV vim_enqkey( |{ p_werks }{ p_spgcd }| ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form modify_fcat_in_t1120
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM modify_fcat_in_t1120 .

  LOOP AT gr_list->mt_fcat REFERENCE INTO DATA(lr_fcat).
    lr_fcat->col_opt = 'A'.

    CASE lr_fcat->fieldname.
      WHEN 'WERKS'.
        lr_fcat->coltext    = TEXT-f20.
        lr_fcat->emphasize  = 'C110'.
        lr_fcat->just       = 'C'.

      WHEN 'SPGCD'.
        lr_fcat->coltext    = TEXT-f21.
        lr_fcat->emphasize  = 'C110'.
        lr_fcat->just       = 'C'.

      WHEN 'LGORT'.
        lr_fcat->coltext    = TEXT-f22.
        lr_fcat->edit       = COND #( WHEN sy-tcode EQ gc_tcode-zgtppr1150v THEN abap_true ).
        lr_fcat->just       = 'C'.
        lr_fcat->mark       = abap_true.

      WHEN 'SCGRP'.
        lr_fcat->coltext    = TEXT-f23.
        lr_fcat->edit       = COND #( WHEN sy-tcode EQ gc_tcode-zgtppr1150v THEN abap_true ).
        lr_fcat->mark       = abap_true.
        lr_fcat->f4availabl = abap_true.
        lr_fcat->ref_field  = space.
        lr_fcat->ref_table  = space.

      WHEN 'SCTXT'.
        lr_fcat->coltext    = TEXT-f24.

      WHEN 'MATNR'.
        lr_fcat->coltext    = TEXT-f26.
        lr_fcat->edit       = COND #( WHEN sy-tcode EQ gc_tcode-zgtppr1150v THEN abap_true ).
        lr_fcat->mark       = abap_true.

      WHEN 'MAKTX'.
        lr_fcat->coltext    = TEXT-f27.

      WHEN 'WERKS_M'.
        lr_fcat->coltext    = TEXT-f28.
        lr_fcat->edit       = COND #( WHEN sy-tcode EQ gc_tcode-zgtppr1150v THEN abap_true ).
        lr_fcat->just       = 'C'.
        lr_fcat->mark       = abap_true.

      WHEN 'LGORT_M'.
        lr_fcat->coltext    = TEXT-f29.
        lr_fcat->edit       = COND #( WHEN sy-tcode EQ gc_tcode-zgtppr1150v THEN abap_true ).
        lr_fcat->just       = 'C'.
        lr_fcat->mark       = abap_true.

      WHEN 'MATNR_M'.
        lr_fcat->coltext    = TEXT-f30.
        lr_fcat->edit       = COND #( WHEN sy-tcode EQ gc_tcode-zgtppr1150v THEN abap_true ).

      WHEN 'MAKTX_M'.
        lr_fcat->coltext    = TEXT-f31.

      WHEN 'STATUS'.
        lr_fcat->coltext    = TEXT-f13.
        lr_fcat->just       = 'C'.
        lr_fcat->tech       = COND #( WHEN sy-tcode NE gc_tcode-zgtppr1150v THEN abap_true ).

      WHEN 'MESSAGE'.
        lr_fcat->coltext    = TEXT-f14.
        lr_fcat->tech       = COND #( WHEN sy-tcode NE gc_tcode-zgtppr1150v THEN abap_true ).

      WHEN 'CRDAT'.
        lr_fcat->coltext    = TEXT-f33.
        lr_fcat->just       = 'C'.

      WHEN 'CRTIM'.
        lr_fcat->coltext    = TEXT-f34.
        lr_fcat->just       = 'C'.

      WHEN 'CRNAM'.
        lr_fcat->coltext    = TEXT-f35.
        lr_fcat->just       = 'C'.

      WHEN 'CHDAT'.
        lr_fcat->coltext    = TEXT-f36.
        lr_fcat->just       = 'C'.

      WHEN 'CHTIM'.
        lr_fcat->coltext    = TEXT-f37.
        lr_fcat->just       = 'C'.

      WHEN 'CHNAM'.
        lr_fcat->coltext    = TEXT-f38.
        lr_fcat->just       = 'C'.

      WHEN OTHERS.
        lr_fcat->tech = abap_true.
    ENDCASE.

    lr_fcat->tooltip = lr_fcat->reptext = lr_fcat->coltext.
    lr_fcat->scrtext_s = lr_fcat->scrtext_m = lr_fcat->scrtext_l = lr_fcat->coltext.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form modify_fcat_in_t1130
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM modify_fcat_in_t1130 .

  LOOP AT gr_list->mt_fcat REFERENCE INTO DATA(lr_fcat).
    lr_fcat->col_opt = 'A'.

    CASE lr_fcat->fieldname.
      WHEN 'WERKS'.
        lr_fcat->coltext    = TEXT-f20.
        lr_fcat->emphasize  = 'C110'.
        lr_fcat->just       = 'C'.

      WHEN 'SPGCD'.
        lr_fcat->coltext    = TEXT-f21.
        lr_fcat->emphasize  = 'C110'.
        lr_fcat->just       = 'C'.

      WHEN 'LGORT'.
        lr_fcat->coltext    = TEXT-f22.
        lr_fcat->edit       = COND #( WHEN sy-tcode EQ gc_tcode-zgtppr1150v THEN abap_true ).
        lr_fcat->just       = 'C'.

      WHEN 'SCGRP'.
        lr_fcat->coltext    = TEXT-f23.
        lr_fcat->edit       = COND #( WHEN sy-tcode EQ gc_tcode-zgtppr1150v THEN abap_true ).
        lr_fcat->mark       = abap_true.
        lr_fcat->f4availabl = abap_true.
        lr_fcat->ref_field  = space.
        lr_fcat->ref_table  = space.

      WHEN 'SCTXT'.
        lr_fcat->coltext    = TEXT-f24.
        lr_fcat->just       = 'C'.

      WHEN 'MATNR_T'.
        lr_fcat->coltext    = TEXT-f44.
        lr_fcat->edit       = COND #( WHEN sy-tcode EQ gc_tcode-zgtppr1150v THEN abap_true ).
        lr_fcat->mark       = abap_true.

      WHEN 'MAKTX_T'.
        lr_fcat->coltext    = TEXT-f45.

      WHEN 'USEYN'.
        lr_fcat->coltext    = TEXT-f46.
        lr_fcat->edit       = COND #( WHEN sy-tcode EQ gc_tcode-zgtppr1150v THEN abap_true ).
        lr_fcat->checkbox   = abap_true.
        lr_fcat->just       = 'C'.

      WHEN 'SCRAT'.
        lr_fcat->coltext    = TEXT-f47.
        lr_fcat->edit       = COND #( WHEN sy-tcode EQ gc_tcode-zgtppr1150v THEN abap_true ).
        lr_fcat->mark       = abap_true.

      WHEN 'STATUS'.
        lr_fcat->coltext    = TEXT-f13.
        lr_fcat->just       = 'C'.
        lr_fcat->tech       = COND #( WHEN sy-tcode NE gc_tcode-zgtppr1150v THEN abap_true ).

      WHEN 'MESSAGE'.
        lr_fcat->coltext    = TEXT-f14.
        lr_fcat->tech       = COND #( WHEN sy-tcode NE gc_tcode-zgtppr1150v THEN abap_true ).

      WHEN 'CRDAT'.
        lr_fcat->coltext    = TEXT-f48.
        lr_fcat->just       = 'C'.

      WHEN 'CRTIM'.
        lr_fcat->coltext    = TEXT-f49.
        lr_fcat->just       = 'C'.

      WHEN 'CRNAM'.
        lr_fcat->coltext    = TEXT-f50.
        lr_fcat->just       = 'C'.

      WHEN 'CHDAT'.
        lr_fcat->coltext    = TEXT-f51.
        lr_fcat->just       = 'C'.

      WHEN 'CHTIM'.
        lr_fcat->coltext    = TEXT-f52.
        lr_fcat->just       = 'C'.

      WHEN 'CHNAM'.
        lr_fcat->coltext    = TEXT-f53.
        lr_fcat->just       = 'C'.

      WHEN OTHERS.
        lr_fcat->tech = abap_true.
    ENDCASE.

    lr_fcat->tooltip = lr_fcat->reptext = lr_fcat->coltext.
    lr_fcat->scrtext_s = lr_fcat->scrtext_m = lr_fcat->scrtext_l = lr_fcat->coltext.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form modify_fcat_in_t1140
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM modify_fcat_in_t1140 .

  LOOP AT gr_list->mt_fcat REFERENCE INTO DATA(lr_fcat).
    lr_fcat->col_opt = 'A'.

    CASE lr_fcat->fieldname.
      WHEN 'WERKS'.
        lr_fcat->coltext    = TEXT-f01.
        lr_fcat->emphasize  = 'C110'.
        lr_fcat->just       = 'C'.

      WHEN 'SPGCD'.
        lr_fcat->coltext    = TEXT-f02.
        lr_fcat->emphasize  = 'C110'.
        lr_fcat->just       = 'C'.

      WHEN 'MATKL'.
        lr_fcat->coltext    = TEXT-f03.
        lr_fcat->edit       = COND #( WHEN sy-tcode EQ gc_tcode-zgtppr1150v THEN abap_true ).
        lr_fcat->mark       = abap_true.

      WHEN 'WGBEZ'.
        lr_fcat->coltext    = TEXT-f04.

      WHEN 'MATNR'.
        lr_fcat->coltext    = TEXT-f05.
        lr_fcat->edit       = COND #( WHEN sy-tcode EQ gc_tcode-zgtppr1150v THEN abap_true ).
        lr_fcat->mark       = abap_true.

      WHEN 'MAKTX'.
        lr_fcat->coltext    = TEXT-f06.

      WHEN 'WERKS_M'.
        lr_fcat->coltext    = TEXT-f40.
        lr_fcat->edit       = COND #( WHEN sy-tcode EQ gc_tcode-zgtppr1150v THEN abap_true ).
        lr_fcat->mark       = abap_true.

      WHEN 'LGORT_M'.
        lr_fcat->coltext    = TEXT-f41.
        lr_fcat->edit       = COND #( WHEN sy-tcode EQ gc_tcode-zgtppr1150v THEN abap_true ).
        lr_fcat->mark       = abap_true.

      WHEN 'MATNR_M'.
        lr_fcat->coltext    = TEXT-f42.
        lr_fcat->edit       = COND #( WHEN sy-tcode EQ gc_tcode-zgtppr1150v THEN abap_true ).
        lr_fcat->mark       = abap_true.

      WHEN 'MAKTX_M'.
        lr_fcat->coltext    = TEXT-f31.

      WHEN 'STATUS'.
        lr_fcat->coltext    = TEXT-f13.
        lr_fcat->just       = 'C'.
        lr_fcat->tech       = COND #( WHEN sy-tcode NE gc_tcode-zgtppr1150v THEN abap_true ).

      WHEN 'MESSAGE'.
        lr_fcat->coltext    = TEXT-f14.
        lr_fcat->tech       = COND #( WHEN sy-tcode NE gc_tcode-zgtppr1150v THEN abap_true ).

      WHEN 'CRDAT'.
        lr_fcat->coltext    = TEXT-f07.
        lr_fcat->just       = 'C'.

      WHEN 'CRTIM'.
        lr_fcat->coltext    = TEXT-f08.
        lr_fcat->just       = 'C'.

      WHEN 'CRNAM'.
        lr_fcat->coltext    = TEXT-f09.
        lr_fcat->just       = 'C'.

      WHEN 'CHDAT'.
        lr_fcat->coltext    = TEXT-f10.
        lr_fcat->just       = 'C'.

      WHEN 'CHTIM'.
        lr_fcat->coltext    = TEXT-f11.
        lr_fcat->just       = 'C'.

      WHEN 'CHNAM'.
        lr_fcat->coltext    = TEXT-f12.
        lr_fcat->just       = 'C'.

      WHEN OTHERS.
        lr_fcat->tech = abap_true.
    ENDCASE.

    lr_fcat->tooltip = lr_fcat->reptext = lr_fcat->coltext.
    lr_fcat->scrtext_s = lr_fcat->scrtext_m = lr_fcat->scrtext_l = lr_fcat->coltext.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form user_command_in_t1120
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM user_command_in_t1120  USING  pv_ucomm.

  CASE pv_ucomm.
    WHEN gc_fcode-insert_row. "// 행 추가.
      PERFORM insert_row_in_t1120.

    WHEN gc_fcode-delete_row. "// 행 삭제.
      PERFORM delete_row_in_t1120.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form user_command_in_t1130
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM user_command_in_t1130 USING  pv_ucomm.

  CASE pv_ucomm.
    WHEN gc_fcode-insert_row. "// 행 추가.
      PERFORM insert_row_in_t1130.

    WHEN gc_fcode-delete_row. "// 행 삭제.
      PERFORM delete_row_in_t1130.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form user_command_in_t1140
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM user_command_in_t1140  USING  pv_ucomm.

  CASE pv_ucomm.
    WHEN gc_fcode-insert_row. "// 행 추가.
      PERFORM insert_row_in_t1140.

    WHEN gc_fcode-delete_row. "// 행 삭제.
      PERFORM delete_row_in_t1140.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_data_changed
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM handle_data_changed  USING pr_data_changed TYPE REF TO cl_alv_changed_data_protocol
                                pv_ucomm TYPE sy-ucomm.

  CASE abap_true.
    WHEN p_t1140. "// (군포) 생산/물자 스크랩코드.
      PERFORM data_changed_in_t1140 USING pr_data_changed pv_ucomm.

    WHEN p_t1120. "// (전주) 생산/물자 스크랩코드 .
      PERFORM data_changed_in_t1120 USING pr_data_changed pv_ucomm.

    WHEN p_t1130. "// (군포) 탈피 후 코드 및 환산율.
      PERFORM data_changed_in_t1130 USING pr_data_changed pv_ucomm.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form data_changed_in_t1120
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM data_changed_in_t1120  USING pr_data_changed TYPE REF TO cl_alv_changed_data_protocol
                                  pv_ucomm TYPE sy-ucomm.

  DATA lr_t1120 TYPE REF TO ty_s_t1120.
  DATA ls_t1120 TYPE ty_s_t1120.

  PERFORM set_defalut_value_of_t1120 USING ls_t1120.

  LOOP AT pr_data_changed->mt_inserted_rows INTO DATA(ls_insert_row).
    pr_data_changed->modify_cell( i_row_id = ls_insert_row-row_id: i_fieldname = 'WERKS'  i_value = ls_t1120-werks ),
                                                                   i_fieldname = 'SPGCD'  i_value = ls_t1120-spgcd ),
                                                                   i_fieldname = 'INIT'   i_value = ls_t1120-init ).
  ENDLOOP.

  LOOP AT pr_data_changed->mp_mod_rows->* REFERENCE INTO lr_t1120.
    READ TABLE pr_data_changed->mt_mod_cells INTO DATA(ls_cell)
                                             WITH KEY tabix = sy-tabix.

    PERFORM field_valid_check_in_t1120 USING lr_t1120->*.
    PERFORM modify_cell_in_t1120       USING pr_data_changed ls_cell lr_t1120->*.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form data_changed_in_t1130
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM data_changed_in_t1130  USING pr_data_changed TYPE REF TO cl_alv_changed_data_protocol
                                  pv_ucomm TYPE sy-ucomm.

  DATA lr_t1130 TYPE REF TO ty_s_t1130.
  DATA ls_t1130 TYPE ty_s_t1130.

  PERFORM set_defalut_value_of_t1130 USING ls_t1130.

  LOOP AT pr_data_changed->mt_inserted_rows INTO DATA(ls_insert_row).
    pr_data_changed->modify_cell( i_row_id = ls_insert_row-row_id: i_fieldname = 'WERKS'  i_value = ls_t1130-werks ),
                                                                   i_fieldname = 'SPGCD'  i_value = ls_t1130-spgcd ),
                                                                   i_fieldname = 'INIT'   i_value = ls_t1130-init ).
  ENDLOOP.

  LOOP AT pr_data_changed->mp_mod_rows->* REFERENCE INTO lr_t1130.
    READ TABLE pr_data_changed->mt_mod_cells INTO DATA(ls_cell)
                                             WITH KEY tabix = sy-tabix.

    PERFORM field_valid_check_in_t1130 USING lr_t1130->*.
    PERFORM modify_cell_in_t1130       USING pr_data_changed ls_cell lr_t1130->*.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form data_changed_in_t1140
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM data_changed_in_t1140  USING pr_data_changed TYPE REF TO cl_alv_changed_data_protocol
                                  pv_ucomm TYPE sy-ucomm.

  DATA lr_t1140 TYPE REF TO ty_s_t1140.
  DATA ls_t1140 TYPE ty_s_t1140.

  PERFORM set_defalut_value_of_t1140 USING ls_t1140.

  LOOP AT pr_data_changed->mt_inserted_rows INTO DATA(ls_insert_row).
    pr_data_changed->modify_cell( i_row_id = ls_insert_row-row_id: i_fieldname = 'WERKS'  i_value = ls_t1140-werks ),
                                                                   i_fieldname = 'SPGCD'  i_value = ls_t1140-spgcd ),
                                                                   i_fieldname = 'INIT'   i_value = ls_t1140-init ).
  ENDLOOP.

  LOOP AT pr_data_changed->mp_mod_rows->* REFERENCE INTO lr_t1140.
    READ TABLE pr_data_changed->mt_mod_cells INTO DATA(ls_cell)
                                             WITH KEY tabix = sy-tabix.

    PERFORM field_valid_check_in_t1140 USING lr_t1140->*.
    PERFORM modify_cell_in_t1140       USING pr_data_changed ls_cell lr_t1140->*.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form field_valid_check_in_t1120
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM field_valid_check_in_t1120  USING ps_t1120 TYPE ty_s_t1120.

  CLEAR: ps_t1120-status, ps_t1120-message, ps_t1120-return.

  PERFORM check_input_value_in_t1120 USING ps_t1120.
  PERFORM check_mandt_field_in_t1120 USING ps_t1120.

  IF ps_t1120-return IS NOT INITIAL.
    ps_t1120-status  = icon_led_red.
    ps_t1120-message = VALUE #( ps_t1120-return[ 1 ]-message OPTIONAL ).
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form field_valid_check_in_t1130
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM field_valid_check_in_t1130  USING ps_t1130 TYPE ty_s_t1130.

  CLEAR: ps_t1130-status, ps_t1130-message, ps_t1130-return.

  PERFORM check_input_value_in_t1130 USING ps_t1130.
  PERFORM check_mandt_field_in_t1130 USING ps_t1130.

  IF ps_t1130-return IS NOT INITIAL.
    ps_t1130-status  = icon_led_red.
    ps_t1130-message = VALUE #( ps_t1130-return[ 1 ]-message OPTIONAL ).
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form field_valid_check_in_t1140
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM field_valid_check_in_t1140  USING ps_t1140 TYPE ty_s_t1140.

  CLEAR: ps_t1140-status, ps_t1140-message, ps_t1140-return.

  PERFORM check_input_value_in_t1140 USING ps_t1140.
  PERFORM check_mandt_field_in_t1140 USING ps_t1140.

  IF ps_t1140-return IS NOT INITIAL.
    ps_t1140-status  = icon_led_red.
    ps_t1140-message = VALUE #( ps_t1140-return[ 1 ]-message OPTIONAL ).
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_input_value_in_t1120
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM check_input_value_in_t1120  USING ps_t1120 TYPE ty_s_t1120.

  CLEAR: ps_t1120-init, ps_t1120-sctxt, ps_t1120-maktx, ps_t1120-maktx_m.

*// 생산저장위치.
  IF ps_t1120-lgort IS NOT INITIAL.
    READ TABLE gt_t001l TRANSPORTING NO FIELDS WITH TABLE KEY werks = ps_t1120-werks
                                                              lgort = ps_t1120-lgort.
    IF sy-subrc IS NOT INITIAL.
      MESSAGE e103(m3) WITH ps_t1120-lgort ps_t1120-werks INTO DATA(lv_message).
      ps_t1120-return = VALUE #( BASE ps_t1120-return ( type = 'E' field = TEXT-f22 message = lv_message ) ).
    ENDIF.
  ENDIF.

*// 스크랩분류코드.
  IF ps_t1120-scgrp IS NOT INITIAL.
    READ TABLE gt_zgtppt1010 INTO DATA(ls_zgtppt1010) WITH KEY codegrp = gc_codegrp-4070
                                                               fld_01  = ps_t1120-werks
                                                               fld_02  = ps_t1120-scgrp BINARY SEARCH.
    IF sy-subrc IS INITIAL.
      ps_t1120-sctxt = ls_zgtppt1010-fld_03.
    ELSE.
      ps_t1120-return = VALUE #( BASE ps_t1120-return ( type = 'E'  field = TEXT-f23  message = TEXT-e02 ) ).
    ENDIF.
  ENDIF.

*// 생산 스크랩코드.
  IF ps_t1120-matnr IS NOT INITIAL.
    PERFORM get_material_desc USING ps_t1120-matnr ps_t1120-maktx.

    SELECT SINGLE @abap_true
      INTO @DATA(lv_check)
      FROM marc
     WHERE marc~matnr EQ @ps_t1120-matnr
       AND marc~werks EQ @ps_t1120-werks.

    IF sy-subrc IS NOT INITIAL.
      MESSAGE e200(m3) WITH ps_t1120-matnr ps_t1120-werks INTO lv_message.
      ps_t1120-return = VALUE #( BASE ps_t1120-return ( type = 'E'  field = TEXT-f26  message = lv_message ) ).
    ENDIF.
  ENDIF.

*// 물자플랜트.
  IF ps_t1120-werks_m IS NOT INITIAL.
    READ TABLE gt_t001w TRANSPORTING NO FIELDS WITH TABLE KEY werks = ps_t1120-werks_m.

    IF sy-subrc IS NOT INITIAL.
      MESSAGE e011(vf) WITH ps_t1120-werks_m INTO lv_message.
      ps_t1120-return = VALUE #( BASE ps_t1120-return ( type = 'E'  field = TEXT-f28  message = lv_message ) ).
    ENDIF.
  ENDIF.

*// 물자저장위치.
  IF ps_t1120-lgort_m IS NOT INITIAL.
    READ TABLE gt_t001l TRANSPORTING NO FIELDS WITH TABLE KEY werks = ps_t1120-werks_m
                                                              lgort = ps_t1120-lgort_m.
    IF sy-subrc IS NOT INITIAL.
      MESSAGE e103(m3) WITH ps_t1120-lgort_m ps_t1120-werks_m INTO lv_message.
      ps_t1120-return = VALUE #( BASE ps_t1120-return ( type = 'E'  field = TEXT-f29  message = lv_message ) ).
    ENDIF.
  ENDIF.

*// 물자 스크랩코드.
  IF ps_t1120-matnr_m IS NOT INITIAL.
    PERFORM get_material_desc USING ps_t1120-matnr_m ps_t1120-maktx_m.

    SELECT SINGLE @abap_true
      INTO @lv_check
      FROM marc
     WHERE marc~matnr EQ @ps_t1120-matnr_m
       AND marc~werks EQ @ps_t1120-werks_m.

    IF sy-subrc IS NOT INITIAL.
      MESSAGE e200(m3) WITH ps_t1120-matnr_m ps_t1120-werks_m INTO lv_message.
      ps_t1120-return = VALUE #( BASE ps_t1120-return ( type = 'E'  field = TEXT-f30  message = lv_message ) ).
    ENDIF.
  ENDIF.

  IF ps_t1120-matnr IS NOT INITIAL AND ps_t1120-matnr EQ ps_t1120-matnr_m.
    ps_t1120-return = VALUE #( BASE ps_t1120-return ( type = 'E'  field = TEXT-f30  message = TEXT-e21 ) ).
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_input_value_in_t1130
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM check_input_value_in_t1130  USING ps_t1130 TYPE ty_s_t1130.

  CLEAR: ps_t1130-init, ps_t1130-sctxt, ps_t1130-maktx_t.

*// 생산저장위치.
  IF ps_t1130-lgort IS NOT INITIAL.
    READ TABLE gt_t001l TRANSPORTING NO FIELDS WITH TABLE KEY werks = ps_t1130-werks
                                                              lgort = ps_t1130-lgort.
    IF sy-subrc IS NOT INITIAL.
      MESSAGE e103(m3) WITH ps_t1130-lgort ps_t1130-werks INTO DATA(lv_message).
      ps_t1130-return = VALUE #( BASE ps_t1130-return ( type = 'E' field = TEXT-f22 message = lv_message ) ).
    ENDIF.
  ENDIF.

*// 스크랩분류코드.
  IF ps_t1130-scgrp IS NOT INITIAL.
    READ TABLE gt_zgtppt1010 INTO DATA(ls_zgtppt1010) WITH KEY codegrp = gc_codegrp-4070
                                                               fld_01  = ps_t1130-werks
                                                               fld_02  = ps_t1130-scgrp BINARY SEARCH.
    IF sy-subrc IS INITIAL.
      ps_t1130-sctxt = ls_zgtppt1010-fld_03.
    ELSE.
      ps_t1130-return = VALUE #( BASE ps_t1130-return ( type = 'E'  field = TEXT-f23  message = TEXT-e02 ) ).
    ENDIF.
  ENDIF.

*// 탈피후 스크랩 자재코드.
  IF ps_t1130-matnr_t IS NOT INITIAL.
    PERFORM get_material_desc USING ps_t1130-matnr_t ps_t1130-maktx_t.

    SELECT SINGLE @abap_true
      INTO @DATA(lv_check)
      FROM marc
     WHERE matnr EQ @ps_t1130-matnr_t
       AND werks EQ @ps_t1130-werks.

    IF sy-subrc IS NOT INITIAL.
      MESSAGE e200(m3) WITH ps_t1130-matnr_t ps_t1130-werks INTO lv_message.
      ps_t1130-return = VALUE #( BASE ps_t1130-return ( type = 'E'  field = TEXT-f44  message = lv_message ) ).
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_input_value_in_t1140
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM check_input_value_in_t1140  USING ps_t1140 TYPE ty_s_t1140.

  CLEAR: ps_t1140-init, ps_t1140-maktx, ps_t1140-wgbez, ps_t1140-maktx_m.

*// 자재 그룹.
  IF ps_t1140-matkl IS NOT INITIAL.
    READ TABLE gt_t023t INTO DATA(ls_t023t) WITH KEY matkl = ps_t1140-matkl.
    IF sy-subrc IS INITIAL.
      ps_t1140-wgbez = ls_t023t-wgbez.
    ELSE.
      MESSAGE e046(wv) WITH ps_t1140-matkl INTO DATA(lv_message).
      ps_t1140-return = VALUE #( BASE ps_t1140-return ( type = 'E' field = TEXT-f03 message = lv_message ) ).
    ENDIF.
  ENDIF.

*// 생산 스크랩 코드.
  IF ps_t1140-matnr IS NOT INITIAL.
    PERFORM get_material_desc USING ps_t1140-matnr ps_t1140-maktx.

    SELECT SINGLE @abap_true
      INTO @DATA(lv_check)
      FROM marc
     WHERE matnr EQ @ps_t1140-matnr
       AND werks EQ @ps_t1140-werks.

    IF sy-subrc IS NOT INITIAL.
      MESSAGE e200(m3) WITH ps_t1140-matnr ps_t1140-werks INTO lv_message.
      ps_t1140-return = VALUE #( BASE ps_t1140-return ( type = 'E' field = TEXT-f05 message = lv_message ) ).
    ENDIF.
  ENDIF.

**// 물자플랜트.
*  IF ps_t1140-werks_m IS NOT INITIAL.
*    READ TABLE gt_t001w TRANSPORTING NO FIELDS WITH TABLE KEY werks = ps_t1140-werks_m.
*
*    IF sy-subrc IS NOT INITIAL.
*      MESSAGE e011(vf) WITH ps_t1140-werks_m INTO lv_message.
*      ps_t1140-return = VALUE #( BASE ps_t1140-return ( type = 'E'  field = TEXT-f28  message = lv_message ) ).
*    ENDIF.
*  ENDIF.
*
**// 물자저장위치.
*  IF ps_t1140-lgort_m IS NOT INITIAL.
*    READ TABLE gt_t001l TRANSPORTING NO FIELDS WITH TABLE KEY werks = ps_t1140-werks_m
*                                                              lgort = ps_t1140-lgort_m.
*    IF sy-subrc IS NOT INITIAL.
*      MESSAGE e103(m3) WITH ps_t1140-lgort_m ps_t1140-werks_m INTO lv_message.
*      ps_t1140-return = VALUE #( BASE ps_t1140-return ( type = 'E'  field = TEXT-f29  message = lv_message ) ).
*    ENDIF.
*  ENDIF.
*
**// 물자 스크랩코드.
*  IF ps_t1140-matnr_m IS NOT INITIAL.
*    PERFORM get_material_desc USING ps_t1140-matnr_m ps_t1140-maktx_m.
*
*    IF ps_t1140-werks_m IS NOT INITIAL.
*      SELECT SINGLE @abap_true
*        INTO @lv_check
*        FROM marc
*       WHERE marc~matnr EQ @ps_t1140-matnr_m
*         AND marc~werks EQ @ps_t1140-werks_m.
*
*      IF sy-subrc IS NOT INITIAL.
*        MESSAGE e200(m3) WITH ps_t1140-matnr_m ps_t1140-werks_m INTO lv_message.
*        ps_t1140-return = VALUE #( BASE ps_t1140-return ( type = 'E'  field = TEXT-f30  message = lv_message ) ).
*      ENDIF.
*    ENDIF.
*  ENDIF.

  IF ps_t1140-matnr IS NOT INITIAL AND ps_t1140-matnr EQ ps_t1140-matnr_m.
    ps_t1140-return = VALUE #( BASE ps_t1140-return ( type = 'E'  field = TEXT-f30  message = TEXT-e21 ) ).
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_mandt_field_in_t1120
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM check_mandt_field_in_t1120  USING ps_t1120 TYPE ty_s_t1120.

  DATA(lr_t1120) = REF #( ps_t1120 ).

  LOOP AT gr_list->mt_fcat INTO DATA(ls_fcat)
                          WHERE mark EQ abap_true
                            AND tech EQ abap_false.
    PERFORM append_mandt_field_to_return USING lr_t1120->(ls_fcat-fieldname) ls_fcat-coltext lr_t1120->return.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_mandt_field_in_t1130
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM check_mandt_field_in_t1130  USING ps_t1130 TYPE ty_s_t1130.

  DATA(lr_t1130) = REF #( ps_t1130 ).

  LOOP AT gr_list->mt_fcat INTO DATA(ls_fcat)
                          WHERE mark EQ abap_true
                            AND tech EQ abap_false.
    PERFORM append_mandt_field_to_return USING lr_t1130->(ls_fcat-fieldname) ls_fcat-coltext lr_t1130->return.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_mandt_field_in_t1140
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM check_mandt_field_in_t1140  USING ps_t1140 TYPE ty_s_t1140.

  DATA(lr_t1140) = REF #( ps_t1140 ).

  LOOP AT gr_list->mt_fcat INTO DATA(ls_fcat)
                          WHERE mark EQ abap_true
                            AND tech EQ abap_false.
    PERFORM append_mandt_field_to_return USING lr_t1140->(ls_fcat-fieldname) ls_fcat-coltext lr_t1140->return.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form modify_cell_in_t1120
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM modify_cell_in_t1120  USING pr_data_changed TYPE REF TO cl_alv_changed_data_protocol
                                 ps_cell  TYPE lvc_s_modi
                                 ps_t1120 TYPE ty_s_t1120.

  pr_data_changed->modify_cell( i_row_id = ps_cell-row_id:  i_fieldname = 'INIT'    i_value = ps_t1120-init ),
                                                            i_fieldname = 'SCTXT'   i_value = ps_t1120-sctxt ),
                                                            i_fieldname = 'MAKTX'   i_value = ps_t1120-maktx ),
                                                            i_fieldname = 'MAKTX_M' i_value = ps_t1120-maktx_m ),
                                                            i_fieldname = 'STATUS'  i_value = ps_t1120-status ),
                                                            i_fieldname = 'MESSAGE' i_value = ps_t1120-message ),
                                                            i_fieldname = 'RETURN'  i_value = ps_t1120-return ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form modify_cell_in_t1130
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM modify_cell_in_t1130  USING pr_data_changed TYPE REF TO cl_alv_changed_data_protocol
                                 ps_cell  TYPE lvc_s_modi
                                 ps_t1130 TYPE ty_s_t1130.

  pr_data_changed->modify_cell( i_row_id = ps_cell-row_id: i_fieldname = 'INIT'    i_value = ps_t1130-init ),
                                                           i_fieldname = 'SCTXT'   i_value = ps_t1130-sctxt ),
                                                           i_fieldname = 'MAKTX_T' i_value = ps_t1130-maktx_t ),
                                                           i_fieldname = 'STATUS'  i_value = ps_t1130-status ),
                                                           i_fieldname = 'MESSAGE' i_value = ps_t1130-message ),
                                                           i_fieldname = 'RETURN'  i_value = ps_t1130-return ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form modify_cell_in_t1140
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM modify_cell_in_t1140  USING pr_data_changed TYPE REF TO cl_alv_changed_data_protocol
                                 ps_cell  TYPE lvc_s_modi
                                 ps_t1140 TYPE ty_s_t1140.

  pr_data_changed->modify_cell( i_row_id = ps_cell-row_id: i_fieldname = 'WGBEZ'   i_value = ps_t1140-wgbez ),
                                                           i_fieldname = 'MAKTX'   i_value = ps_t1140-maktx ),
                                                           i_fieldname = 'INIT'    i_value = ps_t1140-init ),
                                                           i_fieldname = 'MAKTX_M' i_value = ps_t1140-maktx_m ),
                                                           i_fieldname = 'STATUS'  i_value = ps_t1140-status ),
                                                           i_fieldname = 'MESSAGE' i_value = ps_t1140-message ),
                                                           i_fieldname = 'RETURN'  i_value = ps_t1140-return ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form retrieve_data_from_zgtppt1140
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM retrieve_data_from_zgtppt1140 .

  SELECT zt01~*,
         makt~maktx AS maktx_m,
         zt02~wgbez
    FROM zgtppt1140 AS zt01
    LEFT JOIN makt
      ON zt01~matnr_m EQ makt~matnr
     AND makt~spras   EQ @sy-langu
    LEFT JOIN @gt_t023t AS zt02
      ON zt01~matkl EQ zt02~matkl
     AND zt02~spras EQ @sy-langu
   WHERE zt01~werks EQ @p_werks
     AND zt01~spgcd EQ @p_spgcd
   ORDER BY zt01~werks, zt01~spgcd, zt01~matnr
    INTO CORRESPONDING FIELDS OF TABLE @gt_t1140.

  IF sy-subrc IS INITIAL.
    MODIFY gt_t1140 FROM VALUE #( style = gt_style ) TRANSPORTING style
                    WHERE werks EQ p_werks.
  ELSE.
    PERFORM set_init_data_in_t1140.
  ENDIF.

  gr_data = REF #( gt_t1140 ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form retrieve_data_from_zgtppt1120
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM retrieve_data_from_zgtppt1120 .

  SELECT zt01~*
    FROM zgtppt1120 AS zt01
   WHERE zt01~werks EQ @p_werks
     AND zt01~spgcd EQ @p_spgcd
   ORDER BY zt01~werks, zt01~spgcd, zt01~lgort, zt01~scgrp, zt01~matnr
    INTO CORRESPONDING FIELDS OF TABLE @gt_t1120.

  IF sy-subrc IS INITIAL.
    MODIFY gt_t1120 FROM VALUE #( style = gt_style ) TRANSPORTING style
                    WHERE werks EQ p_werks.
  ELSE.
    PERFORM set_init_data_in_t1120.
  ENDIF.

  gr_data = REF #( gt_t1120 ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_defalut_value_of_t1140
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM set_defalut_value_of_t1140  USING ps_t1140 TYPE ty_s_t1140.

  ps_t1140 = VALUE #( werks = p_werks
                      spgcd = p_spgcd
                      init  = abap_true ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_defalut_value_of_t1120
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM set_defalut_value_of_t1120  USING ps_t1120 TYPE ty_s_t1120.

  ps_t1120 = VALUE #( werks = p_werks
                      spgcd = p_spgcd
                      init  = abap_true ).
ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_init_data_in_t1140
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM set_init_data_in_t1140 .

  CHECK sy-tcode EQ gc_tcode-zgtppr1150v.

  DO 10 TIMES.
    APPEND INITIAL LINE TO gt_t1140 REFERENCE INTO DATA(lr_t1140).
    PERFORM set_defalut_value_of_t1140 USING lr_t1140->*.
  ENDDO.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_material_desc
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM get_material_desc  USING pv_matnr pv_maktx.

  SELECT SINGLE maktx
    INTO @pv_maktx
    FROM makt
   WHERE matnr EQ @pv_matnr
     AND spras EQ @sy-langu.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form append_mandt_field_to_return
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM append_mandt_field_to_return  USING pv_field pv_fname
                                         pt_return TYPE bapiret2_tab.


  IF pv_fname = TEXT-T02 OR "물자 플랜트
     pv_fname = TEXT-T03 OR "물자 저장위치
     pv_fname = TEXT-T04.    "물자 스크랩코드
  ELSE.
    CHECK pv_field IS INITIAL.

    MESSAGE e026 WITH pv_fname INTO DATA(lv_message).

    pt_return = VALUE #( BASE pt_return ( type = 'E' field = pv_fname message = lv_message ) ).
  ENDIF.
ENDFORM.
*&---------------------------------------------------------------------*
*& Form user_command_save
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM user_command_save .

  CASE abap_true.
    WHEN p_t1140. "// (군포) 생산/물자 스크랩코드.
      PERFORM maintain_zgtppt1140.

    WHEN p_t1120. "// (전주) 생산/물자 스크랩코드 .
      PERFORM maintain_zgtppt1120.

    WHEN p_t1130. "// (군포) 탈피 후 코드 및 환산율.
      PERFORM maintain_zgtppt1130.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form maintain_zgtppt1140
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM maintain_zgtppt1140 .

  TRY.
      PERFORM check_before_save_zgtppt1140. "// 사전점검.
      PERFORM save_zgtppt1140.              "// 저장.

    CATCH lcx_exception INTO DATA(lr_exception).
      IF lr_exception->get_text( ) IS NOT INITIAL.
        gr_list->refresh( ).
        MESSAGE lr_exception->get_text( ) TYPE 'I' DISPLAY LIKE 'E'.
      ENDIF.
  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form maintain_zgtppt1120
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM maintain_zgtppt1120 .

  TRY.
      PERFORM check_before_save_zgtppt1120. "// 사전점검.
      PERFORM save_zgtppt1120.              "// 저장.

    CATCH lcx_exception INTO DATA(lr_exception).
      IF lr_exception->get_text( ) IS NOT INITIAL.
        MESSAGE lr_exception->get_text( ) TYPE 'I' DISPLAY LIKE 'E'.
      ENDIF.
  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_before_save_zgtppt1140
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM check_before_save_zgtppt1140 RAISING lcx_exception.
  DATA lv_answer TYPE c.

  gr_list->mr_grid->check_changed_data( IMPORTING e_valid = DATA(lv_valid) ).

  IF lv_valid NE abap_true.
    RAISE EXCEPTION TYPE lcx_exception MESSAGE e000 WITH space.
  ENDIF.

  PERFORM saved_data_extraction_t1140.

  IF gs_result-invalid IS NOT INITIAL.
    RAISE EXCEPTION TYPE lcx_exception MESSAGE e000 WITH TEXT-e03.
  ENDIF.

  IF gs_result-total IS INITIAL.
    RAISE EXCEPTION TYPE lcx_exception MESSAGE e000 WITH TEXT-e04.
  ENDIF.

  PERFORM confirmation_popup USING TEXT-c02 lv_answer.

  IF lv_answer NE '1'.
    RAISE EXCEPTION TYPE lcx_exception MESSAGE e000 WITH space.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_zgtppt1140
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM save_zgtppt1140 RAISING lcx_exception.
  DATA lt_zgtppt1140 TYPE TABLE OF zgtppt1140.
  DATA lt_zgtppt1140_db TYPE ty_t_zgtppt1140_db.

  SELECT zt01~*,
         @abap_false AS del
    FROM zgtppt1140 AS zt01
   WHERE werks EQ @p_werks
     AND spgcd EQ @p_spgcd
   ORDER BY werks, spgcd, matnr
    INTO CORRESPONDING FIELDS OF TABLE @lt_zgtppt1140_db.

*// 처리일자 및 시간.
  PERFORM get_date_time USING gs_zgtpps1001.

  LOOP AT gt_t1140 REFERENCE INTO DATA(lr_t1140)
                   WHERE sel EQ abap_true.
    APPEND INITIAL LINE TO lt_zgtppt1140 REFERENCE INTO DATA(lr_zgtppt1140).
    lr_zgtppt1140->* = CORRESPONDING #( lr_t1140->* ).

    READ TABLE lt_zgtppt1140_db REFERENCE INTO DATA(lr_zgtppt1140_db) WITH KEY werks = lr_t1140->werks
                                                                               spgcd = lr_t1140->spgcd
                                                                               matnr = lr_t1140->matnr BINARY SEARCH.
    IF sy-subrc IS INITIAL.
      lr_zgtppt1140->* = VALUE #( BASE lr_zgtppt1140->*  chdat = gs_zgtpps1001-chdat
                                                         chtim = gs_zgtpps1001-chtim
                                                         chnam = gs_zgtpps1001-chnam ).
      lr_t1140->* = VALUE #( BASE lr_t1140->*  chdat = gs_zgtpps1001-chdat
                                               chtim = gs_zgtpps1001-chtim
                                               chnam = gs_zgtpps1001-chnam ).
      lr_zgtppt1140_db->del = abap_true.
    ELSE.
      lr_zgtppt1140->* = CORRESPONDING #( BASE ( lr_zgtppt1140->* ) gs_zgtpps1001 ).
      lr_t1140->* = CORRESPONDING #( BASE ( lr_t1140->* ) gs_zgtpps1001 ).
    ENDIF.

    lr_t1140->style = gt_style.
  ENDLOOP.

  DELETE lt_zgtppt1140_db WHERE del EQ abap_true.

  TRY.
      IF lt_zgtppt1140_db IS NOT INITIAL.
        DELETE zgtppt1140 FROM TABLE lt_zgtppt1140_db.
      ENDIF.

      MODIFY zgtppt1140 FROM TABLE lt_zgtppt1140.

    CATCH cx_root INTO DATA(lr_root).
      ROLLBACK WORK.
      RAISE EXCEPTION TYPE lcx_exception MESSAGE e000 WITH TEXT-e01.
  ENDTRY.

  COMMIT WORK AND WAIT.

  DELETE gt_t1140 WHERE init EQ abap_true.

  gr_list->refresh( ).

  MESSAGE s500(mi).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_before_save_zgtppt1120
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM check_before_save_zgtppt1120 RAISING lcx_exception.
  DATA lv_answer TYPE c.

  gr_list->mr_grid->check_changed_data( IMPORTING e_valid = DATA(lv_valid) ).

  IF lv_valid NE abap_true.
    RAISE EXCEPTION TYPE lcx_exception MESSAGE e000 WITH space.
  ENDIF.

  PERFORM saved_data_extraction_t1120.

  IF gs_result-invalid IS NOT INITIAL.
    RAISE EXCEPTION TYPE lcx_exception MESSAGE e000 WITH TEXT-e03.
  ENDIF.

  IF gs_result-total IS INITIAL.
    RAISE EXCEPTION TYPE lcx_exception MESSAGE e000 WITH TEXT-e04.
  ENDIF.

  PERFORM confirmation_popup USING TEXT-c02 lv_answer.

  IF lv_answer NE '1'.
    RAISE EXCEPTION TYPE lcx_exception MESSAGE e000 WITH space.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_zgtppt1120
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM save_zgtppt1120 RAISING lcx_exception.
  DATA lt_zgtppt1120 TYPE TABLE OF zgtppt1120.
  DATA lt_zgtppt1120_db TYPE ty_t_zgtppt1120_db.

*// 처리일시.
  PERFORM get_date_time USING gs_zgtpps1001.

  SELECT zt01~*,
         @abap_false AS del
    FROM zgtppt1120 AS zt01
   WHERE werks EQ @p_werks
     AND spgcd EQ @p_spgcd
   ORDER BY werks, spgcd, lgort, scgrp
    INTO CORRESPONDING FIELDS OF TABLE @lt_zgtppt1120_db.

  LOOP AT gt_t1120 REFERENCE INTO DATA(lr_t1120)
                   WHERE sel EQ abap_true.
    APPEND INITIAL LINE TO lt_zgtppt1120 REFERENCE INTO DATA(lr_zgtppt1120).
    lr_zgtppt1120->* = CORRESPONDING #( lr_t1120->* ).

    READ TABLE lt_zgtppt1120_db REFERENCE INTO DATA(lr_zgtppt1120_db) WITH KEY werks = lr_t1120->werks
                                                                               spgcd = lr_t1120->spgcd
                                                                               lgort = lr_t1120->lgort
                                                                               scgrp = lr_t1120->scgrp BINARY SEARCH.
    IF sy-subrc IS INITIAL.
      lr_zgtppt1120->* = VALUE #( BASE lr_zgtppt1120->*  chdat = gs_zgtpps1001-chdat
                                                         chtim = gs_zgtpps1001-chtim
                                                         chnam = gs_zgtpps1001-chnam ).
      lr_t1120->* = VALUE #( BASE lr_t1120->*  chdat = gs_zgtpps1001-chdat
                                               chtim = gs_zgtpps1001-chtim
                                               chnam = gs_zgtpps1001-chnam ).
      lr_zgtppt1120_db->del = abap_true.
    ELSE.
      lr_zgtppt1120->* = CORRESPONDING #( BASE ( lr_zgtppt1120->* ) gs_zgtpps1001 ).
      lr_t1120->* = CORRESPONDING #( BASE ( lr_t1120->* ) gs_zgtpps1001 ).
    ENDIF.

    lr_t1120->style = gt_style.
  ENDLOOP.

  DELETE lt_zgtppt1120_db WHERE del EQ abap_true.

  TRY.
      IF lt_zgtppt1120_db IS NOT INITIAL.
        DELETE zgtppt1120 FROM TABLE lt_zgtppt1120_db.
      ENDIF.

      MODIFY zgtppt1120 FROM TABLE lt_zgtppt1120.

    CATCH cx_root INTO DATA(lr_root).
      ROLLBACK WORK.
      RAISE EXCEPTION TYPE lcx_exception MESSAGE e000 WITH TEXT-e01.
  ENDTRY.

  COMMIT WORK AND WAIT.

  DELETE gt_t1120 WHERE init EQ abap_true.

  gr_list->refresh( ).

  MESSAGE s500(mi).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form saved_data_extraction_t1140
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM saved_data_extraction_t1140 .

  CLEAR gs_result.

  MODIFY gt_t1140 FROM VALUE #( sel = space )
                 TRANSPORTING sel
                 WHERE sel EQ abap_true.

  LOOP AT gt_t1140 REFERENCE INTO DATA(lr_t1140)
                  WHERE init EQ abap_false.
    IF lr_t1140->status EQ icon_led_red.
      gs_result-invalid = abap_true.
      CONTINUE.
    ENDIF.

    gs_result-sel += 1.

    lr_t1140->sel = abap_true.
    gs_result-total += 1.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_date_time
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM get_date_time  USING ps_zgtpps1001 TYPE zgtpps1001.

  ps_zgtpps1001-crdat = sy-datum.
  ps_zgtpps1001-crtim = sy-uzeit.
  ps_zgtpps1001-crnam = sy-uname.
  ps_zgtpps1001-chdat = sy-datum.
  ps_zgtpps1001-chtim = sy-uzeit.
  ps_zgtpps1001-chnam = sy-uname.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_master_data
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM get_master_data .

  SELECT werks, name1
    INTO CORRESPONDING FIELDS OF TABLE @gt_t001w
    FROM t001w.

  SELECT werks, lgort, lgobe
    INTO CORRESPONDING FIELDS OF TABLE @gt_t001l
    FROM t001l.

  SELECT spras, matkl, wgbez
    INTO CORRESPONDING FIELDS OF TABLE @gt_t023t
    FROM t023t
   WHERE spras EQ @sy-langu.

  INSERT VALUE t023t( spras = sy-langu
                      matkl = 'DUMMY'
                      wgbez = 'DUMMY' ) INTO TABLE gt_t023t.

  gt_zgtppt1010 = zgtpp_cl_common=>get_code_value( iv_codegrp = gc_codegrp-4070 ).
  SORT gt_zgtppt1010 BY codegrp fld_01 fld_02.

  CASE abap_true.
    WHEN p_t1140. "// (군포) 생산/물자 스크랩코드.
      gt_style = VALUE #( style = cl_gui_alv_grid=>mc_style_disabled  ( fieldname = 'MATKL' )
                                                                      ( fieldname = 'MATNR' ) ).

    WHEN p_t1120. "// (전주) 생산/물자 스크랩코드.
      gt_style = VALUE #( style = cl_gui_alv_grid=>mc_style_disabled  ( fieldname = 'LGORT' )
                                                                      ( fieldname = 'SCGRP' ) ).

    WHEN p_t1130. "// (군포) 탈피 후 코드 및 환산율.
      gt_style = VALUE #( style = cl_gui_alv_grid=>mc_style_disabled  ( fieldname = 'LGORT' )
                                                                      ( fieldname = 'SCGRP' )
                                                                      ( fieldname = 'MATNR_T' ) ).
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_data_changed_fini
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM handle_data_changed_fini  USING pt_good_cells TYPE lvc_t_modi
                                     pv_modified.

  CASE abap_true.
    WHEN p_t1140. "// (군포) 생산/물자 스크랩코드.
      PERFORM data_changed_fini_in_t1140 USING pt_good_cells pv_modified.

    WHEN p_t1120. "// (전주) 생산/물자 스크랩코드 .
      PERFORM data_changed_fini_in_t1120 USING pt_good_cells pv_modified.

    WHEN p_t1130. "// (군포) 탈피 후 코드 및 환산율.
      PERFORM data_changed_fini_in_t1130 USING pt_good_cells pv_modified.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form data_changed_fini_in_t1120
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM data_changed_fini_in_t1120  USING pt_good_cells TYPE lvc_t_modi
                                       pv_modified.

  CHECK pt_good_cells IS NOT INITIAL.

  PERFORM check_duplication_in_t1120.

  gr_list->refresh( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form data_changed_fini_in_t1140
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM data_changed_fini_in_t1140  USING pt_good_cells TYPE lvc_t_modi
                                       pv_modified.

  CHECK pt_good_cells IS NOT INITIAL.

  PERFORM check_duplication_in_t1140.

  gr_list->refresh( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_duplication_in_t1120
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM check_duplication_in_t1120 .

*// 자재 중복 여부.
  SELECT werks, spgcd, lgort, scgrp
    FROM @gt_t1120 AS a
   WHERE scgrp NE @space
   GROUP BY werks, spgcd, lgort, scgrp
  HAVING COUNT( * ) GT 1
    INTO TABLE @DATA(lt_t1120).

*// 기존 데이터 중복 해지.
  LOOP AT gt_t1120 REFERENCE INTO DATA(lr_t1120)
                   WHERE dupli EQ abap_true.
    lr_t1120->dupli = abap_false.
    DELETE lr_t1120->return WHERE field EQ gc_duplication.

    IF lr_t1120->return IS INITIAL.
      CLEAR: lr_t1120->status, lr_t1120->message.
    ENDIF.
  ENDLOOP.

*// 중복 데이터 설정.
  LOOP AT lt_t1120 INTO DATA(ls_t1120).
    LOOP AT gt_t1120 REFERENCE INTO lr_t1120
                     WHERE werks EQ ls_t1120-werks
                       AND spgcd EQ ls_t1120-spgcd
                       AND lgort EQ ls_t1120-lgort
                       AND scgrp EQ ls_t1120-scgrp.
      lr_t1120->dupli  = abap_true.
      lr_t1120->return = VALUE #( BASE lr_t1120->return ( type = 'E' field = gc_duplication message = TEXT-e11 ) ).
      IF lines( lr_t1120->return ) EQ 1.
        lr_t1120->status  = icon_led_red.
        lr_t1120->message = lr_t1120->return[ 1 ]-message.
      ENDIF.
    ENDLOOP.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_duplication_in_t1140
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM check_duplication_in_t1140 .

*// 자재 중복 여부.
  SELECT werks, spgcd, matkl, matnr
    FROM @gt_t1140 AS a
   WHERE matkl NE @space
     AND matnr NE @space
   GROUP BY werks, spgcd, matkl, matnr
  HAVING COUNT( * ) GT 1
    INTO TABLE @DATA(lt_t1140).

*// 기존 데이터 중복 해지.
  LOOP AT gt_t1140 REFERENCE INTO DATA(lr_t1140)
                   WHERE dupli EQ abap_true.
    lr_t1140->dupli = abap_false.
    DELETE lr_t1140->return WHERE field EQ gc_duplication.

    IF lr_t1140->return IS INITIAL.
      CLEAR: lr_t1140->status, lr_t1140->message.
    ENDIF.
  ENDLOOP.

*// 중복 데이터 설정.
  LOOP AT lt_t1140 INTO DATA(ls_t1140).
    LOOP AT gt_t1140 REFERENCE INTO lr_t1140
                     WHERE matkl EQ ls_t1140-matkl
                       AND matnr EQ ls_t1140-matnr.
      lr_t1140->dupli  = abap_true.
      lr_t1140->return = VALUE #( BASE lr_t1140->return ( type = 'E' field = gc_duplication message = TEXT-e11 ) ).
      IF lines( lr_t1140->return ) EQ 1.
        lr_t1140->status  = icon_led_red.
        lr_t1140->message = lr_t1140->return[ 1 ]-message.
      ENDIF.
    ENDLOOP.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_init_data_in_t1120
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM set_init_data_in_t1120 .

  CHECK sy-tcode EQ gc_tcode-zgtppr1150v.

  DO 10 TIMES.
    APPEND INITIAL LINE TO gt_t1120 REFERENCE INTO DATA(lr_t1120).
    PERFORM set_defalut_value_of_t1120 USING lr_t1120->*.
  ENDDO.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form saved_data_extraction_t1120
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM saved_data_extraction_t1120 .

  CLEAR gs_result.

  MODIFY gt_t1120 FROM VALUE #( sel = space )
                  TRANSPORTING sel
                  WHERE sel EQ abap_true.

  LOOP AT gt_t1120 REFERENCE INTO DATA(lr_t1120)
                   WHERE init EQ abap_false.
    IF lr_t1120->return IS NOT INITIAL.
      gs_result-invalid = abap_true.
      RETURN.
    ENDIF.

    gs_result-sel += 1.
    gs_result-total += 1.
    lr_t1120->sel = abap_true.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_f4
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM handle_f4.

  IF p_t1120 EQ abap_true OR p_t1130 EQ abap_true.
    gr_list->mt_f4 = VALUE #( register = abap_true chngeafter = abap_true ( fieldname = 'SCGRP' ) ).
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_on_f4
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM handle_on_f4  USING pv_fieldname
                         pv_fieldvalue
                         ps_row_no     TYPE lvc_s_roid
                         pr_event_data TYPE REF TO cl_alv_event_data
                         pt_bad_cells  TYPE lvc_t_modi
                         pv_display.

  CASE pv_fieldname.
    WHEN 'SCGRP'.
      PERFORM f4_scgrp USING pv_fieldname  pv_fieldvalue ps_row_no
                             pr_event_data pt_bad_cells  pv_display.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form f4_scgrp
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM f4_scgrp  USING pv_fieldname
                     pv_fieldvalue
                     ps_row_no     TYPE lvc_s_roid
                     pr_event_data TYPE REF TO cl_alv_event_data
                     pt_bad_cells  TYPE lvc_t_modi
                     pv_display.
  DATA lv_user_reset TYPE c.
  DATA lt_return TYPE TABLE OF ddshretval.
  DATA lt_code TYPE TABLE OF ty_s_scgrp.

  SELECT zt01~fld_02 AS scgrp,
         zt01~fld_03 AS sctxt
    FROM @gt_zgtppt1010 AS zt01
   WHERE zt01~codegrp EQ @gc_codegrp-4070
     AND zt01~fld_01  EQ @p_werks
   ORDER BY zt01~fld_02
    INTO TABLE @lt_code.

  CALL FUNCTION 'F4IF_INT_TABLE_VALUE_REQUEST'
    EXPORTING
      retfield        = 'SCGRP'
      dynpprog        = sy-repid
      dynpnr          = sy-dynnr
      window_title    = TEXT-t20
      value_org       = 'S'
    IMPORTING
      user_reset      = lv_user_reset
    TABLES
      value_tab       = lt_code[]
      return_tab      = lt_return[]
    EXCEPTIONS
      parameter_error = 1
      no_values_found = 2
      OTHERS          = 3.

  CHECK sy-subrc IS INITIAL.

  pr_event_data->m_event_handled = abap_true.

  CHECK pv_display IS INITIAL AND lt_return[] IS NOT INITIAL.

  pr_event_data->m_data->* = VALUE lvc_t_modi( BASE pr_event_data->m_data->* ( row_id    = ps_row_no-row_id
                                                                               fieldname = pv_fieldname
                                                                               value     = VALUE #( lt_return[ 1 ]-fieldval OPTIONAL ) ) ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_init_data_in_t1130
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM set_init_data_in_t1130.

  CHECK sy-tcode EQ gc_tcode-zgtppr1150v.

  DO 10 TIMES.
    APPEND INITIAL LINE TO gt_t1130 REFERENCE INTO DATA(lr_t1130).
    PERFORM set_defalut_value_of_t1130 USING lr_t1130->*.
  ENDDO.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_defalut_value_of_t1130
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM set_defalut_value_of_t1130  USING ps_t1130 TYPE ty_s_t1130.

  ps_t1130 = VALUE #( werks = p_werks
                      spgcd = p_spgcd
                      init  = abap_true ).
ENDFORM.
*&---------------------------------------------------------------------*
*& Form insert_row_in_t1120
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM insert_row_in_t1120 .

  IF gt_t1120 IS INITIAL.
    PERFORM set_init_data_in_t1120.
  ELSE.
    gr_list->mr_grid->get_selected_rows( IMPORTING et_index_rows = DATA(lt_rows) ).

    IF lt_rows IS NOT INITIAL.
      DATA(ls_row) = VALUE #( lt_rows[ 1 ] OPTIONAL ).

      DO lines( lt_rows ) TIMES.
        INSERT INITIAL LINE INTO gt_t1120 REFERENCE INTO DATA(lr_t1120) INDEX ls_row-index.
        PERFORM set_defalut_value_of_t1120 USING lr_t1120->*.
      ENDDO.
    ELSE.
      APPEND INITIAL LINE TO gt_t1120 REFERENCE INTO lr_t1120.
      PERFORM set_defalut_value_of_t1120 USING lr_t1120->*.
    ENDIF.
  ENDIF.

  gr_list->refresh( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form insert_row_in_t1130
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM insert_row_in_t1130 .

  IF gt_t1130 IS INITIAL.
    PERFORM set_init_data_in_t1130.
  ELSE.
    gr_list->mr_grid->get_selected_rows( IMPORTING et_index_rows = DATA(lt_rows) ).

    IF lt_rows IS NOT INITIAL.
      DATA(ls_row) = VALUE #( lt_rows[ 1 ] OPTIONAL ).

      DO lines( lt_rows ) TIMES.
        INSERT INITIAL LINE INTO gt_t1130 REFERENCE INTO DATA(lr_t1130) INDEX ls_row-index.
        PERFORM set_defalut_value_of_t1130 USING lr_t1130->*.
      ENDDO.
    ELSE.
      APPEND INITIAL LINE TO gt_t1130 REFERENCE INTO lr_t1130.
      PERFORM set_defalut_value_of_t1130 USING lr_t1130->*.
    ENDIF.
  ENDIF.

  gr_list->refresh( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form insert_row_in_t1140
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM insert_row_in_t1140 .

  IF gt_t1140 IS INITIAL.
    PERFORM set_init_data_in_t1140.
  ELSE.
    gr_list->mr_grid->get_selected_rows( IMPORTING et_index_rows = DATA(lt_rows) ).

    IF lt_rows IS NOT INITIAL.
      DATA(ls_row) = VALUE #( lt_rows[ 1 ] OPTIONAL ).

      DO lines( lt_rows ) TIMES.
        INSERT INITIAL LINE INTO gt_t1140 REFERENCE INTO DATA(lr_t1140) INDEX ls_row-index.
        PERFORM set_defalut_value_of_t1140 USING lr_t1140->*.
      ENDDO.
    ELSE.
      APPEND INITIAL LINE TO gt_t1140 REFERENCE INTO lr_t1140.
      PERFORM set_defalut_value_of_t1140 USING lr_t1140->*.
    ENDIF.
  ENDIF.

  gr_list->refresh( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form delete_row_in_t1120
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM delete_row_in_t1120 .
  DATA lt_zgtppt1120 TYPE TABLE OF zgtppt1120.
  DATA lv_answer TYPE c.

  MODIFY gt_t1120 FROM VALUE #( sel = space )
                  TRANSPORTING sel
                  WHERE sel EQ abap_true.

  gr_list->mr_grid->get_selected_rows( IMPORTING et_index_rows = DATA(lt_rows) ).
  DELETE lt_rows WHERE rowtype NE space.

  IF lt_rows IS INITIAL.
    MESSAGE i000 WITH TEXT-e06 DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  PERFORM confirmation_popup USING TEXT-c03 lv_answer.

  IF lv_answer NE '1'.
    RETURN.
  ENDIF.

  LOOP AT lt_rows INTO DATA(ls_row).
    READ TABLE gt_t1120 REFERENCE INTO DATA(lr_t1120) INDEX ls_row-index.

    CHECK sy-subrc IS INITIAL.

    lr_t1120->sel = abap_true.

    IF lr_t1120->style IS NOT INITIAL.
      APPEND CORRESPONDING #( lr_t1120->* ) TO lt_zgtppt1120.
    ENDIF.
  ENDLOOP.

  IF NOT line_exists( gt_t1120[ sel = abap_true ] ).
    MESSAGE i000 WITH TEXT-e07 DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  DELETE gt_t1120 WHERE sel EQ abap_true.
  PERFORM check_duplication_in_t1120.

  IF lt_zgtppt1120 IS NOT INITIAL.
    DELETE zgtppt1120 FROM TABLE lt_zgtppt1120.

    COMMIT WORK AND WAIT.
  ENDIF.

  gr_list->refresh( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form delete_row_in_t1130
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM delete_row_in_t1130 .
  DATA lt_zgtppt1130 TYPE TABLE OF zgtppt1130.
  DATA lv_answer TYPE c.

  MODIFY gt_t1130 FROM VALUE #( sel = space )
                  TRANSPORTING sel
                  WHERE sel EQ abap_true.

  gr_list->mr_grid->get_selected_rows( IMPORTING et_index_rows = DATA(lt_rows) ).
  DELETE lt_rows WHERE rowtype NE space.

  IF lt_rows IS INITIAL.
    MESSAGE i000 WITH TEXT-e06 DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  PERFORM confirmation_popup USING TEXT-c03 lv_answer.

  IF lv_answer NE '1'.
    RETURN.
  ENDIF.

  LOOP AT lt_rows INTO DATA(ls_row).
    READ TABLE gt_t1130 REFERENCE INTO DATA(lr_t1130) INDEX ls_row-index.

    CHECK sy-subrc IS INITIAL.

    lr_t1130->sel = abap_true.

    IF lr_t1130->style IS NOT INITIAL.
      APPEND CORRESPONDING #( lr_t1130->* ) TO lt_zgtppt1130.
    ENDIF.
  ENDLOOP.

  IF NOT line_exists( gt_t1130[ sel = abap_true ] ).
    MESSAGE i000 WITH TEXT-e07 DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  DELETE gt_t1130 WHERE sel EQ abap_true.
  PERFORM check_duplication_in_t1130.

  IF lt_zgtppt1130 IS NOT INITIAL.
    DELETE zgtppt1130 FROM TABLE lt_zgtppt1130.

    COMMIT WORK AND WAIT.
  ENDIF.

  gr_list->refresh( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form delete_row_in_t1140
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM delete_row_in_t1140 .
  DATA lt_zgtppt1140 TYPE TABLE OF zgtppt1140.
  DATA lv_answer TYPE c.

  MODIFY gt_t1140 FROM VALUE #( sel = space )
                  TRANSPORTING sel
                  WHERE sel EQ abap_true.

  gr_list->mr_grid->get_selected_rows( IMPORTING et_index_rows = DATA(lt_rows) ).
  DELETE lt_rows WHERE rowtype NE space.

  IF lt_rows IS INITIAL.
    MESSAGE i000 WITH TEXT-e06 DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  PERFORM confirmation_popup USING TEXT-c03 lv_answer.

  IF lv_answer NE '1'.
    RETURN.
  ENDIF.

  LOOP AT lt_rows INTO DATA(ls_row).
    READ TABLE gt_t1140 REFERENCE INTO DATA(lr_t1140) INDEX ls_row-index.

    CHECK sy-subrc IS INITIAL.

    lr_t1140->sel = abap_true.

    IF lr_t1140->style IS NOT INITIAL.
      APPEND CORRESPONDING #( lr_t1140->* ) TO lt_zgtppt1140.
    ENDIF.
  ENDLOOP.

  IF NOT line_exists( gt_t1140[ sel = abap_true ] ).
    MESSAGE i000 WITH TEXT-e07 DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  DELETE gt_t1140 WHERE sel EQ abap_true.
  PERFORM check_duplication_in_t1140.

  IF lt_zgtppt1140 IS NOT INITIAL.
    DELETE zgtppt1140 FROM TABLE lt_zgtppt1140.
    COMMIT WORK AND WAIT.
  ENDIF.

  gr_list->refresh( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form data_changed_fini_in_t1130
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM data_changed_fini_in_t1130  USING pt_good_cells TYPE lvc_t_modi
                                       pv_modified.

  CHECK pt_good_cells IS NOT INITIAL.

  PERFORM check_duplication_in_t1130.

  gr_list->refresh( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_duplication_in_t1130
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM check_duplication_in_t1130 .

*// 자재 중복 여부.
  SELECT werks, spgcd, lgort, scgrp, matnr_t
    FROM @gt_t1130 AS a
   WHERE matnr_t NE @space
   GROUP BY werks, spgcd, lgort, scgrp, matnr_t
  HAVING COUNT( * ) GT 1
    INTO TABLE @DATA(lt_t1130).

*// 기존 데이터 중복 해지.
  LOOP AT gt_t1130 REFERENCE INTO DATA(lr_t1130)
                   WHERE dupli EQ abap_true.
    lr_t1130->dupli = abap_false.
    DELETE lr_t1130->return WHERE field EQ gc_duplication.

    IF lr_t1130->return IS INITIAL.
      CLEAR: lr_t1130->status, lr_t1130->message.
    ENDIF.
  ENDLOOP.

*// 중복 데이터 설정.
  LOOP AT lt_t1130 INTO DATA(ls_t1130).
    LOOP AT gt_t1130 REFERENCE INTO lr_t1130
                     WHERE werks   EQ ls_t1130-werks
                       AND spgcd   EQ ls_t1130-spgcd
                       AND lgort   EQ ls_t1130-lgort
                       AND scgrp   EQ ls_t1130-scgrp
                       AND matnr_t EQ ls_t1130-matnr_t.
      lr_t1130->dupli  = abap_true.
      lr_t1130->return = VALUE #( BASE lr_t1130->return ( type = 'E' field = gc_duplication message = TEXT-e11 ) ).
      IF lines( lr_t1130->return ) EQ 1.
        lr_t1130->status  = icon_led_red.
        lr_t1130->message = lr_t1130->return[ 1 ]-message.
      ENDIF.
    ENDLOOP.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form retrieve_data_from_zgtppt1130
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM retrieve_data_from_zgtppt1130 .

  SELECT zt01~*
    FROM zgtppt1130 AS zt01
   WHERE zt01~werks EQ @p_werks
     AND zt01~spgcd EQ @p_spgcd
   ORDER BY zt01~werks, zt01~spgcd, zt01~lgort, zt01~scgrp, zt01~matnr_t
    INTO CORRESPONDING FIELDS OF TABLE @gt_t1130.

  IF sy-subrc IS INITIAL.
    MODIFY gt_t1130 FROM VALUE #( style = gt_style ) TRANSPORTING style
                    WHERE werks EQ p_werks.
  ELSE.
    PERFORM set_init_data_in_t1130.
  ENDIF.

  gr_data = REF #( gt_t1130 ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form maintain_zgtppt1130
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM maintain_zgtppt1130 .

  TRY.
      PERFORM check_before_save_zgtppt1130. "// 사전점검.
      PERFORM save_zgtppt1130.              "// 저장.

    CATCH lcx_exception INTO DATA(lr_exception).
      IF lr_exception->get_text( ) IS NOT INITIAL.
        MESSAGE lr_exception->get_text( ) TYPE 'I' DISPLAY LIKE 'E'.
      ENDIF.
  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_before_save_zgtppt1130
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM check_before_save_zgtppt1130 RAISING lcx_exception.
  DATA lv_answer TYPE c.

  gr_list->mr_grid->check_changed_data( IMPORTING e_valid = DATA(lv_valid) ).

  IF lv_valid NE abap_true.
    RAISE EXCEPTION TYPE lcx_exception MESSAGE e000 WITH space.
  ENDIF.

  PERFORM saved_data_extraction_t1130.

  IF gs_result-invalid IS NOT INITIAL.
    RAISE EXCEPTION TYPE lcx_exception MESSAGE e000 WITH TEXT-e03.
  ENDIF.

  IF gs_result-total IS INITIAL.
    RAISE EXCEPTION TYPE lcx_exception MESSAGE e000 WITH TEXT-e04.
  ENDIF.

  PERFORM confirmation_popup USING TEXT-c02 lv_answer.

  IF lv_answer NE '1'.
    RAISE EXCEPTION TYPE lcx_exception MESSAGE e000 WITH space.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form saved_data_extraction_t1130
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM saved_data_extraction_t1130 .

  CLEAR gs_result.

  MODIFY gt_t1130 FROM VALUE #( sel = space )
                  TRANSPORTING sel
                  WHERE sel EQ abap_true.

  LOOP AT gt_t1130 REFERENCE INTO DATA(lr_t1130)
                   WHERE init EQ abap_false.
    IF lr_t1130->return IS NOT INITIAL.
      gs_result-invalid = abap_true.
      RETURN.
    ENDIF.

    gs_result-sel += 1.
    gs_result-total += 1.
    lr_t1130->sel = abap_true.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_zgtppt1130
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM save_zgtppt1130 RAISING lcx_exception.
  DATA lt_zgtppt1130 TYPE ty_t_zgtppt1130_db.
  DATA lt_zgtppt1130_db TYPE ty_t_zgtppt1130_db.

*// 처리일시.
  PERFORM get_date_time USING gs_zgtpps1001.

  SELECT zt01~*,
         @abap_false AS del
    FROM zgtppt1130 AS zt01
   WHERE werks EQ @p_werks
     AND spgcd EQ @p_spgcd
   ORDER BY werks, spgcd, lgort, scgrp, matnr_t
    INTO CORRESPONDING FIELDS OF TABLE @lt_zgtppt1130_db.

  LOOP AT gt_t1130 REFERENCE INTO DATA(lr_t1130)
                   WHERE sel EQ abap_true.
    APPEND INITIAL LINE TO lt_zgtppt1130 REFERENCE INTO DATA(lr_zgtppt1130).
    lr_zgtppt1130->* = CORRESPONDING #( lr_t1130->* ).

    READ TABLE lt_zgtppt1130_db REFERENCE INTO DATA(lr_zgtppt1130_db) WITH KEY werks   = lr_t1130->werks
                                                                               spgcd   = lr_t1130->spgcd
                                                                               lgort   = lr_t1130->lgort
                                                                               scgrp   = lr_t1130->scgrp
                                                                               matnr_t = lr_t1130->matnr_t BINARY SEARCH.
    IF sy-subrc IS INITIAL.
      lr_zgtppt1130->* = VALUE #( BASE lr_zgtppt1130->*  chdat = gs_zgtpps1001-chdat
                                                         chtim = gs_zgtpps1001-chtim
                                                         chnam = gs_zgtpps1001-chnam ).
      lr_t1130->* = VALUE #( BASE lr_t1130->*  chdat = gs_zgtpps1001-chdat
                                               chtim = gs_zgtpps1001-chtim
                                               chnam = gs_zgtpps1001-chnam ).
      lr_zgtppt1130_db->del = abap_true.
    ELSE.
      lr_zgtppt1130->* = CORRESPONDING #( BASE ( lr_zgtppt1130->* ) gs_zgtpps1001 ).
      lr_t1130->* = CORRESPONDING #( BASE ( lr_t1130->* ) gs_zgtpps1001 ).
    ENDIF.

    lr_t1130->style = gt_style.
  ENDLOOP.

  DELETE lt_zgtppt1130_db WHERE del EQ abap_true.

  TRY.
      IF lt_zgtppt1130_db IS NOT INITIAL.
        DELETE zgtppt1130 FROM TABLE lt_zgtppt1130_db.
      ENDIF.

      MODIFY zgtppt1130 FROM TABLE lt_zgtppt1130.

    CATCH cx_root INTO DATA(lr_root).
      ROLLBACK WORK.
      RAISE EXCEPTION TYPE lcx_exception MESSAGE e000 WITH TEXT-e01.
  ENDTRY.

  COMMIT WORK AND WAIT.

  DELETE gt_t1130 WHERE init EQ abap_true.

  gr_list->refresh( ).

  MESSAGE s500(mi).

ENDFORM.
