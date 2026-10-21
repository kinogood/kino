*&---------------------------------------------------------------------*
*& Include          ZGTPPR3160I01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_100 OUTPUT.

  gt_exclude = COND #( WHEN p_disp EQ abap_true THEN VALUE #( ( gc_fcode-rework ) ) ).

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
      IF gr_list IS NOT BOUND.
        gr_list = NEW #( ).
        gr_list->display( EXPORTING ir_handler = NEW lcl_list_handler( )
                          CHANGING  ct_data    = gt_list ).
      ENDIF.

    CATCH cx_root INTO DATA(lr_root).
      MESSAGE lr_root->get_text( ) TYPE 'I' DISPLAY LIKE 'E'.
  ENDTRY.

ENDMODULE.
