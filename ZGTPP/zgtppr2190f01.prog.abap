*&---------------------------------------------------------------------*
*& Include          ZGTPPR2190F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form initialization
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM initialization.

  sscrfields-functxt_01 = TEXT-fc1.
  sscrfields-functxt_02 = TEXT-fc2.

  GET PARAMETER ID 'WRK' FIELD p_werks.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form start_of_selection
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM start_of_selection.

  PERFORM set_init_list USING gc_table-zgtppt2290.
  PERFORM get_master_data.
  PERFORM retrieve_data_from_zgtppt2290.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form end_of_selection
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM end_of_selection .

  CALL SCREEN 100.

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
FORM handle_field_catalog USING pr_sender.

  IF pr_sender EQ gr_list.
    PERFORM modify_fcat_in_list.
  ENDIF.

  IF pr_sender EQ gr_eqpm.
    PERFORM modify_fcat_in_eqpm.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_layout
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM handle_layout USING pr_sender.

  IF pr_sender EQ gr_list.
    PERFORM set_layout_in_list.
  ENDIF.

  IF pr_sender EQ gr_eqpm.
    PERFORM set_layout_in_eqpm.
  ENDIF.

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
    WHEN gc_fcode-fc01. "// 설비-작업장 팹핑 관리.
      PERFORM user_command_fc01.

    WHEN gc_fcode-fc02. "// 공휴일 관리
      PERFORM user_command_fc02.

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

  PERFORM check_plant_code.
  PERFORM enqueue_table.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_toolbar
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM handle_toolbar  USING pr_sender
                           pr_object TYPE REF TO cl_alv_event_toolbar_set.

  IF gr_list IS BOUND AND pr_sender EQ gr_list->mr_grid.
    PERFORM set_toolbar_in_list USING pr_object.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_user_command
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM handle_user_command  USING pr_sender pv_ucomm.

  IF gr_list IS BOUND AND pr_sender EQ gr_list->mr_grid.
    PERFORM user_command_in_list USING pv_ucomm.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_parameter_description
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM get_parameter_description .

  CLEAR p_name1.

  IF p_werks IS NOT INITIAL.
    SELECT SINGLE name1
      INTO @p_name1
      FROM t001w
     WHERE werks EQ @p_werks.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form enqueue_table
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM enqueue_table .

  CALL FUNCTION 'ENQUEUE_E_TABLE'
    EXPORTING
      tabname        = CONV tabname( gv_list )
      varkey         = CONV vim_enqkey( COND #( WHEN gv_list EQ gc_table-zgtppt2270 THEN |{ p_werks }|
                                                WHEN gv_list EQ gc_table-zgtppt2280 THEN |{ p_werks }{ p_spmon+0(4) }|
                                                WHEN gv_list EQ gc_table-zgtppt2290 THEN |{ p_werks }| ) )
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

  CALL FUNCTION 'DEQUEUE_E_TABLE'
    EXPORTING
      tabname = CONV tabname( gv_list )
      varkey  = CONV vim_enqkey( COND #( WHEN gv_list EQ gc_table-zgtppt2270 THEN |{ p_werks }|
                                         WHEN gv_list EQ gc_table-zgtppt2280 THEN |{ p_werks }{ p_spmon+0(4) }|
                                         WHEN gv_list EQ gc_table-zgtppt2290 THEN |{ p_werks }| ) ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form modify_fcat_in_T2270
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM modify_fcat_in_t2270 .

  LOOP AT gr_list->mt_fcat REFERENCE INTO DATA(lr_fcat).
    CASE lr_fcat->fieldname.
      WHEN 'EQUCD'.
        lr_fcat->coltext    = TEXT-f01.
        lr_fcat->edit       = abap_true.
        lr_fcat->mark       = abap_true.
        lr_fcat->outputlen  = 10.

      WHEN 'EQUNM'.
        lr_fcat->coltext    = TEXT-f02.
        lr_fcat->edit       = abap_true.
        lr_fcat->outputlen  = 20.

      WHEN 'ARBPL'.
        lr_fcat->coltext    = TEXT-f03.
        lr_fcat->edit       = abap_true.
        lr_fcat->mark       = abap_true.
        lr_fcat->outputlen  = 10.

      WHEN 'KTEXT'.
        lr_fcat->coltext    = TEXT-f04.
        lr_fcat->outputlen  = 20.

      WHEN 'STATUS'.
        lr_fcat->coltext    = TEXT-f07.
        lr_fcat->just       = 'C'.
        lr_fcat->outputlen  = 7.

      WHEN 'MESSAGE'.
        lr_fcat->coltext    = TEXT-f08.
        lr_fcat->outputlen  = 30.

      WHEN OTHERS.
        lr_fcat->tech = abap_true.
    ENDCASE.

    lr_fcat->tooltip = lr_fcat->reptext = lr_fcat->coltext.
    lr_fcat->scrtext_s = lr_fcat->scrtext_m = lr_fcat->scrtext_l = lr_fcat->coltext.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form modify_fcat_in_t2280
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM modify_fcat_in_t2280 .

  LOOP AT gr_list->mt_fcat REFERENCE INTO DATA(lr_fcat).
    CASE lr_fcat->fieldname.
      WHEN 'ZHOLIDAY'.
        lr_fcat->coltext    = TEXT-f21.
        lr_fcat->edit       = abap_true.
        lr_fcat->mark       = abap_true.
        lr_fcat->just       = 'C'.
        lr_fcat->outputlen  = 10.

      WHEN 'ZDAY'.
        lr_fcat->coltext    = TEXT-f22.
        lr_fcat->just       = 'C'.
        lr_fcat->outputlen  = 3.

      WHEN 'ZHOLINM'.
        lr_fcat->coltext    = TEXT-f23.
        lr_fcat->edit       = abap_true.
        lr_fcat->outputlen  = 20.

      WHEN 'STATUS'.
        lr_fcat->coltext    = TEXT-f07.
        lr_fcat->just       = 'C'.
        lr_fcat->outputlen  = 7.

      WHEN 'MESSAGE'.
        lr_fcat->coltext    = TEXT-f08.
        lr_fcat->outputlen  = 30.

      WHEN OTHERS.
        lr_fcat->tech = abap_true.
    ENDCASE.

    lr_fcat->tooltip = lr_fcat->reptext = lr_fcat->coltext.
    lr_fcat->scrtext_s = lr_fcat->scrtext_m = lr_fcat->scrtext_l = lr_fcat->coltext.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form modify_fcat_in_t2290
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM modify_fcat_in_t2290.

  LOOP AT gr_list->mt_fcat REFERENCE INTO DATA(lr_fcat).
    CASE lr_fcat->fieldname.
      WHEN 'ZWORKDAY'.
        lr_fcat->coltext    = TEXT-f21.
        lr_fcat->just       = 'C'.
        lr_fcat->outputlen  = 10.

      WHEN 'ZDAY'.
        lr_fcat->coltext    = TEXT-f22.
        lr_fcat->just       = 'C'.
        lr_fcat->outputlen  = 3.

      WHEN 'ZHOLINM'.
        lr_fcat->coltext    = TEXT-f23.
        lr_fcat->outputlen  = 20.

      WHEN 'ZWORKTIME'.
        lr_fcat->coltext    = TEXT-f24.
        lr_fcat->edit       = abap_true.
        lr_fcat->no_zero    = abap_true.
        lr_fcat->just       = 'C'.
        lr_fcat->outputlen  = 10.

      WHEN OTHERS.
        lr_fcat->tech = abap_true.
    ENDCASE.

    lr_fcat->tooltip = lr_fcat->reptext = lr_fcat->coltext.
    lr_fcat->scrtext_s = lr_fcat->scrtext_m = lr_fcat->scrtext_l = lr_fcat->coltext.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_toolbar_in_t2270
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM set_toolbar_in_t2270  USING pr_object TYPE REF TO cl_alv_event_toolbar_set.

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
*& Form set_toolbar_in_t2280
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM set_toolbar_in_t2280  USING pr_object TYPE REF TO cl_alv_event_toolbar_set.

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
*& Form set_toolbar_in_t2290
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM set_toolbar_in_t2290  USING pr_object TYPE REF TO cl_alv_event_toolbar_set.

  pr_object->mt_toolbar = VALUE #( BASE pr_object->mt_toolbar
                                  ( butn_type = 3 )
                                  ( function  = gc_fcode-save
                                    icon      = icon_system_save
                                    text      = TEXT-b03
                                    quickinfo = TEXT-b03 )
                                  ( function  = gc_fcode-apply
                                    icon      = icon_incoming_object
                                    text      = TEXT-b04
                                    quickinfo = TEXT-b04 ) ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form user_command_in_t2270
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM user_command_in_t2270  USING  pv_ucomm.

  CASE pv_ucomm.
    WHEN gc_fcode-insert_row. "// 행 추가.
      PERFORM insert_row_in_t2270.

    WHEN gc_fcode-delete_row. "// 행 삭제.
      PERFORM delete_row_in_t2270.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form user_command_in_t2280
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM user_command_in_t2280 USING  pv_ucomm.

  CASE pv_ucomm.
    WHEN gc_fcode-insert_row. "// 행 추가.
      PERFORM insert_row_in_t2280.

    WHEN gc_fcode-delete_row. "// 행 삭제.
      PERFORM delete_row_in_t2280.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form user_command_in_t2290
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM user_command_in_t2290  USING  pv_ucomm.

  CASE pv_ucomm.
    WHEN gc_fcode-save. "// 저장.
      PERFORM user_command_save.

    WHEN gc_fcode-apply. "// 모든 설비에 적용.
      PERFORM user_command_applay.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_data_changed
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM handle_data_changed  USING pr_sender
                                pr_data_changed TYPE REF TO cl_alv_changed_data_protocol
                                pv_ucomm TYPE sy-ucomm.

  IF gr_list IS BOUND AND pr_sender EQ gr_list->mr_grid.
    PERFORM data_changed_in_list  USING pr_data_changed pv_ucomm.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form data_changed_in_list
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM data_changed_in_list  USING pr_data_changed TYPE REF TO cl_alv_changed_data_protocol
                                 pv_ucomm TYPE sy-ucomm.

  CASE gv_list.
    WHEN gc_table-zgtppt2270.
      PERFORM data_changed_in_t2270 USING pr_data_changed pv_ucomm.

    WHEN gc_table-zgtppt2280.
      PERFORM data_changed_in_t2280 USING pr_data_changed pv_ucomm.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form data_changed_in_t1130
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM data_changed_in_t1130  USING pr_data_changed TYPE REF TO cl_alv_changed_data_protocol
                                  pv_ucomm TYPE sy-ucomm.

