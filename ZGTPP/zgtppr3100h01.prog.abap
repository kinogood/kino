*&---------------------------------------------------------------------*
*& Include          ZGTPPR3100H01
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
      READ TABLE GT_DATA INTO DATA(LS_DATA) INDEX P_ROW-INDEX.

      CASE P_COLUMN-FIELDNAME.
        WHEN 'AUFNR'.
          CHECK LS_DATA-AUFNR IS NOT INITIAL.

          SET PARAMETER ID 'ANR' FIELD LS_DATA-AUFNR.
          CALL TRANSACTION 'CO03' AND SKIP FIRST SCREEN.
      ENDCASE.
  ENDCASE.

ENDFORM.
