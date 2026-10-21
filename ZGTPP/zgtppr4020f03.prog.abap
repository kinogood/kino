*----------------------------------------------------------------------*
***INCLUDE ZGTPPR4020F03 .
*----------------------------------------------------------------------*
*&---------------------------------------------------------------------*
*&      Form  HOTSPOT_CLICK_100
*&---------------------------------------------------------------------*
*       text
*----------------------------------------------------------------------*
*      -->P_E_ROW_ID  text
*      -->P_E_COLUMN_ID  text
*----------------------------------------------------------------------*
FORM HOTSPOT_CLICK_100  USING    P_ROW_ID    TYPE LVC_S_ROW
                                 P_COLUMN_ID TYPE LVC_S_COL.

  DATA: LS_LIST TYPE ZGTBDS310.

  READ TABLE IT_LIST INTO LS_LIST INDEX P_ROW_ID-INDEX.

  CASE P_COLUMN_ID-FIELDNAME.
    WHEN 'MBLNR'.
      CHECK NOT LS_LIST-MBLNR IS INITIAL.
*->CCM : ZITCS4HDEV01 2023.04.10 - MB03주석 & MIGO추가
*      SET PARAMETER ID 'MBN' FIELD LS_LIST-MBLNR.
*      SET PARAMETER ID 'MJA' FIELD LS_LIST-MJAHR.
*      CALL TRANSACTION 'MB03' AND SKIP FIRST SCREEN.
      CALL FUNCTION 'MIGO_DIALOG'
        EXPORTING
          I_MBLNR             = LS_LIST-MBLNR
          I_MJAHR             = LS_LIST-MJAHR
        EXCEPTIONS
          ILLEGAL_COMBINATION = 1
          OTHERS              = 2.
*<-
    WHEN 'MBLNR2'.
      CHECK NOT LS_LIST-MBLNR2 IS INITIAL.
*->CCM : ZITCS4HDEV01 2023.04.10 - MB03주석 & MIGO추가
*      SET PARAMETER ID 'MBN' FIELD LS_LIST-MBLNR2.
*      SET PARAMETER ID 'MJA' FIELD LS_LIST-MJAHR.
*      CALL TRANSACTION 'MB03' AND SKIP FIRST SCREEN.
      CALL FUNCTION 'MIGO_DIALOG'
        EXPORTING
          I_MBLNR             = LS_LIST-MBLNR2
          I_MJAHR             = LS_LIST-MJAHR
        EXCEPTIONS
          ILLEGAL_COMBINATION = 1
          OTHERS              = 2.
*<-
    WHEN 'MBLNRC1'.
      CHECK NOT LS_LIST-MBLNRC1 IS INITIAL.
*->CCM : ZITCS4HDEV01 2023.04.10 - MB03주석 & MIGO추가
*      SET PARAMETER ID 'MBN' FIELD LS_LIST-MBLNRC1.
*      SET PARAMETER ID 'MJA' FIELD LS_LIST-MJAHR.
*      CALL TRANSACTION 'MB03' AND SKIP FIRST SCREEN.
      CALL FUNCTION 'MIGO_DIALOG'
        EXPORTING
          I_MBLNR             = LS_LIST-MBLNRC1
          I_MJAHR             = LS_LIST-MJAHR
        EXCEPTIONS
          ILLEGAL_COMBINATION = 1
          OTHERS              = 2.
*<-
    WHEN 'MBLNRC2'.
      CHECK NOT LS_LIST-MBLNRC2 IS INITIAL.
*->CCM : ZITCS4HDEV01 2023.04.10 - MB03주석 & MIGO추가
*      SET PARAMETER ID 'MBN' FIELD LS_LIST-MBLNRC2.
*      SET PARAMETER ID 'MJA' FIELD LS_LIST-MJAHR.
*      CALL TRANSACTION 'MB03' AND SKIP FIRST SCREEN.
      CALL FUNCTION 'MIGO_DIALOG'
        EXPORTING
          I_MBLNR             = LS_LIST-MBLNRC2
          I_MJAHR             = LS_LIST-MJAHR
        EXCEPTIONS
          ILLEGAL_COMBINATION = 1
          OTHERS              = 2.
*<-
  ENDCASE.


ENDFORM.                    " HOTSPOT_CLICK_100
