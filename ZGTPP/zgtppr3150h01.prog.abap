*&---------------------------------------------------------------------*
*& Include          ZGTPPR3150H01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form HDL_DATA_CHANGED
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      --> ER_DATA_CHANGED
*&      --> E_ONF4
*&      --> E_ONF4_BEFORE
*&      --> E_ONF4_AFTER
*&      --> E_UCOMM
*&---------------------------------------------------------------------*
FORM HDL_DATA_CHANGED  USING    P_SENDER TYPE REF TO CL_GUI_ALV_GRID
                                ER_DATA_CHANGED TYPE REF TO
                                CL_ALV_CHANGED_DATA_PROTOCOL
                                E_ONF4          TYPE  CHAR01
                                E_ONF4_BEFORE   TYPE  CHAR01
                                E_ONF4_AFTER    TYPE  CHAR01
                                E_UCOMM         TYPE  SY-UCOMM.

  DATA: LS_LVC_S_MODI TYPE LVC_S_MODI.

  SORT ER_DATA_CHANGED->MT_MOD_CELLS BY ROW_ID.

  CASE P_SENDER.
    WHEN GO_GRID_0100.
      LOOP AT ER_DATA_CHANGED->MT_MOD_CELLS INTO LS_LVC_S_MODI.

      ENDLOOP.

    WHEN GO_GRID_0200.
      LOOP AT ER_DATA_CHANGED->MT_MOD_CELLS INTO LS_LVC_S_MODI.

        CASE LS_LVC_S_MODI-FIELDNAME.
          WHEN 'WERKS'.
            PERFORM SET_NAME1_RTN USING    LS_LVC_S_MODI
                                  CHANGING ER_DATA_CHANGED.

          WHEN 'F_MATN' OR 'T_MATN'.
            PERFORM SET_MAKTX_RTN USING    LS_LVC_S_MODI
                                  CHANGING ER_DATA_CHANGED.

          WHEN 'F_LGORT' OR 'T_LGORT'.
            PERFORM SET_LGOBE_RTN USING    LS_LVC_S_MODI
                                  CHANGING ER_DATA_CHANGED.
        ENDCASE.

      ENDLOOP.

  ENDCASE.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HDL_HOTSPOT_CLICK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      --> E_ROW_ID
*&      --> E_COLUMN_ID
*&      --> ES_ROW_NO
*&---------------------------------------------------------------------*
FORM HDL_HOTSPOT_CLICK  USING   P_SENDER    TYPE REF TO CL_GUI_ALV_GRID
                                P_ROW_ID    TYPE LVC_S_ROW
                                P_COLUMN_ID TYPE LVC_S_COL
                                PS_ROW_NO   TYPE LVC_S_ROID.

  CASE P_SENDER.
    WHEN GO_GRID_0100.
      READ TABLE GT_PROC INTO DATA(LS_PROC) INDEX PS_ROW_NO-ROW_ID.

      CASE P_COLUMN_ID.
        WHEN 'AUFNR'.
          CHECK LS_PROC-AUFNR IS NOT INITIAL.

          SET PARAMETER ID 'ANR' FIELD LS_PROC-AUFNR.
          CALL TRANSACTION 'CO03' AND SKIP FIRST SCREEN.

        WHEN 'F_MBLNR'.
          CHECK LS_PROC-F_MBLNR IS NOT INITIAL.

          CALL FUNCTION 'MIGO_DIALOG'
            EXPORTING
              I_ACTION            = 'A04'
              I_REFDOC            = 'R02'
              I_MBLNR             = LS_PROC-F_MBLNR
              I_MJAHR             = LS_PROC-F_MJAHR
            EXCEPTIONS
              ILLEGAL_COMBINATION = 1
              OTHERS              = 2.

        WHEN 'T_MBLNR'.
          CHECK LS_PROC-T_MBLNR IS NOT INITIAL.

          CALL FUNCTION 'MIGO_DIALOG'
            EXPORTING
              I_ACTION            = 'A04'
              I_REFDOC            = 'R02'
              I_MBLNR             = LS_PROC-T_MBLNR
              I_MJAHR             = LS_PROC-T_MJAHR
            EXCEPTIONS
              ILLEGAL_COMBINATION = 1
              OTHERS              = 2.

        WHEN 'RUECK'.
          CHECK LS_PROC-RUECK IS NOT INITIAL.
          SET PARAMETER ID 'RCK' FIELD LS_PROC-RUECK.
          SET PARAMETER ID 'RZL' FIELD LS_PROC-RMZHL.
          CALL TRANSACTION 'CO14' AND SKIP FIRST SCREEN.

      ENDCASE.

      CLEAR: LS_PROC.

    WHEN GO_GRID_0200.

  ENDCASE .

ENDFORM.