*  DATA lr_t1130 TYPE REF TO ty_s_t1130.
*  DATA ls_t1130 TYPE ty_s_t1130.
*
*  DATA(ls_t1120) = VALUE #( gt_t1120[ checked = icon_checked ] OPTIONAL ).
*
*  IF ls_t1120 IS NOT INITIAL.
*    PERFORM set_defalut_value_of_t1130 USING ls_t1130 ls_t1120.
*  ENDIF.
*
*  LOOP AT pr_data_changed->mt_inserted_rows INTO DATA(ls_insert_row).
*    pr_data_changed->modify_cell( i_row_id = ls_insert_row-row_id: i_fieldname = 'WERKS'  i_value = ls_t1130-werks ),
*                                                                   i_fieldname = 'SPGCD'  i_value = ls_t1130-spgcd ),
*                                                                   i_fieldname = 'LGORT'  i_value = ls_t1130-lgort ),
*                                                                   i_fieldname = 'SCGRP'  i_value = ls_t1130-scgrp ),
*                                                                   i_fieldname = 'SCTXT'  i_value = ls_t1130-sctxt ),
*                                                                   i_fieldname = 'INIT'   i_value = ls_t1130-init ).
*  ENDLOOP.
*
*  LOOP AT pr_data_changed->mp_mod_rows->* REFERENCE INTO lr_t1130.
*    READ TABLE pr_data_changed->mt_mod_cells INTO DATA(ls_cell)
*                                             WITH KEY tabix = sy-tabix.
*
*    PERFORM field_valid_check_in_t1130 USING lr_t1130->*.
*    PERFORM modify_cell_in_t1130       USING pr_data_changed ls_cell lr_t1130->*.
*  ENDLOOP.
*
ENDFORM.
*&---------------------------------------------------------------------*
*& Form data_changed_in_t1140
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM data_changed_in_t1140  USING pr_data_changed TYPE REF TO cl_alv_changed_data_protocol
                                  pv_ucomm TYPE sy-ucomm.

*  DATA lr_t1140 TYPE REF TO ty_s_t1140.
*  DATA ls_t1140 TYPE ty_s_t1140.
*
*  PERFORM set_defalut_value_of_t1140 USING ls_t1140.
*
*  LOOP AT pr_data_changed->mt_inserted_rows INTO DATA(ls_insert_row).
*    pr_data_changed->modify_cell( i_row_id = ls_insert_row-row_id: i_fieldname = 'WERKS'  i_value = ls_t1140-werks ),
*                                                                   i_fieldname = 'SPGCD'  i_value = ls_t1140-spgcd ),
*                                                                   i_fieldname = 'INIT'   i_value = ls_t1140-init ).
*  ENDLOOP.
*
*  LOOP AT pr_data_changed->mp_mod_rows->* REFERENCE INTO lr_t1140.
*    READ TABLE pr_data_changed->mt_mod_cells INTO DATA(ls_cell)
*                                             WITH KEY tabix = sy-tabix.
*
*    PERFORM field_valid_check_in_t1140 USING lr_t1140->*.
*    PERFORM modify_cell_in_t1140       USING pr_data_changed ls_cell lr_t1140->*.
*  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form field_valid_check_in_t2270
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM field_valid_check_in_t2270  USING ps_t2270 TYPE ty_s_t2270.

  CLEAR: ps_t2270-status, ps_t2270-message, ps_t2270-return.

  PERFORM check_input_value_in_t2270 USING ps_t2270.
  PERFORM check_mandt_field_in_t2270 USING ps_t2270.

  IF ps_t2270-return IS NOT INITIAL.
    ps_t2270-status  = icon_led_red.
    ps_t2270-message = VALUE #( ps_t2270-return[ 1 ]-message OPTIONAL ).
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form field_valid_check_in_t1130
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM field_valid_check_in_t1130 ."  USING ps_t1130 TYPE ty_s_t1130.

*  CLEAR: ps_t1130-status, ps_t1130-message, ps_t1130-return.
*
*  PERFORM check_input_value_in_t1130 USING ps_t1130.
*  PERFORM check_mandt_field_in_t1130 USING ps_t1130.
*
*  IF ps_t1130-return IS NOT INITIAL.
*    ps_t1130-status  = icon_led_red.
*    ps_t1130-message = VALUE #( ps_t1130-return[ 1 ]-message OPTIONAL ).
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form field_valid_check_in_t1140
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM field_valid_check_in_t1140  . "USING ps_t1140 TYPE ty_s_t1140.

*  CLEAR: ps_t1140-status, ps_t1140-message, ps_t1140-return.
*
*  PERFORM check_input_value_in_t1140 USING ps_t1140.
*  PERFORM check_mandt_field_in_t1140 USING ps_t1140.
*
*  IF ps_t1140-return IS NOT INITIAL.
*    ps_t1140-status  = icon_led_red.
*    ps_t1140-message = VALUE #( ps_t1140-return[ 1 ]-message OPTIONAL ).
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_input_value_in_t1120
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM check_input_value_in_t2270 USING ps_t2270 TYPE ty_s_t2270.

  CLEAR: ps_t2270-init, ps_t2270-ktext.

*// 작업장.
  IF ps_t2270-arbpl IS NOT INITIAL.
    READ TABLE gt_crhd INTO DATA(ls_crhd) WITH KEY werks = ps_t2270-werks
                                                   arbpl = ps_t2270-arbpl BINARY SEARCH.
    IF sy-subrc IS INITIAL.
      ps_t2270-ktext = ls_crhd-ktext.
    ELSE.
      MESSAGE e011(cr) WITH ps_t2270-werks ps_t2270-arbpl INTO DATA(lv_message).
      ps_t2270-return = VALUE #( BASE ps_t2270-return ( type = 'E'  field = TEXT-f03  message = lv_message ) ).
    ENDIF.
  ENDIF.

  IF ps_t2270-equcd IS NOT INITIAL AND ps_t2270-arbpl IS NOT INITIAL.
    SELECT SINGLE @abap_true
      INTO @DATA(lv_check)
      FROM zgtppt2270
     WHERE werks EQ @ps_t2270-werks
       AND equcd EQ @ps_t2270-equcd
       AND arbpl EQ @ps_t2270-arbpl
       AND equcd NOT IN @s_equcd.

    IF sy-subrc IS INITIAL.
      ps_t2270-return = VALUE #( BASE ps_t2270-return ( type = 'E'  field = TEXT-f01  message = TEXT-e13 ) ).
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_input_value_in_t1130
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM check_input_value_in_t1130 . " USING ps_t1130 TYPE ty_s_t1130.

*  CLEAR: ps_t1130-init, ps_t1130-maktx_t.
*
**// 탈피후 스크랩 자재코드.
*  IF ps_t1130-matnr_t IS NOT INITIAL.
*    PERFORM get_material_desc USING ps_t1130-matnr_t ps_t1130-maktx_t.
*
*    SELECT SINGLE @abap_true
*      INTO @DATA(lv_check)
*      FROM marc
*     WHERE matnr EQ @ps_t1130-matnr_t
*       AND werks EQ @ps_t1130-werks.
*
*    IF sy-subrc IS NOT INITIAL.
*      MESSAGE e200(m3) WITH ps_t1130-matnr_t ps_t1130-werks INTO DATA(lv_message).
*      ps_t1130-return = VALUE #( BASE ps_t1130-return ( type = 'E'  field = TEXT-f44  message = lv_message ) ).
*    ENDIF.
*
*    DATA(ls_t1120) = VALUE #( gt_t1120[ checked = icon_checked ] OPTIONAL ).
*
*    IF ps_t1130-matnr_t EQ ls_t1120-matnr.
*      ps_t1130-return = VALUE #( BASE ps_t1130-return ( type = 'E'  field = TEXT-f44  message = TEXT-e24 ) ).
*    ENDIF.
*
*    IF ps_t1130-matnr_t EQ ls_t1120-matnr_m.
*      ps_t1130-return = VALUE #( BASE ps_t1130-return ( type = 'E'  field = TEXT-f44  message = TEXT-e23 ) ).
*    ENDIF.
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_input_value_in_t1140
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM check_input_value_in_t1140. "  USING ps_t1140 TYPE ty_s_t1140.

