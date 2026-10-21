*&---------------------------------------------------------------------*
*& Include          ZGTPPR9011H01
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

  FIELD-SYMBOLS: <FS_S> LIKE GS_TRANS.

  SORT ER_DATA_CHANGED->MT_MOD_CELLS BY ROW_ID.

  CASE P_SENDER.
    WHEN GO_GRID_0100.
      LOOP AT ER_DATA_CHANGED->MT_MOD_CELLS INTO LS_LVC_S_MODI.

        READ TABLE GT_TRANS ASSIGNING <FS_S> INDEX LS_LVC_S_MODI-ROW_ID.

        CASE LS_LVC_S_MODI-FIELDNAME.
          WHEN 'N_MATNR'.
            PERFORM SET_N_MAKTX_RTN USING    LS_LVC_S_MODI
                                    CHANGING ER_DATA_CHANGED.
        ENDCASE.

      ENDLOOP.
  ENDCASE.

ENDFORM.
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
      READ TABLE GT_TRANS_C INTO DATA(LS_TRANS_C) INDEX P_ROW-INDEX.

      CASE P_COLUMN-FIELDNAME.
        WHEN 'AUFNR'.
          CHECK LS_TRANS_C-AUFNR IS NOT INITIAL.

          SET PARAMETER ID 'ANR' FIELD LS_TRANS_C-AUFNR.
          CALL TRANSACTION 'CO03' AND SKIP FIRST SCREEN.

        WHEN 'MBLNR_GI'.
          CHECK LS_TRANS_C-MBLNR_GI IS NOT INITIAL.

          CALL FUNCTION 'MIGO_DIALOG'
            EXPORTING
              I_ACTION            = 'A04'
              I_REFDOC            = 'R02'
              I_MBLNR             = LS_TRANS_C-MBLNR_GI
              I_MJAHR             = LS_TRANS_C-MJAHR_GI
            EXCEPTIONS
              ILLEGAL_COMBINATION = 1
              OTHERS              = 2.

        WHEN 'MBLNR_GR'.
          CHECK LS_TRANS_C-MBLNR_GR IS NOT INITIAL.

          CALL FUNCTION 'MIGO_DIALOG'
            EXPORTING
              I_ACTION            = 'A04'
              I_REFDOC            = 'R02'
              I_MBLNR             = LS_TRANS_C-MBLNR_GR
              I_MJAHR             = LS_TRANS_C-MJAHR_GR
            EXCEPTIONS
              ILLEGAL_COMBINATION = 1
              OTHERS              = 2.

      ENDCASE.

  ENDCASE.

ENDFORM.
