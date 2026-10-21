*&---------------------------------------------------------------------*
*& Include          ZGTPPR2160O01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_100 OUTPUT.

  SET PF-STATUS '0100'.
  SET TITLEBAR  '0100' WITH GV_TPAR1 GV_TPAR2.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CREATE_ALV_100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE CREATE_ALV_100 OUTPUT.

  TRY.
      IF GR_DOCKING_CONTAINER IS NOT BOUND.
        PERFORM SPLIT_SCREEN_LAYOUT.

        IF P_WKORD EQ ABAP_TRUE.
          GR_SLORD = NEW #( ).
          GR_SLORD->DISPLAY( EXPORTING IR_HANDLER   = NEW LCL_LIST_HANDLER( )
                                       IR_CONTAINER = GR_TOP_CONTAINER
                                       IS_VARIANT   = VALUE #( REPORT = SY-REPID
                                                               HANDLE = GC_HANDLE-SLORD )
                              CHANGING CT_DATA      = GT_SLORD ).

          GR_STOCK = NEW #( ).
          GR_STOCK->DISPLAY( EXPORTING IR_HANDLER = NEW LCL_LIST_HANDLER( )
                                       IR_CONTAINER = GR_LEFT_CONTAINER
                                       IS_VARIANT   = VALUE #( REPORT = SY-REPID
                                                               HANDLE = GC_HANDLE-STOCK )
                              CHANGING CT_DATA      = GT_STOCK ).

          GR_STOCK->MR_GRID->SET_READY_FOR_INPUT( 1 ).

          GR_WKORD = NEW #( ).
          GR_WKORD->DISPLAY( EXPORTING IR_HANDLER = NEW LCL_LIST_HANDLER( )
                                       IR_CONTAINER = GR_RIGHT_CONTAINER
                                       IS_VARIANT   = VALUE #( REPORT = SY-REPID
                                                               HANDLE = GC_HANDLE-WKORD )
                             CHANGING  CT_DATA    = GT_WKORD ).

          GR_WKORD->MR_GRID->SET_READY_FOR_INPUT( 1 ).
        ELSE.
          GR_CUTTING = NEW #( ).
          GR_CUTTING->DISPLAY( EXPORTING IR_HANDLER   = NEW LCL_LIST_HANDLER( )
                                        IR_CONTAINER = GR_TOP_CONTAINER
                                        IS_VARIANT   = VALUE #( REPORT = SY-REPID
                                                                HANDLE = GC_HANDLE-RESULT )
                              CHANGING CT_DATA      = GT_CUTTING ).

          GR_ALLOC = NEW #( ).
          GR_ALLOC->DISPLAY( EXPORTING IR_HANDLER   = NEW LCL_LIST_HANDLER( )
                                       IR_CONTAINER = GR_BOTTOM_CONTAINER
                                       IS_VARIANT   = VALUE #( REPORT = SY-REPID
                                                               HANDLE = GC_HANDLE-RESULT )
                            CHANGING  CT_DATA      = GT_ALLOC ).
        ENDIF.

        CALL FUNCTION 'SAPGUI_SET_FUNCTIONCODE'
          EXPORTING
            FUNCTIONCODE           = GC_FCODE-FIXED_COL
          EXCEPTIONS
            FUNCTION_NOT_SUPPORTED = 1
            OTHERS                 = 2.

      ENDIF.

    CATCH CX_ROOT INTO DATA(LR_ROOT).
      MESSAGE LR_ROOT->GET_TEXT( ) TYPE 'I' DISPLAY LIKE 'E'.
  ENDTRY.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_200 OUTPUT.

  SET PF-STATUS '0200'.
  SET TITLEBAR  '0200' WITH GV_TPAR1.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CREATE_ALV_200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE CREATE_ALV_200 OUTPUT.

  TRY.
      IF GR_TABMT IS NOT BOUND.
        GR_TABMT = NEW #( ).
        GR_TABMT->DISPLAY( EXPORTING IR_HANDLER = NEW LCL_LIST_HANDLER( )
                                     IS_VARIANT = VALUE #( REPORT = SY-REPID
                                                           HANDLE = COND #( WHEN GV_TABMT EQ GC_TABLE-ZGTPPT2420 THEN GC_HANDLE-T2420
                                                                                                                 ELSE GC_HANDLE-T2430 ) )
                           CHANGING  CT_DATA    = GR_DATA->* ).
      ENDIF.

    CATCH CX_ROOT INTO LR_ROOT.
      MESSAGE LR_ROOT->GET_TEXT( ) TYPE 'I' DISPLAY LIKE 'E'.
  ENDTRY.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0300 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0300 OUTPUT.
  SET PF-STATUS '0300'.
  SET TITLEBAR '0300'.
ENDMODULE.
