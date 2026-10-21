*&---------------------------------------------------------------------*
*& Include          ZGTPPR3070H01
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

  CASE P_SENDER.
    WHEN GO_GRID_0100.
      IF P_R1 EQ GC_X.
        READ TABLE GT_CTOP INTO DATA(LS_CTOP) INDEX P_ROW-INDEX.

        CASE P_COLUMN-FIELDNAME.
          WHEN 'AUFNR'.
            CHECK LS_CTOP-AUFNR IS NOT INITIAL.

            SET PARAMETER ID 'ANR' FIELD LS_CTOP-AUFNR.
            CALL TRANSACTION 'CO03' AND SKIP FIRST SCREEN.
        ENDCASE.
      ELSEIF P_R2 EQ GC_X.
        READ TABLE GT_STOP INTO DATA(LS_STOP) INDEX P_ROW-INDEX.

        CASE P_COLUMN-FIELDNAME.
          WHEN 'AUFNR'.
            CHECK LS_STOP-AUFNR IS NOT INITIAL.

            SET PARAMETER ID 'ANR' FIELD LS_STOP-AUFNR.
            CALL TRANSACTION 'CO03' AND SKIP FIRST SCREEN.
        ENDCASE.
      ENDIF.
  ENDCASE.

ENDFORM.