*  CLEAR: ps_t1140-init, ps_t1140-maktx, ps_t1140-wgbez.
*
**// 자재 그룹.
*  IF ps_t1140-matkl IS NOT INITIAL.
*    READ TABLE gt_t023t INTO DATA(ls_t023t) WITH KEY matkl = ps_t1140-matkl.
*    IF sy-subrc IS INITIAL.
*      ps_t1140-wgbez = ls_t023t-wgbez.
*    ELSE.
*      MESSAGE e046(wv) WITH ps_t1140-matkl INTO DATA(lv_message).
*      ps_t1140-return = VALUE #( BASE ps_t1140-return ( type = 'E' field = TEXT-f03 message = lv_message ) ).
*    ENDIF.
*  ENDIF.
*
**// 생산 스크랩 코드.
*  IF ps_t1140-matnr IS NOT INITIAL.
*    PERFORM get_material_desc USING ps_t1140-matnr ps_t1140-maktx.
*
*    SELECT SINGLE @abap_true
*      INTO @DATA(lv_check)
*      FROM marc
*     WHERE matnr EQ @ps_t1140-matnr
*       AND werks EQ @ps_t1140-werks.
*
*    IF sy-subrc IS NOT INITIAL.
*      MESSAGE e200(m3) WITH ps_t1140-matnr ps_t1140-werks INTO lv_message.
*      ps_t1140-return = VALUE #( BASE ps_t1140-return ( type = 'E' field = TEXT-f05 message = lv_message ) ).
*    ENDIF.
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_mandt_field_in_t1120
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM check_mandt_field_in_t2270 USING ps_t2270 TYPE ty_s_t2270.

  DATA(lr_t2270) = REF #( ps_t2270 ).

  LOOP AT gr_list->mt_fcat INTO DATA(ls_fcat)
                           WHERE mark EQ abap_true
                             AND tech EQ abap_false.
    PERFORM append_mandt_field_to_return USING lr_t2270->(ls_fcat-fieldname) ls_fcat-coltext lr_t2270->return.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_mandt_field_in_t1130
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM check_mandt_field_in_t1130. "  USING ps_t1130 TYPE ty_s_t1130.

*  DATA(lr_t1130) = REF #( ps_t1130 ).
*
*  LOOP AT gr_t1130->mt_fcat INTO DATA(ls_fcat)
*                           WHERE mark EQ abap_true
*                             AND tech EQ abap_false.
*    PERFORM append_mandt_field_to_return USING lr_t1130->(ls_fcat-fieldname) ls_fcat-coltext lr_t1130->return.
*  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_mandt_field_in_t1140
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM check_mandt_field_in_t1140. "  USING ps_t1140 TYPE ty_s_t1140.

*  DATA(lr_t1140) = REF #( ps_t1140 ).
*
*  LOOP AT gr_t1140->mt_fcat INTO DATA(ls_fcat)
*                           WHERE mark EQ abap_true
*                             AND tech EQ abap_false.
*    PERFORM append_mandt_field_to_return USING lr_t1140->(ls_fcat-fieldname) ls_fcat-coltext lr_t1140->return.
*  ENDLOOP.
*
ENDFORM.
*&---------------------------------------------------------------------*
*& Form modify_cell_in_t2270
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM modify_cell_in_t2270  USING pr_data_changed TYPE REF TO cl_alv_changed_data_protocol
                                 ps_cell  TYPE lvc_s_modi
                                 ps_t2270 TYPE ty_s_t2270.

  pr_data_changed->modify_cell( i_row_id = ps_cell-row_id:  i_fieldname = 'INIT'    i_value = ps_t2270-init ),
                                                            i_fieldname = 'KTEXT'   i_value = ps_t2270-ktext ),
                                                            i_fieldname = 'STATUS'  i_value = ps_t2270-status ),
                                                            i_fieldname = 'MESSAGE' i_value = ps_t2270-message ),
                                                            i_fieldname = 'RETURN'  i_value = ps_t2270-return ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form modify_cell_in_t1130
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM modify_cell_in_t1130. "  USING pr_data_changed TYPE REF TO cl_alv_changed_data_protocol
  "     ps_cell  TYPE lvc_s_modi
  "     ps_t1130 TYPE ty_s_t1130.

*  pr_data_changed->modify_cell( i_row_id = ps_cell-row_id: i_fieldname = 'MAKTX_T' i_value = ps_t1130-maktx_t ),
*                                                           i_fieldname = 'INIT'    i_value = ps_t1130-init ),
*                                                           i_fieldname = 'STATUS'  i_value = ps_t1130-status ),
*                                                           i_fieldname = 'MESSAGE' i_value = ps_t1130-message ),
*                                                           i_fieldname = 'RETURN'  i_value = ps_t1130-return ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form modify_cell_in_t1140
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM modify_cell_in_t1140. " USING pr_data_changed TYPE REF TO cl_alv_changed_data_protocol
  "      ps_cell  TYPE lvc_s_modi
  "      ps_t1140 TYPE ty_s_t1140.

*  pr_data_changed->modify_cell( i_row_id = ps_cell-row_id: i_fieldname = 'WGBEZ'   i_value = ps_t1140-wgbez ),
*                                                           i_fieldname = 'MAKTX'   i_value = ps_t1140-maktx ),
*                                                           i_fieldname = 'INIT'    i_value = ps_t1140-init ),
*                                                           i_fieldname = 'STATUS'  i_value = ps_t1140-status ),
*                                                           i_fieldname = 'MESSAGE' i_value = ps_t1140-message ),
*                                                           i_fieldname = 'RETURN'  i_value = ps_t1140-return ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form split_screen_layout
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM split_screen_layout .

  TRY.
      gr_docking_container = NEW #( parent    = cl_gui_container=>screen0
                                    side      = 2
                                    extension = 2000 ).

      gr_splitter_container = NEW #( parent  = gr_docking_container
                                     rows    = 1
                                     columns = 2 ).

      gr_splitter_container->set_column_width( id = 1 width = 30 ).

      gr_splitter_container->set_row_sash( id    = 1
                                           type  = cl_gui_splitter_container=>type_sashvisible
                                           value = cl_gui_splitter_container=>true ).

      gr_splitter_container->set_row_sash( id    = 1
                                           type  = cl_gui_splitter_container=>type_movable
                                           value = cl_gui_splitter_container=>true ).

      gr_left_container = gr_splitter_container->get_container( row = 1 column = 1 ).
      gr_right_container = gr_splitter_container->get_container( row = 1 column = 2 ).

    CATCH cx_root INTO DATA(lr_root).
      MESSAGE lr_root->get_text( ) TYPE 'I' DISPLAY LIKE 'E'.
  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_defalut_value_of_t2270
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM set_defalut_value_of_t2270 USING ps_t2270 TYPE ty_s_t2270.

  ps_t2270 = VALUE #( werks = p_werks
                      init  = abap_true ).

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

  CHECK pv_field IS INITIAL.

  MESSAGE e026 WITH pv_fname INTO DATA(lv_message).

  pt_return = VALUE #( BASE pt_return ( type = 'E' field = pv_fname message = lv_message ) ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form user_command_save
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM user_command_save .

  CASE gv_list.
    WHEN gc_table-zgtppt2270.        "// 설비-작업장 맵핑.
      PERFORM maintain_zgtppt2270.

    WHEN gc_table-zgtppt2280.        "// 공휴일 관리.
      PERFORM maintain_zgtppt2280.

    WHEN gc_table-zgtppt2290.        "// RCCP Wrok Day.
      PERFORM maintain_zgtppt2290.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form maintain_zgtppt2270
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM maintain_zgtppt2270.

  TRY.
      PERFORM check_before_save_zgtppt2270. "// 사전점검.
      PERFORM save_zgtppt2270.              "// 저장.

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

*  TRY.
**// 사전점검.
*      PERFORM check_before_save_zgtppt1120.
*
**// 저장.
*      PERFORM save_zgtppt1120.
*
*    CATCH lcx_exception INTO DATA(lr_exception).
*      IF lr_exception->get_text( ) IS NOT INITIAL.
*        MESSAGE lr_exception->get_text( ) TYPE 'I' DISPLAY LIKE 'E'.
*      ENDIF.
*  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_before_save_zgtppt2270
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM check_before_save_zgtppt2270 RAISING lcx_exception.

  DATA lv_answer TYPE c.

  gr_list->mr_grid->check_changed_data( IMPORTING e_valid = DATA(lv_valid) ).

  IF lv_valid NE abap_true.
    RAISE EXCEPTION TYPE lcx_exception MESSAGE e000 WITH space.
  ENDIF.

  PERFORM saved_data_extraction_t2270.

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
*& Form save_zgtppt2270
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM save_zgtppt2270 RAISING lcx_exception.
  DATA lt_zgtppt2270 TYPE TABLE OF zgtppt2270.

  SELECT mandt, werks, equcd, arbpl, equnm,
         crdat, crtim, crnam, chdat, chtim, chnam,
         @abap_false AS del
    FROM zgtppt2270 AS zt01
   WHERE werks EQ @p_werks
     AND equcd IN @s_equcd
   ORDER BY werks, equcd, arbpl
    INTO TABLE @DATA(lt_zgtppt2270_db).

