*&---------------------------------------------------------------------*
*& Include          ZGTPPR4000H01
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
      IF P_R1 EQ GC_X.
        READ TABLE GT_DATA INTO DATA(LS_DATA) INDEX P_ROW-INDEX.

        CASE P_COLUMN-FIELDNAME.
          WHEN 'ZZFOLLOW'.
            CHECK LS_DATA-ZZFOLLOW IS NOT INITIAL.

            SET PARAMETER ID 'ANR' FIELD LS_DATA-ZZFOLLOW.
            CALL TRANSACTION 'CO03' AND SKIP FIRST SCREEN.

          WHEN 'AUFNR'.
            CHECK LS_DATA-AUFNR IS NOT INITIAL.

            SET PARAMETER ID 'ANR' FIELD LS_DATA-AUFNR.
            CALL TRANSACTION 'CO03' AND SKIP FIRST SCREEN.

        ENDCASE.

      ELSEIF P_R2 EQ GC_X.
        READ TABLE GT_REVDATA INTO DATA(LS_REVDATA) INDEX P_ROW-INDEX.

        CASE P_COLUMN-FIELDNAME.
          WHEN 'ZZFOLLOW'.
            CHECK LS_REVDATA-ZZFOLLOW IS NOT INITIAL.

            SET PARAMETER ID 'ANR' FIELD LS_REVDATA-ZZFOLLOW.
            CALL TRANSACTION 'CO03' AND SKIP FIRST SCREEN.

          WHEN 'ZZORIGIN'.
            CHECK LS_REVDATA-ZZORIGIN IS NOT INITIAL.

            SET PARAMETER ID 'ANR' FIELD LS_REVDATA-ZZORIGIN.
            CALL TRANSACTION 'CO03' AND SKIP FIRST SCREEN.

        ENDCASE.

      ELSEIF P_R3 EQ GC_X.
        READ TABLE GT_AUFNR INTO DATA(LS_AUFNR) INDEX P_ROW-INDEX.

        CASE P_COLUMN-FIELDNAME.
          WHEN 'MATGI'.
*        CHECK LS_AUFNR-MATGI NE ICON_LED_RED.

            CLEAR: LT_SELTAB.
            LT_SELTAB = VALUE #(
            ( SELNAME = 'P_R1'    KIND = 'P' SIGN = 'I' OPTION = 'EQ' LOW = GC_X )
            ( SELNAME = 'S_WERKS' KIND = 'S' SIGN = 'I' OPTION = 'EQ' LOW = LS_AUFNR-WERKS )
            ( SELNAME = 'S_AUFNR' KIND = 'S' SIGN = 'I' OPTION = 'EQ' LOW = LS_AUFNR-AUFNR )
            ( SELNAME = 'S_GSTRP' KIND = 'S' SIGN = 'I' OPTION = 'EQ' LOW = LS_AUFNR-GSTRP )
            ( SELNAME = 'P_C5'    KIND = 'P' SIGN = 'I' OPTION = 'EQ' LOW = SPACE ) ).

            SUBMIT ZGTPPR1040 WITH SELECTION-TABLE LT_SELTAB
                              AND  RETURN.

          WHEN 'ORDCF'.
            CHECK LS_AUFNR-ORDCF NE ICON_LED_RED.

            CLEAR: LT_SELTAB.
            LT_SELTAB = VALUE #(
            ( SELNAME = 'P_DIS1'  KIND = 'P' SIGN = 'I' OPTION = 'EQ' LOW = GC_X )
            ( SELNAME = 'P_WERKS' KIND = 'P' SIGN = 'I' OPTION = 'EQ' LOW = LS_AUFNR-WERKS )
            ( SELNAME = 'S_AUFNR' KIND = 'S' SIGN = 'I' OPTION = 'EQ' LOW = LS_AUFNR-AUFNR )
            ( SELNAME = 'P_ALL1'  KIND = 'P' SIGN = 'I' OPTION = 'EQ' LOW = GC_X )
            ( SELNAME = 'P_ALL2'  KIND = 'P' SIGN = 'I' OPTION = 'EQ' LOW = GC_X ) ).

            SUBMIT ZGTPPR4030 WITH SELECTION-TABLE LT_SELTAB
                              AND  RETURN.

          WHEN 'ORDGR'.
            CHECK LS_AUFNR-ORDGR NE ICON_LED_RED.

            CLEAR: LT_SELTAB.
            LT_SELTAB = VALUE #(
            ( SELNAME = 'P_DIS1'  KIND = 'P' SIGN = 'I' OPTION = 'EQ' LOW = GC_X )
            ( SELNAME = 'P_WERKS' KIND = 'P' SIGN = 'I' OPTION = 'EQ' LOW = LS_AUFNR-WERKS )
            ( SELNAME = 'S_AUFNR' KIND = 'S' SIGN = 'I' OPTION = 'EQ' LOW = LS_AUFNR-AUFNR )
            ( SELNAME = 'P_ALL1'  KIND = 'P' SIGN = 'I' OPTION = 'EQ' LOW = GC_X )
            ( SELNAME = 'P_ALL2'  KIND = 'P' SIGN = 'I' OPTION = 'EQ' LOW = GC_X ) ).

            SUBMIT ZGTPPR4030 WITH SELECTION-TABLE LT_SELTAB
                              AND  RETURN.

          WHEN 'AUFNR'.
            CHECK LS_AUFNR-AUFNR IS NOT INITIAL.

            SET PARAMETER ID 'ANR' FIELD LS_AUFNR-AUFNR.
            CALL TRANSACTION 'CO03' AND SKIP FIRST SCREEN.

          WHEN 'ZZORIGIN'.
            CHECK LS_AUFNR-ZZORIGIN IS NOT INITIAL.

            SET PARAMETER ID 'ANR' FIELD LS_AUFNR-ZZORIGIN.
            CALL TRANSACTION 'CO03' AND SKIP FIRST SCREEN.

          WHEN 'ZZFOLLOWING'.
            CHECK LS_AUFNR-ZZFOLLOWING IS NOT INITIAL.

            SET PARAMETER ID 'ANR' FIELD LS_AUFNR-ZZFOLLOWING.
            CALL TRANSACTION 'CO03' AND SKIP FIRST SCREEN.

        ENDCASE.

      ENDIF.
  ENDCASE.

ENDFORM.
