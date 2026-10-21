*&---------------------------------------------------------------------*
*& Include          ZGTPPR1160O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_100 OUTPUT.

  SET PF-STATUS '0100'.
  SET TITLEBAR  '0100' WITH gv_tpar1.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CREATE_ALV_100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE create_alv_100 OUTPUT.

  TRY.
      IF gr_list IS NOT BOUND.
        gr_list = NEW #( ).
        gr_list->display( EXPORTING ir_handler = NEW lcl_list_handler( )
                                    is_variant = VALUE #( report  = sy-repid
                                                          variant = p_vari
                                                          handle  = COND #( WHEN p_prod EQ abap_true THEN gc_handle-prod
                                                                            WHEN p_hmat EQ abap_true THEN gc_handle-hmat
                                                                            WHEN p_comp EQ abap_true THEN gc_handle-comp ) )
                                    iv_default = abap_false
                          CHANGING  ct_data    = gr_data->* ).
      ENDIF.

    CATCH cx_root INTO DATA(lr_root).
      MESSAGE lr_root->get_text( ) TYPE 'I' DISPLAY LIKE 'E'.
  ENDTRY.

ENDMODULE.
