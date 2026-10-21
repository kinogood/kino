*&---------------------------------------------------------------------*
*& Include          ZGTPPR4070H01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form HDL_DOUBLE_CLICK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      --> E_ROW
*&      --> E_COLUMN
*&---------------------------------------------------------------------*
FORM HDL_DOUBLE_CLICK  USING    P_SENDER TYPE REF TO CL_GUI_ALV_GRID
                                P_ROW TYPE LVC_S_ROW
                                P_COLUMN TYPE LVC_S_COL.

  DATA: LS_SELTAB TYPE RSPARAMS,
        LT_SELTAB TYPE TABLE OF RSPARAMS.

  CASE P_SENDER.
    WHEN GO_GRID_0100.

      READ TABLE GT_DATA INTO DATA(LS_DATA) INDEX P_ROW-INDEX.

      CASE P_COLUMN-FIELDNAME.
        WHEN 'AUFNR'.
          IF P_R1 EQ GC_X.
            CHECK LS_DATA-AUFNR IS NOT INITIAL.
          ENDIF.

          SET PARAMETER ID 'ANR' FIELD LS_DATA-AUFNR.
          CALL TRANSACTION 'CO03' AND SKIP FIRST SCREEN.

        WHEN 'GR_STAT'.
          IF P_R1 EQ GC_X.
            CHECK LS_DATA-GR_STAT NE ICON_LED_GREEN.
          ENDIF.

          CLEAR: LT_SELTAB.
          LT_SELTAB = VALUE #(
          ( SELNAME = 'P_DIS1'  KIND = 'P' SIGN = 'I' OPTION = 'EQ' LOW = GC_X )
          ( SELNAME = 'P_WERKS' KIND = 'P' SIGN = 'I' OPTION = 'EQ' LOW = LS_DATA-WERKS )
          ( SELNAME = 'S_AUFNR' KIND = 'S' SIGN = 'I' OPTION = 'EQ' LOW = LS_DATA-AUFNR )
          ( SELNAME = 'P_ALL1'  KIND = 'P' SIGN = 'I' OPTION = 'EQ' LOW = GC_X )
          ( SELNAME = 'P_ALL2'  KIND = 'P' SIGN = 'I' OPTION = 'EQ' LOW = GC_X ) ).

          SUBMIT ZGTPPR4030 WITH SELECTION-TABLE LT_SELTAB
                            AND  RETURN.

        WHEN 'TM_STAT'.
          IF P_R1 EQ GC_X.
            CHECK LS_DATA-TM_STAT NE ICON_LED_GREEN.
          ENDIF.

          CLEAR: LT_SELTAB.
          LT_SELTAB = VALUE #(
          ( SELNAME = 'P_DIS1'  KIND = 'P' SIGN = 'I' OPTION = 'EQ' LOW = GC_X )
          ( SELNAME = 'P_WERKS' KIND = 'P' SIGN = 'I' OPTION = 'EQ' LOW = LS_DATA-WERKS )
          ( SELNAME = 'S_AUFNR' KIND = 'S' SIGN = 'I' OPTION = 'EQ' LOW = LS_DATA-AUFNR )
          ( SELNAME = 'P_ALL1'  KIND = 'P' SIGN = 'I' OPTION = 'EQ' LOW = GC_X )
          ( SELNAME = 'P_ALL2'  KIND = 'P' SIGN = 'I' OPTION = 'EQ' LOW = GC_X ) ).

          SUBMIT ZGTPPR4030 WITH SELECTION-TABLE LT_SELTAB
                            AND  RETURN.

        WHEN 'GI_STAT'.
          IF P_R1 EQ GC_X.
            CHECK LS_DATA-GI_STAT NE ICON_LED_GREEN.
          ENDIF.

          CLEAR: LT_SELTAB.
          LT_SELTAB = VALUE #(
          ( SELNAME = 'P_R1'    KIND = 'P' SIGN = 'I' OPTION = 'EQ' LOW = GC_X )
          ( SELNAME = 'S_WERKS' KIND = 'S' SIGN = 'I' OPTION = 'EQ' LOW = LS_DATA-WERKS )
          ( SELNAME = 'S_AUFNR' KIND = 'S' SIGN = 'I' OPTION = 'EQ' LOW = LS_DATA-AUFNR )
          ( SELNAME = 'S_GSTRP' KIND = 'S' SIGN = 'I' OPTION = 'EQ' LOW = LS_DATA-GSTRP )
          ( SELNAME = 'P_C5'    KIND = 'P' SIGN = 'I' OPTION = 'EQ' LOW = SPACE ) ).

          SUBMIT ZGTPPR1040 WITH SELECTION-TABLE LT_SELTAB
                            AND  RETURN.

      ENDCASE.

  ENDCASE.

ENDFORM.
