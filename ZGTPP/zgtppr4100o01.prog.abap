*&---------------------------------------------------------------------*
*& Include          ZGTPPR4100O01
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
                                                          handle = COND #( WHEN p_post IS NOT INITIAL THEN gc_handle-post
                                                                                                      ELSE gc_handle-result ) )
                           CHANGING ct_data    = gt_list ).
      ENDIF.

    CATCH cx_root INTO DATA(lr_root).
      MESSAGE lr_root->get_text( ) TYPE 'I' DISPLAY LIKE 'E'.
  ENDTRY.

ENDMODULE.