*// 처리일자 및 시간.
  PERFORM get_date_time USING gs_zgtpps1001.

  LOOP AT gt_t2270 REFERENCE INTO DATA(lr_t2270)
                   WHERE sel EQ abap_true.
    APPEND INITIAL LINE TO lt_zgtppt2270 REFERENCE INTO DATA(lr_zgtppt2270).
    lr_zgtppt2270->* = CORRESPONDING #( lr_t2270->* ).

    READ TABLE lt_zgtppt2270_db REFERENCE INTO DATA(lr_zgtppt2270_db) WITH KEY werks = lr_t2270->werks
                                                                               equcd = lr_t2270->equcd
                                                                               arbpl = lr_t2270->arbpl BINARY SEARCH.
    IF sy-subrc IS INITIAL.
      lr_zgtppt2270->* = VALUE #( BASE lr_zgtppt2270->*  chdat = gs_zgtpps1001-chdat
                                                         chtim = gs_zgtpps1001-chtim
                                                         chnam = gs_zgtpps1001-chnam ).
      lr_t2270->* = VALUE #( BASE lr_t2270->*  chdat = gs_zgtpps1001-chdat
                                               chtim = gs_zgtpps1001-chtim
                                               chnam = gs_zgtpps1001-chnam ).
      lr_zgtppt2270_db->del = abap_true.
    ELSE.
      lr_zgtppt2270->* = CORRESPONDING #( BASE ( lr_zgtppt2270->* ) gs_zgtpps1001 ).
      lr_t2270->* = CORRESPONDING #( BASE ( lr_t2270->* ) gs_zgtpps1001 ).
    ENDIF.

    lr_t2270->style = gt_style.
  ENDLOOP.

  DELETE lt_zgtppt2270_db WHERE del EQ abap_true.

  TRY.
      IF lt_zgtppt2270_db IS NOT INITIAL.
        DELETE zgtppt2270 FROM TABLE lt_zgtppt2270_db.
      ENDIF.

      MODIFY zgtppt2270 FROM TABLE lt_zgtppt2270.

    CATCH cx_root INTO DATA(lr_root).
      ROLLBACK WORK.
      RAISE EXCEPTION TYPE lcx_exception MESSAGE e000 WITH TEXT-e01.
  ENDTRY.

  COMMIT WORK AND WAIT.

  DELETE gt_t2270 WHERE init EQ abap_true.

  gr_list->refresh( ).

  MESSAGE s500(mi).
