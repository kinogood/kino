*&---------------------------------------------------------------------*
*& Include          ZGTPPR3180C01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Module STATUS_100 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_100 OUTPUT.

  GT_EXCLUDE = COND #( WHEN P_REQUI EQ ABAP_TRUE THEN VALUE #( ( GC_FCODE-CHANGE )
                                                               ( GC_FCODE-DELETE )
                                                               ( GC_FCODE-REQ_COMP )
                                                               ( GC_FCODE-REQ_BAS_FT ) )
                                                 ELSE VALUE #( ( GC_FCODE-CREATE )
                                                               ( GC_FCODE-SELECT )
                                                               ( GC_FCODE-UNSELECT ) ) ).

  IF P_REQUI NE ABAP_TRUE AND P_SPGCD NE 'GL'.
  ELSE.
    APPEND 'MTO_CREATE' TO GT_EXCLUDE.
  ENDIF.

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
      IF P_REQUI EQ ABAP_TRUE. "// 청구
        IF GR_DOCKING_CONTAINER IS NOT BOUND.
          PERFORM SPLIT_SCREEN_LAYOUT.

          IF GR_MREQ IS NOT BOUND.
            GR_MREQ = NEW #( ).
            GR_MREQ->DISPLAY( EXPORTING IR_HANDLER   = NEW LCL_LIST_HANDLER( )
                                        IR_CONTAINER = GR_TOP_CONTAINER
                                        IS_VARIANT   = VALUE #( REPORT = SY-REPID
                                                                HANDLE = GC_HANDLE-MREQ )
                               CHANGING CT_DATA      = GR_DATA->* ).
          ENDIF.

          IF GR_LIST IS NOT BOUND.
            GR_LIST = NEW #( ).
            GR_LIST->DISPLAY( EXPORTING IR_HANDLER   = NEW LCL_LIST_HANDLER( )
                                        IR_CONTAINER = GR_BOTTOM_CONTAINER
                                        IS_VARIANT   = VALUE #( REPORT = SY-REPID
                                                                HANDLE = GC_HANDLE-LIST )
                               CHANGING CT_DATA      = GT_LIST ).
          ENDIF.
        ENDIF.
      ELSE.
        IF GR_LIST IS NOT BOUND.
          GR_LIST = NEW #( ).
          GR_LIST->DISPLAY( EXPORTING IR_HANDLER   = NEW LCL_LIST_HANDLER( )
                                      IS_VARIANT   = VALUE #( REPORT = SY-REPID
                                                              HANDLE = GC_HANDLE-LIST )
                             CHANGING CT_DATA      = GT_LIST ).
        ENDIF.
      ENDIF.

    CATCH CX_ROOT INTO DATA(LR_ROOT).
      MESSAGE LR_ROOT->GET_TEXT( ) TYPE 'I' DISPLAY LIKE 'E'.
  ENDTRY.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0200 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0200 OUTPUT.

  SET PF-STATUS '0200'.
  SET TITLEBAR  '0200'.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0300 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0300 OUTPUT.

  SET PF-STATUS '0300'.
  SET TITLEBAR  '0300'.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0400 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0400 OUTPUT.

  SET PF-STATUS '0400'.
  SET TITLEBAR  '0400'.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CREATE_ALV_400 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE CREATE_ALV_400 OUTPUT.

  TRY.
      IF GR_COMP IS NOT BOUND.
        GR_COMP = NEW #( ).
        GR_COMP->DISPLAY( EXPORTING IR_HANDLER   = NEW LCL_LIST_HANDLER( )
                                    IR_CONTAINER = NEW CL_GUI_CUSTOM_CONTAINER( CONTAINER_NAME = 'CONT01' )
                                    IS_VARIANT   = VALUE #( REPORT = SY-REPID
                                                            HANDLE = GC_HANDLE-COMP )
                           CHANGING CT_DATA      = GT_COMP ).
      ENDIF.

    CATCH CX_ROOT INTO LR_ROOT.
      MESSAGE LR_ROOT->GET_TEXT( ) TYPE 'I' DISPLAY LIKE 'E'.
  ENDTRY.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_500 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_500 OUTPUT.

  SET PF-STATUS '0500'.
  SET TITLEBAR  '0500'.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CREATE_ALV_500 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE CREATE_ALV_500 OUTPUT.

  TRY.
      IF GR_SMRY IS NOT BOUND.
        GR_SMRY = NEW #( ).
        GR_SMRY->DISPLAY( EXPORTING IR_HANDLER   = NEW LCL_LIST_HANDLER( )
                                    IR_CONTAINER = NEW CL_GUI_CUSTOM_CONTAINER( CONTAINER_NAME = 'CONT01' )
                                    IS_VARIANT   = VALUE #( REPORT = SY-REPID
                                                            HANDLE = COND #( WHEN P_GNMAT IS NOT INITIAL THEN GC_HANDLE-SMAT
                                                                                                         ELSE GC_HANDLE-SPAC ) )
                           CHANGING CT_DATA      = GT_SMRY ).
      ENDIF.

    CATCH CX_ROOT INTO LR_ROOT.
      MESSAGE LR_ROOT->GET_TEXT( ) TYPE 'I' DISPLAY LIKE 'E'.
  ENDTRY.

ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0700 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0700 OUTPUT.
  SET PF-STATUS '0700'.
  SET TITLEBAR '0700'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0800 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0800 OUTPUT.
  SET PF-STATUS '0800'.
  SET TITLEBAR '0800'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module STATUS_0900 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE STATUS_0900 OUTPUT.
  SET PF-STATUS '0900'.
  SET TITLEBAR '0900'.
ENDMODULE.
*&---------------------------------------------------------------------*
*& Module CREATE_ALV_0900 OUTPUT
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
MODULE CREATE_ALV_0900 OUTPUT.
  IF GO_GRID_0900 IS NOT BOUND.
    PERFORM SET_OBJECT_GRID_0900.
    PERFORM SET_LAYOUT_GRID_0900.
    PERFORM SET_FIELDCAT_GRID_0900.
    PERFORM SET_SORTTAB_GRID_0900.
    PERFORM EXCLUDE_OF_TOOLBAR_GRID_0900.
    PERFORM CALL_GRID_0900_DISPLAY.
  ENDIF.
ENDMODULE.
