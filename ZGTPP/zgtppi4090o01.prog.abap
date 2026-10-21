*&---------------------------------------------------------------------*
*& Include          ZGTPPI4090O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_100 OUTPUT.

  gt_exclude = COND #( WHEN gv_saved EQ abap_true OR p_log EQ abap_true THEN VALUE #( ( gc_fcode-send ) ) ).

  SET PF-STATUS '0100' EXCLUDING gt_exclude.
  SET TITLEBAR  '0100' WITH gv_tpar1.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CREATE_ALV_100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE create_alv_100 OUTPUT.

  TRY.
      IF gr_docking_container IS NOT BOUND.
        PERFORM split_screen_layout.

        IF gr_header IS NOT BOUND.
          gr_header = NEW #( ).
          gr_header->display( EXPORTING ir_handler   = NEW lcl_list_handler( )
                                        ir_container = gr_top_container
                                        is_variant   = VALUE #( report = sy-repid
                                                                handle = gc_handle-header )
                              CHANGING ct_data = gt_header ).
        ENDIF.

        IF gr_detail IS NOT BOUND.
          gr_detail = NEW #( ).
          gr_detail->display( EXPORTING ir_handler   = NEW lcl_list_handler( )
                                        ir_container = gr_bottom_container
                                         is_variant   = VALUE #( report = sy-repid
                                                                 handle = gc_handle-detail )
                             CHANGING ct_data = gt_detail ).
        ENDIF.
      ENDIF.

    CATCH cx_root INTO DATA(lr_root).
      MESSAGE lr_root->get_text( ) TYPE 'I' DISPLAY LIKE 'E'.
  ENDTRY.

ENDMODULE.
