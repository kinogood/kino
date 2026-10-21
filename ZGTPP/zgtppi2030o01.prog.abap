*&---------------------------------------------------------------------*
*& Include          ZGTPPI2030O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_100 OUTPUT.

  gt_exclude = COND #( WHEN p_send EQ abap_true THEN VALUE #( ( gc_fcode-resend ) )
                       WHEN p_log  EQ abap_true THEN VALUE #( ( gc_fcode-send   ) ) ).

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
      IF gr_header IS NOT BOUND.
        gr_header = NEW #( ).
        gr_header->display( EXPORTING ir_handler   = NEW lcl_list_handler( )
                                      ir_container = NEW cl_gui_custom_container( container_name = 'CONT1' )
                            CHANGING  ct_data      = gt_header ).
      ENDIF.

    CATCH cx_root INTO DATA(lr_root).
      MESSAGE lr_root->get_text( ) TYPE 'I' DISPLAY LIKE 'E'.
  ENDTRY.

ENDMODULE.
