*&---------------------------------------------------------------------*
*& Include          ZGTPPR2190I01
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
      IF gv_list EQ gc_table-zgtppt2290.
        PERFORM split_screen_layout.

        IF gr_eqpm IS NOT BOUND.
          gr_eqpm = NEW #( ).
          gr_eqpm->display( EXPORTING ir_handler   = NEW lcl_list_handler( )
                                      ir_container = SWITCH #( gv_list WHEN gc_table-zgtppt2290 THEN gr_left_container )
                                      is_variant   = VALUE #( report = sy-repid
                                                              handle = gc_handle-eqpm )
                             CHANGING ct_data      = gt_eqpm ).
        ENDIF.
      ENDIF.

      IF gr_list IS NOT BOUND.
        gr_list = NEW #( ).
        gr_list->display( EXPORTING ir_handler   = NEW lcl_list_handler( )
                                    ir_container = SWITCH #( gv_list WHEN gc_table-zgtppt2290 THEN gr_right_container )
                                    is_variant   = VALUE #( report = sy-repid
                                                            handle = COND #( WHEN gv_list EQ gc_table-zgtppt2270 THEN gc_handle-t2270
                                                                             WHEN gv_list EQ gc_table-zgtppt2280 THEN gc_handle-t2280
                                                                             WHEN gv_list EQ gc_table-zgtppt2290 THEN gc_handle-t2290 ) )
                           CHANGING ct_data    = gr_data->* ).
      ENDIF.

    CATCH cx_root INTO DATA(lr_root).
      MESSAGE lr_root->get_text( ) TYPE 'I' DISPLAY LIKE 'E'.
  ENDTRY.

ENDMODULE.