*
ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_before_save_zgtppt1120
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM check_before_save_zgtppt1120 RAISING lcx_exception.
*  DATA lv_answer TYPE c.
*
*  gr_t1120->mr_grid->check_changed_data( IMPORTING e_valid = DATA(lv_valid) ).
*
*  IF lv_valid NE abap_true.
*    RAISE EXCEPTION TYPE lcx_exception MESSAGE e000 WITH space.
*  ENDIF.
*
*  gr_t1130->mr_grid->check_changed_data( IMPORTING e_valid = lv_valid ).
*
*  IF lv_valid NE abap_true.
*    RAISE EXCEPTION TYPE lcx_exception MESSAGE e000 WITH space.
*  ENDIF.
*
*  PERFORM saved_data_extraction_t1120.
*
*  IF gs_result-invalid IS NOT INITIAL.
*    RAISE EXCEPTION TYPE lcx_exception MESSAGE e000 WITH TEXT-e03.
*  ENDIF.
*
*  IF gs_result-total IS INITIAL.
*    RAISE EXCEPTION TYPE lcx_exception MESSAGE e000 WITH TEXT-e04.
*  ENDIF.
*
*  PERFORM confirmation_popup USING TEXT-c02 lv_answer.
*
*  IF lv_answer NE '1'.
*    RAISE EXCEPTION TYPE lcx_exception MESSAGE e000 WITH space.
*  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_zgtppt1120
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM save_zgtppt1120 RAISING lcx_exception.
*  DATA lt_zgtppt1120 TYPE ty_t_zgtppt1120.
*  DATA lt_zgtppt1130 TYPE ty_t_zgtppt1130.
*  DATA lt_zgtppt1120_db TYPE ty_t_zgtppt1120_db.
*  DATA lt_zgtppt1130_db TYPE ty_t_zgtppt1130_db.
*
**// 처리일시.
*  PERFORM get_date_time USING gs_zgtpps1001.
*
*  PERFORM get_save_data USING lt_zgtppt1120 lt_zgtppt1120_db
*                              lt_zgtppt1130 lt_zgtppt1130_db.
*
*  TRY.
*      IF lt_zgtppt1120_db IS NOT INITIAL.
*        DELETE zgtppt1120 FROM TABLE lt_zgtppt1120_db.
*      ENDIF.
*
*      IF lt_zgtppt1130_db IS NOT INITIAL.
*        DELETE zgtppt1130 FROM TABLE lt_zgtppt1130_db.
*      ENDIF.
*
*      MODIFY zgtppt1120 FROM TABLE lt_zgtppt1120.
*      MODIFY zgtppt1130 FROM TABLE lt_zgtppt1130.
*
*    CATCH cx_root INTO DATA(lr_root).
*      ROLLBACK WORK.
*      RAISE EXCEPTION TYPE lcx_exception MESSAGE e000 WITH TEXT-e01.
*  ENDTRY.
*
*  COMMIT WORK AND WAIT.
*
*  DELETE gt_t1120 WHERE init EQ abap_true.
*
*  READ TABLE gt_t1120 INTO DATA(ls_t1120) WITH KEY checked = icon_checked.
*  IF sy-subrc IS INITIAL.
*    gt_t1130 = ls_t1120-t1130.
*  ELSE.
*    CLEAR gt_t1130.
*  ENDIF.
*
*  gr_t1120->refresh( ).
*  gr_t1130->refresh( ).
*
*  MESSAGE s500(mi).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form saved_data_extraction_t2270
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM saved_data_extraction_t2270 .

  CLEAR gs_result.

  MODIFY gt_t2270 FROM VALUE #( sel = space )
                  TRANSPORTING sel
                  WHERE sel EQ abap_true.

  LOOP AT gt_t2270 REFERENCE INTO DATA(lr_t2270)
                  WHERE init EQ abap_false.
    IF lr_t2270->status EQ icon_led_red.
      gs_result-invalid = abap_true.
      CONTINUE.
    ENDIF.

    gs_result-sel += 1.

    lr_t2270->sel = abap_true.
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

  SELECT werks, arbpl,ktext
    INTO CORRESPONDING FIELDS OF TABLE @gt_crhd
    FROM crhd_v1
   WHERE werks EQ @p_werks
   ORDER BY werks, arbpl.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_data_changed_fini
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM handle_data_changed_fini  USING pr_sender
                                     pt_good_cells TYPE lvc_t_modi
                                     pv_modified.

  IF gr_list IS BOUND AND pr_sender EQ gr_list->mr_grid.
    PERFORM data_changed_fini_in_list USING pt_good_cells pv_modified.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form data_changed_fini_in_LIST
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM data_changed_fini_in_list  USING pt_good_cells TYPE lvc_t_modi
                                      pv_modified.

  CHECK pt_good_cells IS NOT INITIAL.

  CASE gv_list.
    WHEN gc_table-zgtppt2270.
      PERFORM check_duplication_in_t2270.

    WHEN gc_table-zgtppt2280.
      PERFORM check_duplication_in_t2280.
  ENDCASE.

  gr_list->refresh( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form data_changed_fini_in_t1140
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM data_changed_fini_in_t1140  USING pt_good_cells TYPE lvc_t_modi
                                       pv_modified.

*  CHECK pt_good_cells IS NOT INITIAL.
*
*  PERFORM check_duplication_in_t1140.
*
*  gr_t1140->refresh( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_duplication_in_t2270
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM check_duplication_in_t2270 .

*// 중복 여부.
  SELECT werks, equcd, arbpl
    FROM @gt_t2270 AS a
   WHERE equcd NE @space
     AND arbpl NE @space
   GROUP BY werks, equcd, arbpl
  HAVING COUNT( * ) GT 1
    INTO TABLE @DATA(lt_t2270).

*// 기존 데이터 중복 해지.
  LOOP AT gt_t2270 REFERENCE INTO DATA(lr_t2270)
                   WHERE dupli EQ abap_true.
    lr_t2270->dupli = abap_false.
    DELETE lr_t2270->return WHERE field EQ gc_duplication.

    IF lr_t2270->return IS INITIAL.
      CLEAR: lr_t2270->status, lr_t2270->message.
    ENDIF.
  ENDLOOP.

*// 중복 데이터 설정.
  LOOP AT lt_t2270 INTO DATA(ls_t2270).
    LOOP AT gt_t2270 REFERENCE INTO lr_t2270
                     WHERE werks EQ ls_t2270-werks
                       AND equcd EQ ls_t2270-equcd
                       AND arbpl EQ ls_t2270-arbpl.
      lr_t2270->dupli  = abap_true.
      lr_t2270->return = VALUE #( BASE lr_t2270->return ( type = 'E' field = gc_duplication message = TEXT-e11 ) ).
      IF lines( lr_t2270->return ) EQ 1.
        lr_t2270->status  = icon_led_red.
        lr_t2270->message = lr_t2270->return[ 1 ]-message.
      ENDIF.
    ENDLOOP.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_init_data_in_t2270
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM set_init_data_in_t2270 .

  DO 10 TIMES.
    APPEND INITIAL LINE TO gt_t2270  REFERENCE INTO DATA(lr_t2270).
    PERFORM set_defalut_value_of_t2270 USING lr_t2270->*.
  ENDDO.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form saved_data_extraction_t1120
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM saved_data_extraction_t1120 .

*  CLEAR gs_result.
*
*  MODIFY gt_t1120 FROM VALUE #( sel = space )
*                  TRANSPORTING sel
*                  WHERE sel EQ abap_true.
*
*  LOOP AT gt_t1120 REFERENCE INTO DATA(lr_t1120)
*                   WHERE init EQ abap_false.
*    IF lr_t1120->return IS NOT INITIAL.
*      gs_result-invalid = abap_true.
*      RETURN.
*    ENDIF.
*
*    LOOP AT lr_t1120->t1130 INTO DATA(ls_t1130).
*      IF ls_t1130-status EQ icon_led_red.
*        gs_result-invalid = abap_true.
*        RETURN.
*      ENDIF.
*    ENDLOOP.
*
*    IF lr_t1120->checked EQ icon_checked.
*      lr_t1120->t1130 = gt_t1130.
*    ENDIF.
*
*    gs_result-sel += 1.
*    lr_t1120->sel = abap_true.
*    gs_result-total += 1.
*  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_init_data_in_t2280
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM set_init_data_in_t2280.

  DO 10 TIMES.
    APPEND INITIAL LINE TO gt_t2280  REFERENCE INTO DATA(lr_t2280).
    PERFORM set_defalut_value_of_t2280 USING lr_t2280->*.
  ENDDO.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_defalut_value_of_t2280
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM set_defalut_value_of_t2280  USING ps_t2280 TYPE ty_s_t2280.

  ps_t2280 = VALUE #( werks = p_werks
                      gjahr = p_spmon+0(4)
                      init  = abap_true ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_double_click
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM handle_double_click  USING pr_sender
                                ps_row    TYPE lvc_s_roid
                                ps_column TYPE lvc_s_col.

  IF gr_eqpm IS BOUND AND pr_sender EQ gr_eqpm->mr_grid.
    PERFORM double_click_in_eqpm USING ps_row ps_column.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form double_click_in_t1120
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM double_click_in_eqpm  USING ps_row    TYPE lvc_s_roid
                                 ps_column TYPE lvc_s_col.

  TRY.
      DATA(lr_eqpm) = REF #( gt_eqpm[ ps_row-row_id ] ).

    CATCH cx_sy_itab_line_not_found.
      RETURN.
  ENDTRY.

  CHECK lr_eqpm->equnm NE gs_eqpm-equnm.

  PERFORM set_init_t2290 USING lr_eqpm->*.

  gr_list->mr_grid->get_frontend_layout( IMPORTING es_layout = DATA(ls_layout) ).

  ls_layout-grid_title = |{ TEXT-f10 }: { gv_spmon }   { TEXT-f01 }: { gs_eqpm-equcd } { gs_eqpm-equnm }|.

  gr_list->mr_grid->set_frontend_layout( ls_layout ).

  gr_list->refresh( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form insert_row_in_t2270
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM insert_row_in_t2270 .

  IF gt_t2270 IS INITIAL.
    PERFORM set_init_data_in_t2270.
  ELSE.
    gr_list->mr_grid->get_selected_rows( IMPORTING et_index_rows = DATA(lt_rows) ).

    IF lt_rows IS NOT INITIAL.
      DATA(ls_row) = VALUE #( lt_rows[ 1 ] OPTIONAL ).

      DO lines( lt_rows ) TIMES.
        INSERT INITIAL LINE INTO gt_t2270 REFERENCE INTO DATA(lr_t2270) INDEX ls_row-index.
        PERFORM set_defalut_value_of_t2270 USING lr_t2270->*.
      ENDDO.
    ELSE.
      APPEND INITIAL LINE TO gt_t2270 REFERENCE INTO lr_t2270.
      PERFORM set_defalut_value_of_t2270 USING lr_t2270->*.
    ENDIF.
  ENDIF.

  gr_list->refresh( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form insert_row_in_t2280
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM insert_row_in_t2280 .

  IF gt_t2280 IS INITIAL.
    PERFORM set_init_data_in_t2280.
  ELSE.
    gr_list->mr_grid->get_selected_rows( IMPORTING et_index_rows = DATA(lt_rows) ).

    IF lt_rows IS NOT INITIAL.
      DATA(ls_row) = VALUE #( lt_rows[ 1 ] OPTIONAL ).

      DO lines( lt_rows ) TIMES.
        INSERT INITIAL LINE INTO gt_t2280 REFERENCE INTO DATA(lr_t2280) INDEX ls_row-index.
        PERFORM set_defalut_value_of_t2280 USING lr_t2280->*.
      ENDDO.
    ELSE.
      APPEND INITIAL LINE TO gt_t2280 REFERENCE INTO lr_t2280.
      PERFORM set_defalut_value_of_t2280 USING lr_t2280->*.
    ENDIF.
  ENDIF.

  gr_list->refresh( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form delete_row_in_t2270
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM delete_row_in_t2270 .
  DATA lv_answer TYPE c.

  gr_list->mr_grid->get_selected_rows( IMPORTING et_index_rows = DATA(lt_rows) ).
  DELETE lt_rows WHERE rowtype NE space.

  IF lt_rows IS INITIAL.
    MESSAGE i000 WITH TEXT-e06 DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  PERFORM confirmation_popup USING TEXT-c09 lv_answer.

  IF lv_answer NE '1'.
    RETURN.
  ENDIF.

  LOOP AT lt_rows INTO DATA(ls_row).
    READ TABLE gt_t2270 REFERENCE INTO DATA(lr_t2270) INDEX ls_row-index.
    IF sy-subrc IS INITIAL.
      lr_t2270->sel = abap_true.
    ENDIF.
  ENDLOOP.

  DELETE gt_t2270 WHERE sel EQ abap_true.
  PERFORM check_duplication_in_t2270.

  gr_list->refresh( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form delete_row_in_t2280
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM delete_row_in_t2280 .
  DATA lv_answer TYPE c.

  gr_list->mr_grid->get_selected_rows( IMPORTING et_index_rows = DATA(lt_rows) ).
  DELETE lt_rows WHERE rowtype NE space.

  IF lt_rows IS INITIAL.
    MESSAGE i000 WITH TEXT-e06 DISPLAY LIKE 'E'.
    RETURN.
  ENDIF.

  PERFORM confirmation_popup USING TEXT-c09 lv_answer.

  IF lv_answer NE '1'.
    RETURN.
  ENDIF.

  LOOP AT lt_rows INTO DATA(ls_row).
    READ TABLE gt_t2280 REFERENCE INTO DATA(lr_t2280) INDEX ls_row-index.
    IF sy-subrc IS INITIAL.
      lr_t2280->sel = abap_true.
    ENDIF.
  ENDLOOP.

  DELETE gt_t2280 WHERE sel EQ abap_true.
  PERFORM check_duplication_in_t2280.

  gr_list->refresh( ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form user_command_applay
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM user_command_applay .

  TRY.
      PERFORM check_before_save_all_t2290. "// 사전점검.
      PERFORM save_all_zgtppt2290.         "// 저장.

    CATCH lcx_exception INTO DATA(lr_exception).
      IF lr_exception->get_text( ) IS NOT INITIAL.
        gr_list->refresh( ).
        MESSAGE lr_exception->get_text( ) TYPE 'I' DISPLAY LIKE 'E'.
      ENDIF.
  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form user_command_fc01
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM user_command_fc01 .

  PERFORM set_init_list USING gc_table-zgtppt2270.
  PERFORM check_plant_code.
  PERFORM enqueue_table.
  PERFORM get_master_data.
  PERFORM retrieve_data_from_zgtppt2270.

  CALL SCREEN 100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form user_command_fc02
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM user_command_fc02 .

  PERFORM set_init_list USING gc_table-zgtppt2280.
  PERFORM check_plant_code.
  PERFORM enqueue_table.
  PERFORM retrieve_data_from_zgtppt2280.

  CALL SCREEN 100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_plant_code
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM check_plant_code .

  CLEAR p_name1.

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

ENDFORM.
*&---------------------------------------------------------------------*
*& Form retrieve_data_from_zgtppt2270
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM retrieve_data_from_zgtppt2270.

  SELECT zt01~*,
         crhd_v1~ktext
    FROM zgtppt2270 AS zt01
    JOIN crhd_v1
      ON zt01~werks EQ crhd_v1~werks
     AND zt01~arbpl EQ crhd_v1~arbpl
   WHERE zt01~werks EQ @p_werks
     AND zt01~equcd IN @s_equcd
   ORDER BY zt01~werks, zt01~equcd, zt01~arbpl
    INTO CORRESPONDING FIELDS OF TABLE @gt_t2270.

  IF sy-subrc IS INITIAL.
    MODIFY gt_t2270 FROM VALUE #( style = gt_style ) TRANSPORTING style
                    WHERE werks EQ p_werks.
  ELSE.
    PERFORM set_init_data_in_t2270.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form f4_spmon
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM f4_spmon .

  CALL FUNCTION 'POPUP_TO_SELECT_MONTH'
    EXPORTING
      actual_month               = CONV kmonth( sy-datum+0(6) )
    IMPORTING
      selected_month             = p_spmon
    EXCEPTIONS
      factory_calendar_not_found = 1
      holiday_calendar_not_found = 2
      month_not_found            = 3
      OTHERS                     = 4.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_duplication_in_t2280
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM check_duplication_in_t2280 .
  DATA lv_zholiday TYPE zgtppt2280-zholiday.

*// 중복 여부.
  SELECT werks, zholiday
    FROM @gt_t2280 AS a
   WHERE zholiday NE @lv_zholiday
   GROUP BY werks, zholiday
  HAVING COUNT( * ) GT 1
    INTO TABLE @DATA(lt_t2280).

*// 기존 데이터 중복 해지.
  LOOP AT gt_t2280 REFERENCE INTO DATA(lr_t2280)
                   WHERE dupli EQ abap_true.
    lr_t2280->dupli = abap_false.
    DELETE lr_t2280->return WHERE field EQ gc_duplication.

    IF lr_t2280->return IS INITIAL.
      CLEAR: lr_t2280->status, lr_t2280->message.
    ENDIF.
  ENDLOOP.

*// 중복 데이터 설정.
  LOOP AT lt_t2280 INTO DATA(ls_t2280).
    LOOP AT gt_t2280 REFERENCE INTO lr_t2280
                     WHERE werks    EQ ls_t2280-werks
                       AND zholiday EQ ls_t2280-zholiday.
      lr_t2280->dupli  = abap_true.
      lr_t2280->return = VALUE #( BASE lr_t2280->return ( type = 'E' field = gc_duplication message = TEXT-e11 ) ).
      IF lines( lr_t2280->return ) EQ 1.
        lr_t2280->status  = icon_led_red.
        lr_t2280->message = lr_t2280->return[ 1 ]-message.
      ENDIF.
    ENDLOOP.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form data_changed_in_t2270
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM data_changed_in_t2270  USING pr_data_changed TYPE REF TO cl_alv_changed_data_protocol
                                  pv_ucomm TYPE sy-ucomm.

  DATA lr_t2270 TYPE REF TO ty_s_t2270.
  DATA ls_t2270 TYPE ty_s_t2270.

  PERFORM set_defalut_value_of_t2270 USING ls_t2270.

  LOOP AT pr_data_changed->mt_inserted_rows INTO DATA(ls_insert_row).
    pr_data_changed->modify_cell( i_row_id = ls_insert_row-row_id: i_fieldname = 'WERKS'  i_value = ls_t2270-werks ),
                                                                   i_fieldname = 'INIT'   i_value = ls_t2270-init ).
  ENDLOOP.

  LOOP AT pr_data_changed->mp_mod_rows->* REFERENCE INTO lr_t2270.
    READ TABLE pr_data_changed->mt_mod_cells INTO DATA(ls_cell)
                                             WITH KEY tabix = sy-tabix.

    PERFORM field_valid_check_in_t2270 USING lr_t2270->*.
    PERFORM modify_cell_in_t2270       USING pr_data_changed ls_cell lr_t2270->*.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form data_changed_in_t2280
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM data_changed_in_t2280  USING pr_data_changed TYPE REF TO cl_alv_changed_data_protocol
                                  pv_ucomm TYPE sy-ucomm.

  DATA lr_t2280 TYPE REF TO ty_s_t2280.
  DATA ls_t2280 TYPE ty_s_t2280.

  PERFORM set_defalut_value_of_t2280 USING ls_t2280.

  LOOP AT pr_data_changed->mt_inserted_rows INTO DATA(ls_insert_row).
    pr_data_changed->modify_cell( i_row_id = ls_insert_row-row_id: i_fieldname = 'WERKS'  i_value = ls_t2280-werks ),
                                                                   i_fieldname = 'GJAHR'  i_value = ls_t2280-gjahr ),
                                                                   i_fieldname = 'INIT'   i_value = ls_t2280-init ).
  ENDLOOP.

  LOOP AT pr_data_changed->mp_mod_rows->* REFERENCE INTO lr_t2280.
    READ TABLE pr_data_changed->mt_mod_cells INTO DATA(ls_cell)
                                             WITH KEY tabix = sy-tabix.

    PERFORM field_valid_check_in_t2280 USING lr_t2280->*.
    PERFORM modify_cell_in_t2280       USING pr_data_changed ls_cell lr_t2280->*.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form field_valid_check_in_t2280
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM field_valid_check_in_t2280  USING ps_t2280 TYPE ty_s_t2280.

  CLEAR: ps_t2280-status, ps_t2280-message, ps_t2280-return.

  PERFORM check_input_value_in_t2280 USING ps_t2280.
  PERFORM check_mandt_field_in_t2280 USING ps_t2280.

  IF ps_t2280-return IS NOT INITIAL.
    ps_t2280-status  = icon_led_red.
    ps_t2280-message = VALUE #( ps_t2280-return[ 1 ]-message OPTIONAL ).
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_input_value_in_t2280
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM check_input_value_in_t2280  USING ps_t2280 TYPE ty_s_t2280.
  DATA lv_daytxt TYPE hrvsched-daytxt.

  CLEAR: ps_t2280-init, ps_t2280-zday.

  IF ps_t2280-zholiday IS NOT INITIAL.
    CALL FUNCTION 'RH_GET_DATE_DAYNAME'
      EXPORTING
        langu  = sy-langu
        date   = ps_t2280-zholiday
      IMPORTING
        daytxt = lv_daytxt.

    ps_t2280-zday = lv_daytxt+0(1).
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_mandt_field_in_t2280
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM check_mandt_field_in_t2280  USING ps_t2280 TYPE ty_s_t2280.

  DATA(lr_t2280) = REF #( ps_t2280 ).

  LOOP AT gr_list->mt_fcat INTO DATA(ls_fcat)
                           WHERE mark EQ abap_true
                             AND tech EQ abap_false.
    PERFORM append_mandt_field_to_return USING lr_t2280->(ls_fcat-fieldname) ls_fcat-coltext lr_t2280->return.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form modify_cell_in_t2280
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM modify_cell_in_t2280  USING pr_data_changed TYPE REF TO cl_alv_changed_data_protocol
                                 ps_cell  TYPE lvc_s_modi
                                 ps_t2280 TYPE ty_s_t2280.

  pr_data_changed->modify_cell( i_row_id = ps_cell-row_id:  i_fieldname = 'INIT'    i_value = ps_t2280-init ),
                                                            i_fieldname = 'ZDAY'    i_value = ps_t2280-zday ),
                                                            i_fieldname = 'STATUS'  i_value = ps_t2280-status ),
                                                            i_fieldname = 'MESSAGE' i_value = ps_t2280-message ),
                                                            i_fieldname = 'RETURN'  i_value = ps_t2280-return ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form retrieve_data_from_zgtppt2280
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM retrieve_data_from_zgtppt2280 .

  SELECT zt01~*
    FROM zgtppt2280 AS zt01
   WHERE zt01~werks EQ @p_werks
     AND zt01~gjahr EQ @p_spmon+0(4)
   ORDER BY zt01~werks, zt01~zholiday
    INTO CORRESPONDING FIELDS OF TABLE @gt_t2280.

  IF sy-subrc IS INITIAL.
    MODIFY gt_t2280 FROM VALUE #( style = gt_style ) TRANSPORTING style
                    WHERE werks EQ p_werks.
  ELSE.
    PERFORM set_init_data_in_t2280.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form maintain_zgtppt2280
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM maintain_zgtppt2280 .

  TRY.
      PERFORM check_before_save_zgtppt2280. "// 사전점검.
      PERFORM save_zgtppt2280.              "// 저장.

    CATCH lcx_exception INTO DATA(lr_exception).
      IF lr_exception->get_text( ) IS NOT INITIAL.
        gr_list->refresh( ).
        MESSAGE lr_exception->get_text( ) TYPE 'I' DISPLAY LIKE 'E'.
      ENDIF.
  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_before_save_zgtppt2280
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM check_before_save_zgtppt2280 RAISING lcx_exception.

  DATA lv_answer TYPE c.

  gr_list->mr_grid->check_changed_data( IMPORTING e_valid = DATA(lv_valid) ).

  IF lv_valid NE abap_true.
    RAISE EXCEPTION TYPE lcx_exception MESSAGE e000 WITH space.
  ENDIF.

  PERFORM saved_data_extraction_t2280.

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
*& Form save_zgtppt2280
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM save_zgtppt2280 RAISING lcx_exception.
  DATA lt_zgtppt2280 TYPE TABLE OF zgtppt2280.

  SELECT mandt, werks, gjahr, zholiday, zholinm, zday,
         crdat, crtim, crnam, chdat, chtim, chnam,
         @abap_false AS del
    FROM zgtppt2280 AS zt01
   WHERE werks EQ @p_werks
     AND gjahr EQ @p_spmon+0(4)
   ORDER BY werks, gjahr, zholiday
    INTO TABLE @DATA(lt_zgtppt2280_db).

*// 처리일자 및 시간.
  PERFORM get_date_time USING gs_zgtpps1001.

  LOOP AT gt_t2280 REFERENCE INTO DATA(lr_t2280)
                   WHERE sel EQ abap_true.
    APPEND INITIAL LINE TO lt_zgtppt2280 REFERENCE INTO DATA(lr_zgtppt2280).
    lr_zgtppt2280->* = CORRESPONDING #( lr_t2280->* ).

    READ TABLE lt_zgtppt2280_db REFERENCE INTO DATA(lr_zgtppt2280_db) WITH KEY werks    = lr_t2280->werks
                                                                               gjahr    = lr_t2280->gjahr
                                                                               zholiday = lr_t2280->zholiday BINARY SEARCH.
    IF sy-subrc IS INITIAL.
      lr_zgtppt2280->* = VALUE #( BASE lr_zgtppt2280->*  chdat = gs_zgtpps1001-chdat
                                                         chtim = gs_zgtpps1001-chtim
                                                         chnam = gs_zgtpps1001-chnam ).
      lr_t2280->* = VALUE #( BASE lr_t2280->*  chdat = gs_zgtpps1001-chdat
                                               chtim = gs_zgtpps1001-chtim
                                               chnam = gs_zgtpps1001-chnam ).
      lr_zgtppt2280_db->del = abap_true.
    ELSE.
      lr_zgtppt2280->* = CORRESPONDING #( BASE ( lr_zgtppt2280->* ) gs_zgtpps1001 ).
      lr_t2280->* = CORRESPONDING #( BASE ( lr_t2280->* ) gs_zgtpps1001 ).
    ENDIF.

    lr_t2280->style = gt_style.
  ENDLOOP.

  DELETE lt_zgtppt2280_db WHERE del EQ abap_true.

  TRY.
      IF lt_zgtppt2280_db IS NOT INITIAL.
        DELETE zgtppt2280 FROM TABLE lt_zgtppt2280_db.
      ENDIF.

      MODIFY zgtppt2280 FROM TABLE lt_zgtppt2280.

    CATCH cx_root INTO DATA(lr_root).
      ROLLBACK WORK.
      RAISE EXCEPTION TYPE lcx_exception MESSAGE e000 WITH TEXT-e01.
  ENDTRY.

  COMMIT WORK AND WAIT.

  DELETE gt_t2280 WHERE init EQ abap_true.

  gr_list->refresh( ).

  MESSAGE s500(mi).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form saved_data_extraction_t2280
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM saved_data_extraction_t2280 .

  CLEAR gs_result.

  MODIFY gt_t2280 FROM VALUE #( sel = space )
                  TRANSPORTING sel
                  WHERE sel EQ abap_true.

  LOOP AT gt_t2280 REFERENCE INTO DATA(lr_t2280)
                  WHERE init EQ abap_false.
    IF lr_t2280->status EQ icon_led_red.
      gs_result-invalid = abap_true.
      CONTINUE.
    ENDIF.

    gs_result-sel += 1.

    lr_t2280->sel = abap_true.
    gs_result-total += 1.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_init_list
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM set_init_list  USING  pv_list.

  gv_list = pv_list.

  CASE gv_list.
    WHEN gc_table-zgtppt2270.
      gr_data  = REF #( gt_t2270 ).
      gv_tpar1 = TEXT-t21.
      gt_style = VALUE #( style = cl_gui_alv_grid=>mc_style_disabled  ( fieldname = 'EQUCD' )
                                                                      ( fieldname = 'ARBPL' ) ).
    WHEN gc_table-zgtppt2280.
      gr_data  = REF #( gt_t2280 ).
      gv_tpar1 = TEXT-t22.
      gt_style = VALUE #( style = cl_gui_alv_grid=>mc_style_disabled  ( fieldname = 'ZHOLIDAY' ) ).

    WHEN gc_table-zgtppt2290.
      gr_data  = REF #( gt_t2290 ).
      gv_tpar1 = TEXT-t23.
      WRITE p_spmon TO gv_spmon.
      gt_exclude = VALUE #( ( gc_fcode-save ) ).
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form modify_fcat_in_list
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM modify_fcat_in_list .

  CASE gv_list.
    WHEN gc_table-zgtppt2270.
      PERFORM modify_fcat_in_t2270.

    WHEN gc_table-zgtppt2280.
      PERFORM modify_fcat_in_t2280.

    WHEN gc_table-zgtppt2290.
      PERFORM modify_fcat_in_t2290.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form modify_fcat_in_eqpm
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM modify_fcat_in_eqpm .

  LOOP AT gr_eqpm->mt_fcat REFERENCE INTO DATA(lr_fcat).
    CASE lr_fcat->fieldname.
      WHEN 'EQUCD'.
        lr_fcat->coltext    = TEXT-f01.
        lr_fcat->outputlen  = 10.

      WHEN 'EQUNM'.
        lr_fcat->coltext    = TEXT-f02.
        lr_fcat->outputlen  = 20.

      WHEN 'ZSTAT'.
        lr_fcat->coltext    = TEXT-f25.
        lr_fcat->just       = 'C'.
        lr_fcat->outputlen  = 17.

      WHEN OTHERS.
        lr_fcat->tech = abap_true.
    ENDCASE.

    lr_fcat->tooltip = lr_fcat->reptext = lr_fcat->coltext.
    lr_fcat->scrtext_s = lr_fcat->scrtext_m = lr_fcat->scrtext_l = lr_fcat->coltext.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_layout_in_list
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM set_layout_in_list .

  TRY.
      gr_list->ms_layout = VALUE #( BASE gr_list->ms_layout  stylefname = 'STYLE'
                                                             cwidth_opt = abap_false
                                                             info_fname = COND #( WHEN gv_list EQ gc_table-zgtppt2290 THEN 'ROW_COLOR' )
                                                             grid_title = COND #( WHEN gv_list EQ gc_table-zgtppt2270 THEN |{ TEXT-f00 }: { p_werks } { p_name1 }|
                                                                                  WHEN gv_list EQ gc_table-zgtppt2280 THEN |{ TEXT-f09 }: { p_spmon+0(4) }  { TEXT-f00 }: { p_werks } { p_name1 }|
                                                                                  WHEN gv_list EQ gc_table-zgtppt2290 THEN |{ TEXT-f10 }: { gv_spmon }   { TEXT-f01 }: { gs_eqpm-equcd } { gs_eqpm-equnm }| ) ).
    CATCH cx_root.

  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_layout_in_eqpm
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM set_layout_in_eqpm .

  TRY.
      gr_eqpm->ms_layout = VALUE #( BASE gr_eqpm->ms_layout  cwidth_opt = abap_false
                                                             grid_title = |{ TEXT-f00 }: { p_werks } { p_name1 }| ).
    CATCH cx_root.

  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_toolbar_in_list
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM set_toolbar_in_list  USING pr_object TYPE REF TO cl_alv_event_toolbar_set.

  CASE gv_list.
    WHEN gc_table-zgtppt2270.
      PERFORM set_toolbar_in_t2270 USING pr_object.

    WHEN gc_table-zgtppt2280.
      PERFORM set_toolbar_in_t2280 USING pr_object.

    WHEN gc_table-zgtppt2290.
      PERFORM set_toolbar_in_t2290 USING pr_object.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form user_command_in_list
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM user_command_in_list  USING  pv_ucomm.

  CASE gv_list.
    WHEN gc_table-zgtppt2270.
      PERFORM user_command_in_t2270 USING pv_ucomm.

    WHEN gc_table-zgtppt2280.
      PERFORM user_command_in_t2280 USING pv_ucomm.

    WHEN gc_table-zgtppt2290.
      PERFORM user_command_in_t2290 USING pv_ucomm.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form retrieve_data_from_zgtppt2290
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM retrieve_data_from_zgtppt2290 .
  DATA lt_t2290 TYPE TABLE OF ty_s_t2290 WITH NON-UNIQUE SORTED KEY skey COMPONENTS werks spmon equcd.

  SELECT *
    INTO CORRESPONDING FIELDS OF TABLE @gt_t2280
    FROM zgtppt2280
   WHERE werks EQ @p_werks
     AND gjahr EQ @p_spmon+0(4)
   ORDER BY werks, gjahr, zholiday.

  SELECT zt01~werks, zt01~spmon, zt01~equcd,
         zt01~zworkday, zt01~zworktime, zt01~weekday, zt01~zday,
         zt02~zholinm
    FROM zgtppt2290 AS zt01
    LEFT JOIN @gt_t2280 AS zt02
       ON zt01~werks    EQ zt02~werks
      AND zt01~zworkday EQ zt02~zholiday
  WHERE zt01~werks EQ @p_werks
    AND zt01~spmon EQ @p_spmon
    AND zt01~equcd IN @s_equcd
  ORDER BY zt01~werks, zt01~spmon, zt01~equcd, zt01~zworkday
    INTO CORRESPONDING FIELDS OF TABLE @lt_t2290.

  SELECT zt01~equcd,
         zt01~equnm
    FROM zgtppt2270 AS zt01
   WHERE zt01~werks EQ @p_werks
     AND zt01~equcd IN @s_equcd
   GROUP BY zt01~werks, zt01~equcd, zt01~equnm
   ORDER BY zt01~werks, zt01~equcd
    INTO CORRESPONDING FIELDS OF TABLE @gt_eqpm.

  LOOP AT gt_eqpm REFERENCE INTO DATA(lr_eqpm).
    lr_eqpm->t2290 = FILTER #( lt_t2290 USING KEY skey  WHERE werks EQ p_werks
                                                          AND spmon EQ p_spmon
                                                          AND equcd EQ lr_eqpm->equcd ).

    MODIFY lr_eqpm->t2290 FROM VALUE #( row_color = 'C700' )
                          TRANSPORTING row_color
                          WHERE zholinm IS NOT INITIAL
                             OR weekday BETWEEN '6' AND '7' .

    lr_eqpm->zstat = COND #( WHEN lr_eqpm->t2290 IS NOT INITIAL THEN icon_led_green
                                                                ELSE icon_led_red ).
  ENDLOOP.

  IF gt_eqpm IS NOT INITIAL.
    lr_eqpm = REF #( gt_eqpm[ 1 ] ).
    PERFORM set_init_t2290 USING lr_eqpm->*.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form set_init_t2290
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM set_init_t2290 USING ps_eqpm TYPE ty_s_equipment.

  IF ps_eqpm-t2290 IS INITIAL.
    DATA(lv_from) = CONV d( |{ p_spmon }01| ).

    DO ( cl_reca_date=>set_to_end_of_month( lv_from ) - lv_from + 1 ) TIMES.
      APPEND INITIAL LINE TO ps_eqpm-t2290 REFERENCE INTO DATA(lr_t2290).
      lr_t2290->* = VALUE #( werks     = p_werks
                             spmon     = p_spmon
                             equcd     = ps_eqpm-equcd
                             zworkday  = lv_from ).

      PERFORM get_day_attributes USING lr_t2290->*.

      lv_from += 1.
    ENDDO.
  ENDIF.

  gt_t2290 = ps_eqpm-t2290.
  SORT gt_t2290.

  gs_eqpm = ps_eqpm.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_day_attributes
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM get_day_attributes  USING ps_t2290 TYPE ty_s_t2290.

  DATA lt_day_attribute TYPE TABLE OF casdayattr.

  CALL FUNCTION 'DAY_ATTRIBUTES_GET'
    EXPORTING
      date_from      = ps_t2290-zworkday
      date_to        = ps_t2290-zworkday
      language       = sy-langu
    TABLES
      day_attributes = lt_day_attribute
    EXCEPTIONS
      OTHERS         = 0.

  CHECK lt_day_attribute IS NOT INITIAL.

  DATA(ls_day_attribute) = VALUE #( lt_day_attribute[ 1 ] OPTIONAL ).

  ps_t2290 = VALUE #( BASE ps_t2290  zday      = ls_day_attribute-weekday_s
                                     weekday   = ls_day_attribute-weekday
                                     zholinm   = VALUE #( gt_t2280[ KEY skey  werks     = p_werks
                                                                              gjahr    = p_spmon+0(4)
                                                                              zholiday = ps_t2290-zworkday ]-zholinm OPTIONAL )

                                     row_color = COND #( WHEN ps_t2290-zholinm IS NOT INITIAL OR
                                                              ls_day_attribute-weekday BETWEEN '6' AND '7' THEN  'C700' ) ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form maintain_zgtppt2290
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM maintain_zgtppt2290 .

  TRY.
      PERFORM check_before_save_zgtppt2290. "// 사전점검.
      PERFORM save_zgtppt2290.              "// 저장.

    CATCH lcx_exception INTO DATA(lr_exception).
      IF lr_exception->get_text( ) IS NOT INITIAL.
        gr_list->refresh( ).
        MESSAGE lr_exception->get_text( ) TYPE 'I' DISPLAY LIKE 'E'.
      ENDIF.
  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_before_save_zgtppt2290
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM check_before_save_zgtppt2290 RAISING lcx_exception.

  DATA lv_answer TYPE c.

  gr_list->mr_grid->check_changed_data( IMPORTING e_valid = DATA(lv_valid) ).

  IF lv_valid NE abap_true.
    RAISE EXCEPTION TYPE lcx_exception MESSAGE e000 WITH space.
  ENDIF.

  PERFORM saved_data_extraction_t2290.

  IF gs_result-invalid IS NOT INITIAL.
    RAISE EXCEPTION TYPE lcx_exception MESSAGE e000 WITH TEXT-e08.
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
*& Form saved_data_extraction_t2290
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM saved_data_extraction_t2290 .

  CLEAR gs_result.

  LOOP AT gt_t2290 REFERENCE INTO DATA(lr_t2290).
    IF lr_t2290->zworktime GT '24'.
      gs_result-invalid = abap_true.
      EXIT.
    ENDIF.

    gs_result-total += 1.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_zgtppt2290
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM save_zgtppt2290 .
  DATA lt_zgtppt2290 TYPE TABLE OF zgtppt2290.

  SELECT mandt, werks, spmon, equcd, zworkday, zworktime,
         zday, weekday,
         crdat, crtim, crnam, chdat, chtim, chnam,
         @abap_false AS del
    FROM zgtppt2290 AS zt01
   WHERE werks EQ @p_werks
     AND spmon EQ @p_spmon
     AND equcd EQ @gs_eqpm-equcd
   ORDER BY werks, spmon, equcd, zworkday
    INTO TABLE @DATA(lt_zgtppt2290_db).

