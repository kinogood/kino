*&---------------------------------------------------------------------*
*& Include          ZGTPPR4050H01
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

      PERFORM SET_BOTTOM_DATA USING LS_DATA.
      PERFORM SET_BOTTOM_ALV.
      PERFORM SET_SELECTED_ROWS USING P_SENDER P_ROW-INDEX.

    WHEN GO_GRID_0101.
      READ TABLE GT_PO INTO DATA(LS_PO) INDEX P_ROW-INDEX.

      CASE P_COLUMN-FIELDNAME.
        WHEN 'MBLNR'.
          CHECK LS_PO-MBLNR IS NOT INITIAL.

          CALL FUNCTION 'MIGO_DIALOG'
            EXPORTING
              I_ACTION            = 'A04'
              I_REFDOC            = 'R02'
              I_MBLNR             = LS_PO-MBLNR
              I_MJAHR             = LS_PO-MJAHR
              I_ZEILE             = LS_PO-ZEILE
            EXCEPTIONS
              ILLEGAL_COMBINATION = 1
              OTHERS              = 2.
      ENDCASE.

    WHEN GO_GRID_0102.
      READ TABLE GT_PROD INTO DATA(LS_PROD) INDEX P_ROW-INDEX.

      CASE P_COLUMN-FIELDNAME.
        WHEN 'MBLNR'.
          CHECK LS_PROD-MBLNR IS NOT INITIAL.

          CALL FUNCTION 'MIGO_DIALOG'
            EXPORTING
              I_ACTION            = 'A04'
              I_REFDOC            = 'R02'
              I_MBLNR             = LS_PROD-MBLNR
              I_MJAHR             = LS_PROD-MJAHR
              I_ZEILE             = LS_PROD-ZEILE
            EXCEPTIONS
              ILLEGAL_COMBINATION = 1
              OTHERS              = 2.

        WHEN 'AUFNR'.
          CHECK LS_PROD-AUFNR IS NOT INITIAL.

          SET PARAMETER ID 'ANR' FIELD LS_PROD-AUFNR.
          CALL TRANSACTION 'CO03' AND SKIP FIRST SCREEN.

      ENDCASE.

  ENDCASE.

ENDFORM.
