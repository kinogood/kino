*&---------------------------------------------------------------------*
*& Include          ZGTPPR1090H01
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

        CASE LS_LVC_S_MODI-FIELDNAME.
          WHEN 'WERKS'.
            PERFORM SET_NAME1_RTN USING    LS_LVC_S_MODI
                                  CHANGING ER_DATA_CHANGED.

          WHEN 'SPART'.
            PERFORM SET_VTEXT_RTN USING    LS_LVC_S_MODI
                                  CHANGING ER_DATA_CHANGED.

          WHEN 'MTART'.
            PERFORM SET_MTBEZ_RTN USING    LS_LVC_S_MODI
                                  CHANGING ER_DATA_CHANGED.

          WHEN 'MATKL'.
            PERFORM SET_WGBEZ_RTN USING    LS_LVC_S_MODI
                                  CHANGING ER_DATA_CHANGED.

        ENDCASE.
      ENDLOOP.

  ENDCASE.

ENDFORM.