*// 처리일자 및 시간.
  PERFORM get_date_time USING gs_zgtpps1001.

  LOOP AT gt_t2290 REFERENCE INTO DATA(lr_t2290).
    APPEND INITIAL LINE TO lt_zgtppt2290 REFERENCE INTO DATA(lr_zgtppt2290).
    lr_zgtppt2290->* = CORRESPONDING #( lr_t2290->* ).

    READ TABLE lt_zgtppt2290_db REFERENCE INTO DATA(lr_zgtppt2290_db) WITH KEY werks    = lr_t2290->werks
                                                                               spmon    = lr_t2290->spmon
                                                                               equcd    = lr_t2290->equcd
                                                                               zworkday = lr_t2290->zworkday BINARY SEARCH.
    IF sy-subrc IS INITIAL.
      lr_zgtppt2290->* = VALUE #( BASE lr_zgtppt2290->*  chdat = gs_zgtpps1001-chdat
                                                         chtim = gs_zgtpps1001-chtim
                                                         chnam = gs_zgtpps1001-chnam ).
      lr_t2290->* = VALUE #( BASE lr_t2290->*  chdat = gs_zgtpps1001-chdat
                                               chtim = gs_zgtpps1001-chtim
                                               chnam = gs_zgtpps1001-chnam ).
    ELSE.
      lr_zgtppt2290->* = CORRESPONDING #( BASE ( lr_zgtppt2290->* ) gs_zgtpps1001 ).
      lr_t2290->* = CORRESPONDING #( BASE ( lr_t2290->* ) gs_zgtpps1001 ).
    ENDIF.
  ENDLOOP.

  TRY.
      MODIFY zgtppt2290 FROM TABLE lt_zgtppt2290.

    CATCH cx_root INTO DATA(lr_root).
      ROLLBACK WORK.
      RAISE EXCEPTION TYPE lcx_exception MESSAGE e000 WITH TEXT-e01.
  ENDTRY.

  COMMIT WORK AND WAIT.

  DATA(lr_eqpm) = REF #( gt_eqpm[ equcd = gs_eqpm-equcd ] OPTIONAL ).
  lr_eqpm->t2290 = gt_t2290.
  lr_eqpm->zstat = icon_led_green.

  gr_eqpm->refresh( ).
  gr_list->refresh( ).

  MESSAGE s500(mi).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form save_all_zgtppt2290
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM save_all_zgtppt2290 .
  DATA lt_zgtppt2290 TYPE TABLE OF zgtppt2290.

  SELECT mandt, werks, spmon, equcd, zworkday, zworktime, zday, weekday,
         crdat, crtim, crnam, chdat, chtim, chnam,
         @abap_false AS del
    FROM zgtppt2290 AS zt01
   WHERE werks EQ @p_werks
     AND spmon EQ @p_spmon
     AND equcd IN @s_equcd
   ORDER BY werks, spmon, equcd, zworkday
    INTO TABLE @DATA(lt_zgtppt2290_db).

