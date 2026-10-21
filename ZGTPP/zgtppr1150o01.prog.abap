*&---------------------------------------------------------------------*
*& Include          ZGTPPR1150O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_100 OUTPUT.

  SET PF-STATUS '0100' EXCLUDING gt_exclude.
  SET TITLEBAR  '0100' WITH gv_tpar1 gv_tpar2.

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
                                    is_variant = VALUE #( report = sy-repid
                                                          handle = COND #( WHEN p_t1120 EQ abap_true THEN gc_handle-t1120
                                                                           WHEN p_t1130 EQ abap_true THEN gc_handle-t1130
                                                                           WHEN p_t1140 EQ abap_true THEN gc_handle-t1140 ) )
                           CHANGING  ct_data   = gr_data->* ).
      ENDIF.

    CATCH cx_root INTO DATA(lr_root).
      MESSAGE lr_root->get_text( ) TYPE 'I' DISPLAY LIKE 'E'.
  ENDTRY.

ENDMODULE.
