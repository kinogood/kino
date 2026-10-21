*&---------------------------------------------------------------------*
*& Include          ZGTPPR2170O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_100 OUTPUT.

  SET PF-STATUS '0100'.
  SET TITLEBAR  '0100'.

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

        gr_cutting = NEW #( ).
        gr_cutting->display( EXPORTING ir_handler   = NEW lcl_list_handler( )
                                      ir_container = gr_top_container
                                      is_variant   = VALUE #( report = sy-repid
                                                              handle = gc_handle-cutting )
                            CHANGING ct_data      = gt_cutting ).

        gr_alloc = NEW #( ).
        gr_alloc->display( EXPORTING ir_handler   = NEW lcl_list_handler( )
                                     ir_container = gr_bottom_container
                                     is_variant   = VALUE #( report = sy-repid
                                                             handle = gc_handle-alloc )
                          CHANGING  ct_data      = gt_alloc ).

        CALL FUNCTION 'SAPGUI_SET_FUNCTIONCODE'
          EXPORTING
            functioncode           = gc_fcode-fixed_col
          EXCEPTIONS
            function_not_supported = 1
            OTHERS                 = 2.
      ENDIF.

    CATCH cx_root INTO DATA(lr_root).
      MESSAGE lr_root->get_text( ) TYPE 'I' DISPLAY LIKE 'E'.
  ENDTRY.

ENDMODULE.