*// 처리일자 및 시간.
  PERFORM get_date_time USING gs_zgtpps1001.

  LOOP AT gt_eqpm REFERENCE INTO DATA(lr_eqpm).
    LOOP AT gt_t2290 REFERENCE INTO DATA(lr_t2290).
      APPEND INITIAL LINE TO lt_zgtppt2290 REFERENCE INTO DATA(lr_zgtppt2290).
      lr_zgtppt2290->* = CORRESPONDING #( lr_t2290->* ).
      lr_zgtppt2290->equcd = lr_eqpm->equcd.

      READ TABLE lt_zgtppt2290_db REFERENCE INTO DATA(lr_zgtppt2290_db) WITH KEY werks    = lr_zgtppt2290->werks
                                                                                 spmon    = lr_zgtppt2290->spmon
                                                                                 equcd    = lr_zgtppt2290->equcd
                                                                                 zworkday = lr_zgtppt2290->zworkday BINARY SEARCH.
      IF sy-subrc IS INITIAL.
        lr_zgtppt2290->* = VALUE #( BASE lr_zgtppt2290->*  chdat = gs_zgtpps1001-chdat
                                                           chtim = gs_zgtpps1001-chtim
                                                           chnam = gs_zgtpps1001-chnam ).
        lr_t2290->* = VALUE #( BASE lr_t2290->*  chdat = gs_zgtpps1001-chdat
                                                 chtim = gs_zgtpps1001-chtim
                                                 chnam = gs_zgtpps1001-chnam ).
      ELSE.
        lr_zgtppt2290->* = CORRESPONDING #( BASE ( lr_zgtppt2290->* ) gs_zgtpps1001 ).
        lr_t2290->* = CORRESPONDING #( BASE ( lr_t2290->* ) gs_zgtpps1001 ).
      ENDIF.
    ENDLOOP.

    lr_eqpm->t2290 = gt_t2290.
    MODIFY lr_eqpm->t2290 FROM VALUE #( equcd = lr_eqpm->equcd )
                          TRANSPORTING equcd
                          WHERE equcd NE space.
    lr_eqpm->zstat = COND #( WHEN lr_eqpm->t2290 IS NOT INITIAL THEN icon_led_green
                                                                ELSE icon_led_red ).
  ENDLOOP.
