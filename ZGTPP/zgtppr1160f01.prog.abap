*&---------------------------------------------------------------------*
*& Include          ZGTPPR1160F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form initialization
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM initialization.

  s_gstrp[] = VALUE #( sign = 'I' option = 'BT' ( low  = cl_reca_date=>set_to_begin_of_month( sy-datum )
                                                  high = cl_reca_date=>set_to_end_of_month( sy-datum ) ) ).

  s_intvl[] = VALUE #( sign = 'I' option = 'BT' ( low  = 100   high = 100 ) ).

*  PERFORM get_default_variant.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form start_of_selection
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM start_of_selection.

  PERFORM get_input_status.

  CASE abap_true.
    WHEN p_prod.
      PERFORM get_input_status_by_prod_ord.  "// 생산오더별.

    WHEN p_hmat.
      PERFORM get_input_status_by_hmat.      "// 모품목별.

    WHEN p_comp.
      PERFORM get_input_status_by_component. "// 자품목별.
  ENDCASE.

  gr_data = COND #( WHEN p_prod EQ abap_true THEN REF #( gt_prod )
                    WHEN p_hmat EQ abap_true THEN REF #( gt_hmat )
                    WHEN p_comp EQ abap_true THEN REF #( gt_comp ) ).

ENDFORM.
*&---------------------------------------------------------------------*
*& Form end_of_selection
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM end_of_selection .

  IF gr_data->* IS NOT INITIAL.
    PERFORM call_screen_100.
  ELSE.
    MESSAGE s033.
    LEAVE LIST-PROCESSING.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form user_command_exit
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM user_command_exit .

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
FORM handle_field_catalog .

  CASE abap_true.
    WHEN p_prod.
      PERFORM handle_field_catalog_in_prod.

    WHEN p_hmat.
      PERFORM handle_field_catalog_in_hmat.

    WHEN p_comp.
      PERFORM handle_field_catalog_in_comp.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_layout
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM handle_layout .

  TRY.
