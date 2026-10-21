*&---------------------------------------------------------------------*
*& Include          ZGTPPR4080H01
*&---------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*& Form HDL_BUTTON_CLICK
*&---------------------------------------------------------------------*
*& text
*&---------------------------------------------------------------------*
*&      --> SENDER
*&      --> ES_COL_ID
*&      --> ES_ROW_NO
*&---------------------------------------------------------------------*
FORM HDL_BUTTON_CLICK  USING    P_SENDER TYPE REF TO CL_GUI_ALV_GRID
                                PS_COL_ID TYPE LVC_S_COL
                                PS_ROW_NO TYPE LVC_S_ROID.
  DATA: LV_CKP(1).

  CASE P_SENDER.
    WHEN GO_GRID_0100.
      READ TABLE GT_DATA ASSIGNING FIELD-SYMBOL(<FS>) INDEX PS_ROW_NO-ROW_ID.

      IF <FS>-TCODE IS INITIAL.
        MESSAGE W000 WITH '해당되는 T-CODE가 없습니다.'.
      ELSE.
        IF <FS>-TCODE+0(1) EQ 'Z'.
          EXPORT CKP = 'X' TO MEMORY ID 'CKP'.
          CALL TRANSACTION <FS>-TCODE.

          IMPORT CKP TO LV_CKP FROM MEMORY ID 'CKP'.
          IF LV_CKP EQ 'S'.
            PERFORM SAVE_ZGTPPT4080 USING <FS>.

            FREE MEMORY ID 'CKP'.
            CLEAR: LV_CKP.
          ENDIF.

        ELSE.
          CALL TRANSACTION <FS>-TCODE.
          PERFORM SAVE_ZGTPPT4080 USING <FS>.

        ENDIF.
      ENDIF.

      " REFRESH DISPLAY
      PERFORM REF_ALV_RTN USING GO_GRID_0100.
  ENDCASE.
ENDFORM.