*
  TRY.
      MODIFY zgtppt2290 FROM TABLE lt_zgtppt2290.

    CATCH cx_root INTO DATA(lr_root).
      ROLLBACK WORK.
      RAISE EXCEPTION TYPE lcx_exception MESSAGE e000 WITH TEXT-e01.
  ENDTRY.

  COMMIT WORK AND WAIT.

  gr_eqpm->refresh( ).
  gr_list->refresh( ).

  MESSAGE s500(mi).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_before_save_all_t2290
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM check_before_save_all_t2290 RAISING lcx_exception.

  DATA lv_answer TYPE c.

  gr_list->mr_grid->check_changed_data( IMPORTING e_valid = DATA(lv_valid) ).

  IF lv_valid NE abap_true.
    RAISE EXCEPTION TYPE lcx_exception MESSAGE e000 WITH space.
  ENDIF.

  PERFORM saved_data_extraction_t2290.

  IF gs_result-invalid IS NOT INITIAL.
    RAISE EXCEPTION TYPE lcx_exception MESSAGE e000 WITH TEXT-e08.
  ENDIF.

  IF gs_result-total IS INITIAL.
    RAISE EXCEPTION TYPE lcx_exception MESSAGE e000 WITH TEXT-e04.
  ENDIF.

  PERFORM confirmation_popup USING TEXT-c10 lv_answer.

  IF lv_answer NE '1'.
    RAISE EXCEPTION TYPE lcx_exception MESSAGE e000 WITH space.
  ENDIF.

ENDFORM.
