*&---------------------------------------------------------------------*
*& Include          ZGTPPR4090O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE status_100 OUTPUT.

  IF P_WERKS = '6500'.
    SET PF-STATUS '0100'.
  ELSEIF P_WERKS = '6600'.
    SET PF-STATUS '0100' EXCLUDING 'DISP_SCRAT'.
  ENDIF.
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
        PERFORM split_screen_layout.

        gr_list = NEW #( ).
        gr_list->display( EXPORTING ir_handler   = NEW lcl_list_handler( )
                                    ir_container = COND #( WHEN p_werks NE gc_werks-6600 THEN gr_top_container )
                                    is_variant   = VALUE #( report = sy-repid
                                                            handle = gc_handle-list )
                           CHANGING ct_data      = gt_list ).

        IF gr_weighing IS NOT BOUND.
          gr_weighing = NEW #( ).
          gr_weighing->display( EXPORTING ir_handler   = NEW lcl_list_handler( )
                                          ir_container = gr_bottom_container
                                          is_variant   = VALUE #( report = sy-repid
                                                                  handle = gc_handle-weighing )
                                 CHANGING ct_data      = gt_weighing ).
        ENDIF.

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
