*&---------------------------------------------------------------------*
*& Include          ZGTPPR2330F01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_100 OUTPUT.

  REFRESH GT_EXCLUDE.
  GT_EXCLUDE = COND #( WHEN GV_CHANGED EQ ABAP_TRUE THEN VALUE #( ( GC_FCODE-CHANGE ) ) ).

  SET PF-STATUS '0100' EXCLUDING GT_EXCLUDE.
  SET TITLEBAR  '0100' WITH GV_TPAR1.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CREATE_ALV_100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE CREATE_ALV_100 OUTPUT.

  TRY.
      IF GR_LIST IS NOT BOUND.
        PERFORM SPLIT_SCREEN_LAYOUT.

        GR_ORDER = NEW #( ).
        GR_ORDER->DISPLAY( EXPORTING IR_HANDLER   = NEW LCL_LIST_HANDLER( )
                                    IR_CONTAINER = GR_TOP_CONTAINER
                                    IS_VARIANT   = VALUE #( REPORT = SY-REPID
                                                            HANDLE = GC_HANDLE-AUFK )
                           CHANGING CT_DATA      = GT_ORDER ).

        GR_LIST = NEW #( ).
        GR_LIST->DISPLAY( EXPORTING IR_HANDLER   = NEW LCL_LIST_HANDLER( )
                                    IR_CONTAINER = GR_BOTTOM_CONTAINER
                                    IS_VARIANT   = VALUE #( REPORT = SY-REPID
                                                            HANDLE = GC_HANDLE-LIST )
                            CHANGING CT_DATA      = GT_LIST ).
      ENDIF.

    CATCH CX_ROOT INTO DATA(LR_ROOT).
      MESSAGE LR_ROOT->GET_TEXT( ) TYPE 'I' DISPLAY LIKE 'E'.
  ENDTRY.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CREATE_ALV_0200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE CREATE_ALV_0200 OUTPUT.

  IF GO_GRID_0200 IS NOT BOUND.
    PERFORM SET_OBJECT_GRID_0200.
    PERFORM EVENT_HANDLER_REGISTER USING GO_GRID_0200.
    PERFORM SET_LAYOUT_GRID_0200.
    PERFORM SET_FIELDCAT_GRID_0200.
    PERFORM SET_CELL_ATTRIBUTE_GRID_0200.
    PERFORM SET_F4_FIELD_GRID_0200.
    PERFORM EXCLUDE_OF_TOOLBAR_GRID_0200.
    PERFORM CALL_GRID_0200_DISPLAY.
  ENDIF.

  IF GO_GRID_0201 IS NOT BOUND.
    PERFORM SET_OBJECT_GRID_0201.
    PERFORM SET_LAYOUT_GRID_0201.
    PERFORM EVENT_HANDLER_REGISTER USING GO_GRID_0201.
    PERFORM SET_FIELDCAT_GRID_0201.
    PERFORM SET_CELL_ATTRIBUTE_GRID_0201.
    PERFORM CALL_GRID_0201_DISPLAY.
  ENDIF.
ENDMODULE.