*      gr_list->ms_layout-cwidth_opt = abap_false.

    CATCH cx_root.

  ENDTRY.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_double_click
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM handle_double_click USING ps_row    TYPE lvc_s_roid
                               ps_column TYPE lvc_s_col.

  TRY.
      DATA(ls_prod) = gt_prod[ ps_row-row_id ].

    CATCH cx_sy_itab_line_not_found.
      RETURN.
  ENDTRY.

  CASE ps_column-fieldname.
    WHEN 'AUFNR'.
      CHECK ls_prod-aufnr IS NOT INITIAL.

      SET PARAMETER ID 'ANR' FIELD ls_prod-aufnr.

      TRY.
          CALL TRANSACTION 'CO03' WITH AUTHORITY-CHECK AND SKIP FIRST SCREEN.

        CATCH cx_sy_authorization_error.
          MESSAGE e077(s#) WITH 'CO03' DISPLAY LIKE 'S'.
      ENDTRY.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form at_selection_screen_output
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM at_selection_screen_output .

  PERFORM get_default_variant.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form at_selection_screen
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM at_selection_screen .

  CASE sscrfields-ucomm.
*// 실행.
    WHEN gc_fcode-onli.
      PERFORM check_sel_screen_input_value.
  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form check_sel_screen_input_value
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM check_sel_screen_input_value.

*// Variant 점검.
  IF p_vari IS NOT INITIAL.
    DATA(ls_variant) = VALUE disvariant( report = sy-repid
                                         handle = COND #( WHEN p_prod EQ abap_true THEN gc_handle-prod
                                                          WHEN p_hmat EQ abap_true THEN gc_handle-hmat
                                                          WHEN p_comp EQ abap_true THEN gc_handle-comp )
                                         variant = p_vari ).

    CALL FUNCTION 'LVC_VARIANT_EXISTENCE_CHECK'
      EXPORTING
        i_save        = 'A'
      CHANGING
        cs_variant    = ls_variant
      EXCEPTIONS
        wrong_input   = 1
        not_found     = 2
        program_error = 3
        OTHERS        = 4.

    IF sy-subrc IS NOT INITIAL.
      MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
                                        WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
    ENDIF.
  ENDIF.

  CLEAR gt_inpst.

  IF p_opt_in IS NOT INITIAL.
    APPEND VALUE #( sign = 'I' option = 'EQ' low = TEXT-c21 ) TO gt_inpst.
  ENDIF.

  IF p_und_in IS NOT INITIAL.
    APPEND VALUE #( sign = 'I' option = 'EQ' low = TEXT-c22 ) TO gt_inpst.
  ENDIF.

  IF p_ovr_in IS NOT INITIAL.
    APPEND VALUE #( sign = 'I' option = 'EQ' low = TEXT-c23 ) TO gt_inpst.
  ENDIF.

  IF p_unp_in IS NOT INITIAL.
    APPEND VALUE #( sign = 'I' option = 'EQ' low = TEXT-c24 ) TO gt_inpst.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form call_screen_100
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM call_screen_100 .

  gv_tpar1 = COND #( WHEN p_prod EQ abap_true THEN TEXT-c11
                     WHEN p_hmat EQ abap_true THEN TEXT-c12
                     WHEN p_comp EQ abap_true THEN TEXT-c13 ).

  CALL SCREEN 100.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form f4_variant
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM f4_variant .

  DATA(ls_variant) = VALUE disvariant( report = sy-repid
                                       handle = COND #( WHEN p_prod EQ abap_true THEN gc_handle-prod
                                                        WHEN p_hmat EQ abap_true THEN gc_handle-hmat
                                                        WHEN p_comp EQ abap_true THEN gc_handle-comp ) ).

  CALL FUNCTION 'LVC_VARIANT_F4'
    EXPORTING
      is_variant = ls_variant
      i_save     = 'A'
    IMPORTING
      es_variant = ls_variant
    EXCEPTIONS
      not_found  = 1
      OTHERS     = 2.

  IF sy-subrc IS NOT INITIAL.
    MESSAGE ID sy-msgid TYPE sy-msgty NUMBER sy-msgno
            WITH sy-msgv1 sy-msgv2 sy-msgv3 sy-msgv4.
  ELSE.
    IF ls_variant-variant IS NOT INITIAL.
      p_vari = ls_variant-variant.
    ENDIF.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_default_variant
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM get_default_variant .

  DATA(ls_variant) = VALUE disvariant( report = sy-repid
                                       handle = COND #( WHEN p_prod EQ abap_true THEN gc_handle-prod
                                                        WHEN p_hmat EQ abap_true THEN gc_handle-hmat
                                                        WHEN p_comp EQ abap_true THEN gc_handle-comp ) ).

  CALL FUNCTION 'LVC_VARIANT_DEFAULT_GET'
    EXPORTING
      i_save     = space
    CHANGING
      cs_variant = ls_variant
    EXCEPTIONS
      not_found  = 2.

  IF sy-subrc IS INITIAL.
    p_vari = ls_variant-variant.
  ENDIF.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_field_catalog_in_prod
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM handle_field_catalog_in_prod .

  LOOP AT gr_list->mt_fcat REFERENCE INTO DATA(lr_fcat).
    lr_fcat->col_opt = 'A'.

    CASE lr_fcat->fieldname.
      WHEN 'WERKS'.
        lr_fcat->coltext    = TEXT-f01.
        lr_fcat->key        = abap_true.
        lr_fcat->just       = 'C'.

      WHEN 'AUFNR'.
        lr_fcat->coltext    = TEXT-f02.
        lr_fcat->key        = abap_true.
        lr_fcat->just       = 'C'.

      WHEN 'ORDST'.
        lr_fcat->coltext    = TEXT-f03.

      WHEN 'ZPJNO'.
        lr_fcat->coltext    = TEXT-f04.

      WHEN 'ZPTXT'.
        lr_fcat->coltext    = TEXT-f05.

      WHEN 'BSTNK'.
        lr_fcat->coltext    = TEXT-f06.

      WHEN 'ZJOB_NAME'.
        lr_fcat->coltext    = TEXT-f07.

      WHEN 'MATNR'.
        lr_fcat->coltext    = TEXT-f08.
        lr_fcat->key        = abap_true.

      WHEN 'MAKTX'.
        lr_fcat->coltext    = TEXT-f09.
        lr_fcat->key        = abap_true.

      WHEN 'COLOR'.
        lr_fcat->coltext    = TEXT-f10.

      WHEN 'DISPO'.
        lr_fcat->coltext    = TEXT-f11.
        lr_fcat->just       = 'C'.

      WHEN 'GAMNG'.
        lr_fcat->coltext    = TEXT-f12.
        lr_fcat->no_zero    = abap_true.

      WHEN 'WEMNG'.
        lr_fcat->coltext    = TEXT-f13.
        lr_fcat->no_zero    = abap_true.

      WHEN 'GMEIN'.
        lr_fcat->coltext    = TEXT-f14.
        lr_fcat->just       = 'C'.

      WHEN 'IDNRK'.
        lr_fcat->coltext    = TEXT-f15.
        lr_fcat->emphasize  = 'C500'.

      WHEN 'IDNTX'.
        lr_fcat->coltext    = TEXT-f16.
        lr_fcat->emphasize  = 'C500'.

      WHEN 'ERFMG'.
        lr_fcat->coltext    = TEXT-f17.
        lr_fcat->no_zero    = abap_true.

      WHEN 'ZCUMNG'.
        lr_fcat->coltext    = TEXT-f18.
        lr_fcat->no_zero    = abap_true.

      WHEN 'BACKLOG'.
        lr_fcat->coltext    = TEXT-f19.
        lr_fcat->just       = 'C'.

      WHEN 'MENGE'.
        lr_fcat->coltext    = TEXT-f20.
        lr_fcat->no_zero    = abap_true.

      WHEN 'ERFME'.
        lr_fcat->coltext    = TEXT-f21.
        lr_fcat->just       = 'C'.

      WHEN 'INPST'.
        lr_fcat->coltext    = TEXT-f22.

      WHEN 'ZQTYDIF'.
        lr_fcat->coltext    = TEXT-f23.
        lr_fcat->no_zero    = abap_true.

      WHEN 'ZGIRATE'.
        lr_fcat->coltext    = TEXT-f24.
        lr_fcat->no_zero    = abap_true.

      WHEN 'STPRS'.
        lr_fcat->coltext    = TEXT-f25.
        lr_fcat->no_zero    = abap_true.

      WHEN 'ZAMTDIF'.
        lr_fcat->coltext    = TEXT-f26.
        lr_fcat->no_zero    = abap_true.

      WHEN 'WAERS'.
        lr_fcat->coltext    = TEXT-f27.
        lr_fcat->just       = 'C'.

      WHEN OTHERS.
        lr_fcat->tech = abap_true.
    ENDCASE.

    lr_fcat->tooltip = lr_fcat->reptext = lr_fcat->coltext.
    lr_fcat->scrtext_s = lr_fcat->scrtext_m = lr_fcat->scrtext_l = lr_fcat->coltext.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_field_catalog_in_hmat
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM handle_field_catalog_in_hmat .

  LOOP AT gr_list->mt_fcat REFERENCE INTO DATA(lr_fcat).
    lr_fcat->col_opt = 'A'.

    CASE lr_fcat->fieldname.
      WHEN 'WERKS'.
        lr_fcat->coltext    = TEXT-f01.
        lr_fcat->key        = abap_true.
        lr_fcat->just       = 'C'.

      WHEN 'MATNR'.
        lr_fcat->coltext    = TEXT-f08.
        lr_fcat->key        = abap_true.

      WHEN 'MAKTX'.
        lr_fcat->coltext    = TEXT-f09.
        lr_fcat->key        = abap_true.

      WHEN 'COLOR'.
        lr_fcat->coltext    = TEXT-f10.

      WHEN 'DISPO'.
        lr_fcat->coltext    = TEXT-f11.
        lr_fcat->just       = 'C'.

      WHEN 'GAMNG'.
        lr_fcat->coltext    = TEXT-f12.
        lr_fcat->no_zero    = abap_true.

      WHEN 'WEMNG'.
        lr_fcat->coltext    = TEXT-f13.
        lr_fcat->no_zero    = abap_true.

      WHEN 'GMEIN'.
        lr_fcat->coltext    = TEXT-f14.
        lr_fcat->just       = 'C'.

      WHEN 'IDNRK'.
        lr_fcat->coltext    = TEXT-f15.
        lr_fcat->emphasize  = 'C500'.

      WHEN 'IDNTX'.
        lr_fcat->coltext    = TEXT-f16.
        lr_fcat->emphasize  = 'C500'.

      WHEN 'ERFMG'.
        lr_fcat->coltext    = TEXT-f17.
        lr_fcat->no_zero    = abap_true.

      WHEN 'ZCUMNG'.
        lr_fcat->coltext    = TEXT-f18.

      WHEN 'BACKLOG'.
        lr_fcat->coltext    = TEXT-f19.
        lr_fcat->just       = 'C'.

      WHEN 'MENGE'.
        lr_fcat->coltext    = TEXT-f20.
        lr_fcat->no_zero    = abap_true.

      WHEN 'ERFME'.
        lr_fcat->coltext    = TEXT-f21.
        lr_fcat->just       = 'C'.

      WHEN 'INPST'.
        lr_fcat->coltext    = TEXT-f22.

      WHEN 'ZQTYDIF'.
        lr_fcat->coltext    = TEXT-f23.
        lr_fcat->no_zero    = abap_true.

      WHEN 'ZGIRATE'.
        lr_fcat->coltext    = TEXT-f24.
        lr_fcat->no_zero    = abap_true.

      WHEN 'STPRS'.
        lr_fcat->coltext    = TEXT-f25.
        lr_fcat->no_zero    = abap_true.

      WHEN 'ZAMTDIF'.
        lr_fcat->coltext    = TEXT-f26.
        lr_fcat->no_zero    = abap_true.

      WHEN 'WAERS'.
        lr_fcat->coltext    = TEXT-f27.
        lr_fcat->no_zero    = abap_true.

      WHEN OTHERS.
        lr_fcat->tech = abap_true.
    ENDCASE.

    lr_fcat->tooltip = lr_fcat->reptext = lr_fcat->coltext.
    lr_fcat->scrtext_s = lr_fcat->scrtext_m = lr_fcat->scrtext_l = lr_fcat->coltext.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form handle_field_catalog_in_comp
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM handle_field_catalog_in_comp .

  LOOP AT gr_list->mt_fcat REFERENCE INTO DATA(lr_fcat).
    lr_fcat->col_opt = 'A'.

    CASE lr_fcat->fieldname.
      WHEN 'WERKS'.
        lr_fcat->coltext    = TEXT-f01.
        lr_fcat->key        = abap_true.
        lr_fcat->just       = 'C'.

      WHEN 'IDNRK'.
        lr_fcat->coltext    = TEXT-f15.
        lr_fcat->key        = abap_true.

      WHEN 'IDNTX'.
        lr_fcat->coltext    = TEXT-f16.
        lr_fcat->key        = abap_true.

      WHEN 'ERFMG'.
        lr_fcat->coltext    = TEXT-f17.
        lr_fcat->no_zero    = abap_true.

      WHEN 'ZCUMNG'.
        lr_fcat->coltext    = TEXT-f18.
        lr_fcat->no_zero    = abap_true.

      WHEN 'BACKLOG'.
        lr_fcat->coltext    = TEXT-f19.
        lr_fcat->just       = 'C'.

      WHEN 'MENGE'.
        lr_fcat->coltext    = TEXT-f20.
        lr_fcat->no_zero    = abap_true.

      WHEN 'ERFME'.
        lr_fcat->coltext    = TEXT-f21.
        lr_fcat->just       = 'C'.

      WHEN 'INPST'.
        lr_fcat->coltext    = TEXT-f22.

      WHEN 'ZQTYDIF'.
        lr_fcat->coltext    = TEXT-f23.
        lr_fcat->no_zero    = abap_true.

      WHEN 'ZGIRATE'.
        lr_fcat->coltext    = TEXT-f24.
        lr_fcat->no_zero    = abap_true.

      WHEN 'STPRS'.
        lr_fcat->coltext    = TEXT-f25.
        lr_fcat->no_zero    = abap_true.

      WHEN 'ZAMTDIF'.
        lr_fcat->coltext    = TEXT-f26.
        lr_fcat->no_zero    = abap_true.

      WHEN 'WAERS'.
        lr_fcat->coltext    = TEXT-f27.
        lr_fcat->just       = 'C'.

      WHEN OTHERS.
        lr_fcat->tech = abap_true.
    ENDCASE.

    lr_fcat->tooltip = lr_fcat->reptext = lr_fcat->coltext.
    lr_fcat->scrtext_s = lr_fcat->scrtext_m = lr_fcat->scrtext_l = lr_fcat->coltext.
  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_input_status_by_prod_ord
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM get_input_status_by_prod_ord .

  DATA lv_line TYPE bsvx-sttxt.

  LOOP AT gt_prod REFERENCE INTO DATA(lr_prod).
    TRY.
        lr_prod->ordst = gt_stext[ KEY skey objnr = lr_prod->objnr ]-ordst.

      CATCH cx_sy_itab_line_not_found.
        PERFORM get_object_status USING lr_prod->objnr lv_line.

        APPEND INITIAL LINE TO gt_stext REFERENCE INTO DATA(lr_stext).
        lr_stext->* = VALUE #( objnr = lr_prod->objnr
                               ordst = lv_line ).
        lr_prod->ordst = lr_stext->ordst.
    ENDTRY.

    IF lr_prod->gamng IS NOT INITIAL.
      lr_prod->zcumng = lr_prod->erfmg * ( lr_prod->wemng / lr_prod->gamng ). "// 소요량(생산입고수량 기준).
    ENDIF.

    lr_prod->zqtydif = lr_prod->menge - lr_prod->zcumng.   "// 차이수량 = 자재투입수량 - 소요량(생산입고수량 기준).
    lr_prod->zamtdif = lr_prod->zqtydif * lr_prod->stprs.  "// 차이금액 = 차이수량 * 표준가.

    PERFORM calc_compoment_girate USING lr_prod->erfmg lr_prod->menge lr_prod->zcumng
                                        lr_prod->inpst lr_prod->zgirate.
  ENDLOOP.

  IF gt_inpst IS NOT INITIAL.
    DELETE gt_prod WHERE inpst NOT IN gt_inpst.
  ENDIF.

  SORT gt_prod BY werks aufnr.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_input_status_by_hmat
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM get_input_status_by_hmat .

  DATA lt_prod_order TYPE TABLE OF ty_s_prod_order WITH NON-UNIQUE SORTED KEY skey COMPONENTS aufnr.

  LOOP AT gt_prod INTO DATA(ls_key)
                  GROUP BY ( werks = ls_key-werks
                             matnr = ls_key-matnr
                             idnrk = ls_key-idnrk )
                  INTO DATA(lt_group).

    CLEAR lt_prod_order.

    LOOP AT GROUP lt_group INTO DATA(ls_prod).
      TRY.
          DATA(lr_hmat) = REF #( gt_hmat[ KEY skey werks = ls_prod-werks
                                                   matnr = ls_prod-matnr
                                                   idnrk = ls_prod-idnrk ] ).
        CATCH cx_sy_itab_line_not_found.
          APPEND INITIAL LINE TO gt_hmat REFERENCE INTO lr_hmat.
          lr_hmat->* = VALUE #( werks = ls_prod-werks
                                matnr = ls_prod-matnr
                                maktx = ls_prod-maktx
                                color = ls_prod-color
                                gmein = ls_prod-gmein
                                dispo = ls_prod-dispo
                                idnrk = ls_prod-idnrk
                                idntx = ls_prod-idntx
                                stprs = ls_prod-stprs
                                waers = ls_prod-waers ).
      ENDTRY.

      IF NOT line_exists( lt_prod_order[ aufnr = ls_prod-aufnr ] ).
        lr_hmat->gamng = lr_hmat->gamng + ls_prod-gamng.
        lr_hmat->wemng = lr_hmat->wemng + ls_prod-wemng.
        APPEND ls_prod-aufnr TO lt_prod_order.
      ENDIF.

      lr_hmat->erfmg = lr_hmat->erfmg + ls_prod-erfmg.
      lr_hmat->menge = lr_hmat->menge + ls_prod-menge.

      IF lr_hmat->gamng IS NOT INITIAL.
        lr_hmat->zcumng = lr_hmat->erfmg * ( lr_hmat->wemng / lr_hmat->gamng ). "// 소요량(생산입고수량 기준).
      ENDIF.

      lr_hmat->zqtydif = lr_hmat->menge - lr_hmat->zcumng.  "// 차이수량 = 자재투입수량 - 소요량(생산입고수량 기준).
      lr_hmat->zamtdif = lr_hmat->zqtydif * lr_hmat->stprs. "// 차이금액 = 차이수량 * 표준가.

      PERFORM calc_compoment_girate USING lr_hmat->erfmg lr_hmat->menge lr_hmat->zcumng
                                          lr_hmat->inpst lr_hmat->zgirate.

      lr_hmat->backlog = COND #( WHEN ls_prod-backlog IS NOT INITIAL THEN ls_prod-backlog ELSE lr_hmat->backlog ).
      lr_hmat->erfme   = COND #( WHEN ls_prod-erfme   IS NOT INITIAL THEN ls_prod-erfme   ELSE lr_hmat->erfme ).
      lr_hmat->gmein   = COND #( WHEN ls_prod-gmein   IS NOT INITIAL THEN ls_prod-gmein   ELSE lr_hmat->gmein ).
    ENDLOOP.
  ENDLOOP.

  SORT gt_hmat BY werks matnr.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_input_status_by_component
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM get_input_status_by_component .

  DATA lt_prod_order TYPE TABLE OF ty_s_prod_order WITH NON-UNIQUE SORTED KEY skey COMPONENTS aufnr.

  LOOP AT gt_prod INTO DATA(ls_key)
                  GROUP BY ( werks = ls_key-werks
                             idnrk = ls_key-idnrk )
                  INTO DATA(lt_group).

    CLEAR lt_prod_order.

    LOOP AT GROUP lt_group INTO DATA(ls_prod).
      TRY.
          DATA(lr_comp) = REF #( gt_comp[ KEY skey werks = ls_prod-werks
                                                   idnrk = ls_prod-idnrk ] ).
        CATCH cx_sy_itab_line_not_found.
          APPEND INITIAL LINE TO gt_comp REFERENCE INTO lr_comp.
          lr_comp->* = VALUE #( werks = ls_prod-werks
                                idnrk = ls_prod-idnrk
                                idntx = ls_prod-idntx
                                stprs = ls_prod-stprs
                                waers = ls_prod-waers ).
      ENDTRY.

      IF NOT line_exists( lt_prod_order[ aufnr = ls_prod-aufnr ] ).
        lr_comp->gamng = lr_comp->gamng + ls_prod-gamng.
        lr_comp->wemng = lr_comp->wemng + ls_prod-wemng.
        lr_comp->gmein = ls_prod-gmein.
        APPEND ls_prod-aufnr TO lt_prod_order.
      ENDIF.

      lr_comp->erfmg = lr_comp->erfmg + ls_prod-erfmg.
      lr_comp->menge = lr_comp->menge + ls_prod-menge.

      IF lr_comp->gamng IS NOT INITIAL.
        lr_comp->zcumng = lr_comp->erfmg * ( lr_comp->wemng / lr_comp->gamng ). "// 소요량(생산입고수량 기준).
      ENDIF.

      lr_comp->zqtydif = lr_comp->menge - lr_comp->zcumng. "// 차이수량 = 자재투입수량 - 소요량(생산입고수량 기준).
      lr_comp->zamtdif = lr_comp->zqtydif * lr_comp->stprs."// 차이금액 = 차이수량 * 표준가.

      PERFORM calc_compoment_girate USING lr_comp->erfmg lr_comp->menge lr_comp->zcumng
                                          lr_comp->inpst lr_comp->zgirate.

      lr_comp->backlog = COND #( WHEN ls_prod-backlog IS NOT INITIAL THEN ls_prod-backlog ELSE lr_comp->backlog ).
      lr_comp->erfme   = COND #( WHEN ls_prod-erfme   IS NOT INITIAL THEN ls_prod-erfme   ELSE lr_comp->erfme ).
      lr_comp->gmein   = COND #( WHEN ls_prod-gmein   IS NOT INITIAL THEN ls_prod-gmein   ELSE lr_comp->gmein ).
    ENDLOOP.
  ENDLOOP.

  SORT gt_comp BY werks idnrk.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_object_status
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM get_object_status  USING pv_objnr  pv_line.

  CLEAR pv_line.

  CALL FUNCTION 'STATUS_TEXT_EDIT'
    EXPORTING
      objnr            = pv_objnr
      spras            = sy-langu
    IMPORTING
      line             = pv_line
    EXCEPTIONS
      object_not_found = 1
      OTHERS           = 2.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form get_input_status
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM get_input_status .

  IF p_hlbex EQ abap_true.
    DATA(lv_where) = |mara~mtart NOT IN ('MCHF','HALB')|.
  ENDIF.

  WITH +prod AS ( SELECT aufk~werks, aufk~aufnr, aufk~objnr,
                         afko~gamng, afko~gmein,
                         afpo~matnr, afpo~wemng,
                         vbak~zpjno, vbak~bstnk,
                         zt01~zptxt, zt02~zjob_name,
                         marc~dispo,
                         makt~maktx,
                         t001~waers
                    FROM aufk
                    JOIN afko
                      ON aufk~aufnr EQ afko~aufnr
                    JOIN afpo
                      ON afko~aufnr EQ afpo~aufnr
                    JOIN marc
                      ON afpo~matnr EQ marc~matnr
                     AND aufk~werks EQ marc~werks
                    LEFT JOIN vbak
                      ON afpo~kdauf EQ vbak~vbeln
                    LEFT JOIN zsd0106t AS zt01
                      ON vbak~zpjno EQ zt01~zpjno
                    LEFT JOIN zgtedt2121 AS zt02
                      ON zt02~zsystem_id EQ 'KBDM'
                     AND aufk~werks      EQ zt02~zwerks
                     AND vbak~bstnk      EQ zt02~zjob_no
                    JOIN makt
                      ON afpo~matnr EQ makt~matnr
                     AND makt~spras EQ @sy-langu
                    JOIN t001w
                      ON aufk~werks EQ t001w~werks
                    JOIN t001k
                      ON t001w~bwkey EQ t001k~bwkey
                    JOIN t001
                      ON t001k~bukrs EQ t001~bukrs
                   WHERE aufk~werks IN @s_werks
                     AND aufk~auart IN @s_auart
                     AND aufk~aufnr IN @s_aufnr
                     AND afpo~matnr IN @s_matnr
                     AND afpo~kdauf IN @s_kdauf
                     AND afko~gstrp IN @s_gstrp
                     AND vbak~zpjno IN @s_zpjno
                     AND vbak~bstnk IN @s_bstnk
                     AND marc~dispo IN @s_dispo ),

    +comp AS ( SELECT resb~aufnr, resb~werks, resb~matnr AS idnrk, makt~maktx AS idntx, resb~erfme, SUM( resb~erfmg ) AS erfmg
                 FROM +prod AS zt01
                 JOIN resb
                   ON zt01~aufnr EQ resb~aufnr
                 JOIN mara
                   ON zt01~matnr EQ mara~matnr
                 JOIN makt
                   ON mara~matnr EQ makt~matnr
                  AND makt~spras EQ @sy-langu
                WHERE resb~matnr IN @s_idnrk
                  AND resb~kzkup EQ @space
                  AND (lv_where)
                  AND NOT EXISTS ( SELECT jsto~objnr
                                     FROM jsto
                                     JOIN tj04
                                       ON jsto~obtyp EQ tj04~obtyp
                                     JOIN jest
                                       ON jsto~objnr EQ jest~objnr
                                      AND tj04~istat EQ jest~stat
                                     JOIN tj02t
                                       ON jest~stat   EQ tj02t~istat
                                      AND tj02t~spras EQ 'E'
                                    WHERE jsto~objnr  EQ resb~objnr
                                      AND tj02t~txt04 LIKE '%DLT%')
             GROUP BY resb~aufnr, resb~werks, resb~matnr, makt~maktx, resb~erfme ),

    +matdoc AS ( SELECT zt01~aufnr, matdoc~matnr, matdoc~erfme, SUM( matdoc~erfmg ) AS menge
                   FROM +prod AS zt01
                   JOIN matdoc
                     ON zt01~aufnr EQ matdoc~aufnr
                  WHERE matdoc~bwart IN ('261','Z61')
                    AND matdoc~cancelled EQ @space
                  GROUP BY zt01~aufnr, matdoc~matnr, matdoc~erfme ),

    +affw AS ( SELECT affw~aufnr, affw~matnr, @icon_led_green AS backlog
                 FROM +comp AS zt01
                 JOIN affw
                   ON zt01~aufnr EQ affw~aufnr
                  AND zt01~idnrk EQ affw~matnr
                GROUP BY affw~aufnr, affw~matnr ),

    +mbew AS ( SELECT DISTINCT mbew~matnr, zt01~werks, mbew~stprs, mbew~peinh
                 FROM +comp AS zt01
                 JOIN t001w
                   ON zt01~werks EQ t001w~werks
                 JOIN t001k
                   ON t001w~bwkey EQ t001k~bwkey
                 JOIN mbew
                   ON zt01~idnrk  EQ mbew~matnr
                  AND t001k~bwkey EQ mbew~bwkey ),

    +mbewh AS ( SELECT DISTINCT mbewh~matnr, zt01~werks, mbewh~stprs, mbewh~peinh
                 FROM +comp AS zt01
                 JOIN t001w
                   ON zt01~werks EQ t001w~werks
                 JOIN t001k
                   ON t001w~bwkey EQ t001k~bwkey
                 JOIN mbewh
                   ON zt01~idnrk  EQ mbewh~matnr
                  AND t001k~bwkey EQ mbewh~bwkey
                  AND mbewh~lfgja EQ @sy-datum+0(4)
                  AND mbewh~lfmon EQ @sy-datum+4(2) )

    SELECT zt01~werks, zt01~aufnr, zt01~gamng, zt01~gmein,
           zt01~matnr, zt01~wemng, zt01~zpjno, zt01~bstnk,
           zt01~dispo, zt01~maktx, zt01~zptxt, zt01~zjob_name,
           zt01~objnr, zt01~waers,
           zt02~idnrk, zt02~idntx, zt02~erfmg,
           zt03~menge,
           zt04~backlog,
           coalesce( zt02~erfme, zt03~erfme ) AS erfme,
           coalesce( division( zt06~stprs, zt06~peinh, 3 ), division( zt05~stprs, zt05~peinh, 3 ) ) AS stprs
      FROM +prod AS zt01
      JOIN +comp AS zt02
        ON zt01~aufnr EQ zt02~aufnr
      LEFT JOIN +matdoc AS zt03
        ON zt01~aufnr EQ zt03~aufnr
       AND zt02~idnrk EQ zt03~matnr
      LEFT JOIN +affw AS zt04
        ON zt01~aufnr EQ zt04~aufnr
      LEFT JOIN +mbew AS zt05
        ON zt02~idnrk EQ zt05~matnr
       AND zt02~werks EQ zt05~werks
      LEFT JOIN +mbewh AS zt06
        ON zt02~idnrk EQ zt06~matnr
       AND zt02~werks EQ zt06~werks
      INTO CORRESPONDING FIELDS OF TABLE @gt_prod.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form calc_compoment_girate
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
FORM calc_compoment_girate  USING pv_erfmg pv_menge pv_zcumng
                                  pv_inpst TYPE char10
                                  pv_zgirate.

  IF pv_erfmg IS INITIAL. "// 소요량(생산오더수량 기준).
    pv_zgirate = COND #( WHEN pv_menge GT 0 THEN '9999.999'
                         WHEN pv_menge EQ 0 THEN '0'
                         ELSE '-9999.999' ).
    pv_inpst = TEXT-c24.
  ELSE.
    IF pv_zcumng IS NOT INITIAL.
      pv_zgirate = pv_menge / pv_zcumng * 100. "// 투입율(%) = ( 생산투입수량 / 소요량(생산입고수량 기준) ) * 100.
    ENDIF.

    pv_inpst = COND #( WHEN pv_zgirate IN s_intvl      THEN TEXT-c21
                       WHEN pv_zgirate LT s_intvl-low  THEN TEXT-c22
                       WHEN pv_zgirate GT s_intvl-high THEN TEXT-c23 ).
  ENDIF.

ENDFORM.
