*&---------------------------------------------------------------------*
*& Include          ZGTPPR1100H01
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
          WHEN 'MATKL'.
            PERFORM SET_ZPPT1080_RTN USING    LS_LVC_S_MODI
                                     CHANGING ER_DATA_CHANGED.

          WHEN 'RGEKZ'.
            IF P_R6 EQ GC_X AND ( P_R1 EQ GC_X OR P_R2 EQ GC_X ).
              PERFORM SET_KAUSF_RTN USING    LS_LVC_S_MODI
                                    CHANGING ER_DATA_CHANGED.
            ENDIF.
        ENDCASE.

      ENDLOOP.

  ENDCASE.

  CALL METHOD ER_DATA_CHANGED->REFRESH_PROTOCOL( ).

ENDFORM.
