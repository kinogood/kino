*&---------------------------------------------------------------------*
*& Include          ZGTPPR4010H01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form CONSTRUCTOR
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> I_REPID
*&---------------------------------------------------------------------*
FORM CONSTRUCTOR  USING    P_REPID TYPE SYREPID.

  GV_REPID = SY-REPID.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HDL_DATA_CHANGED
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> ER_DATA_CHANGED
*&      --> E_ONF4
*&      --> E_ONF4_BEFORE
*&      --> E_ONF4_AFTER
*&      --> E_UCOMM
*&---------------------------------------------------------------------*
FORM HDL_DATA_CHANGED  USING ER_DATA_CHANGED TYPE REF TO
                             CL_ALV_CHANGED_DATA_PROTOCOL
                             E_ONF4          TYPE  CHAR01
                             E_ONF4_BEFORE   TYPE  CHAR01
                             E_ONF4_AFTER    TYPE  CHAR01
                             E_UCOMM         TYPE  SY-UCOMM.

  DATA: LS_LVC_S_MODI TYPE LVC_S_MODI.

  FIELD-SYMBOLS: <FS_S> LIKE GS_DATA.

  SORT ER_DATA_CHANGED->MT_MOD_CELLS BY ROW_ID.

  LOOP AT ER_DATA_CHANGED->MT_MOD_CELLS INTO LS_LVC_S_MODI.

    READ TABLE GT_DATA ASSIGNING <FS_S> INDEX LS_LVC_S_MODI-ROW_ID.

    CASE LS_LVC_S_MODI-FIELDNAME.
      WHEN 'TPOSNR'.
        PERFORM SET_TKALAB_RTN USING    LS_LVC_S_MODI
                               CHANGING ER_DATA_CHANGED.
    ENDCASE.

  ENDLOOP.

ENDFORM.
*&---------------------------------------------------------------------*
*& Form HDL_DOUBLE_CLICK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> E_ROW
*&      --> E_COLUMN
*&---------------------------------------------------------------------*
FORM HDL_DOUBLE_CLICK  USING P_ROW      STRUCTURE LVC_S_ROW
                             P_COLUMN   STRUCTURE LVC_S_COL.

  IF P_R1 EQ GC_X.
    READ TABLE GT_DATA INTO DATA(LS_DATA) INDEX P_ROW-INDEX.

    CASE P_COLUMN-FIELDNAME.
      WHEN 'MBLNR'.
        CHECK LS_DATA-MBLNR IS NOT INITIAL.

        CALL FUNCTION 'MIGO_DIALOG'
          EXPORTING
            I_ACTION            = 'A04'
            I_REFDOC            = 'R02'
            I_MBLNR             = LS_DATA-MBLNR
            I_MJAHR             = LS_DATA-MJAHR
          EXCEPTIONS
            ILLEGAL_COMBINATION = 1
            OTHERS              = 2.
    ENDCASE.

  ELSEIF P_R2 EQ GC_X.
    READ TABLE GT_REVDATA INTO DATA(LS_REVDATA) INDEX P_ROW-INDEX.

    CASE P_COLUMN-FIELDNAME.
      WHEN 'MBLNR'.
        CHECK LS_REVDATA-MBLNR IS NOT INITIAL.

        CALL FUNCTION 'MIGO_DIALOG'
          EXPORTING
            I_ACTION            = 'A04'
            I_REFDOC            = 'R02'
            I_MBLNR             = LS_REVDATA-MBLNR
            I_MJAHR             = LS_REVDATA-MJAHR
          EXCEPTIONS
            ILLEGAL_COMBINATION = 1
            OTHERS              = 2.

      WHEN 'SMBLN'.
        CHECK LS_REVDATA-SMBLN IS NOT INITIAL.

        CALL FUNCTION 'MIGO_DIALOG'
          EXPORTING
            I_ACTION            = 'A04'
            I_REFDOC            = 'R02'
            I_MBLNR             = LS_REVDATA-SMBLN
            I_MJAHR             = LS_REVDATA-MJAHR
          EXCEPTIONS
            ILLEGAL_COMBINATION = 1
            OTHERS              = 2.

    ENDCASE.

  ENDIF.

  CLEAR: LS_DATA, LS_REVDATA.

ENDFORM.
